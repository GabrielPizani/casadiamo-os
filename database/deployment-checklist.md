# Casa Di Amo OS Supabase Deployment Checklist

## Purpose

This checklist explains how to deploy Casa Di Amo OS to Supabase safely.

It is written for a non-engineer founder. Follow it in order. Do not skip gates. If a step says **STOP**, do not continue until the issue is fixed.

## Approved Source Documents

Deployment must follow these files:

- `database/schema.sql`
- `database/rls.sql`
- `database/rls-implementation-plan.md`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`
- `docs/compliance-lgpd.md`

Current repository note:

- `database/schema.sql` exists.
- `database/rls.sql` is required for production deployment.
- In the current checkout, `database/rls.sql` is not present. Production go-live is blocked until it exists, is reviewed, and passes the validation steps below.

## Non-Negotiable Deployment Rules

- Do not deploy production without RLS.
- Do not expose the Supabase service role key in frontend, Lovable, Vercel public variables, browser code, mobile code, or support tools.
- Do not trust a user-provided `company_id` unless membership and permission checks pass.
- Do not process webhooks until provider signature and tenant mapping are verified.
- Do not enable public Storage buckets unless the bucket is explicitly approved for public assets.
- Do not go live if cross-tenant negative tests fail.

## People and Access

Before starting:

- One founder owns the deployment checklist.
- One technical reviewer approves SQL files before production.
- One rollback owner is available during go-live.
- Supabase Dashboard access is restricted to trusted operators.
- Production database password is stored in a password manager.
- Service role key is stored only in the backend secret store.

## Deployment Environments

Use two Supabase projects:

| Environment | Purpose | Required before go-live |
| --- | --- | --- |
| Staging | Dry run deployment and validation | Yes |
| Production | Real customer data | Yes |

Use the same region for staging and production unless there is a legal or operational reason not to.

## 1. Migration Order

### Gate 1: File readiness

Confirm these files are approved:

- [ ] `database/schema.sql`
- [ ] `database/rls.sql`
- [ ] `database/rls-implementation-plan.md`
- [ ] `docs/multi-tenancy-strategy.md`
- [ ] `docs/rbac-model.md`
- [ ] `docs/compliance-lgpd.md`

**STOP if `database/rls.sql` is missing.**

### Gate 2: Staging migration order

Run this order in staging first:

1. Create a fresh Supabase staging project.
2. Open **Supabase Dashboard -> SQL Editor**.
3. Create a new query named `01_schema`.
4. Paste the full contents of `database/schema.sql`.
5. Run the query.
6. Confirm it finishes successfully.
7. Create a new query named `02_rls`.
8. Paste the full contents of `database/rls.sql`.
9. Run the query.
10. Confirm it finishes successfully.
11. Run all validation queries in this checklist.
12. Run all negative security tests in this checklist.

### Gate 3: Production migration order

Run this order in production only after staging passes:

1. Create a production backup checkpoint.
2. Record the production project reference id.
3. Record the exact Git commit being deployed.
4. Open **Supabase Dashboard -> SQL Editor**.
5. Run `database/schema.sql`.
6. Run `database/rls.sql`.
7. Run all validation queries.
8. Configure Auth.
9. Configure Storage.
10. Deploy Edge Functions.
11. Add secrets.
12. Run final go-live checklist.

## 2. Supabase Project Configuration

Configure both staging and production.

### Project settings

- [ ] Project name includes environment: `casadiamo-staging` or `casadiamo-production`.
- [ ] Region is selected intentionally and recorded.
- [ ] Database password is stored in a password manager.
- [ ] Organization access is limited to required operators.
- [ ] Production backups are enabled.
- [ ] Point-in-time recovery is enabled if available on the selected plan.
- [ ] Database connection string is stored only in backend/server environments.
- [ ] API URL and publishable key are stored in frontend environment variables.
- [ ] Service role key is stored only as a server-side secret.

### API settings

- [ ] Exposed schemas include only the schemas required by Supabase defaults and the app.
- [ ] `public` is treated as exposed and protected by RLS.
- [ ] No custom schema is exposed unless it has been reviewed.
- [ ] CORS/site origins include only approved app domains.

### Database safety settings

- [ ] RLS is enabled on every `public` table after `rls.sql` runs.
- [ ] Platform-owned writes are not available to tenant users.
- [ ] Derived tenant tables are protected through parent ownership checks or direct `company_id`.
- [ ] No tenant-owned table is accessible to anonymous users.

## 3. Auth Configuration

Open **Supabase Dashboard -> Authentication -> Providers**.

### Required Auth settings

- [ ] Email provider is configured if email login is part of MVP.
- [ ] Anonymous sign-ins are disabled.
- [ ] Phone/social providers are disabled unless explicitly needed for MVP.
- [ ] Public self-signup is disabled until tenant onboarding and default Company Owner assignment are tested.
- [ ] Invited or admin-created user flow is used for first tenants.
- [ ] JWT expiry is short enough for membership removals to take effect quickly.
- [ ] Site URL is set to the production app URL.
- [ ] Redirect URLs include only staging and production app URLs.
- [ ] Redirect URLs do not include wildcard localhost entries in production.
- [ ] Email templates do not include secrets or tenant data.

### Required Auth behavior

- [ ] Each Supabase Auth user receives exactly one `user_profiles` row.
- [ ] Tenant access is granted only through `company_members`.
- [ ] Company role is stored in `company_members.role_id`, not in user-editable metadata.
- [ ] Platform admin access is stored in `platform_admins`, not in user-editable metadata.
- [ ] Removing or suspending a `company_members` row blocks tenant access.

## 4. Storage Configuration

Storage must follow tenant isolation and LGPD rules.

### Buckets

Create only the buckets needed for MVP:

| Bucket | Public? | Purpose |
| --- | --- | --- |
| `tenant-files` | No | Customer files, message attachments, documents, operational uploads |
| `tenant-exports` | No | LGPD exports and generated data exports |
| `tenant-public-assets` | Only if approved | Company logos and public branding assets |

### Storage rules

- [ ] No private customer, appointment, payment, export, message, or AI file is stored in a public bucket.
- [ ] `tenant-files` is private.
- [ ] `tenant-exports` is private.
- [ ] Export links expire.
- [ ] Upload, read, update, and delete rules are enforced with Storage RLS policies.
- [ ] Storage object paths include tenant context, such as `company_id/...`.
- [ ] `files.company_id` matches the owning tenant for each stored object.
- [ ] Service role Storage access is used only from backend jobs.
- [ ] Raw provider credentials are never uploaded to Storage.

## 5. Edge Functions Configuration

Deploy only MVP-required Edge Functions.

### Function classes

Every function must fit exactly one class:

| Class | Caller | Required checks |
| --- | --- | --- |
| User-delegated | Authenticated tenant user | JWT, active profile, active company, active membership, permission, row ownership |
| Webhook | External provider | Signature, replay/idempotency, active integration, tenant mapping |
| Scheduled job | Internal scheduler | Job secret, company scope, idempotency, audit/logging |
| Platform admin | Casa Di Amo operator | Platform admin status, platform permission, reason, audit log |

### Edge Function rules

- [ ] No function trusts raw request `company_id` without database validation.
- [ ] No function logs tokens, secrets, payment credentials, raw customer exports, or unnecessary personal data.
- [ ] Every service-role function validates the tenant before reading or writing tenant data.
- [ ] Every webhook function validates provider signature before storing or processing payloads.
- [ ] Every scheduled job processes work company by company.
- [ ] Every platform-admin function requires a reason and writes an audit record.
- [ ] Every function has staging and production secrets set separately.
- [ ] Every function has a rollback plan.

## 6. Required Secrets

Store secrets in Supabase Edge Function secrets and deployment platform secrets. Never commit them to Git.

### Always required

| Secret | Store where | Notes |
| --- | --- | --- |
| `SUPABASE_URL` | Frontend and backend | Safe to expose when using publishable/anon key with RLS |
| `SUPABASE_PUBLISHABLE_KEY` or `SUPABASE_ANON_KEY` | Frontend | Prefer publishable key for new Supabase projects; legacy anon key is acceptable only when required by the client setup. Must rely on RLS; not a security boundary by itself |
| `SUPABASE_SERVICE_ROLE_KEY` | Backend/Edge Functions only | Never expose publicly |
| `APP_BASE_URL` | Frontend and backend | Production app URL |
| `INTERNAL_JOB_SECRET` | Backend/Edge Functions only | Used by scheduled/internal functions |

### Required only when the related MVP feature is enabled

| Secret | Required for |
| --- | --- |
| `HUBSPOT_CLIENT_ID` / `HUBSPOT_CLIENT_SECRET` | HubSpot OAuth |
| `MANYCHAT_API_KEY` | ManyChat integration |
| `WHATSAPP_ACCESS_TOKEN` / `WHATSAPP_WEBHOOK_SECRET` | WhatsApp messaging and webhooks |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Google Calendar OAuth |
| `CALENDLY_CLIENT_ID` / `CALENDLY_CLIENT_SECRET` / `CALENDLY_WEBHOOK_SECRET` | Calendly integration |
| `PAYMENT_PROVIDER_SECRET_KEY` / `PAYMENT_WEBHOOK_SECRET` | Payments |
| `AI_PROVIDER_API_KEY` | AI workflows |
| `EMAIL_PROVIDER_API_KEY` | Transactional email |

### Secret review

- [ ] No secret value appears in `.env.example`.
- [ ] No secret value appears in SQL files.
- [ ] No secret value appears in browser-visible variables.
- [ ] No secret value appears in logs.
- [ ] Every webhook secret has a rotation owner.
- [ ] Every provider secret has staging and production values separated.

## 7. Validation Queries

Run these in **Supabase Dashboard -> SQL Editor** after migrations.

### Query A: Confirm expected table count

Expected result: `public_table_count` is `110`.

```sql
select count(*) as public_table_count
from information_schema.tables
where table_schema = 'public'
  and table_type = 'BASE TABLE';
