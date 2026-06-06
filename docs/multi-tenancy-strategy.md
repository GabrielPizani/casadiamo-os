# Casa Di Amo OS Multi-Tenancy Strategy

## Executive Summary

Casa Di Amo OS will use a shared-database, shared-schema, company-scoped multi-tenant architecture on Supabase and PostgreSQL.

The tenant root is `companies`. Every tenant-owned operational record must include or safely derive `company_id`. User access is granted through `company_members`, evaluated with company-scoped roles and permissions. Platform administration is separate from company membership and must be explicitly audited.

This model is recommended because Casa Di Amo OS is a white-label SaaS platform for service businesses that needs fast onboarding, centralized operations, shared integrations, consistent analytics, and a future path to tenant tiering, partitioning, sharding, and enterprise isolation.

The core security principle is defense in depth:

- Application-level tenant context.
- PostgreSQL Row Level Security.
- Tenant-safe foreign keys.
- RBAC permissions.
- Service-role controls.
- Audit logs.
- Data governance workflows.

## Architectural Decision Record

### ADR: Multi-Tenancy Model for Casa Di Amo OS

Status: Accepted.

Date: 2026-06-06.

### Context

Casa Di Amo OS is a multi-tenant SaaS and white-label operating system for service businesses.

The platform must support:

- Authentication.
- Companies.
- Users and team management.
- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- LGPD workflows.
- Platform billing.
- Future integrations with HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, and AI Agents.

The technical foundation is:

- Supabase.
- PostgreSQL.
- Supabase Auth.
- React and Lovable frontend.
- Vercel hosting.

### Decision

Use a shared Supabase project and shared PostgreSQL schema for the initial production architecture.

Use `companies` as the tenant root.

Use `company_members` as the only normal path from a user to tenant data.

Use PostgreSQL Row Level Security as the primary database-level enforcement mechanism.

Use platform administration tables separately from company membership.

Use future tenant tiering, partitioning, sharding, or enterprise isolation only when operational scale, compliance, or revenue requires it.

### Consequences

Positive consequences:

- Faster delivery.
- Lower operational complexity.
- Simple onboarding for many service businesses.
- Centralized analytics and platform operations.
- Easier shared integration management.
- Clear path to RLS-based isolation.

Negative consequences:

- RLS policies must be correct.
- Tenant-safe constraints must be added before production.
- High-volume tables need partition and retention planning.
- A single shared database requires careful performance governance.
- Enterprise tenants may eventually need stronger physical isolation.

## Recommended Approach

The recommended approach is:

1. Start with shared-database, shared-schema tenancy.
2. Scope operational records by `company_id`.
3. Enforce access through Supabase Auth, `user_profiles`, `company_members`, RBAC, and RLS.
4. Keep platform administration separate from company membership.
5. Treat external integrations as tenant-owned connections.
6. Use audit logs for sensitive user, company, platform, billing, integration, and compliance actions.
7. Add partitioning and tenant tiering as scale increases.
8. Reserve dedicated infrastructure for enterprise or regulated tenants.

## 1. Tenant Model

### Primary Tenant

The primary tenant is:

- `companies`

A company represents one service business using Casa Di Amo OS.

Examples:

- Clinic.
- Beauty or aesthetics business.
- Pet shop.
- Consultancy.
- Local service provider.

### Tenant Type

Casa Di Amo OS uses company-level tenancy.

This means:

- Customers belong to companies.
- Staff belongs to companies through memberships.
- Services belong to companies.
- Appointments belong to companies.
- CRM, marketing, automation, payment, report, integration, file, compliance, and AI records belong to companies.

### Tenant Context

Every tenant-scoped operation must resolve an active company context.

Valid tenant context requires:

- Authenticated Supabase user.
- Existing `user_profiles` record.
- Active `company_members` record.
- Active `companies` record.
- Role and permission allowing the action.

### White-Label Behavior

White-label behavior is company-scoped.

Company-level configuration includes:

- Branding.
- Logo.
- Colors.
- Public profile.
- Domain configuration.
- Locations.
- Notification preferences.
- Scheduling preferences.
- Marketing configuration.

White-label configuration must never change tenant isolation rules.

