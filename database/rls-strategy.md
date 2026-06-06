# Casa Di Amo OS RLS Architecture

## Purpose

This document defines the Row Level Security architecture for Casa Di Amo OS.

Casa Di Amo OS is a multi-tenant SaaS platform for service businesses. The backend is Supabase on PostgreSQL, and the platform requires multi-company tenancy, profile-based permissions, and data isolation between companies.

This document does not contain SQL. It defines the security architecture, evaluation rules, access patterns, and negative test cases that database policies and application code must satisfy.

## Source Baseline

The requested source files were not present in the current repository snapshot:

- `multi-tenancy-strategy.md`
- `schema.sql`
- `database-architecture.md`
- `rbac-model.md`

The available repository source of truth establishes:

- Casa Di Amo OS is a multi-tenant SaaS platform for service businesses.
- The backend is Supabase and PostgreSQL.
- The platform requires data isolation between companies.
- Permissions are profile-based.
- Security, multi-tenancy, scalability, maintainability, and documentation-first development are architecture priorities.

This RLS architecture is therefore intentionally schema-neutral. Before implementation, it must be reconciled with the canonical schema and RBAC documents once those files exist in the repository.

## Security Principles

1. RLS is mandatory for every tenant-owned table exposed through Supabase.
2. Tenant isolation is enforced in the database, not only in frontend or API code.
3. Every tenant-owned row has one authoritative tenant identifier.
4. Users can only access tenant data through an active tenant membership.
5. Profile-based permissions determine actions after tenant membership is proven.
6. Service role access is exceptional, server-only, audited, and scoped by application logic.
7. Platform admin access is exceptional, audited, and separate from tenant roles.
8. Edge Functions must enforce the same authorization model before invoking privileged operations.
9. Deny-by-default is the baseline for missing membership, missing tenant context, inactive users, and unknown permissions.

## Tenant Isolation Model

### Tenant Boundary

The tenant boundary is the company/business account. Each tenant represents one service business using Casa Di Amo OS.

Tenant-owned data includes, at minimum, records related to:

- CRM
- Customers
- Scheduling
- Marketing
- Automations
- Analytics and reports
- Team management
- Settings
- External integrations

### Tenant Identifier

Every tenant-owned table must include a non-null tenant identifier that points to the owning tenant.

The tenant identifier is the primary isolation key. RLS policies must compare row ownership against the authenticated user's active tenant memberships, not against client-provided claims alone.

### Membership Model

A user may belong to one or more tenants. A tenant membership connects:

- authenticated user
- tenant
- profile or role
- membership status
- optional permission overrides if the RBAC model later supports them

Only active memberships grant access.

### Tenant Context

For tenant-owned reads and writes, the effective tenant must be derived from one of these trusted sources:

1. The row being accessed.
2. A validated route or request tenant context checked against membership.
3. A server-side Edge Function context that has already validated the caller.

Client-provided tenant identifiers are never trusted until validated against active membership and requested action.

### Cross-Tenant Isolation

Users must not be able to:

- read rows from tenants where they have no active membership
- insert rows into tenants where they have no create permission
- update rows from tenants where they have no update permission
- change a row from one tenant to another
- delete rows from tenants where they have no delete permission
- infer the existence of inaccessible tenant rows through updates, deletes, counts, or error differences

## Access Control Flow

All tenant-owned access follows this flow:

1. Authenticate the caller through Supabase Auth.
2. Resolve the authenticated user id.
3. Resolve active tenant membership for the target tenant.
4. Confirm membership status is active.
5. Resolve the user's profile or role for that tenant.
6. Evaluate the requested action against the profile permissions.
7. Apply row-specific constraints, such as ownership, record status, or module boundary.
8. Allow the operation only when every required check passes.
9. Log privileged or sensitive access where applicable.

If any step cannot be resolved, access is denied.

## Permission Evaluation Flow

Permission evaluation is action-based and tenant-scoped.

