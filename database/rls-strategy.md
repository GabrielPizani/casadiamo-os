# Casa Di Amo OS RLS Strategy

## Purpose

This document defines the complete Row Level Security strategy for Casa Di Amo OS.

Casa Di Amo OS is a white-label, multi-tenant SaaS platform for service businesses. The approved repository context identifies Supabase and PostgreSQL as the backend and database layer, and requires company-level data isolation, profile-based permissions, and scalable architecture for many users.

This document does not generate SQL. It defines the security architecture that future database policies, Edge Functions, integrations, and AI-assisted workflows must implement.

## Source Baseline and Documentation Constraint

The requested approved source documents were not present in the current repository checkout:

- `database-architecture.md`
- `erd.md`
- `schema.sql`
- `multi-tenancy-strategy.md`
- `rbac-model.md`
- `platform-billing-model.md`
- `compliance-lgpd.md`

The available repository documentation establishes:

- Casa Di Amo OS is a multi-tenant SaaS platform for service businesses.
- The platform centralizes CRM, scheduling, customers, marketing, automations, analytics, reports, team management, and settings.
- The architecture uses Supabase and PostgreSQL.
- The platform requires multi-company tenancy, profile-based permissions, isolation of data between companies, and scalability for many users.
- Future integrations include HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, Meta Ads, Claude, Cursor, and Lovable.
- Security, multi-tenancy, scalability, maintainability, and documentation-first development are core architecture priorities.

Because the canonical schema, ERD, RBAC, billing, and LGPD documents are absent, this strategy is intentionally schema-neutral. Before implementation, this document must be reconciled with those approved documents once they are added to the repository.

## Core RLS Principles

### Objective

Establish database-enforced tenant isolation and action authorization as the default security boundary for all tenant-owned data exposed through Supabase.

### Security Risks

- Frontend-only authorization can be bypassed.
- API-only filtering can accidentally leak cross-tenant records.
- Service role usage can bypass RLS entirely.
- Editable user metadata can create forged authorization claims.
- Missing policies can silently expose or block critical data paths.

### Mitigation Strategy

- Enable RLS for every tenant-owned table in exposed schemas.
- Treat company id as the primary tenant boundary for tenant-owned rows.
- Require active membership before evaluating permissions.
- Evaluate profile-based permissions after tenant membership is proven.
- Keep service role credentials server-side only.
- Use trusted server-side authorization data for platform admin and privileged claims.
- Deny access by default when tenant, membership, profile, permission, or context cannot be resolved.

## 1. Tenant Isolation Model

### Objective

Ensure each company can access only its own operational data across CRM, customers, scheduling, marketing, automations, reports, team management, settings, billing-related records, integrations, and AI-generated outputs.

### Security Risks

- A user from Company A reads or mutates Company B records.
- A user submits another company id in a request payload.
- Shared integration tables mix records from multiple companies.
- Analytics, reports, counts, or exports aggregate data across company boundaries.
- AI or automation workflows process tenant data without a tenant scope.

### Mitigation Strategy

- Every tenant-owned row must have exactly one authoritative company ownership field.
- RLS policies must compare row ownership to the authenticated user's active company memberships.
- Company ownership cannot be changed through normal tenant user updates.
- Cross-company foreign key relationships are prohibited for tenant-owned records.
- All reporting, analytics, exports, automation runs, integration syncs, and AI outputs must be company-scoped.
- Unauthorized cross-tenant access must return no accessible data and must not disclose whether the target record exists.

## 2. Authentication Flow

### Objective

Bind every tenant-facing database operation to a verified Supabase authenticated user before any membership or permission decision is made.

### Security Risks

- Anonymous users access tenant-owned tables.
- Expired or forged tokens are accepted by application code.
- Authorization decisions rely on untrusted client state.
- Stale claims grant permissions after membership changes.
- User-controlled metadata is treated as authoritative.

### Mitigation Strategy