```

### Query B: Confirm all public tables have RLS enabled

Expected result: zero rows.

```sql
select schemaname, tablename
from pg_tables
where schemaname = 'public'
  and rowsecurity = false
order by tablename;
```

### Query C: Confirm every public table has at least one policy

Expected result: zero rows, except any table intentionally marked service-role-only with no direct client access in `rls.sql`.

```sql
select t.tablename
from pg_tables t
left join pg_policies p
  on p.schemaname = t.schemaname
 and p.tablename = t.tablename
where t.schemaname = 'public'
  and p.policyname is null
order by t.tablename;
```

### Query D: Confirm no anonymous policies remain on app tables

Expected result: zero rows.

```sql
select schemaname, tablename, policyname, roles, cmd
from pg_policies
where schemaname = 'public'
  and (
    'anon' = any (roles)
    or 'public' = any (roles)
  )
order by tablename, policyname;
```

### Query E: Confirm tenant-owned tables have `company_id` where expected

Expected result: review any rows returned. They must match the approved derived/platform/system classification.

```sql
select t.table_name
from information_schema.tables t
where t.table_schema = 'public'
  and t.table_type = 'BASE TABLE'
  and not exists (
    select 1
    from information_schema.columns c
    where c.table_schema = t.table_schema
      and c.table_name = t.table_name
      and c.column_name = 'company_id'
  )
