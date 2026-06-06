# Casa Di Amo OS RLS Implementation Plan

## Purpose

This document converts the current schema, RLS strategy, multi-tenancy strategy, RBAC model, and schema review into an implementation roadmap for Supabase Row Level Security.

It does not generate SQL. It defines ownership, order, policy scope, helper function contracts, validation requirements, negative tests, and rollout steps for a future migration.

## Source Baseline

Source documents reviewed:

- `database/schema.sql`
- `database/rls-strategy.md`
- `database/schema-review.md`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`

Security baseline:

- Casa Di Amo OS uses shared-database, shared-schema, company-scoped tenancy.
- `companies` is the tenant root.
- `company_members` is the normal path from a Supabase Auth user to tenant data.
- Company RBAC is separate from platform administration.
- RLS must be enabled for all tables in exposed schemas before MVP.
- Service-role access is backend-only and must enforce equivalent tenant, permission, and audit checks.

## Ownership Classification Rules

### Tenant-owned

Rows owned by one company and protected by that company's active membership and RBAC. Most tables in this class have direct `company_id`.

For nullable `company_id` tables, rows with a non-null `company_id` are tenant-owned. Null-company rows are reserved for platform or system use and must be denied to tenant users unless a future approved design explicitly grants access.

### Derived tenant-owned

Rows without direct `company_id` where tenant ownership is inherited from a required parent. These need either parent-join RLS policies or a schema change that adds direct `company_id` before production hardening.

### Platform-owned

Global product, administration, plan, feature, platform RBAC, tenant lifecycle, or platform audit records. Normal company roles must not grant access to these tables.

### System-owned

Auth-adjacent or internal operational records not owned by one tenant as product data. Tenant users may receive narrow self-service access only where explicitly required.

## Table Classification

### Tenant-owned tables

These tables require tenant RLS before MVP:

| Domain | Tables |
| --- | --- |
| Tenant billing and entitlements | `billing_accounts`, `company_subscriptions`, `company_feature_entitlements`, `usage_limits`, `usage_counters`, `usage_records` |
| Company configuration and team | `company_settings`, `company_branding`, `company_locations`, `roles`, `company_members`, `company_invitations`, `staff_profiles`, `staff_working_hours`, `staff_time_off`, `api_clients`, `service_accounts` |
| Customers | `customers`, `customer_addresses`, `customer_notes`, `customer_tags`, `customer_tag_assignments`, `customer_consents` |
| Services and resources | `service_categories`, `services`, `service_resources`, `service_staff_assignments` |
| Appointments and calendars | `recurring_appointment_rules`, `appointments`, `appointment_services`, `appointment_participants`, `appointment_status_history`, `appointment_reminders`, `appointment_waitlists`, `resource_bookings`, `booking_holds`, `calendar_connections`, `calendar_event_mappings` |
| CRM | `crm_pipelines`, `crm_stages`, `crm_deals`, `crm_activities`, `crm_external_mappings` |
| Files, documents, messaging, and marketing | `files`, `media_assets`, `document_templates`, `file_links`, `message_templates`, `marketing_audiences`, `marketing_campaigns`, `marketing_messages`, `marketing_deliveries`, `conversations`, `conversation_participants`, `messages`, `message_attachments`, `message_status_events`, `notification_preferences` |
| Integrations | `integration_connections`, `oauth_grants`, `integration_sync_jobs`, `webhook_signing_secrets`, `webhook_events` |
| Automations | `automation_workflows`, `automation_triggers`, `automation_steps`, `automation_events`, `automation_runs`, `automation_run_steps` |
| Payments | `payment_customers`, `subscriptions`, `invoices`, `invoice_items`, `payments`, `refunds` |
| Reports, audit, and compliance | `report_definitions`, `report_snapshots`, `metric_daily_rollups`, `audit_logs`, `data_subject_requests`, `data_exports`, `data_deletion_jobs`, `retention_policies`, `consent_audit_logs` |
| Reliability and event processing | `job_queue`, `idempotency_keys`, `outbox_events`, `dead_letter_events` |
| AI governance | `ai_prompts`, `ai_runs`, `ai_outputs`, `ai_usage_records`, `ai_feedback` |

### Derived tenant-owned tables

These tables are tenant-owned through parent relationships and need special treatment:

| Table | Ownership path | MVP recommendation |
| --- | --- | --- |
| `subscription_items` | `company_subscriptions.company_id` | Derive in RLS for MVP; add direct `company_id` before production hardening. |
| `tenant_invoices` | `billing_accounts.company_id`; optional `company_subscriptions.company_id` | Add direct `company_id` before production if tenant invoice reads are exposed. |
| `role_permissions` | `roles.company_id` | Derive for MVP; deny tenant access when parent role has null `company_id`. |
| `api_keys` | `api_clients.company_id` | Do not expose key hashes to tenants; manage through backend functions. |
| `job_attempts` | `job_queue.company_id` | Keep service-role only for MVP; expose only redacted status through backend if needed. |

### Platform-owned tables

These tables are owned by Casa Di Amo platform operations:

- `companies`
- `platform_roles`
- `platform_permissions`
- `platform_role_permissions`
- `platform_admins`
- `platform_admin_audit_logs`
- `plans`
- `features`
- `plan_features`
- `permissions`

Notes:

- `companies` is the tenant root and platform-managed, but active company members need limited read access to their own company.
- Company owners may need limited update access to safe company profile fields. Tenant users must not change platform lifecycle fields such as status, plan linkage, or billing state through direct table access.
- `permissions` is a global permission catalog. Tenant members may read permission metadata only as needed for UI and RBAC evaluation; writes are platform-only.

### System-owned tables

These records are not normal tenant business records:

- `user_profiles`
- `user_sessions_audit`

Notes:

- `user_profiles` represents global application identity. Users may read and update safe fields on their own profile. Tenant access to another user's profile must be mediated through shared active company membership and field minimization.
- `user_sessions_audit` is append-only operational security data. Tenant users should not receive direct table access.

## Implementation Roadmap

### Phase 0: Security design freeze

1. Freeze the table classification in this document.
2. Confirm default role seeds: Company Owner, Manager, Employee, Viewer, Platform Admin.
3. Freeze permission keys from the RBAC model and add any missing module keys needed for MVP.
4. Decide which tenant-owned tables are directly exposed to Supabase clients and which are only accessed through Edge Functions.
5. Mark all service-role-only tables explicitly, especially secrets, keys, webhooks, jobs, outbox, dead letters, AI runs, and raw provider payloads.

### Phase 1: Helper function contracts

Create reviewed helper functions before table policies. Helpers must be small, deterministic in behavior, avoid dynamic SQL, avoid user-editable metadata, and live outside exposed public client surfaces when privileged.

Required helper contracts:

| Helper | Purpose |
| --- | --- |
| `current_user_profile_id()` | Resolve `auth.uid()` to one active `user_profiles.id`. |
| `is_active_company(company_id)` | Confirm the tenant root is active. |
| `is_active_company_member(company_id)` | Confirm the current user has active membership in the company. |
| `current_company_member_id(company_id)` | Resolve the current user's active `company_members.id` for the company. |
| `current_company_role_id(company_id)` | Resolve the current user's active role in the company. |
| `has_company_permission(company_id, permission_key)` | Check active membership plus role permission. |
| `has_any_company_permission(company_id, permission_keys)` | Support policies that accept more than one permission. |
| `is_platform_admin()` | Confirm active platform admin status. |
| `has_platform_permission(permission_key)` | Check platform role permission without using company membership. |
| `can_read_tenant_row(company_id)` | Shared read predicate for tenant-owned rows. |
| `can_insert_tenant_row(company_id, permission_key)` | Shared create predicate for tenant-owned rows. |
| `can_update_tenant_row(old_company_id, new_company_id, permission_key)` | Ensure existing and proposed company ownership are valid and unchanged. |
| `can_delete_tenant_row(company_id, permission_key)` | Shared delete predicate with permission evaluation. |

### Phase 2: Membership and ownership validation helpers

Create membership and tenant-reference validation before write policies.

Required validation contracts:

| Helper | Purpose |
| --- | --- |
| `membership_is_active(company_member_id, company_id)` | Confirm referenced company member belongs to the same company and is active. |
| `role_belongs_to_company(role_id, company_id)` | Prevent assigning roles across companies. |
| `customer_belongs_to_company(customer_id, company_id)` | Protect customer references in CRM, appointments, payments, marketing, compliance, and messaging. |
| `staff_profile_belongs_to_company(staff_profile_id, company_id)` | Protect schedule, appointment, service, and resource assignments. |
| `service_belongs_to_company(service_id, company_id)` | Protect appointment services, resources, invoices, and waitlists. |
| `location_belongs_to_company(company_location_id, company_id)` | Protect scheduling and resource locations. |
| `appointment_belongs_to_company(appointment_id, company_id)` | Protect appointment child records. |
| `conversation_belongs_to_company(conversation_id, company_id)` | Protect messages and participants. |
| `file_belongs_to_company(file_id, company_id)` | Protect attachments, exports, and linked files. |
| `integration_connection_belongs_to_company(integration_connection_id, company_id)` | Protect OAuth, webhooks, sync jobs, and provider mappings. |
| `invoice_belongs_to_company(invoice_id, company_id)` | Protect invoice items, payments, refunds, and financial references. |
| `automation_workflow_belongs_to_company(automation_workflow_id, company_id)` | Protect automation definitions and runs. |
| `ai_run_belongs_to_company(ai_run_id, company_id)` | Protect AI outputs, usage records, and feedback. |

### Phase 3: Foundational RLS policies

Implement identity, tenant root, membership, role, and permission access first:

1. Enable RLS on every public table.
2. Deny `anon` on all tenant, platform, and system tables.
3. Add self-profile policies for `user_profiles`.
4. Add limited own-company read policy for `companies`.
5. Add active membership read policy for `company_members`.
6. Add restricted invitation visibility for `company_invitations`.
7. Add role and permission read policies required for tenant UI and RLS evaluation.
8. Deny platform-owned writes except through platform-admin or service-role workflows.

### Phase 4: Core tenant MVP policies

Implement P0 tenant policies for the MVP operational core:

1. Company settings, branding, and locations.
2. Members, invitations, roles, and role permissions.
3. Staff profiles, working hours, and time off.
4. Customers, notes, tags, addresses, and consents.
5. Service catalog and service assignments.
6. Appointments, appointment children, reminders, waitlists, holds, resource bookings, and calendar mappings.
7. CRM pipelines, stages, deals, activities, and external mappings.
8. Files, templates, conversations, messages, and attachments.
9. Payments, invoices, invoice items, payment customers, subscriptions, and refunds.

### Phase 5: Integration, automation, reporting, compliance, and AI policies

Add policies for higher-risk and service-role-heavy modules after core tenant isolation is proven:

1. Integration connections, OAuth grants, webhook secrets, webhook events, and sync jobs.
2. Marketing audiences, campaigns, messages, and deliveries.
3. Automation workflows, triggers, steps, events, runs, and run steps.
4. Reports, snapshots, metric rollups, and audit logs.
5. Data subject requests, exports, deletion jobs, retention policies, and consent audit logs.
6. Usage records, limits, counters, tenant invoices, billing accounts, subscriptions, and entitlements.
7. AI prompts, runs, outputs, usage records, and feedback.
8. Reliability tables: job queue, attempts, idempotency, outbox, and dead letter events.

### Phase 6: Production hardening

Before production hardening is complete:

1. Add direct `company_id` to important derived tenant tables called out in the schema review.
2. Add tenant-safe composite foreign keys for high-risk parent-child relationships.
3. Add tenant-aware indexes that match RLS helper lookup paths.
4. Add partial indexes for active members, active records, scheduled appointments, pending jobs, queued events, unpaid invoices, and open CRM records.
5. Partition high-volume event and audit tables where justified by load.
6. Review cascade deletes for financial, audit, messaging, compliance, webhook, and AI tables.

## P0 RLS Policies Required Before MVP

### Universal P0 policies

Every public table must have one of these outcomes before MVP:

- Tenant policy for direct company ownership.
- Derived tenant policy through a required parent.
- Platform-only policy.
- System-only policy.
- Explicit no-direct-client-access policy.

### Tenant-owned direct company policies

For tenant-owned tables with direct `company_id`:

- Read: authenticated user has active profile, active company, and active membership in `row.company_id`.
- Insert: read predicate plus create or manage permission for the module; inserted `company_id` must be a company where the user is active.
- Update: existing row and proposed row must remain in the same company; user needs update, configure, manage, approve, refund, export, or module-specific permission as appropriate.
- Delete: user needs delete or manage permission, and deletion must not violate financial, audit, compliance, or retention restrictions.

### Derived tenant policies

For derived tenant-owned tables:

- Read and write must derive ownership from the parent row.
- Parent row must be accessible through active membership.
- Writes must validate parent ownership and module permission.
- Derived rows with parent records that have null company scope must be denied to tenant users.

### Platform policies

For platform-owned tables:

- Tenant users receive no access by default.
- Active tenant members may read limited `companies` fields for their own company.
- Active tenant members may read global `permissions` metadata only if needed for UI.
- Platform admin access must use separate platform admin helpers and must be audited.
- Platform admin status must not grant tenant business permissions.

### System policies

For system-owned tables:

- `user_profiles`: users can read and update safe fields on their own profile.
- Cross-user profile reads are minimized and allowed only when needed through shared active company membership.
- `user_sessions_audit`: no direct tenant access; service-role append and security review only.

### Service-role-only P0 tables

These tables should not be directly writable from the browser for MVP:

- `api_keys`
- `webhook_signing_secrets`
- `webhook_events`
- `integration_sync_jobs`
- `automation_events`
- `automation_runs`
- `automation_run_steps`
- `job_queue`
- `job_attempts`
- `idempotency_keys`
- `outbox_events`
- `dead_letter_events`
- `ai_runs`
- `ai_outputs`
- `ai_usage_records`

Any tenant-facing view of these records should be mediated through redacted Edge Functions or security-invoker views with separate review.

## Security Dependencies

Required before writing production RLS migrations:

- Permission catalog and default role seeds are finalized.
- RLS helper functions are reviewed for search path, volatility, privileges, recursion risk, and performance.
- No authorization decision depends on user-editable metadata.
- Helper functions do not use unsafe dynamic SQL.
- Privileged helper functions are not exposed as broad public RPCs.
- RLS helper lookup paths are indexed, especially `user_profiles.auth_user_id`, `company_members.user_profile_id`, `company_members.company_id`, `roles.company_id`, `role_permissions.role_id`, and `permissions.permission_key`.
- Service-role keys remain server-side only.
- Edge Functions validate user token, active membership, company status, permission, and row ownership before privileged work.
- Platform admin support access requires a reason, actor, target company, action, and audit record.
- Tenant-safe composite FKs are added for high-risk relationships before production launch.

## Supabase Rollout Sequence

### Local and review rollout

1. Create RLS helper migration in a private implementation branch.
2. Add policy migrations in the implementation order above.
3. Seed two or more test companies, users, roles, and permissions.
4. Run positive tenant tests and negative cross-tenant tests locally.
5. Run Supabase/Postgres advisors and resolve security warnings.
6. Review every public table for RLS enabled and policy coverage.

### Staging rollout

1. Deploy helper functions first.
2. Deploy platform/system deny policies.
3. Deploy identity, profile, company, membership, role, and permission policies.
4. Deploy core tenant policies by module.
5. Deploy service-role-only module policies and Edge Function checks.
6. Run the full negative security suite against staging.
7. Run smoke tests through the Supabase client and any Edge Functions.
8. Review logs for denied operations, unexpected zero-row updates, slow helper lookups, and service-role bypasses.

### Production rollout

1. Take a schema and data backup.
2. Deploy during a low-traffic window.
3. Deploy helper functions and policies in the same dependency order used in staging.
4. Verify RLS is enabled on all public tables.
5. Verify no tenant user can access another tenant's seeded canary records.
6. Monitor denied requests, policy errors, PostgREST errors, slow queries, and Edge Function authorization failures.
7. Keep rollback scripts ready, but prefer targeted policy correction over broad RLS disablement.

## Negative Security Tests

### Tenant isolation

- Company A member cannot read Company B rows in every tenant-owned table.
- Company A member cannot filter, count, export, or report on Company B rows.
- Multi-company user sees only records for authorized companies and cannot use stale client context to access another company.
- Tenant rows with null `company_id` are invisible to tenant users.
- Unauthorized access returns no usable data and does not disclose row existence.

### Membership and company status

- Anonymous caller cannot read or write tenant-owned data.
- Authenticated user without `user_profiles` cannot access tenant data.
- Authenticated user without `company_members` cannot access tenant data.
- Pending, invited, suspended, removed, archived, or unknown membership states are denied.
- Inactive company state denies tenant data access.
- Removed member loses access without relying on refreshed frontend state.

### RBAC

- Viewer cannot create, update, delete, export, configure, approve, refund, manage integrations, or run privileged AI actions.
- Employee cannot manage settings, roles, members, integrations, exports, refunds, audit logs, or compliance workflows.
- Manager cannot assign owner role, remove owner, manage platform billing, or access platform administration.
- Missing permission mappings deny access.
- Unknown roles deny access.
- Platform admin status does not imply company membership or tenant business write access.

### Inserts

- Insert without required tenant ownership is denied.
- Insert with another company's `company_id` is denied.
- Insert referencing another company's customer, service, staff profile, appointment, invoice, integration, file, automation, or AI run is denied.
- Insert assigning a company member, owner, creator, or actor from another company is denied.
- Insert into service-role-only tables from browser clients is denied.

### Updates

- Updating `company_id` is denied.
- Updating a foreign reference to another company's record is denied.
- Updating settings, integrations, roles, refunds, compliance jobs, exports, or automation publication without elevated permission is denied.
- Bulk update cannot bypass per-row authorization.
- Update after membership removal is denied.
- Update requiring SELECT policy does not silently fail in application flows without test coverage.

### Deletes

- Delete without delete or manage permission is denied.
- Cross-company delete is denied.
- Delete that would cascade into another tenant is impossible or denied.
- Hard delete of audit, financial, compliance, webhook, message, AI, or retention-protected data is denied outside approved workflows.
- Unauthorized delete does not reveal whether the target row exists.

### Derived tenant tables

- Company A cannot access `subscription_items` through Company B subscriptions.
- Company A cannot access `tenant_invoices` through Company B billing accounts.
- Company A cannot read or mutate `role_permissions` for Company B roles.
- Company A cannot manage `api_keys` through Company B API clients.
- Tenant users cannot access `job_attempts` for another company's job queue entries.

### Service role and Edge Functions

- Browser never receives service-role credentials.
- User-delegated Edge Function rejects missing token.
- User-delegated Edge Function rejects valid user without active membership.
- User-delegated Edge Function rejects valid member without required permission.
- Service-role workflow resolves company context from trusted configuration, not raw client payload.
- Scheduled job processes one company scope at a time.
- Platform admin function rejects tenant user callers.
- Platform admin function requires reason-bound audited access.

### Webhooks, integrations, and AI

- Invalid webhook signature is denied.
- Webhook payload mapped to no active integration is denied.
- Webhook payload attempting tenant mismatch is denied.
- Replay payload is denied or idempotent.
- AI agent cannot retrieve another company's data.
- AI agent cannot write without authenticated, platform, or approved system context plus required permission.
- AI logs, prompts, outputs, memory, and usage records do not mix company data.

## Testing Plan

### Coverage tests

- Assert every public table is classified in this plan.
- Assert every public table has RLS enabled.
- Assert every public table has exactly one intended policy model: tenant, derived tenant, platform, system, or no direct client access.
- Assert no exposed table depends on user-editable metadata for authorization.

### Policy behavior tests

- Seed at least two companies, two users, all default roles, and representative rows in every MVP tenant table.
- Run read, insert, update, and delete attempts for Company A against Company B rows.
- Run role matrix tests for Company Owner, Manager, Employee, and Viewer.
- Run platform admin tests separately from company member tests.
- Run service-role workflow tests with explicit company context and audit assertions.

### Regression tests

- Add a failing test whenever a new tenant-owned table is added without RLS classification.
- Add a failing test whenever a new nullable `company_id` table lacks null-company tenant denial.
- Add a failing test whenever a foreign key allows cross-company references in high-risk modules.
- Add a failing test whenever a service-role Edge Function accepts unvalidated client-supplied `company_id`.

## MVP Exit Criteria

RLS is MVP-ready only when:

1. Every table in `public` has RLS enabled.
2. Every table is classified as tenant-owned, derived tenant-owned, platform-owned, or system-owned.
3. Tenant-owned read access requires active auth, active profile, active company, and active membership.
4. Tenant-owned write access requires active membership plus explicit RBAC permission.
5. Company ownership cannot be changed through tenant-facing paths.
6. Derived tenant-owned tables are either safely protected through parents or receive direct `company_id`.
7. Platform admin access is separate from company membership and audited.
8. Service-role access is limited to trusted backend workflows with equivalent authorization checks.
9. Negative cross-tenant, RBAC, membership, service-role, webhook, integration, AI, and delete tests pass.
10. No executable SQL has been introduced by this planning document.