### Evaluation Inputs

The authorization layer evaluates:

- authenticated user
- target tenant
- membership status
- profile or role
- requested module
- requested action
- target row ownership
- record lifecycle state
- platform admin status, if applicable
- service role context, if applicable

### Action Types

At minimum, every module must define permissions for:

- read
- create
- update
- delete
- manage settings or configuration where applicable
- export or bulk access where applicable
- integration management where applicable

### Evaluation Order

Permissions are evaluated in this order:

1. Reject anonymous access unless the table is explicitly public and non-tenant-owned.
2. Reject inactive, suspended, or removed memberships.
3. Reject missing tenant context for tenant-owned operations.
4. Reject tenant mismatch between user membership and target row.
5. Evaluate profile permission for the requested module and action.
6. Apply row-specific restrictions.
7. Apply platform admin exception only if the caller is an authenticated platform operator using an approved admin path.
8. Apply service role exception only for approved server-side workflows.

### Deny Conditions

Access is denied when:

- the caller is anonymous
- the user has no tenant membership
- the membership is inactive
- the target tenant does not match an active membership
- the user's profile lacks the action permission
- the row belongs to another tenant
- the request attempts to mutate the tenant identifier
- the request depends on user-controlled metadata for authorization
- the request comes from a browser using privileged credentials

## Insert Rules

Tenant-owned inserts must satisfy all of the following:

1. The caller is authenticated.
2. The target tenant exists.
3. The caller has an active membership in the target tenant.
4. The caller's profile allows create access for the target module.
5. The inserted row's tenant identifier equals the authorized tenant.
6. Ownership fields, if present, reference users valid for the same tenant.
7. Foreign keys, if present, reference rows from the same tenant.
8. Integration identifiers, if present, belong to the same tenant.
9. The row does not create privileged state unless the caller has a management permission.

Tenant identifiers must not be defaulted from arbitrary client input. The application may pass tenant context, but database policies must still validate the user is allowed to create within that tenant.

## Update Rules

Tenant-owned updates must satisfy all of the following:

1. The caller is authenticated.
2. The existing row belongs to a tenant where the caller has active membership.
3. The caller's profile allows update access for the target module.
4. The updated row remains in the same tenant.
5. Tenant identifier changes are denied.
6. Foreign key changes cannot point to rows from another tenant.
7. Ownership changes cannot assign records to users outside the same tenant.
8. Sensitive fields require explicit management permissions.
9. Lifecycle transitions must respect module-specific rules.

Update authorization must evaluate both the existing row and the proposed row state.

## Delete Rules

Tenant-owned deletes must satisfy all of the following:

1. The caller is authenticated.
2. The row belongs to a tenant where the caller has active membership.
3. The caller's profile allows delete access for the target module.
4. The row is not protected by retention, billing, audit, or integration constraints.
5. Cascading effects cannot delete data from another tenant.
6. Soft-delete is preferred for customer, scheduling, CRM, automation, analytics, and integration records unless the data retention policy explicitly permits hard delete.

Delete policies must not reveal whether rows exist in another tenant. Unauthorized deletes should behave as no accessible row affected.

## Service Role Exceptions

The Supabase service role bypasses RLS and must never be exposed to browsers, mobile clients, Lovable frontend code, or public automation clients.

Service role access is permitted only for server-side workflows that require privileged execution, such as:

- trusted Edge Functions
- background automation jobs
- integration synchronization
- webhook ingestion after signature validation
- administrative maintenance
- data repair operations

Service role workflows must:

1. Run only in trusted server environments.
2. Validate the initiating user or external system before performing tenant work.
3. Resolve tenant context server-side.
4. Apply equivalent tenant and permission checks in application logic.
5. Limit operations to the minimum required tenant and records.
6. Avoid broad cross-tenant reads unless explicitly required for platform operations.
7. Emit audit events for sensitive or privileged operations.
8. Fail closed when tenant, membership, signature, or permission validation fails.

