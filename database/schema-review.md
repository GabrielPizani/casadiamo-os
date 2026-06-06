# Casa Di Amo OS Schema Review

## Review Scope

This review evaluates `database/schema.sql` as a production Supabase PostgreSQL schema for Casa Di Amo OS.

Focus areas:

- Normalization.
- Scalability.
- Performance.
- Foreign keys.
- Indexing strategy.
- Tenant isolation.

## Executive Assessment

The schema is a strong first production draft. It covers the approved architecture and ERD, uses UUID primary keys, includes timestamps, defines foreign keys, adds many indexes, and keeps Row Level Security out as requested.

However, I would not deploy it to production unchanged. The main risks are tenant integrity, indexing completeness, high-volume table growth, and excessive unstructured `jsonb` usage in places that will likely need queryable columns.

## What Is Strong

### 1. Broad Entity Coverage

The schema covers the full SaaS operating model:

- Platform administration.
- SaaS billing and entitlements.
- Authentication and tenant membership.
- Companies, users, staff, customers, services, appointments, CRM, marketing, automations, payments, reports, integrations, files, compliance, reliability, and AI governance.

This is the right scope for a serious multi-tenant SaaS foundation.

### 2. Consistent Primary Keys and Timestamps

All application tables use:

- `id uuid primary key default gen_random_uuid()`.
- `created_at timestamptz not null default now()`.
- `updated_at timestamptz not null default now()`.

The shared `set_updated_at()` trigger pattern is appropriate for Supabase/PostgreSQL.

### 3. Tenant-Scoped Modeling

Most operational tables include `company_id`, which is essential for:

- Tenant filtering.
- Future RLS policies.
- Tenant-level analytics.
- Data export and deletion.
- Operational debugging.

### 4. Solid Initial Foreign Key Coverage

The schema defines a large number of foreign keys across the main operational graph, including customers, appointments, services, CRM, marketing, payments, automation, integrations, reports, privacy, and AI.

### 5. Good First-Pass Index Coverage

The schema includes indexes for common access paths such as:

- Tenant-scoped lookups.
- Customer lookup by company and contact fields.
- Appointment queries by company and start time.
- Appointment queries by staff and start time.
- CRM stage and customer access.
- Marketing campaign and delivery access.
- Payment and invoice access.
- Report rollups.
- Audit log lookup.
- Queue and outbox processing.

## Improvements Required Before Deployment

### 1. Enforce Tenant Consistency Across Foreign Keys

Severity: Critical.

Many child tables include `company_id` and also reference parent entities by `id`, but the foreign key does not prove that the parent belongs to the same company.

Example risk:

- An `appointment_service` has its own `company_id`.
- It references an `appointment_id`.
- It references a `service_id`.
- The database does not currently guarantee that all three records belong to the same company.

This pattern appears across appointments, CRM, marketing, payments, automations, files, reports, privacy, and AI.

Recommended improvement:

- Add composite uniqueness on parent tables such as `(id, company_id)`.
- Use composite foreign keys from child tables such as `(appointment_id, company_id)` to `appointments(id, company_id)`.
- Apply this consistently to tenant-owned relationships.

This is the most important improvement before production because RLS will restrict reads, but database constraints should also prevent invalid cross-tenant writes.

### 2. Add `company_id` to Tenant-Derived Child Tables

Severity: High.

Some tables derive tenant context only through a parent:

- `subscription_items`.
- `tenant_invoices`.
- `role_permissions`.
- `api_keys`.
- `job_attempts`.

This is not wrong, but it weakens operational scalability and makes RLS, exports, retention, support tooling, and tenant debugging harder.

Recommended improvement:

- Add `company_id` to tenant-derived high-usage tables.
- Keep platform-global join tables without `company_id` only when they are truly platform-scoped.
- For `tenant_invoices`, add `company_id` directly even though it can be derived from `billing_accounts`.
- For `api_keys`, add `company_id` when the owning API client is tenant-scoped.
- For `job_attempts`, add `company_id` when the owning job is tenant-scoped.

### 3. Improve Foreign Key Index Coverage

Severity: High.

The schema has 244 foreign key references and 127 indexes. Static review found many FK columns without a leading index. Not every FK needs a standalone index, but high-cardinality or frequently joined FKs should be indexed before deployment.

Priority candidates:

- `appointments.recurring_appointment_rule_id`.
- `appointment_services.service_id`.
- `appointment_reminders.appointment_id`.
- `resource_bookings.appointment_id`.
- `calendar_event_mappings.calendar_connection_id`.
- `crm_deals.crm_pipeline_id`.
- `crm_deals.crm_stage_id`.
- `crm_activities.crm_deal_id`.
- `marketing_messages.message_template_id`.
- `marketing_deliveries.marketing_message_id`.
- `conversation_participants.customer_id`.
- `messages.sender_participant_id`.
- `message_attachments.message_id`.
- `webhook_events.integration_connection_id`.
- `automation_runs.automation_event_id`.
- `automation_run_steps.automation_step_id`.
- `invoices.appointment_id`.
- `invoices.subscription_id`.
- `invoice_items.service_id`.
- `payments.customer_id`.
- `refunds.requested_by_company_member_id`.
- `data_exports.file_id`.
- `ai_runs.automation_run_id`.

