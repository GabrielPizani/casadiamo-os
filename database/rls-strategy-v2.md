# Casa Di Amo OS RLS Strategy V2

## Purpose

This document re-evaluates `database/rls-strategy.md` against the approved architecture documents now present in the repository and defines the revised Row Level Security strategy for Casa Di Amo OS.

This document does not generate SQL. It describes the required RLS architecture, table classes, authorization flows, negative tests, and implementation readiness criteria.

## Source Documents Reviewed

- `database/database-architecture.md`
- `database/erd.md`
- `database/schema.sql`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`
- `docs/platform-billing-model.md`
- `docs/compliance-lgpd.md`
- `database/rls-strategy.md`

## Executive Assessment

The existing `rls-strategy.md` is directionally correct but was written before the approved schema, ERD, billing model, RBAC model, and LGPD model were available. It establishes useful principles, but it is too schema-neutral for the current architecture.

The approved documents now require a more precise strategy:

- Casa Di Amo OS uses shared-database, shared-schema tenancy on Supabase and PostgreSQL.
- The tenant root is `companies`.
- User access is granted through `user_profiles`, `company_members`, company-scoped `roles`, `permissions`, and `role_permissions`.
- Platform administration is separate from company membership through `platform_admins`, `platform_roles`, `platform_permissions`, and platform audit logs.
- Most tenant-owned tables include `company_id`, but some tables derive tenant ownership through parent tables.
- Billing entitlements are runtime feature gates and must not bypass tenant isolation.
- LGPD workflows for consent, export, deletion, retention, sensitive data, and audit must remain tenant-scoped.
- Integrations, webhooks, files, automation events, reliability queues, and AI governance tables require explicit cross-tenant protections.

## Review Findings

### 1. Missing Sections

The existing strategy is missing or under-specifies these sections now required by the approved architecture:

1. **Schema ownership matrix**: no mapping of direct company-owned, derived company-owned, platform-owned, and global user/profile tables.
2. **Derived tenant table rules**: no explicit treatment of `subscription_items`, `tenant_invoices`, `api_keys`, `job_attempts`, and other tables whose tenant boundary is inherited from a parent.
3. **Platform-owned catalog rules**: no clear strategy for `plans`, `features`, `plan_features`, platform roles, and platform permissions.
4. **Billing entitlement gates**: no strategy for `company_feature_entitlements`, `usage_limits`, `usage_counters`, `usage_records`, subscription states, trials, cancellation, non-payment, and owner billing access.
5. **Tenant lifecycle rules**: no explicit effect for active, suspended, canceled, paused, expired, archived, or deleted company states.
6. **API client and service account rules**: no table-specific model for `api_clients`, `api_keys`, and `service_accounts`.
7. **File and polymorphic reference controls**: no explicit strategy for `files`, `file_links`, `audit_logs`, automation events, AI input references, and other entity type/entity id patterns.
8. **Storage-adjacent controls**: no separation between file metadata access and Supabase Storage object access.
9. **LGPD workflows**: no concrete model for `customer_consents`, `consent_audit_logs`, `data_subject_requests`, `data_exports`, `data_deletion_jobs`, and `retention_policies`.
10. **AI governance tables**: no table-specific model for `ai_prompts`, `ai_runs`, `ai_outputs`, `ai_usage_records`, and `ai_feedback`.
11. **Webhook secret handling**: no strong private access model for `webhook_signing_secrets` and raw webhook payloads.
12. **Reliability and worker queues**: no model for `job_queue`, `job_attempts`, `idempotency_keys`, `outbox_events`, and `dead_letter_events`.
13. **RBAC role matrix alignment**: no mapping to Platform Admin, Company Owner, Manager, Employee, and Viewer restrictions.
14. **Sensitive permission rules**: no explicit owner-only or platform-only controls for settings, member removal, role assignment, integration management, refunds, exports, compliance, audit, plan management, tenant suspension, impersonation, and billing overrides.
15. **Audit append-only behavior**: no clear rule that tenant users cannot mutate audit records after creation.

### 2. Incorrect Assumptions

The existing strategy contains these assumptions that must be corrected:

1. **Assumption: the schema was unavailable.** The schema is now available and contains concrete tables, ownership columns, parent relationships, and audit/compliance structures.
2. **Assumption: every tenant-owned row has direct tenant ownership.** The schema includes derived-tenant tables where ownership must be inherited through parent rows.
3. **Assumption: soft delete is generally preferred.** The schema does not consistently define soft-delete columns; deletion strategy must be governed by retention, LGPD, financial records, audit records, and module-specific lifecycle fields.
4. **Assumption: platform admin is generic trusted data.** The schema has explicit platform admin tables and platform role/permission structures.
5. **Assumption: RBAC can be described only as generic module actions.** The approved RBAC model defines concrete roles and sensitive permission classes.
6. **Assumption: billing is only another tenant module.** The billing model defines platform-owned plans/features, tenant-owned subscriptions and entitlements, and provider-driven webhook state.
7. **Assumption: AI access is only a delegated workflow concern.** The ERD and schema contain AI governance entities that need table-level tenant and retention rules.
8. **Assumption: webhook payloads can be treated like normal integration records.** The approved docs require signature validation, deduplication, secure secret handling, and minimized payload storage.

### 3. Security Gaps

The current strategy leaves the following security gaps:

1. No table class taxonomy for direct tenant, derived tenant, platform, self-profile, and private worker tables.
2. No explicit denial model for suspended companies or inactive memberships.
3. No derived-tenant validation for parent-linked rows.
4. No RBAC-sensitive handling for owner-only and platform-only permissions.
5. No billing entitlement access rules for feature-gated actions.
6. No separate RLS posture for secret-bearing metadata such as API keys, webhook secret hashes, OAuth grants, and integration credentials metadata.
7. No append-only model for audit and consent history.
8. No LGPD export/deletion retention guardrails.
9. No polymorphic reference enforcement requirement.
10. No worker-queue access boundary for background jobs.
11. No explicit storage metadata versus storage object boundary.
12. No service-role testing model for worker, webhook, billing, AI, and compliance jobs.
13. No model for platform support impersonation or support access audit.

### 4. Multi-Tenant Risks

The approved architecture identifies these multi-tenant risk areas that v2 must control:

1. Appointments linked to services, staff, resources, or customers from another company.
2. CRM deals linked to another company's customers or pipeline stages.
3. Marketing deliveries targeting customers from another company.
4. Payments, refunds, invoices, and provider mappings crossing company boundaries.
5. Files linked to records from another company.
6. Webhooks mapped to the wrong integration connection.
7. AI runs using context from another company.
8. Audit, event, and polymorphic references pointing to a different tenant.
9. Derived tables without direct `company_id` being exposed through parent joins that are not tenant-safe.
10. Platform support access occurring without justification and audit.
11. Cross-company customer deduplication or matching being introduced by default.
12. Company suspension preserving records but failing to block operational access.

### 5. RBAC Inconsistencies

The current strategy is not wrong in principle, but it is incomplete against the approved RBAC model:

1. It does not distinguish Platform Admin from Company Owner, Manager, Employee, and Viewer at the policy-strategy level.
2. It treats module actions generically instead of mapping owner-only, platform-only, and approval-recommended permissions.
3. It does not reflect that Company Owner has full tenant control but still no platform administration.
4. It does not reflect that Manager can manage operations but lacks ownership-level destructive controls.
5. It does not reflect that Employee access is assigned and operational, not full module-wide management.
6. It does not reflect that Viewer is read-only and cannot access audit logs, compliance workflows, or platform administration.
7. It does not separate finance permissions from general staff permissions.
8. It does not map billing access where Company Owner can manage billing, Manager has limited billing visibility, and Platform Admin manages platform billing support and overrides.
9. It does not require audit for role assignment, member suspension/removal, company settings changes, integration changes, API key changes, payment refund, invoice adjustment, export, compliance, support access, and tenant impersonation.

## RLS Strategy V2

## 1. Tenant Isolation Model

### Objective

Enforce company-scoped isolation for all tenant operations in a shared Supabase PostgreSQL database.

### Strategy

The tenant root is `companies`. Tenant access is granted through `company_members`. Company roles and permissions are evaluated after active membership is confirmed.

Every table must be assigned to one of these RLS ownership classes:

| Class | Description | Examples | RLS posture |
| --- | --- | --- | --- |
| Platform-private | Platform administration and global authorization tables | `platform_roles`, `platform_permissions`, `platform_role_permissions`, `platform_admins`, `platform_admin_audit_logs` | Hidden from tenant users; platform-admin-only through approved admin paths |
| Platform catalog | Global billing catalog and feature definitions | `plans`, `features`, `plan_features` | Read limited to needed active catalog data; writes platform-admin-only |
| User-self | Auth-linked profile and session records | `user_profiles`, `user_sessions_audit` | User can read limited self data; admin/support access audited |
| Direct tenant | Tables with authoritative `company_id` | Most company, customer, service, appointment, CRM, marketing, payment, report, integration, compliance, reliability, and AI tables | Active membership and permission checks against row `company_id` |
| Derived tenant | Tables without direct `company_id` that inherit tenant from a parent | `subscription_items`, `tenant_invoices`, `api_keys`, `job_attempts`, role permission mappings through `roles` | Access only through tenant-safe parent ownership validation |
| Polymorphic tenant | Tables with entity type/entity id references | `file_links`, `audit_logs`, events, AI inputs, automation triggers | Validate both row `company_id` and referenced entity tenant |
| Worker-private | Queue, webhook, and secret-like operational tables | `webhook_signing_secrets`, `job_attempts`, some queue processing states | Service-role or platform-worker only, with tenant-scoped processing |

### Security Risks

- Direct company id checks miss derived tables.
- Platform-owned catalog data is overexposed.
- Tenant users reach platform administration tables.
- Polymorphic references point across tenants.
- Suspended companies continue normal operations.

### Mitigation Strategy

- Require an explicit RLS class for every table before implementation.
- Apply direct company membership checks only to direct tenant tables.
- Apply parent-derived checks to derived tenant tables.
- Keep platform-private and worker-private tables unavailable to normal tenant clients.
- Require active `companies.status` for operational access.
- Preserve limited owner/platform access for billing, export, and compliance after suspension or cancellation where the billing and LGPD models require it.

## 2. Authentication and Profile Flow

### Objective

Ensure every user-facing database operation starts from Supabase Auth and a valid `user_profiles` record.

### Strategy

The authorization chain is:

1. Supabase authenticated user.
2. Matching `user_profiles.auth_user_id`.
3. Active user profile status.
4. Active company membership for tenant-scoped access.
5. Active company status for operational access.
6. Active company role and permission assignment.
7. Row ownership and module-specific constraints.

### Security Risks

- Anonymous access to public schema tables.
- Authorization based on editable metadata.
- Stale tokens after membership changes.
- Missing user profile causing inconsistent access behavior.

### Mitigation Strategy

- Deny tenant-owned access when no authenticated user exists.
- Treat `user_profiles` as the application identity bridge.
- Do not rely on editable user metadata for authorization.
- Re-check database membership and permission state for sensitive operations.
- Ensure user profile deactivation blocks tenant access even if the Supabase session remains valid.

## 3. Membership Validation Flow

### Objective

Grant tenant access only to users with active company membership.

### Strategy

A valid tenant member must satisfy:

- `company_members.company_id` matches the target company.
- `company_members.user_profile_id` matches the authenticated user's profile.
- `company_members.status` is active.
- `company_members.role_id` points to an active company role.
- the target company is in a state that allows the requested operation.

Pending invitations are not memberships. Suspended, removed, inactive, archived, or unknown membership states grant no tenant data access.

### Security Risks

- Removed users retain access through stale sessions.
- Invite-pending users access data early.
- Users with multiple memberships operate in the wrong company.
- Suspended tenants continue to run jobs, integrations, or automations.

### Mitigation Strategy

- Validate membership inside RLS and again inside privileged Edge Functions.
- Deny missing or inactive membership states by default.
- Require explicit company context for every tenant-scoped operation.
- Block operational access for suspended companies while preserving approved billing, export, compliance, and support access.
- Add negative tests for membership removal, suspension, multi-company switching, and stale tenant context.

## 4. Permission Evaluation Flow

### Objective

Align RLS with the approved RBAC model and enforce module/action permissions after membership validation.

### Strategy

RLS and server-side authorization must evaluate:

1. authenticated user
2. active user profile
3. active company
4. active company membership
5. active role assignment
6. permission key
7. module/action requested
8. row company ownership
9. record-specific constraints
10. billing entitlement when a feature gate applies
11. LGPD, retention, audit, or platform-admin constraints when applicable

Company roles are company-scoped. A user may have different roles in different companies. Platform Admin is not a company role.

### Security Risks

- A valid tenant member performs actions outside their role.
- Role assignments from one company are reused in another company.
- Missing permission mappings default to allow.
- Sensitive actions are treated as ordinary writes.
- Billing entitlements bypass or replace RBAC.

### Mitigation Strategy

- Deny unknown roles, inactive roles, missing permissions, and unsupported actions.
- Require explicit permission keys for create, update, delete, manage, export, refund, compliance, integration, audit, impersonation, and AI actions.
- Require owner-only controls for settings configuration, member removal, role assignment, integration management, refunds, report export, compliance management, and audit reads unless approved docs grant a narrower role.
- Require platform-only controls for plan management, feature management, tenant suspension, billing override, platform audit access, tenant impersonation, and infrastructure operations.
- Treat billing entitlements as an additional feature gate, not a substitute for membership and RBAC.

## 5. Company Ownership Rules

### Objective

Prevent cross-company data relationships and unauthorized company ownership changes.

### Strategy

Direct tenant rows must keep their original company boundary. Derived tenant rows must inherit company ownership from a tenant-safe parent. Polymorphic references must include or derive company ownership and must validate the referenced entity belongs to the same company.

High-risk relationship classes:

- appointment to service, staff, resource, customer, reminder, waitlist, booking, and calendar mapping
- CRM deal to customer, pipeline, stage, activity, and external mapping
- marketing audience, campaign, message, delivery, customer, conversation, and message record
- payment customer, invoice, invoice item, payment, refund, tenant invoice, and subscription
- file metadata and file links
- automation workflow, trigger, step, event, run, and run step
- integration connection, OAuth grant, sync job, webhook secret, and webhook event
- AI prompt, run, output, feedback, usage, and input entity reference
- compliance request, export, deletion job, retention policy, and consent audit

### Security Risks

- A row is moved into another company through an update.
- A child row points to a parent row from another company.
- A polymorphic reference targets another tenant.
- Imports, webhooks, or AI workflows create mixed-tenant relationships.

### Mitigation Strategy

- Treat company ownership as immutable through tenant-facing paths.
- Validate parent and child company ownership on every write.
- Require tenant-safe parent validation for derived tables.
- Require explicit cross-reference checks for polymorphic references.
- Reject cross-company relationships even when the actor belongs to both companies unless the operation is explicitly scoped to one company and all referenced rows match that company.

## 6. Table Class Policy Strategy

### Objective

Define the RLS posture for each schema class before SQL policies are written.

### Strategy

#### Platform-private tables

`platform_roles`, `platform_permissions`, `platform_role_permissions`, `platform_admins`, and `platform_admin_audit_logs` are not tenant data. Tenant users must not read or write them. Platform admin reads and writes must go through approved admin paths and audit-sensitive operations.

#### Platform catalog tables

`plans`, `features`, and `plan_features` are platform-owned. Tenant users may need limited read access to active public catalog information. All writes are platform-admin-only.

#### User profile tables

`user_profiles` supports self-profile access and company membership resolution. Tenant users may read limited profile data for themselves and company teammates only when their role allows team visibility.

#### Direct tenant tables

Tables with `company_id` use active company membership and RBAC checks. Write operations must validate row ownership and module permissions.

#### Derived tenant tables

`subscription_items`, `tenant_invoices`, `api_keys`, `job_attempts`, and `role_permissions` must derive tenant ownership from their parent rows. They must not be exposed through standalone policies that skip parent ownership.

#### Secret-bearing and credential-adjacent tables

`api_keys`, `oauth_grants`, `webhook_signing_secrets`, integration metadata, and service account records require stricter access than ordinary tenant records. Tenant users should see only safe metadata, never hashes, secrets, tokens, or raw credentials.

#### Audit and history tables

`audit_logs`, `platform_admin_audit_logs`, `consent_audit_logs`, `user_sessions_audit`, status history, usage records, and webhook event history should be append-only from normal application paths.

### Security Risks

- A single generic policy is applied to every table.
- Derived tables leak records through missing parent validation.
- Secret hashes or payloads become visible to tenant users.
- Audit history is editable by tenant users.

### Mitigation Strategy

- Maintain a table-to-policy-class inventory as part of RLS implementation.
- Use stricter policies for secret-bearing and audit/history tables.
- Prefer service-role worker paths for queue internals, webhook processing, and credential rotation.
- Expose only safe views or redacted API responses for secret metadata, and ensure views do not bypass RLS.

## 7. Platform Admin Rules

### Objective

Separate platform governance from company membership and audit support access.

### Strategy

Platform Admin access is represented by `platform_admins`, `platform_roles`, `platform_permissions`, and `platform_role_permissions`. It must not be inferred from company roles.

Platform Admins may perform platform operations, tenant lifecycle administration, support access, billing support, security administration, and approved impersonation only through dedicated admin workflows.

### Security Risks

- Company Owner gains platform administration.
- Platform admin access bypasses audit.
- Support personnel inspect tenant personal data without a reason.
- Platform admin policies are accidentally combined with company membership policies.

### Mitigation Strategy

- Keep platform admin policies separate from tenant membership policies.
- Require active platform admin status and platform permission keys.
- Require reason, ticket, incident, or governance context for tenant support access.
- Audit support access, impersonation, billing override, tenant suspension, role changes, and sensitive reads.
- Never expose service-role credentials to platform admin clients.

## 8. Billing and Entitlement RLS Strategy

### Objective

Protect platform billing, tenant billing, entitlements, and usage records without allowing billing state to bypass tenant isolation.

### Strategy

Billing has three access zones:

1. Platform-owned catalog and configuration: `plans`, `features`, `plan_features`.
2. Tenant-owned billing state: `billing_accounts`, `company_subscriptions`, `company_feature_entitlements`, `usage_limits`, `usage_counters`, `usage_records`, `tenant_invoices`.
3. Tenant business payments: `payment_customers`, `subscriptions`, `invoices`, `invoice_items`, `payments`, `refunds`.

Feature entitlements are runtime feature gates. They determine whether a company may use a product capability, but they do not replace RLS, membership, or RBAC.

Company Owner may manage billing. Manager may have limited billing visibility according to the billing model. Platform Admin may perform billing support, overrides, reconciliation, and provider sync through audited workflows.

### Security Risks

- Past-due or canceled billing states delete or expose tenant data incorrectly.
- Billing provider webhooks mutate the wrong company.
- Managers or employees access billing settings beyond their role.
- Entitlement failure grants paid features accidentally.
- Tenant invoices derive company ownership through billing account or subscription and leak if not parent-scoped.

### Mitigation Strategy

- Scope all tenant billing records to company membership or parent-derived company ownership.
- Gate feature use through entitlements after RLS and RBAC succeed.
- Keep owner access to billing, export, and compliance during cancellation or non-payment states as required by billing docs.
- Process provider webhooks with signature validation, idempotency, company resolution, and audit.
- Restrict billing overrides and plan/feature management to platform admin capabilities.
- Prevent automatic data deletion on cancellation; use retention and compliance workflows.

## 9. LGPD and Privacy RLS Strategy

### Objective

Protect personal data and compliance workflows while supporting tenant-scoped consent, export, deletion, retention, and audit requirements.

### Strategy

LGPD-sensitive tables include:

- `customers`, `customer_addresses`, `customer_notes`, and customer-related operational records
- `customer_consents` and `consent_audit_logs`
- `data_subject_requests`, `data_exports`, and `data_deletion_jobs`
- `retention_policies`
- files, messages, appointment notes, CRM activities, AI prompts, AI outputs, webhook payloads, and payment records

Company Owner may manage compliance workflows. Manager access is limited by approved role permissions. Platform Admin access to tenant personal data must be justified and audited.

### Security Risks

- Consent from one company is reused in another company.
- Data export includes cross-tenant records.
- Deletion bypasses legal hold, audit, financial retention, or consent proof requirements.
- Sensitive personal data appears in logs, webhooks, AI prompts, or files without minimization.
- Tenant users mutate audit or consent history.

### Mitigation Strategy

- Scope all LGPD workflows by company.
- Require compliance permission for export, deletion, anonymization, retention policy management, and sensitive data review.
- Preserve consent proof even after marketing revocation.
- Keep audit, consent audit, financial, and legal-hold records protected from casual hard delete.
- Run large exports and deletion jobs asynchronously through tenant-scoped service-role workers.
- Ensure exports include only records owned by the requesting company.
- Minimize personal data in webhook payloads, AI prompts, logs, and operational metadata.

## 10. Insert Strategy

### Objective

Allow creation only when the actor has company membership, module permission, and feature entitlement where applicable.

### Strategy

Tenant insert checks must validate:

- authenticated user and active profile
- active company membership
- active company status for operational modules
- role permission for the target module and action
- feature entitlement for gated product capabilities
- row company ownership
- same-company parent references
- same-company polymorphic references when applicable
- LGPD consent or purpose limitation when creating marketing or sensitive records

Service-role inserts must perform equivalent checks in server code before writing.

### Security Risks

- User inserts into another company.
- Derived rows are inserted under a parent from another company.
- Marketing records are created without consent or entitlement.
- AI, automation, or webhook inserts skip RBAC.
- Secret-bearing records expose sensitive fields.

### Mitigation Strategy

- Deny tenant inserts unless company ownership and permissions are proven.
- Require parent ownership validation for derived rows.
- Require owner-only or elevated permissions for settings, team, role, integration, billing, compliance, export, AI workflow, and automation publication records.
- Use service-role Edge Functions for webhook, billing provider, worker, and compliance inserts where direct client access is unsafe.
- Audit sensitive inserts.

## 11. Update Strategy

### Objective

Allow changes only when the existing row and proposed state remain within the authorized company and permission boundary.

### Strategy

Tenant update checks must validate:

- visibility of the existing row through tenant membership
- permission to perform the requested update
- unchanged company ownership
- same-company parent and foreign references after the change
- sensitive field permission
- lifecycle transition permission
- feature entitlement for gated state changes
- retention, legal hold, billing, and LGPD constraints

### Security Risks

- Company ownership is changed through an update.
- Parent references move a child row across tenants.
- Sensitive fields are changed by non-owner roles.
- Subscription, entitlement, or usage state is modified outside platform billing workflows.
- Compliance or audit records are tampered with.

### Mitigation Strategy

- Deny company ownership mutation from tenant-facing paths.
- Validate old and new row states.
- Require elevated permissions for role assignment, settings, integration credentials, refunds, invoice adjustments, exports, compliance, audit access, AI workflow changes, and automation publication.
- Make audit and history rows immutable except through approved system workflows.
- Require platform-admin workflows for plan, feature, entitlement override, tenant suspension, and platform billing changes.

## 12. Delete Strategy

### Objective

Prevent unauthorized destructive actions and align deletions with billing, audit, retention, and LGPD requirements.

### Strategy

Delete access must be restricted by company membership, RBAC permission, data class, retention policy, legal hold, and audit needs.

Hard delete is not the default for:

- audit logs
- platform admin audit logs
- consent audit logs
- financial records
- provider reconciliation records
- billing records
- data subject request history
- webhook processing history needed for idempotency
- AI usage records needed for billing or audit

### Security Risks

- Cross-tenant deletes.
- Deletes bypass financial or compliance retention.
- Cascades remove related records in another company.
- Unauthorized deletes reveal inaccessible row existence.
- Service-role deletion jobs remove too much data.

### Mitigation Strategy

- Require explicit delete or compliance permission.
- Prefer status transitions, archival, anonymization, or retention jobs when the schema supports them.
- Use controlled LGPD deletion jobs for data subject deletion and anonymization.
- Ensure cascades remain tenant-safe.
- Keep owner access to export and compliance actions during cancellation as required.
- Audit destructive and compliance-related deletes.

## 13. Service Role and Edge Function Model

### Objective

Constrain RLS bypass to trusted backend operations that enforce equivalent tenant, RBAC, billing, and LGPD controls.

### Strategy

Allowed service-role contexts:

- webhook processing
- integration sync jobs
- background workers
- billing provider sync
- usage counter updates
- scheduled reporting rollups
- data migrations
- tenant lifecycle jobs
- LGPD export and deletion jobs
- AI workflow execution where direct user-scoped access is insufficient
- platform admin maintenance through audited functions

Service-role workflows must validate actor or trigger identity, resolve company context, verify permission or platform capability, enforce entitlements where relevant, and audit sensitive outcomes.

### Security Risks

- Service role key is exposed to clients.
- Backend workers process all tenants without scope.
- Webhook or billing jobs write to the wrong company.
- AI service-role tools retrieve cross-tenant context.
- Compliance jobs delete data outside the request tenant.

### Mitigation Strategy

- Keep service-role credentials only in trusted server environments.
- Never expose service role to frontend, browser, mobile, Lovable client, or public automation clients.
- Process tenant work one company at a time.
- Require idempotency for webhook, billing, queue, and sync jobs.
- Write audit records for privileged service-role operations.
- Add negative tests for service-role misuse, wrong tenant resolution, inactive tenants, and missing audit records.

## 14. Webhook and Integration Access Model

### Objective

Secure external integration events and credentials for HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, Meta Ads, billing providers, and future integrations.

### Strategy

Integration records are tenant-owned. Webhook handlers must resolve company ownership from trusted `integration_connections`, signing secrets, provider mappings, and idempotency records.

Tenant users manage integrations only with `integrations.manage` or approved role permissions. Secret material and hashes are not normal tenant-readable data.

### Security Risks

- Forged webhook payload creates tenant records.
- Provider payload maps to the wrong company.
- Raw payload contains personal data or secrets.
- Duplicate webhook creates duplicate customers, payments, appointments, or messages.
- Tenant users read secret hashes or OAuth metadata.

### Mitigation Strategy

- Validate webhook signature or provider authenticity before processing.
- Deduplicate events by provider and external event id.
- Resolve company through trusted integration connection, not unverified payload company ids.
- Store only minimized payloads where possible.
- Restrict `webhook_signing_secrets`, OAuth grants, and API key hashes to service-role/admin workflows.
- Audit integration connection, credential, webhook rejection, sync failure, and provider mapping changes.

## 15. AI Agent Access Model

### Objective

Ensure AI-assisted workflows respect tenant isolation, RBAC, billing limits, LGPD minimization, and auditability.

### Strategy

AI governance tables are company-scoped: `ai_prompts`, `ai_runs`, `ai_outputs`, `ai_usage_records`, and `ai_feedback`. AI prompts, runs, outputs, usage, and feedback must never mix company contexts.

AI actions must be tied to one of these authorized contexts:

- authenticated tenant user with active membership and AI permission
- approved automation workflow within one company
- platform admin support workflow with justification and audit
- trusted service-role worker with tenant-scoped execution

AI usage is also subject to feature entitlement and usage limits.

### Security Risks

- AI prompts include unnecessary personal data.
- AI runs retrieve another company's context.
- AI outputs are reused across tenants.
- AI usage bypasses billing limits.
- AI tools mutate tenant data without user permission.

### Mitigation Strategy

- Require company scope for prompts, runs, outputs, feedback, and usage records.
- Minimize personal data before calling AI providers.
- Prefer summarized context over raw records.
- Require role permission and feature entitlement for AI actions.
- Require human approval for destructive, billing-impacting, integration-impacting, or high-impact customer actions unless future approved docs define safe autonomous behavior.
- Store AI usage for billing and audit.
- Apply LGPD deletion or retention rules to AI outputs that contain personal data.

## 16. Audit Requirements

### Objective

Make sensitive access, privileged changes, compliance workflows, and cross-system operations traceable.

### Strategy

Audit must cover:

- role assignment
- member invitation, suspension, removal
- company settings and branding changes
- integration connection, credential, and API key changes
- service account changes
- billing plan, subscription, entitlement, refund, invoice, and override events
- payment status changes
- data export, deletion, anonymization, and retention policy changes
- consent grant and revocation
- platform support access and tenant impersonation
- AI runs, outputs, tool calls, and write-back actions involving tenant data
- webhook rejection, processing, replay, and tenant mismatch events
- destructive operations

Audit rows should include actor, actor type, company, action, entity type, entity id, permission or platform capability used, request context, reason where applicable, outcome, timestamp, and correlation id.

### Security Risks

- Support access cannot be investigated.
- Service-role jobs have no actor context.
- Tenant users modify audit history.
- LGPD requests cannot be proven.
- Billing and AI usage cannot be reconciled.

### Mitigation Strategy

- Treat audit and consent audit rows as append-only from normal application paths.
- Separate platform admin audit from tenant audit.
- Include company context for tenant-scoped audit records.
- Avoid storing secrets or unnecessary personal data in audit metadata.
- Make service-role workers write actor type and job context.
- Preserve audit records according to retention and legal hold rules.

## 17. Supabase-Specific Implementation Guardrails

### Objective

Avoid common Supabase/PostgreSQL RLS failure modes when this architecture is later converted to SQL.

### Strategy

Implementation must follow these guardrails:

- Enable RLS for every tenant-owned table in exposed schemas.
- Apply defense in depth even for private operational tables.
- Keep privileged helper routines outside exposed schemas.
- Ensure helper routines cannot be used to bypass tenant or permission checks.
- Treat views as unsafe unless configured to respect invoker permissions or kept out of exposed schemas.
- Ensure mutation policies also require row visibility where PostgreSQL requires it.
- Never authorize from editable user metadata.
- Never expose service-role or secret keys to clients.
- Redact or avoid secret fields in any tenant-readable access path.

### Security Risks

- Views bypass table-level protection.
- Helper routines run with excessive privilege.
- Mutation policies silently fail or over-allow.
- Browser clients receive privileged keys.
- Public schema tables are exposed through Supabase APIs before policies exist.

### Mitigation Strategy

- Place security helper routines in a private schema.
- Keep helper routines minimal, deterministic, and auditable.
- Add policy tests for read, create, update, delete, and denied paths.
- Review every exposed table before enabling client access.
- Use advisors and manual review before production rollout.

## 18. Negative Security Test Cases

### Objective

Define required adversarial tests for the future RLS implementation.

### Test Categories

#### Tenant Isolation

- Company A user cannot read, create, update, delete, count, export, or report on Company B data.
- Multi-company user cannot mix parent records from Company A with child records from Company B.
- Suspended company members cannot perform operational actions.
- Cross-company customer deduplication is denied by default.

#### Derived Tables

- Tenant invoice access fails unless the parent billing account or subscription belongs to the user's company.
- API key metadata access fails unless the parent API client belongs to the user's company and the role can manage API access.
- Job attempt access fails unless the parent job belongs to the user's company and the caller is an approved worker/admin context.
- Role permission access fails unless the role belongs to the user's company and the caller can manage roles.

#### RBAC

- Viewer cannot create, update, delete, export, manage settings, manage integrations, read audit/compliance workflows, or run privileged AI actions.
- Employee cannot manage members, settings, roles, billing, refunds, compliance, or integrations unless explicitly granted in future docs.
- Manager cannot perform owner-only destructive controls.
- Company Owner cannot access platform administration.
- Platform Admin cannot use tenant-facing paths without platform authorization and audit.

#### Billing and Entitlements

- Inactive entitlement blocks gated feature use after membership and RBAC checks pass.
- Non-payment restriction does not expose another tenant or delete data automatically.
- Manager cannot change plan or payment method when only owner is allowed.
- Billing provider webhook cannot create duplicate subscription or invoice records.

#### LGPD and Privacy

- Data export includes only the requesting company data.
- Deletion job cannot process records outside the request company.
- Consent revocation blocks future marketing for that company and channel.
- Consent proof and audit records cannot be edited by tenant users.
- Legal hold blocks destructive retention jobs.

#### Webhooks and Integrations

- Invalid signature is rejected.
- Provider payload mapped to no active integration is rejected.
- Payload attempting tenant mismatch is rejected.
- Replay is denied or handled idempotently.
- Tenant users cannot read secret hashes, OAuth tokens, or raw secrets.

#### AI Agents

- AI run cannot retrieve or write data for another company.
- AI output cannot be reused across tenants.
- AI usage cannot bypass usage limits.
- AI tool call cannot mutate records without required role permission.
- AI prompt and output containing personal data follow retention and deletion policy.

#### Service Role

- Browser cannot access service-role credentials.
- Service-role worker rejects missing tenant context.
- Worker refuses inactive company where operational processing is blocked.
- Worker writes audit records for privileged operations.
- Worker handles each tenant independently.

#### Polymorphic References

- File link cannot point to an entity in another company.
- Audit entity reference cannot hide a cross-tenant access event.
- Automation or AI input reference cannot point across companies.
- Outbox or dead-letter event cannot publish another company's payload.

## 19. Implementation Readiness Checklist

Before SQL is generated, the team must complete this checklist:

1. Classify every table into platform-private, platform catalog, user-self, direct tenant, derived tenant, polymorphic tenant, or worker-private.
2. Define exact permission keys for each module/action used in RLS helpers.
3. Define status values for companies, memberships, roles, subscriptions, entitlements, jobs, integrations, and compliance workflows.
4. Decide which catalog rows tenant users may read.
5. Decide which profile fields are visible to teammates.
6. Define redacted access patterns for API keys, service accounts, OAuth grants, and webhook secrets.
7. Define parent-derived ownership rules for every table without direct `company_id`.
8. Define polymorphic reference validation rules for files, audit, events, automations, and AI.
9. Define service-role Edge Function contracts for webhooks, billing, workers, LGPD jobs, reports, and AI.
10. Define audit event names and required metadata.
11. Define retention and hard-delete rules for each LGPD-sensitive table.
12. Add tenant-safe constraints before production where the schema permits them.
13. Add negative security tests before enabling tenant client access.
14. Run Supabase security review and database advisor checks before production rollout.

## Final Recommendation

Replace `database/rls-strategy.md` as the implementation guide with this v2 strategy before writing SQL policies.

The most important correction is to move from a generic company-id strategy to a table-class strategy. Direct tenant tables, derived tenant tables, platform tables, secret-bearing tables, worker tables, polymorphic references, billing records, LGPD records, and AI governance records each require distinct RLS behavior.

Do not generate SQL until every table has an assigned policy class, every sensitive permission is mapped to the approved RBAC model, and every derived or polymorphic relationship has a documented tenant validation rule.
