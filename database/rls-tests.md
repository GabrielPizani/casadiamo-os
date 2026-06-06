# Casa Di Amo OS RLS Validation Tests

## Purpose

This document defines the validation test plan for `database/rls.sql`.

The goal is to prove that Supabase Row Level Security enforces tenant isolation, RBAC boundaries, platform admin behavior, service-role behavior, and secret-table protection before Casa Di Amo OS ships an MVP.

This is a test specification, not application code. Convert these scenarios into automated Supabase/PostgreSQL tests once a local Supabase project, seed data, and test runner are added.

## Source Documents

- `database/schema.sql`
- `database/rls.sql`
- `database/rls-strategy-v2.md`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`

## Test Actors

| Actor | Description |
| --- | --- |
| Tenant A Owner | Active Company Owner in Tenant A only. |
| Tenant A Manager | Active Manager in Tenant A only. |
| Tenant A Employee | Active Employee in Tenant A only. |
| Tenant A Viewer | Active Viewer in Tenant A only. |
| Tenant B Owner | Active Company Owner in Tenant B only. |
| Multi-Tenant User | Active member of Tenant A and Tenant B with separate role assignments. |
| Platform Admin | Active platform admin in `platform_admins`. |
| Suspended Member | Former or suspended member of Tenant A. |
| Anonymous User | No authenticated Supabase user. |
| Service Role | Trusted server-side service role or secret key context. |

## Baseline Seed Requirements

Create deterministic test fixtures before running these tests:

1. Two active companies: Tenant A and Tenant B.
2. Active roles and permissions for Company Owner, Manager, Employee, and Viewer.
3. One active user profile per actor.
4. Active `company_members` rows matching each tenant actor.
5. Representative Tenant A and Tenant B records in these modules:
   - company settings
   - staff profiles
   - customers
   - services
   - appointments
   - CRM deals
   - marketing campaigns
   - invoices and payments
   - files and file links
   - integration connections
   - automation workflows
   - audit logs
   - AI prompts, AI runs, and AI outputs
6. Secret and worker-private records:
   - API client and API key
   - OAuth grant
   - webhook signing secret
   - webhook event
   - job queue and job attempt
   - idempotency key
   - outbox event
   - dead letter event

## Pass Criteria

RLS validation passes only when:

1. Every denied read returns zero rows or an authorization failure without leaking record existence.
2. Every denied write affects zero rows or fails with an authorization error.
3. Cross-tenant references are rejected on insert and update.
4. Role-limited users cannot perform actions outside their permissions.
5. Secret and worker-private tables are inaccessible to normal authenticated users.
6. Platform Admin paths work only for platform-admin actors.
7. Service Role paths work only in trusted server-side context and are separately audited by application workflows.

## Test Group 1: Tenant A Cannot Read Tenant B

### Objective

Validate that Tenant A users cannot read Tenant B data from tenant-owned tables.

### Setup

- Authenticate as Tenant A Owner.
- Ensure Tenant A Owner has no membership in Tenant B.
- Ensure Tenant B has records across all core modules.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T1.1 | Tenant A Owner | Tenant B `companies` row | Read by Tenant B id | Denied or zero rows. |
| T1.2 | Tenant A Owner | Tenant B `company_settings` | Read by Tenant B `company_id` | Zero rows. |
| T1.3 | Tenant A Manager | Tenant B `customers` | Read all Tenant B customers | Zero rows. |
| T1.4 | Tenant A Employee | Tenant B `appointments` | Read appointment by id | Zero rows. |
| T1.5 | Tenant A Viewer | Tenant B `crm_deals` | Read deal by id | Zero rows. |
| T1.6 | Tenant A Owner | Tenant B `invoices`, `payments`, `refunds` | Read finance records | Zero rows. |
| T1.7 | Tenant A Owner | Tenant B `files` and `file_links` | Read file metadata and links | Zero rows. |
| T1.8 | Tenant A Owner | Tenant B `ai_runs` and `ai_outputs` | Read AI records | Zero rows. |
| T1.9 | Tenant A Owner | Tenant B `audit_logs` | Read audit entries | Zero rows unless actor is platform admin. |

### Additional Checks

- Filtering with Tenant B `company_id` must not reveal row counts.
- Queries using known Tenant B record ids must not reveal whether the record exists.
- Multi-Tenant User must only see Tenant B records when operating under a valid Tenant B membership and permission context.

## Test Group 2: Tenant A Cannot Modify Tenant B

### Objective

Validate that Tenant A users cannot create, update, delete, or cross-link Tenant B records.

### Setup

- Authenticate as Tenant A Owner.
- Capture known Tenant B ids for customer, staff, service, appointment, CRM, file, invoice, integration, and AI records.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T2.1 | Tenant A Owner | Tenant B `customers` | Insert with Tenant B `company_id` | Denied. |
| T2.2 | Tenant A Owner | Tenant B `customers` | Update Tenant B customer | Denied or zero rows. |
| T2.3 | Tenant A Owner | Tenant B `customers` | Delete Tenant B customer | Denied or zero rows. |
| T2.4 | Tenant A Owner | Tenant A `appointments` | Insert referencing Tenant B customer | Denied. |
| T2.5 | Tenant A Manager | Tenant A `appointments` | Update to Tenant B staff/service/customer | Denied. |
| T2.6 | Tenant A Owner | Tenant A `crm_deals` | Insert referencing Tenant B customer or stage | Denied. |
| T2.7 | Tenant A Owner | Tenant A `marketing_deliveries` | Create delivery for Tenant B customer | Denied. |
| T2.8 | Tenant A Owner | Tenant A `file_links` | Link Tenant A file to Tenant B entity | Denied. |
| T2.9 | Tenant A Owner | Tenant A `ai_runs` | Set input entity to Tenant B record | Denied. |
| T2.10 | Tenant A Owner | Tenant B `integration_connections` | Update or delete integration | Denied or zero rows. |

### Additional Checks

- Updates must validate both the existing row and proposed row state.
- Changing `company_id` on tenant-owned rows must be denied.
- Cross-tenant parent-child relationships must be denied even if the actor knows both record ids.

## Test Group 3: Employee Cannot Access Manager Resources

### Objective

Validate that Employee role access is limited to permitted operational work and cannot access Manager-level resources.

### Setup

- Authenticate as Tenant A Employee.
- Ensure Employee has only employee-level permissions from the RBAC model.
- Ensure Tenant A Manager has access to team, reporting, marketing, automation, and operational management resources.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T3.1 | Tenant A Employee | `company_members` | Read full team membership list | Denied or limited according to explicit employee permission. |
| T3.2 | Tenant A Employee | `roles` and `role_permissions` | Read or mutate role configuration | Denied unless explicit permission exists. |
| T3.3 | Tenant A Employee | `company_settings` | Update company settings | Denied. |
| T3.4 | Tenant A Employee | `company_invitations` | Create invitation | Denied. |
| T3.5 | Tenant A Employee | `marketing_campaigns` | Create/update campaign without marketing permission | Denied. |
| T3.6 | Tenant A Employee | `automation_workflows` | Publish or update workflow without automation permission | Denied. |
| T3.7 | Tenant A Employee | `report_definitions` | Create/update report definition | Denied. |
| T3.8 | Tenant A Employee | `integration_connections` | Manage integration | Denied. |
| T3.9 | Tenant A Employee | `refunds` | Create refund | Denied. |
| T3.10 | Tenant A Employee | `audit_logs` | Read audit logs | Denied. |

### Additional Checks

- Employee may access assigned or explicitly permitted operational records only.
- Employee must never gain Manager behavior through frontend-only permission checks.
- Employee cannot assign roles, remove members, configure settings, export reports, manage compliance, or read audit logs.

## Test Group 4: Viewer Is Read-Only

### Objective

Validate that Viewer can read permitted company data but cannot create, update, delete, export, configure, or manage resources.

### Setup

- Authenticate as Tenant A Viewer.
- Ensure Viewer has only read permissions for permitted modules.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T4.1 | Tenant A Viewer | Tenant A permitted customer data | Read | Allowed if Viewer has read permission. |
| T4.2 | Tenant A Viewer | `customers` | Insert | Denied. |
| T4.3 | Tenant A Viewer | `customers` | Update | Denied. |
| T4.4 | Tenant A Viewer | `customers` | Delete | Denied. |
| T4.5 | Tenant A Viewer | `appointments` | Create/update/delete | Denied. |
| T4.6 | Tenant A Viewer | `company_settings` | Update | Denied. |
| T4.7 | Tenant A Viewer | `reports` | Export or create report | Denied. |
| T4.8 | Tenant A Viewer | `audit_logs` | Read | Denied unless explicitly granted by approved RBAC changes. |
| T4.9 | Tenant A Viewer | `data_exports` | Create export | Denied. |
| T4.10 | Tenant A Viewer | `ai_runs` | Create AI run | Denied unless explicit AI permission exists. |

### Additional Checks

- Viewer cannot use bulk endpoints to bypass write denial.
- Viewer cannot mutate records through upsert behavior.
- Viewer cannot delete by filtering on known ids.

## Test Group 5: Platform Admin Access

### Objective

Validate that Platform Admin access is separate from company membership and works only through platform-admin authorization.

### Setup

- Authenticate as Platform Admin with active `platform_admins` record and active platform role.
- Authenticate as Tenant A Owner without platform admin status.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T5.1 | Platform Admin | `platform_roles` | Read | Allowed. |
| T5.2 | Platform Admin | `platform_permissions` | Read | Allowed. |
| T5.3 | Platform Admin | Tenant A and Tenant B operational records | Support read | Allowed only through platform-admin policies. |
| T5.4 | Platform Admin | `companies` | Suspend/restore through approved capability | Allowed only with platform permission. |
| T5.5 | Platform Admin | `plans`, `features`, `plan_features` | Manage catalog | Allowed only with platform permission. |
| T5.6 | Tenant A Owner | `platform_roles` | Read | Denied. |
| T5.7 | Tenant A Owner | `platform_admins` | Read/write | Denied. |
| T5.8 | Tenant A Owner | Tenant B records | Read/write via tenant path | Denied. |
| T5.9 | Platform Admin without required platform permission | Platform-only action | Denied. |
| T5.10 | Suspended platform admin | Any platform admin action | Denied. |

### Additional Checks

- Platform Admin must not require company membership to perform platform support reads.
- Platform Admin access must be audited by application workflows for support, impersonation, billing override, tenant suspension, and security review.
- Tenant roles must never imply Platform Admin access.

## Test Group 6: Service Role Access

### Objective

Validate that service-role behavior is reserved for trusted server-side workflows and is not confused with authenticated user behavior.

### Setup

- Run tests with authenticated tenant users and separately with trusted service-role context.
- Service-role tests should be executed only from secure backend, migration, or Edge Function test harnesses.

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T6.1 | Authenticated Tenant A Owner | Secret/worker tables | Read `api_keys`, `webhook_signing_secrets`, `job_queue` | Denied. |
| T6.2 | Service Role | Tenant A and Tenant B records | Read for backend job | Allowed by database role, but application must enforce tenant scope. |
| T6.3 | Service Role | Webhook processing | Insert `webhook_events` after signature validation | Allowed by server context. |
| T6.4 | Service Role | Integration sync | Update sync jobs and mapped records | Allowed by server context. |
| T6.5 | Service Role | LGPD deletion/export worker | Process one company request | Allowed by server context and company scope. |
| T6.6 | Service Role | Cross-tenant batch job | Process all tenants without scoping | Test must fail at application validation layer. |
| T6.7 | Browser/client context | Service role key | Attempt use | Must be impossible; no service role key in client environment. |

### Additional Checks

- Service-role tests must verify application-layer authorization because service role bypasses RLS by design.
- Every privileged service-role workflow must record actor type, company id, action, entity, outcome, and correlation id in audit logs where required.
- Service-role jobs must process tenant work independently to prevent one tenant's data or failure from leaking into another tenant.

## Test Group 7: Secret Table Protection

### Objective

Validate that secret-bearing and worker-private tables are not accessible through authenticated client policies.

### Protected Tables

- `api_keys`
- `oauth_grants`
- `webhook_signing_secrets`
- `job_queue`
- `job_attempts`
- `idempotency_keys`
- `outbox_events`
- `dead_letter_events`

### Test Cases

| ID | Actor | Target | Operation | Expected Result |
| --- | --- | --- | --- | --- |
| T7.1 | Tenant A Owner | `api_keys` | Select | Denied. |
| T7.2 | Tenant A Owner | `api_keys` | Insert/update/delete | Denied. |
| T7.3 | Tenant A Manager | `oauth_grants` | Select | Denied. |
| T7.4 | Tenant A Owner | `webhook_signing_secrets` | Select secret hash | Denied. |
| T7.5 | Tenant A Owner | `job_queue` | Select/insert/update/delete | Denied. |
| T7.6 | Tenant A Owner | `job_attempts` | Select/insert/update/delete | Denied. |
| T7.7 | Tenant A Owner | `idempotency_keys` | Select/insert/update/delete | Denied. |
| T7.8 | Tenant A Owner | `outbox_events` | Select/insert/update/delete | Denied. |
| T7.9 | Tenant A Owner | `dead_letter_events` | Select/insert/update/delete | Denied. |
| T7.10 | Platform Admin via tenant client path | Secret/worker tables | Direct access | Denied unless using approved backend/admin workflow. |

### Additional Checks

- Tenant-facing APIs may expose redacted metadata through controlled backend endpoints, not direct table policies.
- No client-visible response may include hashes, OAuth tokens, signing secrets, raw provider secrets, or worker payloads.
- Secret rotation must be performed through audited backend workflows.

## Regression Matrix

Run the following matrix for each tenant-owned module before MVP:

| Module | Read isolation | Insert isolation | Update isolation | Delete isolation | RBAC enforced | Cross-tenant refs denied |
| --- | --- | --- | --- | --- | --- | --- |
| Companies/settings | Required | Required | Required | Required | Required | Required |
| Users/team/RBAC | Required | Required | Required | Required | Required | Required |
| Customers | Required | Required | Required | Required | Required | Required |
| Services | Required | Required | Required | Required | Required | Required |
| Appointments | Required | Required | Required | Required | Required | Required |
| CRM | Required | Required | Required | Required | Required | Required |
| Marketing/messages | Required | Required | Required | Required | Required | Required |
| Integrations/webhooks | Required | Required | Required | Required | Required | Required |
| Automations | Required | Required | Required | Required | Required | Required |
| Payments/billing | Required | Required | Required | Required | Required | Required |
| Reports/audit | Required | Required | Required | Required | Required | Required |
| LGPD/compliance | Required | Required | Required | Required | Required | Required |
| AI governance | Required | Required | Required | Required | Required | Required |
| Files/documents | Required | Required | Required | Required | Required | Required |

## MVP Exit Criteria

RLS validation is MVP-ready only when:

1. All test groups pass in an automated test harness.
2. Negative cross-tenant reads and writes are verified for each tenant-owned module.
3. Viewer write attempts are denied across all modules.
4. Employee cannot perform Manager, Owner, or Platform Admin actions.
5. Platform Admin paths are separately authenticated and audited.
6. Service-role tests prove backend jobs enforce tenant scope before writes.
7. Secret and worker-private tables have no client grants and no client policies.
8. Audit logs are append-only from normal tenant client paths.
9. AI records cannot cross tenant boundaries.
10. Test results are captured in CI before production rollout.