- Require Supabase Auth for all tenant-owned table access.
- Treat authenticated user id as the starting identity for RLS checks.
- Resolve authorization from database-backed membership and permission records, not from client-provided tenant context alone.
- Avoid using editable user metadata for authorization decisions.
- Use short-lived sessions and server-side revalidation for sensitive operations.
- Deny tenant-owned access when the request has no authenticated user.

## 3. Membership Validation Flow

### Objective

Confirm that the authenticated user has an active relationship with the target company before allowing any company-scoped operation.

### Security Risks

- Removed users keep access to company data.
- Suspended users continue to operate through stale sessions.
- Users with multiple companies accidentally operate in the wrong company.
- Invite-pending users access data before activation.
- Membership records are interpreted inconsistently across modules.

### Mitigation Strategy

- Model membership as the authoritative relationship between user and company.
- Require active membership status for all tenant-owned reads and writes.
- Treat pending, invited, suspended, removed, archived, and unknown membership states as denied.
- Resolve the target company explicitly for every company-scoped operation.
- Re-check membership inside Edge Functions before privileged work.
- Keep membership validation centralized and consistent across modules.

## 4. Permission Evaluation Flow

### Objective

Apply profile-based authorization after company membership is validated, so users can perform only the actions allowed by their company role or profile.

### Security Risks

- A valid company member performs actions outside their role.
- Read-only users create, update, delete, export, or manage settings.
- Module-specific permissions are bypassed through generic database access.
- Missing permission mappings default to allow.
- Bulk actions or reports bypass normal per-module authorization.

### Mitigation Strategy

- Evaluate permissions in this order: authenticate user, validate active membership, resolve profile, resolve module permission, evaluate action, apply row-specific constraints.
- Define at least read, create, update, delete, manage settings, export, bulk operation, integration management, and AI operation permissions where applicable.
- Deny unknown profiles, missing permission mappings, and unsupported actions.
- Require explicit elevated permissions for settings, team management, integration credentials, billing-sensitive operations, exports, and AI workflows over tenant data.
- Keep platform admin permissions separate from company profile permissions.

## 5. Company Ownership Rules

### Objective

Preserve immutable company ownership for tenant-owned records and prevent cross-company relationships.

### Security Risks

- Users move a record into another company by changing its company owner field.
- A record in one company references a customer, schedule, automation, integration, or team member from another company.
- Ownership fields are assigned to users outside the company.
- Soft-deleted records are restored into the wrong company context.
- Imported data creates mixed-company relationships.

### Mitigation Strategy

- Tenant-owned records must be created with a company owner matching the user's active authorized company.
- Company ownership must be immutable after creation except through audited platform maintenance workflows.
- Foreign references between tenant-owned tables must stay within the same company.
- Assignee, owner, creator, and updater user references must point to users with valid company membership when the field is company-scoped.
- Imports, sync jobs, automations, and AI agents must validate company ownership before writing relationships.
- Any attempted company owner change through tenant-facing paths must be denied.

## 6. Platform Admin Rules

### Objective

Allow Casa Di Amo platform operators to perform approved governance, support, security, and operational tasks without weakening tenant isolation for normal users.

### Security Risks

- Tenant users gain platform admin capability.
- Platform admin status is stored in editable metadata.
- Operators access tenant data without business justification.
- Admin paths mutate tenant data without auditability.
- Platform admin access becomes a hidden bypass for RBAC.

### Mitigation Strategy

- Represent platform admin authorization separately from company memberships and company profiles.
- Store platform admin status only in trusted server-side authorization data.
- Restrict platform admin access to dedicated admin surfaces and approved Edge Functions.
- Require least-privilege platform capabilities, not one unlimited admin category.
- Require reason, ticket, incident, or governance context for sensitive tenant access.
- Audit platform admin reads and writes with operator id, company id, action, resource, timestamp, and reason.
- Never grant tenant business permissions implicitly through platform admin status.

## 7. Insert Policies Strategy

### Objective

Permit record creation only when the authenticated user is an active member of the target company and has create permission for the target module.

### Security Risks