## 2. Tenant Ownership

### Company-Owned Data

A company owns its operational data.

Company-owned data includes:

- Company settings.
- Company branding.
- Company locations.
- Company members.
- Staff profiles.
- Customers.
- Customer addresses.
- Customer notes.
- Customer consents.
- Services.
- Service resources.
- Appointments.
- CRM records.
- Marketing records.
- Conversations and messages.
- Automations.
- Payment records.
- Reports.
- Files.
- Integrations.
- Webhook events after tenant resolution.
- Audit logs.
- Privacy requests.
- AI prompts, runs, outputs, and usage records.

### Platform-Owned Data

Platform-owned data is global to Casa Di Amo OS.

Platform-owned data includes:

- Platform administrators.
- Platform roles and permissions.
- Global SaaS plans.
- Global features.
- Plan feature mappings.
- Platform audit logs.
- Tenant billing configuration.
- Global operational settings.

Platform-owned records must not be accessible through normal company roles.

### User Ownership

Users are global identities.

`user_profiles` are not owned by one company.

Access to a company is granted through `company_members`.

This supports:

- One user working for multiple companies.
- Different roles per company.
- Tenant-specific staff profiles.
- Tenant-specific access removal.

### Customer Ownership

Customers are company-owned records.

The same real-world person may appear as separate customer records in multiple companies.

No cross-company customer deduplication should occur by default.

This protects tenant privacy and avoids accidental data sharing.

### Integration Ownership

Integrations are company-owned.

HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, and AI Agent integrations must be connected to one company context.

Rules:

- Store external IDs in mapping tables.
- Do not use provider IDs as internal primary identifiers.
- Validate webhook tenant context before processing.
- Keep provider payloads minimized.
- Make sync jobs idempotent and tenant-scoped.

## 3. Tenant Isolation

### Isolation Layers

Tenant isolation must exist at multiple layers:

1. UI tenant context.
2. Application authorization.
3. Database RLS.
4. Tenant-safe foreign keys.
5. Background job validation.
6. Service-role controls.
7. Audit logging.

### Database Ownership Pattern

Tenant-owned tables should use direct `company_id` wherever practical.

Acceptable ownership patterns:

- Direct `company_id`.
- Required parent with `company_id`.
- Explicit platform-owned table with no tenant data.

Preferred production pattern:

- Parent has `id`.
- Parent has `company_id`.
- Parent has uniqueness on `(id, company_id)`.
- Child includes `company_id`.
- Child references parent using composite foreign key.

### Tenant-Safe Foreign Keys

Tenant-safe foreign keys prevent accidental cross-company writes.

Example requirement:

- An appointment service must reference an appointment from the same company.
- It must reference a service from the same company.
- It must not be possible to combine records from different companies.

Apply tenant-safe constraints to:

- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- Integrations.
- Files.
- Privacy records.
- AI records.

### Derived Tenant Tables

Some tables may derive tenant ownership from parents.

Examples:

- Subscription items.
- Job attempts.
- API keys.

Recommendation:

- Add direct `company_id` to high-volume or security-sensitive derived tables.
- Keep purely platform-owned join tables without `company_id`.
- Document any table where tenant context is derived rather than stored.

## 4. Row Level Security Approach

### RLS Principle

RLS is the primary database security layer for tenant-owned data.

Application filters are required for performance and usability, but they are not sufficient for security.

### RLS Inputs

Policies should evaluate:

- Current Supabase user ID.
- `user_profiles.auth_user_id`.
- Active company membership.
- Active company status.
- Role assignment.
- Permission key.
- Target record `company_id`.

### Baseline Read Policy

A user can read tenant-owned records only when:

- The user is authenticated.
- The user has an active profile.
- The user has active membership in the record's company.
- The company is active.

### Baseline Write Policy

A user can create, update, or delete tenant-owned records only when:

- Baseline read conditions are true.
- The user's role grants the required permission.
- The target `company_id` matches the active tenant context.
- The operation does not violate business restrictions.

### Helper Function Strategy

Use carefully reviewed database helper functions for repeated RLS checks.

Recommended concepts:

- Current user profile.
- Active company membership.
- Company permission lookup.
- Platform admin check.
- Tenant ownership check.