Service role is an execution capability, not an authorization model. It cannot be used to skip tenant isolation requirements.

## Platform Admin Exceptions

Platform admins are Casa Di Amo operators responsible for governance, support, security, and operational maintenance. Platform admin access is separate from tenant user roles.

Platform admin exceptions may allow cross-tenant visibility only through approved admin surfaces and support workflows.

Platform admin access must:

1. Require authenticated platform operator identity.
2. Be represented separately from tenant membership.
3. Use least-privilege admin capabilities.
4. Require explicit reason or ticket context for sensitive tenant access.
5. Be audited with operator id, target tenant, action, timestamp, and affected resource.
6. Avoid tenant data mutation unless required for support, security, or operational correction.
7. Never grant tenant business permissions implicitly.
8. Be unavailable from normal tenant-facing application paths.

Platform admins must not rely on editable user metadata for authorization. Admin status must come from trusted server-side authorization data.

## Edge Function Access Patterns

Edge Functions are the primary place for server-side privileged workflows.

### User-Delegated Edge Functions

Use this pattern when a logged-in tenant user initiates the operation.

Required flow:

1. Receive the user's access token.
2. Validate the token with Supabase Auth.
3. Resolve the user id.
4. Resolve target tenant from the request.
5. Validate active tenant membership.
6. Evaluate the required profile permission.
7. Perform the operation using normal user-scoped access when possible.
8. Use service role only when the operation cannot be completed through normal RLS.
9. Audit privileged operations.

Examples:

- create automation
- update customer record through a workflow
- connect or refresh an integration
- execute a bulk import

### System-Initiated Edge Functions

Use this pattern for scheduled jobs and background automations.

Required flow:

1. Authenticate the scheduler or internal trigger.
2. Resolve the tenant scope from trusted stored configuration.
3. Load only active tenants and active integrations.
4. Execute using service role with tenant-scoped queries.
5. Record job results and failures per tenant.
6. Prevent one tenant's failure from exposing or corrupting another tenant's data.

Examples:

- scheduled reminders
- analytics aggregation
- calendar synchronization
- CRM synchronization

### Webhook Edge Functions

Use this pattern for external integrations such as messaging, calendar, CRM, or marketing systems.

Required flow:

1. Validate external signature, token, or shared secret.
2. Resolve tenant from trusted integration configuration, not unverified payload claims.
3. Confirm the integration is active for that tenant.
4. Normalize and validate payload data.
5. Perform tenant-scoped writes with service role only after validation.
6. Store raw payloads only when retention and privacy rules permit.
7. Audit rejected signatures and suspicious tenant mismatches.

Examples:

- HubSpot events
- ManyChat events
- WhatsApp events
- Google Calendar events
- Calendly events

### Platform Admin Edge Functions

Use this pattern for admin support and governance operations.

Required flow:

1. Authenticate the platform operator.
2. Verify platform admin capability from trusted authorization data.
3. Require target tenant and operation reason.
4. Apply least privilege for the requested support action.
5. Execute through service role only when required.
6. Write an immutable audit record.

## Integration Security

External integrations must be tenant-bound. Integration credentials, tokens, webhook mappings, and sync state belong to one tenant unless a future architecture document explicitly defines shared platform credentials.

Integration access rules:

1. Tenant users may manage integrations only when their profile grants integration management.
2. Integration callbacks must map to exactly one tenant before writing tenant data.
3. Integration records must not be visible across tenants.
4. Failed webhook validation must not reveal tenant configuration.
5. Token refresh jobs must operate tenant by tenant.
6. Integration logs must avoid exposing secrets.

## Governance Requirements

Before implementing database policies, the canonical schema and RBAC model must define:

- tenant table
- user membership table
- profile or role table
- permission mapping
- platform admin representation
- audit event table
- tenant-owned tables and their tenant identifiers
- module ownership boundaries
- integration credential storage rules
- soft-delete and retention rules