- Users create records under another company.
- Inserts omit company ownership and become globally visible or orphaned.
- Inserts reference records from another company.
- Users create privileged settings, integrations, automations, or billing-impacting records without permission.
- Webhooks create records before tenant mapping is verified.

### Mitigation Strategy

- Require authenticated identity for tenant-user inserts.
- Require active company membership for the target company.
- Require explicit create permission for the relevant module.
- Require inserted company owner to match the authorized company context.
- Validate all tenant-owned references belong to the same company.
- Require elevated permissions for settings, team management, integration configuration, billing-impacting records, and AI workflow setup.
- Require webhook and service-role inserts to resolve company context from trusted server-side configuration before writing.

## 8. Update Policies Strategy

### Objective

Permit record changes only when the existing row belongs to an authorized company, the proposed row remains in that company, and the user's profile allows the requested update.

### Security Risks

- Users update another company's records.
- Users move records across companies.
- Users change sensitive fields without elevated permissions.
- Updates create cross-company references.
- Bulk updates bypass per-row authorization.
- Stale membership allows continued mutation.

### Mitigation Strategy

- Evaluate authorization against both existing row state and proposed row state.
- Require active company membership for the row's company.
- Require explicit update permission for the relevant module.
- Deny changes to company ownership through tenant-facing paths.
- Validate changed references remain within the same company.
- Require elevated permissions for lifecycle state, settings, team roles, integration credentials, billing-sensitive fields, exports, and AI workflow configuration.
- Apply the same checks to single-record and bulk update paths.

## 9. Delete Policies Strategy

### Objective

Permit deletion only when the user is authorized for the row's company, has delete permission for the module, and deletion does not violate retention, audit, billing, integration, or LGPD obligations.

### Security Risks

- Users delete another company's records.
- Users without delete permission remove operational or customer data.
- Cascades delete records across companies.
- Hard deletes remove data needed for audit, billing, support, or compliance.
- Unauthorized deletes reveal whether inaccessible records exist.

### Mitigation Strategy

- Require active company membership and module-specific delete permission.
- Prefer soft delete for customer, CRM, scheduling, automation, analytics, integration, and audit-adjacent records.
- Restrict hard delete to approved retention and LGPD workflows.
- Prevent cascade paths from crossing company boundaries.
- Ensure unauthorized delete attempts behave as no accessible row affected.
- Audit sensitive deletes and all platform-admin or service-role deletes.

## 10. Service Role Exceptions

### Objective

Constrain Supabase service role usage to trusted server-side workflows that require RLS bypass while preserving equivalent tenant, permission, and audit controls in application logic.

### Security Risks

- Service role key is exposed to frontend or public clients.
- Service role operations bypass tenant isolation.
- Edge Functions use service role without validating the initiating user.
- Background jobs process all tenants without scoping.
- Integration syncs overwrite data in the wrong company.

### Mitigation Strategy

- Never expose service role credentials to browsers, Lovable frontend code, mobile clients, or public automation clients.
- Permit service role only in trusted Edge Functions, scheduled jobs, webhook handlers, admin maintenance, and controlled data repair workflows.
- Validate the initiating user, platform operator, scheduler, or external system before privileged work.
- Resolve company scope server-side from trusted configuration or validated membership.
- Limit privileged operations to the minimum company, module, records, and duration required.
- Apply equivalent membership, permission, platform admin, and integration checks in server code.
- Audit privileged reads and writes where sensitive, cross-tenant, or compliance-relevant.

## 11. Edge Function Access Model

### Objective

Define secure patterns for Edge Functions that perform tenant-scoped business logic, privileged operations, integrations, scheduled jobs, platform administration, or AI workflows.

### Security Risks

- Edge Functions trust client-provided company ids without validation.
- Functions use service role for user-delegated operations without membership checks.
- Scheduled jobs mix data from multiple companies.
- Admin functions are callable by tenant users.
- Function logs expose customer data, credentials, or integration payloads.

### Mitigation Strategy