Recommended improvement:

- Add indexes for FKs used in joins, delete checks, synchronization, background jobs, dashboards, or operational support queries.
- Prefer composite tenant-aware indexes where query patterns include `company_id`.

### 4. Add Partial Indexes for Active Operational Records

Severity: High.

Many tables include status fields but only have broad indexes. Production SaaS workloads usually query active records far more often than historical records.

Recommended partial indexes:

- Active company members by company.
- Active customers by company.
- Active staff by company.
- Active services by company.
- Scheduled appointments by company and start time.
- Open CRM deals by company and stage.
- Pending automation events.
- Queued automation runs.
- Pending appointment reminders.
- Active integration connections.
- Queued sync jobs.
- Pending outbox events.
- Active subscriptions.
- Unpaid invoices.

This will reduce index size and improve hot-path query performance.

### 5. Add Time-Based Partitioning Plan for High-Volume Tables

Severity: High.

Several tables will grow quickly:

- `audit_logs`.
- `webhook_events`.
- `automation_events`.
- `automation_runs`.
- `automation_run_steps`.
- `marketing_deliveries`.
- `messages`.
- `message_status_events`.
- `usage_records`.
- `metric_daily_rollups`.
- `outbox_events`.
- `job_queue`.
- `job_attempts`.
- `ai_usage_records`.

Recommended improvement:

- Partition high-volume event tables by time, usually monthly.
- Keep tenant-aware indexes on each partition.
- Define archival and retention strategy before production.
- Avoid partitioning every table immediately; start with event, audit, messaging, usage, and webhook tables.

### 6. Normalize Important `jsonb` Fields That Will Be Queried

Severity: Medium.

`jsonb` is useful for provider metadata and flexible settings, but several fields are likely to become query targets:

- `segment_rules`.
- `filters`.
- `metrics`.
- `payload`.
- `provider_response`.
- `provider_payload`.
- `configuration`.
- `branching_rules`.
- `retry_behavior`.
- `metadata`.

Recommended improvement:

- Keep `jsonb` for raw provider metadata and rarely queried extensions.
- Promote frequently filtered values to typed columns.
- Add GIN indexes only where real query patterns require them.
- Version structured configuration fields where behavior depends on shape.

### 7. Add Stronger Domain Constraints

Severity: Medium.

Many status, type, direction, channel, and provider fields are plain `text`.

Examples:

- `status`.
- `channel`.
- `provider`.
- `direction`.
- `sync_status`.
- `billing_interval`.
- `appointment status`.
- `payment status`.

Recommended improvement:

- Add check constraints for stable domains.
- Use lookup tables when values are tenant-configurable.
- Use PostgreSQL enums only for values that are truly global and rarely change.

This prevents invalid states such as misspelled statuses or unsupported channels.

### 8. Define Uniqueness Rules for Natural Business Keys

Severity: Medium.

Some unique constraints already exist, but more are needed before production.

Recommended additions:

- `company_locations(company_id, name)` when names must be unique.
- `services(company_id, name)` if duplicate service names are not allowed.
- `message_templates(company_id, channel, name)`.
- `marketing_audiences(company_id, name)`.
- `marketing_campaigns(company_id, name)` if campaign names are used operationally.
- `crm_stages(crm_pipeline_id, display_order)`.
- `calendar_event_mappings(calendar_connection_id, external_event_id)` already exists and is good.
- `webhook_events(provider, external_event_id)` already exists and is good.
- `idempotency_keys(key, operation)` exists, but should include `company_id` when tenant-scoped.

### 9. Revisit Delete Behaviors for Compliance and Audit

Severity: Medium.

Several tenant-owned child tables use `on delete cascade`. Cascades are convenient, but they may conflict with auditability, financial history, privacy workflows, and recovery.

Recommended improvement:

- Keep cascade for pure join tables.
- Avoid cascade for financial records, audit logs, sent messages, webhook events, and compliance records.
- Prefer soft deletion or status transitions for business records.
- Define retention jobs for physical deletion.

### 10. Improve Money Modeling

Severity: Medium.

Money fields use `numeric(12, 2)`, which is acceptable for many local service businesses, but should be reviewed for scale and currency precision.

Recommended improvement:

- Consider minor-unit integer amounts for payment provider consistency.
- If keeping decimal amounts, confirm precision for all currencies and high-value invoices.
- Add currency checks or a currency reference table.
- Ensure invoice totals are either computed consistently or protected by reconciliation rules.

### 11. Add Exclusion Constraints for Booking Conflicts

Severity: Medium.

Appointments and resource bookings have start and end times, but no database-level conflict prevention.

Recommended improvement:

- Use PostgreSQL range types and exclusion constraints for resource bookings.
- Consider exclusion constraints for staff schedules if direct booking conflicts must be prevented at the database layer.
- If conflict resolution stays in application logic, document that decision clearly.

### 12. Add Case-Insensitive Strategy for Emails and Slugs

Severity: Medium.

Fields such as email and slug are plain `text`.

Recommended improvement:

- Use `citext` or generated normalized columns for emails and slugs.
- Enforce lowercase slugs.
- Add uniqueness rules based on normalized values.

Relevant fields:

- `user_profiles.email`.
- `companies.slug`.
- `company_invitations.invited_email`.
- `customers.email`.

### 13. Add More Tenant-Aware Composite Indexes

Severity: Medium.

Most query paths in a multi-tenant SaaS begin with `company_id`. Some indexes start with non-tenant FKs, which may be useful for joins but less optimal for tenant-scoped application queries.

Recommended improvement:

- Prefer indexes like `(company_id, status, created_at)`.
- Prefer `(company_id, customer_id)` for tenant-scoped customer lookups.
- Prefer `(company_id, starts_at)` and `(company_id, status, starts_at)` for appointments.
- Prefer `(company_id, event_type, occurred_at)` for events.
- Prefer `(company_id, provider, status)` for integrations.

### 14. Make Polymorphic References Safer

Severity: Medium.

Polymorphic references exist in audit logs, automation events, file links, AI runs, CRM mappings, data deletion jobs, and usage records.

Recommended improvement:

- Add entity type check constraints where allowed types are known.
- Require `company_id` for all tenant-scoped polymorphic references.
- Add tenant consistency validation in application services or database triggers.
- Avoid polymorphic references for core financial and scheduling flows.

## Normalization Review

Overall normalization is good. The schema separates:

- Users from company membership.
- Staff profile from membership.
- Customers from addresses, notes, tags, and consent.
- Services from categories, staff assignments, and resources.
- Appointments from services, participants, reminders, and status history.
- Campaign definitions from deliveries.
- Workflow definitions from execution runs.
- Invoices from invoice items and payments.

Primary normalization concerns:

- Heavy `jsonb` use could hide structured data that will need constraints and indexes.
- Some duplicated `company_id` fields require composite FK enforcement to avoid inconsistent records.
- Some provider fields are free text and should eventually be normalized or constrained.

## Scalability Review

The schema is broad enough for scale, but high-volume tables need explicit operational strategy.

Before production:

- Partition large event/history tables.
- Add archival workflows.
- Define retention policies per tenant and table type.
- Add tenant-aware indexes for dashboard and worker queries.
- Define batch processing patterns for sync jobs, automations, and outbox processing.

## Performance Review

The baseline index strategy is good but incomplete.

Before production:

- Add missing FK indexes for hot joins and delete checks.
- Add partial indexes for active, pending, scheduled, unpaid, queued, and open records.
- Add composite indexes matching real application query paths.
- Avoid adding broad GIN indexes on every `jsonb` column until query patterns are proven.

## Foreign Key Review

Foreign key coverage is strong, but tenant-safe FK design is not complete.

Before production:

- Add composite FKs that include `company_id` for tenant-owned parent-child relationships.
- Avoid cross-tenant parent references by construction.
- Review `on delete cascade` usage for financial, audit, messaging, and compliance records.
- Add deferred constraints only where multi-step transactional workflows require them.

## Indexing Review

The schema includes a good first pass of operational indexes, but it should be tuned before deployment.

Recommended index classes:

- Tenant filters: `(company_id, status)`.
- Time-series access: `(company_id, created_at)` or `(company_id, occurred_at)`.
- Scheduling: `(company_id, starts_at)`, `(primary_staff_profile_id, starts_at)`, and resource time indexes.
- CRM: `(company_id, crm_stage_id)`, `(company_id, owner_company_member_id)`.
- Payments: `(company_id, status)`, `(company_id, due_date)`.
- Messaging: `(conversation_id, created_at)`, `(company_id, channel, created_at)`.
- Workers: `(status, scheduled_for)`, `(status, created_at)`.

## Tenant Isolation Review

The schema is structurally prepared for RLS, but tenant isolation is not complete until:

- RLS policies are added.
- Composite tenant-safe FKs are added.
- Tenant-scoped service-role access patterns are defined.
- Polymorphic references are validated against tenant ownership.
- Derived tenant tables either receive `company_id` or have documented secure derivation paths.

## Deployment Readiness Verdict

Current status: not ready for production deployment.

Recommended path:

1. Add composite tenant-safe constraints for company-owned relationships.
2. Add direct `company_id` to important derived tenant tables.
3. Add missing FK and partial indexes for hot paths.
4. Add partitioning strategy for high-volume history/event tables.
5. Add stronger domain constraints for statuses, channels, providers, and directions.
6. Revisit cascade delete behavior for audit, finance, compliance, messaging, and events.
7. Run the schema against a real PostgreSQL/Supabase database before merging.

After those changes, the schema will be a strong foundation for the first RLS policy pass.
