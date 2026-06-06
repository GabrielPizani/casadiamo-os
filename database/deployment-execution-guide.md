# Casa Di Amo OS Supabase Deployment Execution Guide

## Read This First

This guide is for a non-technical founder deploying Casa Di Amo OS to Supabase.

Follow the steps in order. Do not skip validation. If a step says **STOP**, stop and ask the technical reviewer to fix the issue.

Required files:

- `database/schema.sql`
- `database/rls.sql`
- `database/deployment-checklist.md`

Current blocker:

- `database/rls.sql` is required before production go-live.
- If `database/rls.sql` is missing, you may review this guide, but you must not launch production.

## Step 1: Create the Supabase project

### Exact Supabase screen

Supabase Dashboard -> Organization home.

### Exact button to click

Click **New project**.

### Exact configuration

Create two projects:

| Project | Name | Use |
| --- | --- | --- |
| Staging | `casadiamo-staging` | Practice deployment and testing |
| Production | `casadiamo-production` | Real customer data |

For each project:

1. Choose the approved Supabase organization.
2. Enter the project name.
3. Choose the same region for staging and production unless the technical reviewer says otherwise.
4. Generate a strong database password.
5. Save the password in the company password manager.
6. Click **Create new project**.

### Expected result

Supabase creates the project and opens the project dashboard.

### Validation method

Open **Project Settings -> General** and confirm:

- Project name is correct.
- Project reference ID is visible.
- Region is correct.

Record the project reference ID in the deployment notes.

### Common mistakes

- Creating only production and skipping staging.
- Losing the database password.
- Choosing different regions without a reason.
- Giving dashboard access to people who do not need it.

## Step 2: Configure Auth setup

### Exact Supabase screen

Supabase Dashboard -> Authentication -> Providers.

### Exact button to click

Click **Email**.

### Exact configuration

For MVP:

1. Enable **Email** only if email login is part of the launch.
2. Disable unused providers such as phone, Google, GitHub, Facebook, and anonymous login unless the MVP explicitly needs them.
3. Keep anonymous sign-ins disabled.
4. Keep public signup disabled until onboarding is fully tested.

Then open:

Supabase Dashboard -> Authentication -> URL Configuration.

Set:

| Field | Staging value | Production value |
| --- | --- | --- |
| Site URL | Staging app URL | Production app URL |
| Redirect URLs | Staging app callback URL | Production app callback URL |

Use only real staging and production URLs. Do not leave wildcard localhost URLs in production.

### Expected result

Users can authenticate only through approved MVP methods.

### Validation method

Open **Authentication -> Providers** and confirm:

- Email is configured if needed.
- Anonymous sign-ins are off.
- Unused providers are off.

Open **Authentication -> URL Configuration** and confirm:

- Site URL is the correct app URL.
- Redirect URLs contain only approved URLs.

### Common mistakes

- Leaving public signup enabled before tenant onboarding is tested.
- Leaving anonymous sign-ins enabled.
- Adding `localhost` redirects to production.
- Putting role or company permission data in user-editable metadata.

## Step 3: Execute `schema.sql`

### Exact Supabase screen

Supabase Dashboard -> SQL Editor.

### Exact button to click

Click **New query**.

### Exact configuration

1. Name the query `01_schema`.
2. Open the repository file `database/schema.sql`.
3. Copy the entire file.
4. Paste it into the SQL editor.
5. Confirm you are in the staging project first.
6. Click **Run**.

Repeat in production only after staging passes all checks.

### Expected result

The query completes successfully and creates the database tables, indexes, and triggers.

### Validation method

In **SQL Editor**, click **New query**, paste this validation query, then click **Run**:

```sql
select count(*) as public_table_count
from information_schema.tables
where table_schema = 'public'
  and table_type = 'BASE TABLE';
```

Expected result:

- `public_table_count` is `110`.

### Common mistakes

- Running production before staging.
- Copying only part of `schema.sql`.
- Running `schema.sql` twice in the same project.
- Continuing after an error message.

## Step 4: Execute `rls.sql`

### Exact Supabase screen

Supabase Dashboard -> SQL Editor.

### Exact button to click

Click **New query**.

### Exact configuration

1. Confirm `database/rls.sql` exists.
2. Confirm the technical reviewer approved `database/rls.sql`.
3. Name the query `02_rls`.
4. Open the repository file `database/rls.sql`.
5. Copy the entire file.
6. Paste it into the SQL editor.
7. Confirm you are in the staging project first.
8. Click **Run**.

**STOP if `database/rls.sql` is missing.**

Repeat in production only after staging validation and negative tests pass.

### Expected result

The query completes successfully and enables Row Level Security policies.

### Validation method

Run this query:

```sql
select schemaname, tablename
from pg_tables
where schemaname = 'public'
  and rowsecurity = false
order by tablename;
```

Expected result:

- Zero rows.

Then run:

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

Expected result:

- Zero rows, except tables explicitly marked as no-direct-client-access in the approved `rls.sql`.

### Common mistakes

- Deploying without `rls.sql`.
- Disabling RLS to make an app screen work.
- Ignoring tables that return from the RLS validation query.
- Treating frontend filters as a replacement for RLS.

## Step 5: Create storage buckets

### Exact Supabase screen

Supabase Dashboard -> Storage.

### Exact button to click

Click **New bucket**.

### Exact configuration

Create these buckets only:

| Bucket name | Public bucket setting | Use |
| --- | --- | --- |
| `tenant-files` | Off | Customer files, message attachments, documents |
| `tenant-exports` | Off | LGPD exports and generated exports |
| `tenant-public-assets` | Off unless approved | Company logos and public branding assets |

For each private bucket:

1. Enter the bucket name.
2. Keep **Public bucket** turned off.
3. Click **Create bucket**.

### Expected result

The Storage page shows the approved buckets.

### Validation method

Open **SQL Editor -> New query**, run:

```sql
select id, name, public
from storage.buckets
order by id;
```

Expected result:

- `tenant-files` exists and `public` is false.
- `tenant-exports` exists and `public` is false.
- `tenant-public-assets` is false unless explicitly approved.

### Common mistakes

- Making customer files public.
- Making exports public.
- Uploading provider secrets to Storage.
- Creating extra buckets not listed in the MVP plan.

## Step 6: Configure secrets

### Exact Supabase screen

Supabase Dashboard -> Edge Functions -> Secrets.

### Exact button to click

Click **Add new secret**.

### Exact configuration

Add these secrets where needed:

| Secret | Where to use | Required now? |
| --- | --- | --- |
| `SUPABASE_URL` | Frontend and backend | Yes |
| `SUPABASE_PUBLISHABLE_KEY` or `SUPABASE_ANON_KEY` | Frontend | Yes |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions and backend only | Yes for backend functions |
| `APP_BASE_URL` | Frontend and backend | Yes |
| `INTERNAL_JOB_SECRET` | Scheduled/internal functions | Yes if scheduled jobs exist |

Only add provider secrets when that MVP integration is enabled:

- `HUBSPOT_CLIENT_ID`
- `HUBSPOT_CLIENT_SECRET`
- `MANYCHAT_API_KEY`
- `WHATSAPP_ACCESS_TOKEN`
- `WHATSAPP_WEBHOOK_SECRET`
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `CALENDLY_CLIENT_ID`
- `CALENDLY_CLIENT_SECRET`
- `CALENDLY_WEBHOOK_SECRET`
- `PAYMENT_PROVIDER_SECRET_KEY`
- `PAYMENT_WEBHOOK_SECRET`
- `AI_PROVIDER_API_KEY`
- `EMAIL_PROVIDER_API_KEY`

### Expected result

Secrets appear in the Edge Functions secrets list without showing their values.

### Validation method

Confirm:

- Frontend has only `SUPABASE_URL` and publishable/anon key.
- Service role key is not in frontend variables.
- Staging and production secrets are separate.
- No secret values are committed to Git.

### Common mistakes

- Putting `SUPABASE_SERVICE_ROLE_KEY` in Lovable or Vercel public variables.
- Reusing staging provider secrets in production.
- Pasting secret values into SQL files.
- Logging secrets from Edge Functions.

## Step 7: Configure Edge Functions

### Exact Supabase screen

Supabase Dashboard -> Edge Functions.

### Exact button to click

Use **Deploy a new function** if the button is available in the dashboard. If the dashboard asks for CLI deployment, ask the technical reviewer to deploy the approved function from the repository.

### Exact configuration

Deploy only MVP-approved functions.

Every function must be labeled as one of these:

| Function type | Must validate |
| --- | --- |
| User-delegated | JWT, active profile, active company, active membership, permission, row ownership |
| Webhook | Provider signature, replay protection, active integration, tenant mapping |
| Scheduled job | Internal job secret, company scope, idempotency |
| Platform admin | Platform admin status, platform permission, reason, audit log |

For each function:

1. Confirm it has a staging version.
2. Confirm required secrets exist.
3. Confirm logs do not print tokens, customer exports, payment credentials, or provider secrets.
4. Confirm the function rejects missing or invalid authorization.
5. Deploy staging first.
6. Deploy production only after staging passes.

### Expected result

The Edge Functions page shows only MVP-approved deployed functions.

### Validation method

For each function, confirm:

- Staging invocation succeeds for a valid request.
- Staging invocation rejects an invalid token or invalid signature.
- Logs show no secrets.
- Production has the same secret names with production values.

### Common mistakes

- Deploying future-scope functions before MVP.
- Trusting `company_id` from a request body.
- Using service role without membership or tenant validation.
- Processing webhooks before signature validation.

## Step 8: Create seed data

### Exact Supabase screen

Supabase Dashboard -> Table Editor.