- User-delegated functions must validate the user's token, active company membership, profile permission, requested action, and company ownership before work starts.
- System-initiated functions must authenticate the scheduler or internal trigger and process data company by company.
- Platform-admin functions must verify trusted platform authorization and require operation reason.
- Functions should use user-scoped access when possible and service role only when necessary.
- Function logs must avoid secrets, tokens, and unnecessary personal data.
- Privileged function outcomes must be auditable, especially for settings, integrations, billing-sensitive actions, AI outputs, and data exports.

## 12. Webhook Access Model

### Objective

Allow external systems such as HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, and Meta Ads to deliver events without giving them direct tenant database access.

### Security Risks

- Forged webhook payloads create or modify tenant data.
- Payload-provided company ids are trusted before verification.
- A webhook for one company writes into another company.
- Replay attacks duplicate sensitive actions.
- Raw payload storage creates unnecessary LGPD exposure.

### Mitigation Strategy

- Validate webhook signature, token, shared secret, or provider-specific authenticity before processing.
- Resolve company context from trusted integration configuration, not from unverified payload claims alone.
- Confirm the integration is active and belongs to the resolved company.
- Normalize, validate, and constrain payload data before tenant writes.
- Use replay protection where provider capabilities allow it.
- Store raw payloads only when required for diagnostics, audit, or compliance, and apply retention controls.
- Log rejected signatures, tenant mismatches, and suspicious payloads without exposing secrets.

## 13. AI Agent Access Model

### Objective

Permit AI-assisted workflows to support Casa Di Amo operations while ensuring AI agents cannot bypass tenant isolation, RBAC, LGPD constraints, or platform governance.

### Security Risks

- AI agents retrieve or generate content using data from the wrong company.
- Prompts include personal data without need or retention controls.
- AI-generated actions modify tenant data without user authorization.
- Agent tools use service role credentials too broadly.
- Cross-tenant context leaks through embeddings, logs, memory, or prompt history.

### Mitigation Strategy

- Treat AI agents as delegated actors, not independent authorities.
- Require every AI request to carry an authenticated user, platform admin, or approved system context.
- Resolve company scope before retrieval, generation, tool use, or write-back.
- Require explicit profile permission for AI-assisted actions that read sensitive data, create records, update records, export data, or trigger automations.
- Keep AI memory, generated content, embeddings, and tool results company-scoped.
- Use service role for AI tools only inside trusted server-side execution with equivalent authorization checks.
- Minimize personal data in prompts and logs, and apply LGPD retention, deletion, and audit requirements.
- Require human confirmation for destructive, billing-impacting, integration-impacting, or broad automation actions unless future approved documentation defines safe autonomous patterns.

## 14. Negative Security Test Cases

### Objective

Define the minimum adversarial tests required before the RLS strategy is considered production-ready.

### Security Risks

- Happy-path testing misses cross-tenant leaks.
- Missing update checks allow ownership changes.
- Service role paths pass tests while bypassing real authorization.
- Webhooks, AI agents, exports, and background jobs remain untested.
- Unauthorized operations reveal record existence through inconsistent behavior.

### Mitigation Strategy

The following negative tests must fail safely:

#### Tenant Isolation

- Company A user cannot read Company B customers, schedules, CRM records, automations, reports, settings, integrations, or AI outputs.
- Company A user cannot filter, count, export, or report on Company B data.
- Multi-company user sees only records for the active authorized company context.
- Cross-company foreign references are rejected.
- Unauthorized access does not reveal whether inaccessible rows exist.

#### Authentication and Membership

- Anonymous caller cannot access tenant-owned data.
- Authenticated user with no membership cannot access tenant-owned data.
- Pending, suspended, removed, archived, or unknown membership states are denied.
- Stale client-side company context does not restore access.

#### RBAC

- Read-only profile cannot create, update, delete, export, manage settings, manage integrations, or run privileged AI actions.
- Non-admin company profile cannot manage team permissions.
- Missing permission mapping is denied.
- Unknown profile is denied.

#### Inserts