order by t.table_name;
```

### Query F: Confirm Auth profile uniqueness

Expected result: zero rows.

```sql
select auth_user_id, count(*) as profile_count
from public.user_profiles
group by auth_user_id
having count(*) > 1;
```

### Query G: Confirm no active member points to inactive company

Expected result: zero rows.

```sql
select cm.id, cm.company_id
from public.company_members cm
join public.companies c on c.id = cm.company_id
where cm.status = 'active'
  and c.status <> 'active';
```

### Query H: Confirm no active member has a role from another company

Expected result: zero rows.

```sql
select cm.id as company_member_id, cm.company_id, cm.role_id
from public.company_members cm
join public.roles r on r.id = cm.role_id
where cm.status = 'active'
  and r.company_id is distinct from cm.company_id;
```

### Query I: Confirm platform admins use platform roles

Expected result: zero rows.

```sql
select pa.id as platform_admin_id, pa.platform_role_id
from public.platform_admins pa
left join public.platform_roles pr on pr.id = pa.platform_role_id
where pr.id is null;
```

### Query J: Confirm service-role-only tables are protected by RLS

Expected result: all listed tables show `rowsecurity = true`.

```sql
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'api_keys',
    'webhook_signing_secrets',
    'webhook_events',
    'integration_sync_jobs',
    'automation_events',
    'automation_runs',
    'automation_run_steps',
    'job_queue',
    'job_attempts',
    'idempotency_keys',
    'outbox_events',
    'dead_letter_events',
    'ai_runs',
    'ai_outputs',
    'ai_usage_records'
  )