No tenant-owned table is complete until its RLS behavior is documented for read, insert, update, and delete.

## Negative Test Cases

The following cases must be covered before RLS is considered production-ready.

### Tenant Isolation

1. User from Tenant A cannot read customers from Tenant B.
2. User from Tenant A cannot update scheduling records from Tenant B.
3. User from Tenant A cannot delete CRM records from Tenant B.
4. User with memberships in Tenant A and Tenant B only sees rows for the selected authorized tenant.
5. Query filters using another tenant id return no inaccessible rows.
6. Counts, reports, and analytics do not include inaccessible tenant data.
7. Foreign key changes cannot link Tenant A rows to Tenant B rows.

### Membership

1. Anonymous user cannot access tenant-owned tables.
2. Authenticated user with no tenant membership cannot access tenant-owned tables.
3. Removed member cannot access former tenant data.
4. Suspended or inactive member cannot access tenant data.
5. User cannot create rows for a tenant where membership is missing.
6. User cannot regain access through stale client-side tenant context.

### RBAC

1. Read-only profile cannot create records.
2. Read-only profile cannot update records.
3. Read-only profile cannot delete records.
4. Non-admin tenant profile cannot manage team settings.
5. Non-integration-manager profile cannot connect or disconnect integrations.
6. Profile lacking export permission cannot export or bulk-read sensitive records.
7. Unknown profile or missing permission mapping is denied.

### Insert

1. Insert without tenant identifier is denied for tenant-owned tables.
2. Insert with another tenant's identifier is denied.
3. Insert referencing another tenant's customer is denied.
4. Insert assigning ownership to a user outside the tenant is denied.
5. Insert creating privileged configuration without management permission is denied.

### Update

1. Updating a row's tenant identifier is denied.
2. Updating a row to reference another tenant's record is denied.
3. Updating sensitive settings without management permission is denied.
4. Updating integration credentials without integration management permission is denied.
5. Updating a soft-deleted or archived row is denied unless lifecycle rules allow it.

### Delete

1. Delete without delete permission is denied.
2. Delete across tenant boundary is denied.
3. Delete that would cascade into another tenant is denied.
4. Hard delete of retention-protected records is denied.
5. Unauthorized delete does not reveal whether the target row exists.

### Service Role

1. Browser requests never receive service role credentials.
2. Service role Edge Function rejects missing user token for user-delegated operations.
3. Service role Edge Function rejects invalid tenant membership.
4. Service role webhook rejects invalid signatures.
5. Service role scheduled job cannot process inactive tenant integrations.
6. Service role operation writes audit events for privileged changes.

### Platform Admin

1. Tenant user cannot call platform admin paths.
2. Platform admin status cannot be granted through editable user metadata.
3. Platform admin cross-tenant read requires approved admin path.
4. Platform admin mutation requires explicit support or governance reason.
5. Platform admin operation writes audit events.

### Edge Functions

1. User-delegated function denies missing access token.
2. User-delegated function denies valid user without target tenant membership.
3. User-delegated function denies valid member without required permission.
4. Webhook function denies unverified external payload.
5. Webhook function denies payload that maps to no active tenant integration.
6. Scheduled function scopes work per tenant and does not mix tenant data.

## Implementation Acceptance Criteria

RLS implementation is acceptable only when:

1. Every tenant-owned table has RLS enabled.
2. Every tenant-owned table has documented read, insert, update, and delete behavior.
3. Policies enforce active membership and profile permissions.
4. Policies prevent tenant identifier mutation.
5. Cross-tenant foreign key and ownership changes are blocked.
6. Service role usage is isolated to trusted server-side code.
7. Platform admin access is separate from tenant roles and audited.
8. Edge Functions apply authorization before privileged operations.
9. Negative tests pass for tenant isolation, RBAC, writes, deletes, service role, platform admin, and integrations.
10. The strategy is reconciled with the canonical schema and RBAC model once those documents are added to the repository.