- Insert without company owner is denied.
- Insert with another company owner is denied.
- Insert referencing another company's record is denied.
- Insert assigning ownership to a user outside the company is denied.
- Insert creating settings, integration, billing-sensitive, or AI workflow records without elevated permission is denied.

#### Updates

- Update of company owner is denied.
- Update creating cross-company references is denied.
- Update of sensitive settings without permission is denied.
- Bulk update cannot bypass per-row authorization.
- Update after membership removal is denied.

#### Deletes

- Delete without delete permission is denied.
- Cross-company delete is denied.
- Delete that cascades across companies is denied.
- Hard delete of retention-protected data is denied.
- Unauthorized delete does not reveal row existence.

#### Service Role and Edge Functions

- Browser never receives service role credentials.
- User-delegated function rejects missing token.
- User-delegated function rejects valid user without company membership.
- User-delegated function rejects valid member without required permission.
- Scheduled job scopes work per company and cannot mix company data.
- Platform admin function rejects tenant user callers.

#### Webhooks and Integrations

- Invalid webhook signature is denied.
- Payload mapping to no active integration is denied.
- Payload attempting tenant mismatch is denied.
- Replay payload is denied or safely idempotent.
- Integration logs do not expose credentials or unnecessary personal data.

#### AI Agents

- AI agent cannot retrieve another company's data.
- AI agent cannot act without authenticated, admin, or approved system context.
- AI agent cannot write data without matching profile permission.
- AI agent cannot perform destructive, billing-impacting, or integration-impacting action without required authorization and confirmation.
- AI logs and memory do not mix company data.

## 15. Audit Requirements

### Objective

Provide traceability for sensitive, privileged, cross-system, compliance-relevant, and tenant-impacting operations.

### Security Risks

- Unauthorized access cannot be investigated.
- Platform admin activity is invisible.
- Service role and Edge Function actions lack actor attribution.
- Integration and AI activity cannot be tied to company, user, or source system.
- LGPD-related access, deletion, correction, or export activity is not provable.

### Mitigation Strategy

Audit records must capture, where applicable:

- actor type: tenant user, platform admin, service role workflow, webhook provider, scheduler, or AI agent
- actor id or external system id
- company id
- target resource type and resource id
- action performed
- permission or admin capability used
- request source or function name
- integration provider when applicable
- AI agent or model workflow when applicable
- reason, ticket, or governance context for platform admin access
- outcome: allowed, denied, failed, or partially completed
- timestamp
- relevant correlation id

Audit coverage is required for:

- platform admin access
- service role operations
- membership and permission changes
- settings changes
- integration connection, token refresh, webhook processing, and disconnect events
- billing-sensitive operations
- data exports and bulk reads
- destructive operations and hard deletes
- LGPD access, correction, portability, anonymization, and deletion workflows
- AI retrieval, generated outputs, tool calls, and write-back actions involving tenant data

Audit logs must be tenant-scoped where tenant users can view them, platform-scoped where operators need governance visibility, protected from tenant-user tampering, and retained according to the approved compliance and billing model once those documents are available.

## Implementation Readiness Criteria

RLS implementation may begin only after the canonical database architecture, ERD, schema, multi-tenancy strategy, RBAC model, platform billing model, and LGPD compliance documentation are present and reconciled with this strategy.

Before production, the implementation must prove:

1. Every tenant-owned table has RLS enabled.
2. Every tenant-owned table has read, insert, update, and delete behavior mapped to company membership and profile permissions.
3. Company ownership cannot be changed through tenant-facing paths.
4. Cross-company references are blocked.
5. Platform admin access is separated from tenant roles and audited.
6. Service role access is limited to trusted server-side workflows.
7. Edge Functions, webhooks, integrations, AI agents, exports, and scheduled jobs enforce company scope.
8. LGPD-sensitive access, deletion, correction, export, retention, and audit requirements are implemented according to approved compliance documentation.
9. Negative security tests pass across tenant isolation, authentication, membership, RBAC, writes, deletes, privileged paths, webhooks, integrations, AI agents, and auditability.