Security notes:

- Avoid unsafe `security definer` functions.
- Keep helper functions small.
- Avoid dynamic SQL in policy helpers.
- Test negative cross-tenant cases.

### Service Role Strategy

Service-role access is allowed only for trusted backend operations.

Allowed use cases:

- Webhook processing.
- Integration sync jobs.
- Background workers.
- Data migrations.
- Scheduled reporting rollups.
- Tenant lifecycle jobs.
- Compliance export and deletion jobs.
- AI agent orchestration jobs.

Rules:

- Never expose service-role keys to the frontend.
- Validate tenant ownership in service code.
- Include `company_id` on tenant-owned writes.
- Log sensitive service-role operations.
- Keep worker permissions narrow by responsibility.

## 5. Platform Administration

### Administration Boundary

Platform administrators are not company members by default.

Platform admin access must use separate entities:

- `platform_admins`.
- `platform_roles`.
- `platform_permissions`.
- `platform_role_permissions`.
- `platform_admin_audit_logs`.

### Allowed Platform Operations

Platform administrators may manage:

- Companies.
- Tenant status.
- Tenant billing state.
- SaaS plans.
- Feature entitlements.
- Integration health.
- Security investigations.
- Compliance workflows.
- Support operations.
- Platform-level audit review.

### Restrictions

Platform administrators must not:

- Silently modify tenant business records.
- Use company roles as a shortcut for platform access.
- Access tenant data without justification.
- Bypass audit logging.
- Use service-role access from frontend flows.

### Support Access

Support access must be:

- Explicit.
- Time-bound.
- Reason-bound.
- Audited.
- Visible in support context.

Tenant impersonation should be exceptional, not a default support workflow.

## 6. Cross-Tenant Protection

### Non-Negotiable Rules

- No tenant-owned data without tenant boundary.
- No cross-company operational joins for product behavior.
- No cross-company customer deduplication by default.
- No user-supplied `company_id` without membership validation.
- No provider webhook processing without tenant resolution.
- No platform admin access without audit logs.
- No RLS rollout without negative cross-tenant tests.

### Cross-Tenant Risk Areas

High-risk areas:

- Appointments referencing services or staff from another company.
- CRM deals linked to customers from another company.
- Marketing deliveries targeting customers from another company.
- Payments linked to invoices from another company.
- Files linked to records from another company.
- Webhooks mapped to the wrong integration connection.
- AI runs using context from another company.
- Platform support access without audit.

### Required Protections

Use:

- Tenant-safe composite FKs.
- RLS policies.
- RBAC permission checks.
- Tenant-scoped idempotency keys.
- Tenant-scoped background jobs.
- Tenant-aware indexes.
- Audit logs.
- Integration connection ownership checks.

## 7. User Membership Model

### Core Entities

Membership is modeled with:

- `auth.users`.
- `user_profiles`.
- `company_members`.
- `roles`.
- `permissions`.
- `role_permissions`.
- `staff_profiles`.

### Membership Rules

- One Supabase user maps to one application user profile.
- One user profile can belong to many companies.
- One company has many members.
- One company member has one active role in that company.
- Staff profile is tenant-specific.
- Removing membership removes tenant access.
- Suspending membership immediately blocks tenant access.

### Role Model

Default company roles:

- Company Owner.
- Manager.
- Employee.
- Viewer.

Platform role:

- Platform Admin.

Company roles must not grant platform privileges.

Platform roles must not imply company membership.

## 8. Company Hierarchy

### Current Hierarchy

Initial hierarchy:

1. Platform.
2. Company.
3. Company locations.
4. Company members.
5. Staff profiles.
6. Operational records.

### Company Locations

Locations belong to one company.

Locations support:

- Scheduling.
- Staff availability.
- Service delivery.
- Reports.
- Resource booking.

### Future Multi-Location and Group Support

Future hierarchy may include:

- Company groups.
- Franchises.
- Regional accounts.
- Brands.
- Sub-companies.

Do not add group-level data sharing until explicit product requirements exist.

Recommended future pattern:

- `company_groups`.
- `company_group_memberships`.
- Group-level reporting only.
- No automatic customer sharing between companies.