order by tablename;
```

### Query K: Confirm Storage buckets

Expected result: only approved buckets.

```sql
select id, name, public
from storage.buckets
order by id;
```

### Query L: Confirm Storage policies exist

Expected result: policies exist for any MVP storage bucket.

```sql
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
order by policyname;
```

## 8. Negative Validation Tests

Run these in staging before production.

Use two companies:

- Company A
- Company B

Use four users:

- Company A Owner
- Company A Employee
- Company A Viewer
- Company B Owner

### Required tests

- [ ] Company A user cannot read Company B customers.
- [ ] Company A user cannot read Company B appointments.
- [ ] Company A user cannot read Company B CRM deals.
- [ ] Company A user cannot read Company B invoices.
- [ ] Company A user cannot read Company B files.
- [ ] Company A user cannot update `company_id` on any row.
- [ ] Company A user cannot create a child row pointing to Company B parent data.
- [ ] Viewer cannot create, update, delete, export, configure, refund, or manage integrations.
- [ ] Employee cannot manage settings, roles, integrations, exports, refunds, audit logs, or compliance workflows.
- [ ] Suspended member cannot read or write tenant data.
- [ ] Anonymous user cannot read or write tenant data.
- [ ] Webhook with invalid signature is rejected.
- [ ] Webhook for Company A cannot write Company B data.
- [ ] Service-role job without validated company context is rejected by application logic.
- [ ] Export for Company A excludes Company B data.
- [ ] Deletion/anonymization job for Company A excludes Company B data.

**STOP if any test fails.**

## 9. Rollback Strategy

Supabase database migrations should be treated as forward-only. The safest rollback for production data is a verified backup restore or a tested forward fix.

### Before production migration

- [ ] Take a production backup.
- [ ] Confirm backup restore is available on the selected Supabase plan.
- [ ] Export the current schema definition.
- [ ] Record the Git commit hash.
- [ ] Record staging validation results.
- [ ] Confirm rollback owner is online.

### If schema migration fails before customer data is written

1. Stop deployment.
2. Do not run `rls.sql`.
3. Drop and recreate the staging project if this happened in staging.
4. For production, restore from the pre-migration backup or open Supabase support if restore is plan-gated.
5. Fix the migration in a new reviewed commit.
6. Restart from staging.

### If RLS migration fails

1. Stop deployment.
2. Do not disable RLS broadly.
3. Identify the failed table or policy.
4. Apply a narrow forward fix in staging.
5. Re-run all validation queries and negative tests.
6. Apply the same fix to production only after staging passes.

### If post-go-live tenant isolation fails

1. Put the application in maintenance mode.
2. Disable affected Edge Functions or redeploy them with a temporary reject-all response.
3. Revoke affected provider webhook secrets if webhooks are involved.
4. Rotate the service role key if exposure is suspected.
5. Apply the narrowest database policy fix.
6. Run cross-tenant negative tests.
7. Review audit logs for possible exposure.
8. Follow incident and LGPD notification procedures if personal data exposure is confirmed.

### If frontend deployment fails but database is healthy

1. Roll back the frontend deployment in Vercel/Lovable.
2. Keep Supabase RLS enabled.
3. Do not roll back the database unless data integrity or security is affected.

## 10. Go-Live Checklist

Do not go live until every item is checked.

### Files and migrations

- [ ] `database/schema.sql` ran successfully in staging.
- [ ] `database/rls.sql` ran successfully in staging.
- [ ] All validation queries passed in staging.
- [ ] All negative tests passed in staging.
- [ ] Production backup was taken.
- [ ] `database/schema.sql` ran successfully in production.
- [ ] `database/rls.sql` ran successfully in production.
- [ ] All validation queries passed in production.

### Security

- [ ] RLS is enabled on every public table.
- [ ] No tenant-owned data is accessible to anonymous users.
- [ ] Company A cannot access Company B canary records.
- [ ] Service role key exists only in backend/Edge Function secrets.
- [ ] Frontend has only `SUPABASE_URL` and the publishable/anon key.
- [ ] Platform admin access requires platform role and audit logging.
- [ ] Storage buckets are private except approved public assets.
- [ ] Storage policies exist for all active buckets.
- [ ] Webhook secrets are configured and tested.
- [ ] Sensitive logs are masked.

### Auth

- [ ] Production Site URL is correct.
- [ ] Production Redirect URLs are correct.
- [ ] Anonymous sign-ins are disabled.
- [ ] Public signup is disabled unless onboarding automation is fully tested.
- [ ] First tenant Company Owner assignment is tested.
- [ ] Suspended member access denial is tested.

### Edge Functions

- [ ] Only MVP-required functions are deployed.
- [ ] Every function has staging and production secrets.
- [ ] User-delegated functions validate JWT and membership.
- [ ] Webhook functions validate signatures.
- [ ] Scheduled functions use `INTERNAL_JOB_SECRET`.
- [ ] Platform-admin functions require reason-bound audit.

### LGPD and data governance

- [ ] Consent tracking works.
- [ ] Consent audit logging works.
- [ ] Data export workflow is tenant-scoped.
- [ ] Data deletion/anonymization workflow is tenant-scoped.
- [ ] Export links expire.
- [ ] Audit logs cannot be modified by normal tenant users.
- [ ] Financial and audit records are protected from casual hard delete.

### Final go/no-go

- [ ] Founder reviewed this checklist.
- [ ] Technical reviewer approved staging results.
- [ ] Rollback owner is online.
- [ ] Support contact is available.
- [ ] Monitoring is open.
- [ ] Go-live time is recorded.

If every item is checked, production deployment is ready.

If any item is unchecked, do not go live.
