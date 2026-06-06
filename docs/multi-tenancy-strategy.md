# Casa Di Amo OS Multi-Tenancy Strategy

## Purpose

This document defines the multi-tenancy strategy for Casa Di Amo OS.

Casa Di Amo OS is a white-label SaaS platform for service businesses. The platform must isolate tenant data, support users who belong to multiple companies, allow controlled platform administration, and scale to many companies without changing the core product architecture.

## 1. Tenancy Model

### Primary Model

Casa Di Amo OS uses a shared-database, shared-schema, company-scoped multi-tenancy model.

The tenant root is:

- `companies`

The tenant membership model is:

- `user_profiles`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`

The platform model is:

- Platform administration records.
- Global SaaS plans.
- Global feature catalog.
- Tenant billing configuration.
- Operational records that are explicitly platform-owned.

### Why This Model

Shared schema is the right starting point because Casa Di Amo OS needs:

- Fast product iteration.
- Centralized analytics.
- Consistent integrations.
- Efficient onboarding for small and mid-sized service businesses.
- Lower operational overhead than one database per tenant.
- A clear future path to partitioning or tenant tiering.

### Tenant Context

Every authenticated request must resolve an active tenant context before reading or writing tenant-owned records.

The active tenant context is valid only when:

- The user is authenticated through Supabase Auth.
- The user has a `user_profiles` record.
- The user has an active `company_members` record for the selected company.
- The company is active.
- The user has the required role or permission for the requested action.

Users may belong to multiple companies, but each operational request must execute against one active company context.

## 2. Tenant Isolation Strategy

### Database Isolation

Tenant isolation must be enforced primarily in PostgreSQL, not only in application code.

Tenant-owned tables must follow one of these patterns:

1. Direct ownership with `company_id`.
2. Derived ownership through a required parent that has `company_id`.
3. Explicit platform ownership for records that are not tenant data.

Preferred pattern:

- Use direct `company_id` on operational tables.
- Use composite tenant-safe foreign keys for parent-child relationships.
- Keep platform-global records physically separate from tenant-owned records.

### Tenant-Safe Foreign Keys

For production deployment, tenant-owned relationships should guarantee same-company ownership at the database level.

Recommended pattern:

- Parent tables expose uniqueness on `(id, company_id)`.
- Child tables reference parent records with composite foreign keys that include `company_id`.
- Child records cannot point to a parent in another company.

This is required for high-risk modules:

- Customers.
- Appointments.
- Services.
- CRM.
- Marketing.
- Automations.
- Payments.
- Files.
- Reports.
- Integrations.
- Privacy workflows.
- AI records.

### Tenant-Owned Data

Tenant-owned records include:

- Customers.
- Services.
- Staff profiles.
- Appointments.
- CRM records.
- Marketing records.
- Conversations and messages.
- Automations.
- Payments and invoices.
- Reports.
- Files and documents.
- Integration connections.
- Webhook events after tenant resolution.
- Audit logs.
- Privacy records.
- AI usage records.

### Platform-Owned Data

Platform-owned records include:

- SaaS plans.
- Global feature definitions.
- Platform administrators.
- Platform roles and permissions.
- Platform audit logs.
- Global operational configuration.

Platform-owned records must not be accessible through normal company membership.

### Polymorphic References

Polymorphic references are allowed for audit logs, events, files, AI runs, and integration mappings, but they must be controlled.

Rules:

- Always include entity type and entity ID.
- Include or derive `company_id` for tenant-scoped references.
- Validate that referenced records belong to the same company.
- Do not use polymorphic references for core transactional integrity where a direct foreign key is possible.

## 3. Company Ownership Model

### Company as System of Record

`companies` is the system tenant boundary.

A company owns:

- Its members.
- Its customers.
- Its services.
- Its appointments.
- Its CRM pipelines and deals.
- Its marketing audiences and campaigns.
- Its automations.
- Its payment records.
- Its reports.
- Its integrations.
- Its files.
- Its compliance records.

### User Membership

Users are global identities, not tenant-owned identities.

The relationship between users and companies is represented by `company_members`.

Rules:

- A `user_profile` can belong to multiple companies.
- A `company_member` belongs to exactly one company.
- A `company_member` has one active tenant role.
- A suspended membership loses access immediately.
- A removed membership must not be able to read historical tenant data.

### Staff Model

Staff identity is tenant-specific.

`staff_profiles` extend `company_members` only inside one company context.

This allows:

- The same person to work for multiple companies.
- Different roles per company.
- Different staff visibility per company.
- Different service assignments per company.

### Customer Ownership

Customers are company-owned records.

Initial strategy:

- A customer belongs to exactly one company.
- The same real-world person may appear as separate customer records in different companies.
- No cross-company customer deduplication should occur unless a future explicit platform-level identity model is approved.

This preserves tenant privacy and avoids accidental data sharing between companies.

### External Provider Ownership

Casa Di Amo OS is the source of truth for internal tenant operations.

External systems are integration providers unless a documented decision says otherwise.

Rules:

- External IDs live in mapping tables.
- Provider payloads do not become core identifiers.
- Provider-specific structures must not leak into the core tenant model.
- Integration sync must be idempotent and tenant-scoped.

## 4. Platform Administration Model

### Separation of Duties

Platform administrators are not normal tenant users.

Platform administration must be modeled separately from company access:

- `platform_admins`
- `platform_roles`
- `platform_permissions`
- `platform_role_permissions`
- `platform_admin_audit_logs`

### Platform Admin Access

Platform admin access should be allowed only for:

- Support operations.
- Billing operations.
- Security incident response.
- Tenant lifecycle management.
- Integration troubleshooting.
- Compliance workflows.

Platform admin access must be:

- Explicit.
- Audited.
- Least-privilege.
- Separate from company membership.
- Denied by default.

### Tenant Impersonation

Tenant impersonation should not be the default support model.

If impersonation is required later, it must include:

- Explicit reason.
- Time-bound session.
- Target company.
- Target actor.
- Approval workflow for sensitive tenants.
- Full audit logging.
- Visible support marker in application context.

### Platform Operations

Platform operations may manage:

- Companies.
- Company subscription status.
- Plan entitlements.
- Tenant suspension.
- Data export and retention workflows.
- Integration health.
- Security investigations.

Platform operations must not silently modify tenant business records unless the action is explicitly audited and justified.

## 5. Row Level Security Approach

### RLS Principle

RLS must be the primary enforcement layer for tenant data isolation in Supabase.

Application filters are required for performance and UX, but they are not sufficient for security.

### RLS Policy Foundation

RLS policies should use:

- Authenticated Supabase user ID.
- `user_profiles.auth_user_id`.
- Active `company_members`.
- Active `companies`.
- Requested `company_id`.
- Role and permission checks for privileged actions.

Baseline read policy:

- A user can read tenant-owned records only when the record's `company_id` belongs to a company where the user has an active membership.

Baseline write policy:

- A user can write tenant-owned records only when:
  - The record's `company_id` belongs to an active membership.
  - The company is active.
  - The membership is active.
  - The role has the required permission.

### RLS Function Strategy

Use stable helper functions for repeated checks.

Recommended helper concepts:

- `current_user_profile_id()`.
- `is_company_member(company_id)`.
- `has_company_permission(company_id, permission_key)`.
- `is_platform_admin()`.

These functions should be reviewed carefully to avoid security definer mistakes and accidental privilege escalation.

### Service Role Strategy

The service role must bypass RLS only for trusted backend operations.

Allowed uses:

- Background workers.
- Integration sync jobs.
- Webhook processing.
- Data migration.
- Scheduled rollups.
- Tenant lifecycle jobs.

Rules:

- Never expose service-role credentials to the frontend.
- Keep service-role operations narrow and auditable.
- Include `company_id` in service-role writes whenever the record is tenant-owned.
- Validate tenant ownership in service code even when RLS is bypassed.

### RLS and Platform Administration

Platform administrator access should not be implemented as broad tenant membership.

Preferred approach:

- Platform admin policies are separate from company membership policies.
- Platform admin reads and writes are audited.
- Sensitive operations require explicit platform permissions.
- Tenant business data access by platform admins should be exceptional, not routine.

### RLS Rollout Order

Recommended rollout:

1. Add tenant-safe composite constraints.
2. Add direct `company_id` where needed for tenant-derived tables.
3. Create helper functions.
4. Enable RLS on tenant-owned tables.
5. Add read policies.
6. Add write policies.
7. Add privileged action policies.
8. Add platform admin policies.
9. Test cross-tenant denial cases.
10. Test service-role workflows separately.

## 6. Future Scaling Strategy

### Phase 1: Shared Schema

Initial production model:

- One Supabase project.
- Shared PostgreSQL schema.
- All tenant-owned records scoped by `company_id`.
- RLS enabled on tenant-owned tables.
- Tenant-aware indexes for operational paths.

This supports early scale with the simplest operational model.

### Phase 2: Tenant-Aware Performance Optimization

As usage grows:

- Add partial indexes for active records.
- Add composite indexes beginning with `company_id`.
- Partition high-volume event tables by time.
- Archive old events, webhooks, messages, and audit records.
- Use rollup tables for dashboards.
- Move expensive analytics away from transactional tables.

High-volume candidates:

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

### Phase 3: Tenant Tiering

Larger tenants may require differentiated scaling.

Possible strategies:

- Dedicated read replicas for analytics-heavy tenants.
- Dedicated storage buckets for large tenants.
- Tenant-specific background job queues.
- Higher rate limits and isolated worker pools.
- Advanced retention policies by plan.

Tenant tiering should be entitlement-driven through plans and feature access.

### Phase 4: Tenant Sharding

If shared-schema scale becomes insufficient, introduce tenant sharding.

Shard routing should be based on company identity.

Requirements before sharding:

- Stable company IDs.
- No cross-tenant operational joins.
- External integrations scoped by company.
- Background jobs scoped by company.
- Tenant export and migration tooling.
- Central platform catalog for tenant-to-shard routing.

### Phase 5: Enterprise Isolation

For large or regulated customers, future isolation options may include:

- Dedicated database.
- Dedicated Supabase project.
- Dedicated storage.
- Dedicated worker pool.
- Dedicated analytics pipeline.

This should be offered only when justified by compliance, revenue, scale, or data residency requirements.

## Non-Negotiable Rules

- No tenant-owned operational data without a tenant boundary.
- No frontend access using service-role credentials.
- No platform admin access without audit logs.
- No cross-tenant data sharing by default.
- No provider-specific IDs as primary business identifiers.
- No RLS rollout without negative cross-tenant tests.
- No production deployment without tenant-safe foreign key review.

## Deployment Readiness Checklist

Before production:

- Confirm every tenant-owned table has or derives `company_id`.
- Add composite tenant-safe foreign keys for critical relationships.
- Enable RLS on tenant-owned tables.
- Add membership-based read policies.
- Add permission-based write policies.
- Add platform admin policies separately.
- Add cross-tenant denial tests.
- Add service-role workflow tests.
- Add audit logging for platform access.
- Add partitioning and retention plans for high-volume tables.