## 9. Future Scaling Strategy

### Phase 1: Shared Supabase Project

Initial production:

- One Supabase project.
- Shared PostgreSQL schema.
- `company_id` scoped records.
- RLS on tenant-owned tables.
- Tenant-aware indexes.
- Central integration workers.

### Phase 2: Performance Scaling

As usage grows:

- Add partial indexes for active records.
- Add composite indexes starting with `company_id`.
- Partition high-volume event and history tables by time.
- Archive old webhook, message, audit, automation, and usage records.
- Use report rollups and snapshots.
- Keep dashboards away from raw transactional scans.

High-volume tables:

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

Tenant tiering should be based on billing plan, usage, compliance, and operational load.

Possible tiering:

- Higher rate limits.
- Dedicated worker queues.
- Dedicated storage buckets.
- Priority integration sync.
- Advanced retention controls.
- Larger report windows.
- Higher AI usage limits.

### Phase 4: Tenant Sharding

Introduce sharding only when shared schema scale becomes insufficient.

Sharding requirements:

- Stable `company_id`.
- Tenant-scoped jobs.
- Tenant-scoped integrations.
- Tenant export and migration tooling.
- Central tenant routing catalog.
- No required cross-tenant joins for product workflows.

### Phase 5: Enterprise Isolation

Enterprise isolation may include:

- Dedicated database.
- Dedicated Supabase project.
- Dedicated storage.
- Dedicated integration workers.
- Dedicated analytics pipeline.
- Data residency controls.

Offer only when justified by compliance, revenue, scale, or enterprise contract.

## 10. Data Governance

### Governance Scope

Data governance applies to:

- Tenant data.
- Platform data.
- Integration data.
- Billing data.
- Audit data.
- AI data.
- Compliance data.

### LGPD Alignment

The platform must support:

- Consent management.
- Consent audit history.
- Data subject requests.
- Data export.
- Data deletion or anonymization.
- Retention policies.
- Sensitive data handling.

### Data Retention

Retention must be tenant-aware.

Rules:

- Retention policies apply by company and entity type.
- Legal hold overrides normal retention.
- Financial and audit records should not be casually deleted.
- Old operational events should be archived or deleted through controlled jobs.

### Data Export

Exports must:

- Resolve tenant context.
- Validate requester permission.
- Include only owned data.
- Exclude secrets and unrelated tenant data.
- Be audited.
- Use expiring file access.

### Data Deletion

Deletion must:

- Validate tenant ownership.
- Respect legal and financial retention.
- Prefer anonymization when business records must remain.
- Stop future marketing and automation usage.
- Preserve minimal audit proof.

### AI Data Governance

AI Agents must follow tenant boundaries.

Rules:

- AI prompts must not mix company contexts.
- AI runs must include or derive `company_id`.
- AI outputs containing personal data follow retention and deletion policy.
- AI usage records support billing and audit.
- Sensitive customer context should be minimized before calling AI providers.

## Alternative Approaches Considered

### Alternative 1: Database Per Tenant

Description:

- Each company receives its own database.

Pros:

- Strong physical isolation.
- Easier tenant-level backup and restore.
- Easier enterprise compliance story.

Cons:

- High operational complexity.
- Harder migrations.
- Harder cross-tenant platform analytics.
- More expensive for small tenants.
- Slower onboarding.

Decision:

- Not recommended for the default model.
- Keep as future enterprise option.

### Alternative 2: Schema Per Tenant

Description:

- One database with one PostgreSQL schema per company.

Pros:

- Better logical isolation than shared tables.
- Less heavy than database per tenant.

Cons:

- Migration complexity grows with tenant count.
- Harder query tooling.
- Supabase and RLS patterns become more complex.
- Integrations and analytics become harder.

Decision:

- Not recommended.

### Alternative 3: Shared Schema Without RLS

Description:

- Use only application filters with `company_id`.

Pros:

- Simpler initial implementation.
- Less database policy work.

Cons:

- Unsafe for multi-tenant SaaS.
- A single query bug can leak tenant data.
- Does not meet production security expectations.

Decision:

- Rejected.

### Alternative 4: Shared Schema With RLS