### Exact button to click

Click **Insert** or **Add row** on each table.

### Exact configuration

Create staging seed data first.

Minimum seed set:

1. Two companies:
   - Company A
   - Company B
2. Four Auth users in **Authentication -> Users -> Add user**:
   - Company A Owner
   - Company A Employee
   - Company A Viewer
   - Company B Owner
3. One `user_profiles` row per Auth user.
4. Company roles:
   - Company Owner
   - Employee
   - Viewer
5. Required permission rows from the approved RBAC model.
6. Role permission mappings.
7. `company_members` rows connecting users to companies and roles.
8. Test customer for Company A.
9. Test customer for Company B.
10. Test appointment, CRM deal, invoice, and file metadata for both companies.

### Expected result

Staging has two separate companies with separate users and test records.

### Validation method

Run:

```sql
select c.legal_name, count(cm.id) as member_count
from public.companies c
left join public.company_members cm on cm.company_id = c.id
group by c.legal_name
order by c.legal_name;
```

Expected result:

- Company A has members.
- Company B has members.

Run:

```sql
select c.legal_name, count(cu.id) as customer_count
from public.companies c
left join public.customers cu on cu.company_id = c.id
group by c.legal_name
order by c.legal_name;
```

Expected result:

- Company A has test customers.
- Company B has test customers.

### Common mistakes

- Creating Auth users but forgetting `user_profiles`.
- Creating users but not `company_members`.
- Assigning a role from the wrong company.
- Using one company only, which cannot test tenant isolation.

## Step 9: Run validation tests

### Exact Supabase screen

Supabase Dashboard -> SQL Editor.

### Exact button to click

Click **New query**, paste each query, then click **Run**.

### Exact configuration

Run all validation queries from `database/deployment-checklist.md`.

Minimum required SQL checks:

1. Table count is `110`.
2. All public tables have RLS enabled.
3. Every public table has a policy or approved no-direct-client-access design.
4. No anonymous policies remain on app tables.
5. Tenant-owned table exceptions match the approved derived/platform/system classification.
6. One Auth user has only one profile.
7. Active members do not point to inactive companies.
8. Active members do not use roles from another company.
9. Platform admins use platform roles.
10. Service-role-only tables have RLS enabled.
11. Storage buckets are approved.
12. Storage policies exist.

Then run manual negative tests:

- Company A user cannot see Company B customers.
- Company A user cannot see Company B appointments.
- Company A user cannot see Company B invoices.
- Viewer cannot create or update records.
- Suspended member cannot access tenant data.
- Anonymous user cannot access tenant data.
- Invalid webhook signature is rejected.
- Export for Company A excludes Company B data.

### Expected result

All validation queries return the expected result. All negative tests fail safely.

### Validation method

Create a deployment notes page with:

- Date.
- Environment.
- Person running tests.
- Screenshot or copied result for every validation query.
- Pass/fail for every negative test.
- Technical reviewer approval.

### Common mistakes

- Testing only happy paths.
- Testing only one company.
- Ignoring zero-row update behavior.
- Running validation in staging but not production.

## Step 10: Go-live verification

### Exact Supabase screen

Use these screens:

- Supabase Dashboard -> SQL Editor.
- Supabase Dashboard -> Authentication -> Providers.
- Supabase Dashboard -> Authentication -> URL Configuration.
- Supabase Dashboard -> Storage.
- Supabase Dashboard -> Edge Functions.
- Supabase Dashboard -> Project Settings -> API.

### Exact button to click

Use **Run** in SQL Editor for final queries. Use **Save** on configuration screens after confirming values.

### Exact configuration

Before launch, confirm:

- `database/schema.sql` ran in production.
- `database/rls.sql` ran in production.
- RLS is enabled on every public table.
- Production Auth URLs are correct.
- Anonymous sign-ins are disabled.
- Storage buckets are private except approved public assets.
- Production secrets are configured.
- Service role key is not public.
- Only MVP Edge Functions are deployed.
- Company A cannot access Company B canary records.
- Rollback owner is online.
- Production backup exists.

### Expected result

Production is ready to receive real users and tenant data.

### Validation method

Run the final RLS query:

```sql
select schemaname, tablename
from pg_tables
where schemaname = 'public'
  and rowsecurity = false
order by tablename;
```

Expected result:

- Zero rows.

Run the final table count query:

```sql
select count(*) as public_table_count
from information_schema.tables
where table_schema = 'public'
  and table_type = 'BASE TABLE';
```

Expected result:

- `public_table_count` is `110`.

### Common mistakes

- Launching production before `rls.sql` exists.
- Launching after staging passed but production validation was skipped.
- Leaving service role key in public frontend settings.
- Forgetting to test suspended member access.
- Forgetting to check Storage bucket privacy.

## Final Rule

If every step passes, go-live can proceed.

If any step fails, do not launch. Fix the issue in staging first, re-test, then repeat production validation.