Description:

- One shared schema with company-scoped rows and RLS policies.

Pros:

- Best fit for Supabase.
- Good balance of speed, cost, isolation, and scale.
- Supports centralized analytics.
- Compatible with tenant tiering later.

Cons:

- Requires careful policy design.
- Requires tenant-safe constraints.
- Requires negative security tests.

Decision:

- Accepted as default approach.

## Tradeoffs

### Simplicity vs Isolation

Shared schema is simpler than database-per-tenant, but requires strong RLS and tenant-safe constraints.

### Speed vs Governance

Fast onboarding is easier with shared infrastructure, but governance must be enforced through policies, audit logs, and data lifecycle workflows.

### Centralized Analytics vs Physical Separation

Centralized analytics are easier in a shared model. Physical separation may be required later for enterprise tenants.

### Flexible Integrations vs Tenant Safety

Integrations need flexible mappings and webhook handling, but every provider event must resolve to exactly one company before processing.

### AI Capability vs Privacy

AI Agents can improve operations, but prompts, outputs, and usage records must remain tenant-scoped and governed by retention and privacy rules.

## Risks

### Risk: Incorrect RLS Policy

Impact:

- Cross-tenant data exposure.

Mitigation:

- Keep policies simple.
- Use helper functions.
- Add negative cross-tenant tests.
- Review policies before deploy.

### Risk: Cross-Tenant Foreign Key References

Impact:

- Data corruption or leakage through invalid relationships.

Mitigation:

- Add composite tenant-safe FKs.
- Add `(id, company_id)` uniqueness to parent tables.
- Validate service-role writes.

### Risk: Service Role Misuse

Impact:

- RLS bypass and broad data exposure.

Mitigation:

- Never expose service-role keys to frontend.
- Limit service-role use to backend workers.
- Log sensitive service-role operations.

### Risk: Integration Webhook Misrouting

Impact:

- Provider events update the wrong tenant.

Mitigation:

- Resolve tenant through integration connection.
- Validate provider signatures.
- Use idempotency keys.
- Store webhook events before processing.

### Risk: High-Volume Table Growth

Impact:

- Slow queries, bloated indexes, expensive dashboards.

Mitigation:

- Partition event tables.
- Add rollups.
- Archive old records.
- Use tenant-aware indexes.

### Risk: Platform Admin Overreach

Impact:

- Unauthorized tenant data access.

Mitigation:

- Separate platform roles.
- Require reason-bound access.
- Audit every support action.
- Avoid default impersonation.

### Risk: AI Data Leakage

Impact:

- Sensitive customer context sent to or mixed through AI workflows.

Mitigation:

- Scope AI runs by company.
- Minimize prompt data.
- Audit AI runs.
- Apply retention rules to AI outputs.

## Final Recommendation

Casa Di Amo OS should proceed with shared-database, shared-schema, company-scoped tenancy on Supabase and PostgreSQL.

The final recommended model is:

- `companies` is the tenant root.
- `company_members` grants tenant access.
- `roles`, `permissions`, and `role_permissions` define company RBAC.
- Platform administration is separate from company membership.
- Tenant-owned tables include or derive `company_id`.
- RLS enforces tenant access at the database layer.
- Composite tenant-safe FKs prevent cross-tenant relationship corruption.
- Service-role access is backend-only and audited.
- Integrations are tenant-owned.
- AI Agents are tenant-scoped and governed.
- Scaling starts with shared schema and evolves toward partitioning, tenant tiering, sharding, or enterprise isolation only when justified.

This approach provides the best balance of speed, security, scalability, and operational simplicity for a white-label SaaS platform serving service businesses.

## Deployment Readiness Checklist

Before production:

- Add tenant-safe composite foreign keys.
- Add direct `company_id` to important tenant-derived tables.
- Enable RLS on tenant-owned tables.
- Create membership-based read policies.
- Create permission-based write policies.
- Create separate platform admin policies.
- Add cross-tenant denial tests.
- Add service-role worker tests.
- Add integration webhook tenant-resolution tests.
- Add AI tenant-boundary tests.
- Add audit logging for platform access.
- Add retention and partitioning plans for high-volume tables.
