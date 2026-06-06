-- Casa Di Amo OS - Supabase RLS implementation
-- Source documents: database/schema.sql, database/rls-strategy-v2.md, docs/multi-tenancy-strategy.md, docs/rbac-model.md
-- This file enables RLS, defines private authorization helpers, and creates table-class policies.
-- Service-role and secret keys bypass RLS by design and must only be used in trusted server-side environments.

begin;

create schema if not exists app_private;
revoke all on schema app_private from public;
revoke all on schema app_private from anon;
revoke all on schema app_private from authenticated;
grant usage on schema app_private to authenticated, service_role;

-- Remove default public API exposure first; grant back only the operations protected below.
revoke all on all tables in schema public from anon;
revoke all on all tables in schema public from authenticated;
revoke all on all sequences in schema public from anon;
revoke all on all sequences in schema public from authenticated;
grant all on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to service_role;

-- Enable and force RLS on every table in the exposed public schema.
alter table public.platform_roles enable row level security;
alter table public.platform_roles force row level security;
alter table public.platform_permissions enable row level security;
alter table public.platform_permissions force row level security;
alter table public.platform_role_permissions enable row level security;
alter table public.platform_role_permissions force row level security;
alter table public.user_profiles enable row level security;
alter table public.user_profiles force row level security;
alter table public.platform_admins enable row level security;
alter table public.platform_admins force row level security;
alter table public.plans enable row level security;
alter table public.plans force row level security;
alter table public.features enable row level security;
alter table public.features force row level security;
alter table public.plan_features enable row level security;
alter table public.plan_features force row level security;
alter table public.companies enable row level security;
alter table public.companies force row level security;
alter table public.billing_accounts enable row level security;
alter table public.billing_accounts force row level security;
alter table public.company_subscriptions enable row level security;
alter table public.company_subscriptions force row level security;
alter table public.subscription_items enable row level security;
alter table public.subscription_items force row level security;
alter table public.company_feature_entitlements enable row level security;
alter table public.company_feature_entitlements force row level security;
alter table public.usage_limits enable row level security;
alter table public.usage_limits force row level security;
alter table public.usage_counters enable row level security;
alter table public.usage_counters force row level security;
alter table public.usage_records enable row level security;
alter table public.usage_records force row level security;
alter table public.tenant_invoices enable row level security;
alter table public.tenant_invoices force row level security;
alter table public.company_settings enable row level security;
alter table public.company_settings force row level security;
alter table public.company_branding enable row level security;
alter table public.company_branding force row level security;
alter table public.company_locations enable row level security;
alter table public.company_locations force row level security;
alter table public.roles enable row level security;
alter table public.roles force row level security;
alter table public.permissions enable row level security;
alter table public.permissions force row level security;
alter table public.role_permissions enable row level security;
alter table public.role_permissions force row level security;
alter table public.company_members enable row level security;
alter table public.company_members force row level security;
alter table public.company_invitations enable row level security;
alter table public.company_invitations force row level security;
alter table public.user_sessions_audit enable row level security;
alter table public.user_sessions_audit force row level security;
alter table public.platform_admin_audit_logs enable row level security;
alter table public.platform_admin_audit_logs force row level security;
alter table public.staff_profiles enable row level security;
alter table public.staff_profiles force row level security;
alter table public.staff_working_hours enable row level security;
alter table public.staff_working_hours force row level security;
alter table public.staff_time_off enable row level security;
alter table public.staff_time_off force row level security;
alter table public.api_clients enable row level security;
alter table public.api_clients force row level security;
alter table public.api_keys enable row level security;
alter table public.api_keys force row level security;
alter table public.service_accounts enable row level security;
alter table public.service_accounts force row level security;
alter table public.customers enable row level security;
alter table public.customers force row level security;
alter table public.customer_addresses enable row level security;
alter table public.customer_addresses force row level security;
alter table public.customer_notes enable row level security;
alter table public.customer_notes force row level security;
alter table public.customer_tags enable row level security;
alter table public.customer_tags force row level security;
alter table public.customer_tag_assignments enable row level security;
alter table public.customer_tag_assignments force row level security;
alter table public.customer_consents enable row level security;
alter table public.customer_consents force row level security;
alter table public.service_categories enable row level security;
alter table public.service_categories force row level security;
alter table public.services enable row level security;
alter table public.services force row level security;
alter table public.service_resources enable row level security;
alter table public.service_resources force row level security;
alter table public.service_staff_assignments enable row level security;
alter table public.service_staff_assignments force row level security;
alter table public.recurring_appointment_rules enable row level security;
alter table public.recurring_appointment_rules force row level security;
alter table public.appointments enable row level security;
alter table public.appointments force row level security;
alter table public.appointment_services enable row level security;
alter table public.appointment_services force row level security;
alter table public.appointment_participants enable row level security;
alter table public.appointment_participants force row level security;
alter table public.appointment_status_history enable row level security;
alter table public.appointment_status_history force row level security;
alter table public.appointment_reminders enable row level security;
alter table public.appointment_reminders force row level security;
alter table public.appointment_waitlists enable row level security;
alter table public.appointment_waitlists force row level security;
alter table public.resource_bookings enable row level security;
alter table public.resource_bookings force row level security;
alter table public.booking_holds enable row level security;
alter table public.booking_holds force row level security;
alter table public.calendar_connections enable row level security;
alter table public.calendar_connections force row level security;
alter table public.calendar_event_mappings enable row level security;
alter table public.calendar_event_mappings force row level security;
alter table public.crm_pipelines enable row level security;
alter table public.crm_pipelines force row level security;
alter table public.crm_stages enable row level security;
alter table public.crm_stages force row level security;
alter table public.crm_deals enable row level security;
alter table public.crm_deals force row level security;
alter table public.crm_activities enable row level security;
alter table public.crm_activities force row level security;
alter table public.crm_external_mappings enable row level security;
alter table public.crm_external_mappings force row level security;
alter table public.files enable row level security;
alter table public.files force row level security;
alter table public.media_assets enable row level security;
alter table public.media_assets force row level security;
alter table public.document_templates enable row level security;
alter table public.document_templates force row level security;
alter table public.file_links enable row level security;
alter table public.file_links force row level security;
alter table public.message_templates enable row level security;
alter table public.message_templates force row level security;
alter table public.marketing_audiences enable row level security;
alter table public.marketing_audiences force row level security;
alter table public.marketing_campaigns enable row level security;
alter table public.marketing_campaigns force row level security;
alter table public.marketing_messages enable row level security;
alter table public.marketing_messages force row level security;
alter table public.marketing_deliveries enable row level security;
alter table public.marketing_deliveries force row level security;
alter table public.conversations enable row level security;
alter table public.conversations force row level security;
alter table public.conversation_participants enable row level security;
alter table public.conversation_participants force row level security;
alter table public.messages enable row level security;
alter table public.messages force row level security;
alter table public.message_attachments enable row level security;
alter table public.message_attachments force row level security;
alter table public.message_status_events enable row level security;
alter table public.message_status_events force row level security;
alter table public.notification_preferences enable row level security;
alter table public.notification_preferences force row level security;
alter table public.integration_connections enable row level security;
alter table public.integration_connections force row level security;
alter table public.oauth_grants enable row level security;
alter table public.oauth_grants force row level security;
alter table public.integration_sync_jobs enable row level security;
alter table public.integration_sync_jobs force row level security;
alter table public.webhook_signing_secrets enable row level security;
alter table public.webhook_signing_secrets force row level security;
alter table public.webhook_events enable row level security;
alter table public.webhook_events force row level security;
alter table public.automation_workflows enable row level security;
alter table public.automation_workflows force row level security;
alter table public.automation_triggers enable row level security;
alter table public.automation_triggers force row level security;
alter table public.automation_steps enable row level security;
alter table public.automation_steps force row level security;
alter table public.automation_events enable row level security;
alter table public.automation_events force row level security;
alter table public.automation_runs enable row level security;
alter table public.automation_runs force row level security;
alter table public.automation_run_steps enable row level security;
alter table public.automation_run_steps force row level security;
alter table public.payment_customers enable row level security;
alter table public.payment_customers force row level security;
alter table public.subscriptions enable row level security;
alter table public.subscriptions force row level security;
alter table public.invoices enable row level security;
alter table public.invoices force row level security;
alter table public.invoice_items enable row level security;
alter table public.invoice_items force row level security;
alter table public.payments enable row level security;
alter table public.payments force row level security;
alter table public.refunds enable row level security;
alter table public.refunds force row level security;
alter table public.report_definitions enable row level security;
alter table public.report_definitions force row level security;
alter table public.report_snapshots enable row level security;
alter table public.report_snapshots force row level security;
alter table public.metric_daily_rollups enable row level security;
alter table public.metric_daily_rollups force row level security;
alter table public.audit_logs enable row level security;
alter table public.audit_logs force row level security;
alter table public.data_subject_requests enable row level security;
alter table public.data_subject_requests force row level security;
alter table public.data_exports enable row level security;
alter table public.data_exports force row level security;
alter table public.data_deletion_jobs enable row level security;
alter table public.data_deletion_jobs force row level security;
alter table public.retention_policies enable row level security;
alter table public.retention_policies force row level security;
alter table public.consent_audit_logs enable row level security;
alter table public.consent_audit_logs force row level security;
alter table public.job_queue enable row level security;
alter table public.job_queue force row level security;
alter table public.job_attempts enable row level security;
alter table public.job_attempts force row level security;
alter table public.idempotency_keys enable row level security;
alter table public.idempotency_keys force row level security;
alter table public.outbox_events enable row level security;
alter table public.outbox_events force row level security;
alter table public.dead_letter_events enable row level security;
alter table public.dead_letter_events force row level security;
alter table public.ai_prompts enable row level security;
alter table public.ai_prompts force row level security;
alter table public.ai_runs enable row level security;
alter table public.ai_runs force row level security;
alter table public.ai_outputs enable row level security;
alter table public.ai_outputs force row level security;
alter table public.ai_usage_records enable row level security;
alter table public.ai_usage_records force row level security;
alter table public.ai_feedback enable row level security;
alter table public.ai_feedback force row level security;

-- Private authorization helpers. Keep SECURITY DEFINER functions outside exposed schemas.
create or replace function app_private.current_user_profile_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select up.id
  from public.user_profiles up
  where up.auth_user_id = auth.uid()
    and up.status = 'active'
  limit 1;
$$;

create or replace function app_private.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.platform_admins pa
    join public.platform_roles pr on pr.id = pa.platform_role_id
    where pa.user_profile_id = app_private.current_user_profile_id()
      and pa.status = 'active'
      and pr.status = 'active'
  );
$$;

create or replace function app_private.has_platform_permission(p_permission_key text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.platform_admins pa
    join public.platform_roles pr on pr.id = pa.platform_role_id
    join public.platform_role_permissions prp on prp.platform_role_id = pr.id
    join public.platform_permissions pp on pp.id = prp.platform_permission_id
    where pa.user_profile_id = app_private.current_user_profile_id()
      and pa.status = 'active'
      and pr.status = 'active'
      and pp.permission_key = p_permission_key
  );
$$;

create or replace function app_private.is_company_active(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.companies c
    where c.id = p_company_id
      and c.status = 'active'
  );
$$;

create or replace function app_private.is_company_member(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.company_members cm
    join public.roles r on r.id = cm.role_id
    where cm.company_id = p_company_id
      and cm.user_profile_id = app_private.current_user_profile_id()
      and cm.status = 'active'
      and r.status = 'active'
      and r.company_id = p_company_id
      and r.scope = 'company'
  );
$$;

create or replace function app_private.can_access_company(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_company_id is not null
     and app_private.is_company_active(p_company_id)
     and app_private.is_company_member(p_company_id);
$$;

create or replace function app_private.has_company_permission_key(p_company_id uuid, p_permission_key text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.company_members cm
    join public.roles r on r.id = cm.role_id
    join public.role_permissions rp on rp.role_id = r.id
    join public.permissions p on p.id = rp.permission_id
    where cm.company_id = p_company_id
      and cm.user_profile_id = app_private.current_user_profile_id()
      and cm.status = 'active'
      and r.status = 'active'
      and r.company_id = p_company_id
      and r.scope = 'company'
      and p.permission_key = p_permission_key
  );
$$;

create or replace function app_private.can_company(p_company_id uuid, p_module text, p_action text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select app_private.is_company_member(p_company_id)
     and (
       app_private.has_company_permission_key(p_company_id, p_module || '.' || p_action)
       or app_private.has_company_permission_key(p_company_id, p_module || '.manage')
     );
$$;

create or replace function app_private.can_company_operate(p_company_id uuid, p_module text, p_action text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select app_private.is_company_active(p_company_id)
     and app_private.can_company(p_company_id, p_module, p_action);
$$;

create or replace function app_private.has_any_company_permission_key(p_company_id uuid, p_permission_keys text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from unnest(p_permission_keys) permission_key
    where app_private.has_company_permission_key(p_company_id, permission_key)
  );
$$;

create or replace function app_private.role_belongs_to_company(p_role_id uuid, p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_role_id is not null
     and exists (
       select 1
       from public.roles r
       where r.id = p_role_id
         and r.company_id = p_company_id
         and r.status = 'active'
         and r.scope = 'company'
     );
$$;

create or replace function app_private.profile_shares_company(p_user_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_user_profile_id = app_private.current_user_profile_id()
      or exists (
        select 1
        from public.company_members self_cm
        join public.company_members target_cm on target_cm.company_id = self_cm.company_id
        where self_cm.user_profile_id = app_private.current_user_profile_id()
          and target_cm.user_profile_id = p_user_profile_id
          and self_cm.status = 'active'
          and target_cm.status = 'active'
          and app_private.is_company_active(self_cm.company_id)
      );
$$;

create or replace function app_private.company_for_entity(p_entity_type text, p_entity_id uuid)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_company_id uuid;
  v_entity_type text := lower(coalesce(p_entity_type, ''));
begin
  if p_entity_id is null then
    return null;
  end if;

  case v_entity_type
    when 'platform_role', 'platform_roles' then
      v_company_id := null;
    when 'platform_permission', 'platform_permissions' then
      v_company_id := null;
    when 'platform_role_permission', 'platform_role_permissions' then
      v_company_id := null;
    when 'user_profile', 'user_profiles' then
      v_company_id := null;
    when 'platform_admin', 'platform_admins' then
      v_company_id := null;
    when 'plan', 'plans' then
      v_company_id := null;
    when 'feature', 'features' then
      v_company_id := null;
    when 'plan_feature', 'plan_features' then
      v_company_id := null;
    when 'companies', 'company' then
      v_company_id := p_entity_id;
    when 'billing_account', 'billing_accounts' then
      select e.company_id into v_company_id from public.billing_accounts e where e.id = p_entity_id;
    when 'company_subscription', 'company_subscriptions' then
      select e.company_id into v_company_id from public.company_subscriptions e where e.id = p_entity_id;
    when 'subscription_item', 'subscription_items' then
      select cs.company_id into v_company_id from public.subscription_items e join public.company_subscriptions cs on cs.id = e.company_subscription_id where e.id = p_entity_id;
    when 'company_feature_entitlement', 'company_feature_entitlements' then
      select e.company_id into v_company_id from public.company_feature_entitlements e where e.id = p_entity_id;
    when 'usage_limit', 'usage_limits' then
      select e.company_id into v_company_id from public.usage_limits e where e.id = p_entity_id;
    when 'usage_counter', 'usage_counters' then
      select e.company_id into v_company_id from public.usage_counters e where e.id = p_entity_id;
    when 'usage_record', 'usage_records' then
      select e.company_id into v_company_id from public.usage_records e where e.id = p_entity_id;
    when 'tenant_invoice', 'tenant_invoices' then
      select ba.company_id into v_company_id from public.tenant_invoices e join public.billing_accounts ba on ba.id = e.billing_account_id where e.id = p_entity_id;
    when 'company_setting', 'company_settings' then
      select e.company_id into v_company_id from public.company_settings e where e.id = p_entity_id;
    when 'company_branding' then
      select e.company_id into v_company_id from public.company_branding e where e.id = p_entity_id;
    when 'company_location', 'company_locations' then
      select e.company_id into v_company_id from public.company_locations e where e.id = p_entity_id;
    when 'role', 'roles' then
      select e.company_id into v_company_id from public.roles e where e.id = p_entity_id;
    when 'permission', 'permissions' then
      v_company_id := null;
    when 'role_permission', 'role_permissions' then
      select r.company_id into v_company_id from public.role_permissions e join public.roles r on r.id = e.role_id where e.id = p_entity_id;
    when 'company_member', 'company_members' then
      select e.company_id into v_company_id from public.company_members e where e.id = p_entity_id;
    when 'company_invitation', 'company_invitations' then
      select e.company_id into v_company_id from public.company_invitations e where e.id = p_entity_id;
    when 'user_sessions_audit' then
      v_company_id := null;
    when 'platform_admin_audit_log', 'platform_admin_audit_logs' then
      v_company_id := null;
    when 'staff_profile', 'staff_profiles' then
      select e.company_id into v_company_id from public.staff_profiles e where e.id = p_entity_id;
    when 'staff_working_hour', 'staff_working_hours' then
      select e.company_id into v_company_id from public.staff_working_hours e where e.id = p_entity_id;
    when 'staff_time_off' then
      select e.company_id into v_company_id from public.staff_time_off e where e.id = p_entity_id;
    when 'api_client', 'api_clients' then
      select e.company_id into v_company_id from public.api_clients e where e.id = p_entity_id;
    when 'api_key', 'api_keys' then
      select ac.company_id into v_company_id from public.api_keys e join public.api_clients ac on ac.id = e.api_client_id where e.id = p_entity_id;
    when 'service_account', 'service_accounts' then
      select e.company_id into v_company_id from public.service_accounts e where e.id = p_entity_id;
    when 'customer', 'customers' then
      select e.company_id into v_company_id from public.customers e where e.id = p_entity_id;
    when 'customer_addresse', 'customer_addresses' then
      select e.company_id into v_company_id from public.customer_addresses e where e.id = p_entity_id;
    when 'customer_note', 'customer_notes' then
      select e.company_id into v_company_id from public.customer_notes e where e.id = p_entity_id;
    when 'customer_tag', 'customer_tags' then
      select e.company_id into v_company_id from public.customer_tags e where e.id = p_entity_id;
    when 'customer_tag_assignment', 'customer_tag_assignments' then
      select e.company_id into v_company_id from public.customer_tag_assignments e where e.id = p_entity_id;
    when 'customer_consent', 'customer_consents' then
      select e.company_id into v_company_id from public.customer_consents e where e.id = p_entity_id;
    when 'service_categorie', 'service_categories' then
      select e.company_id into v_company_id from public.service_categories e where e.id = p_entity_id;
    when 'service', 'services' then
      select e.company_id into v_company_id from public.services e where e.id = p_entity_id;
    when 'service_resource', 'service_resources' then
      select e.company_id into v_company_id from public.service_resources e where e.id = p_entity_id;
    when 'service_staff_assignment', 'service_staff_assignments' then
      select e.company_id into v_company_id from public.service_staff_assignments e where e.id = p_entity_id;
    when 'recurring_appointment_rule', 'recurring_appointment_rules' then
      select e.company_id into v_company_id from public.recurring_appointment_rules e where e.id = p_entity_id;
    when 'appointment', 'appointments' then
      select e.company_id into v_company_id from public.appointments e where e.id = p_entity_id;
    when 'appointment_service', 'appointment_services' then
      select e.company_id into v_company_id from public.appointment_services e where e.id = p_entity_id;
    when 'appointment_participant', 'appointment_participants' then
      select e.company_id into v_company_id from public.appointment_participants e where e.id = p_entity_id;
    when 'appointment_status_history' then
      select e.company_id into v_company_id from public.appointment_status_history e where e.id = p_entity_id;
    when 'appointment_reminder', 'appointment_reminders' then
      select e.company_id into v_company_id from public.appointment_reminders e where e.id = p_entity_id;
    when 'appointment_waitlist', 'appointment_waitlists' then
      select e.company_id into v_company_id from public.appointment_waitlists e where e.id = p_entity_id;
    when 'resource_booking', 'resource_bookings' then
      select e.company_id into v_company_id from public.resource_bookings e where e.id = p_entity_id;
    when 'booking_hold', 'booking_holds' then
      select e.company_id into v_company_id from public.booking_holds e where e.id = p_entity_id;
    when 'calendar_connection', 'calendar_connections' then
      select e.company_id into v_company_id from public.calendar_connections e where e.id = p_entity_id;
    when 'calendar_event_mapping', 'calendar_event_mappings' then
      select e.company_id into v_company_id from public.calendar_event_mappings e where e.id = p_entity_id;
    when 'crm_pipeline', 'crm_pipelines' then
      select e.company_id into v_company_id from public.crm_pipelines e where e.id = p_entity_id;
    when 'crm_stage', 'crm_stages' then
      select e.company_id into v_company_id from public.crm_stages e where e.id = p_entity_id;
    when 'crm_deal', 'crm_deals' then
      select e.company_id into v_company_id from public.crm_deals e where e.id = p_entity_id;
    when 'crm_activitie', 'crm_activities' then
      select e.company_id into v_company_id from public.crm_activities e where e.id = p_entity_id;
    when 'crm_external_mapping', 'crm_external_mappings' then
      select e.company_id into v_company_id from public.crm_external_mappings e where e.id = p_entity_id;
    when 'file', 'files' then
      select e.company_id into v_company_id from public.files e where e.id = p_entity_id;
    when 'media_asset', 'media_assets' then
      select e.company_id into v_company_id from public.media_assets e where e.id = p_entity_id;
    when 'document_template', 'document_templates' then
      select e.company_id into v_company_id from public.document_templates e where e.id = p_entity_id;
    when 'file_link', 'file_links' then
      select e.company_id into v_company_id from public.file_links e where e.id = p_entity_id;
    when 'message_template', 'message_templates' then
      select e.company_id into v_company_id from public.message_templates e where e.id = p_entity_id;
    when 'marketing_audience', 'marketing_audiences' then
      select e.company_id into v_company_id from public.marketing_audiences e where e.id = p_entity_id;
    when 'marketing_campaign', 'marketing_campaigns' then
      select e.company_id into v_company_id from public.marketing_campaigns e where e.id = p_entity_id;
    when 'marketing_message', 'marketing_messages' then
      select e.company_id into v_company_id from public.marketing_messages e where e.id = p_entity_id;
    when 'marketing_deliverie', 'marketing_deliveries' then
      select e.company_id into v_company_id from public.marketing_deliveries e where e.id = p_entity_id;
    when 'conversation', 'conversations' then
      select e.company_id into v_company_id from public.conversations e where e.id = p_entity_id;
    when 'conversation_participant', 'conversation_participants' then
      select e.company_id into v_company_id from public.conversation_participants e where e.id = p_entity_id;
    when 'message', 'messages' then
      select e.company_id into v_company_id from public.messages e where e.id = p_entity_id;
    when 'message_attachment', 'message_attachments' then
      select e.company_id into v_company_id from public.message_attachments e where e.id = p_entity_id;
    when 'message_status_event', 'message_status_events' then
      select e.company_id into v_company_id from public.message_status_events e where e.id = p_entity_id;
    when 'notification_preference', 'notification_preferences' then
      select e.company_id into v_company_id from public.notification_preferences e where e.id = p_entity_id;
    when 'integration_connection', 'integration_connections' then
      select e.company_id into v_company_id from public.integration_connections e where e.id = p_entity_id;
    when 'oauth_grant', 'oauth_grants' then
      select e.company_id into v_company_id from public.oauth_grants e where e.id = p_entity_id;
    when 'integration_sync_job', 'integration_sync_jobs' then
      select e.company_id into v_company_id from public.integration_sync_jobs e where e.id = p_entity_id;
    when 'webhook_signing_secret', 'webhook_signing_secrets' then
      select e.company_id into v_company_id from public.webhook_signing_secrets e where e.id = p_entity_id;
    when 'webhook_event', 'webhook_events' then
      select e.company_id into v_company_id from public.webhook_events e where e.id = p_entity_id;
    when 'automation_workflow', 'automation_workflows' then
      select e.company_id into v_company_id from public.automation_workflows e where e.id = p_entity_id;
    when 'automation_trigger', 'automation_triggers' then
      select e.company_id into v_company_id from public.automation_triggers e where e.id = p_entity_id;
    when 'automation_step', 'automation_steps' then
      select e.company_id into v_company_id from public.automation_steps e where e.id = p_entity_id;
    when 'automation_event', 'automation_events' then
      select e.company_id into v_company_id from public.automation_events e where e.id = p_entity_id;
    when 'automation_run', 'automation_runs' then
      select e.company_id into v_company_id from public.automation_runs e where e.id = p_entity_id;
    when 'automation_run_step', 'automation_run_steps' then
      select e.company_id into v_company_id from public.automation_run_steps e where e.id = p_entity_id;
    when 'payment_customer', 'payment_customers' then
      select e.company_id into v_company_id from public.payment_customers e where e.id = p_entity_id;
    when 'subscription', 'subscriptions' then
      select e.company_id into v_company_id from public.subscriptions e where e.id = p_entity_id;
    when 'invoice', 'invoices' then
      select e.company_id into v_company_id from public.invoices e where e.id = p_entity_id;
    when 'invoice_item', 'invoice_items' then
      select e.company_id into v_company_id from public.invoice_items e where e.id = p_entity_id;
    when 'payment', 'payments' then
      select e.company_id into v_company_id from public.payments e where e.id = p_entity_id;
    when 'refund', 'refunds' then
      select e.company_id into v_company_id from public.refunds e where e.id = p_entity_id;
    when 'report_definition', 'report_definitions' then
      select e.company_id into v_company_id from public.report_definitions e where e.id = p_entity_id;
    when 'report_snapshot', 'report_snapshots' then
      select e.company_id into v_company_id from public.report_snapshots e where e.id = p_entity_id;
    when 'metric_daily_rollup', 'metric_daily_rollups' then
      select e.company_id into v_company_id from public.metric_daily_rollups e where e.id = p_entity_id;
    when 'audit_log', 'audit_logs' then
      select e.company_id into v_company_id from public.audit_logs e where e.id = p_entity_id;
    when 'data_subject_request', 'data_subject_requests' then
      select e.company_id into v_company_id from public.data_subject_requests e where e.id = p_entity_id;
    when 'data_export', 'data_exports' then
      select e.company_id into v_company_id from public.data_exports e where e.id = p_entity_id;
    when 'data_deletion_job', 'data_deletion_jobs' then
      select e.company_id into v_company_id from public.data_deletion_jobs e where e.id = p_entity_id;
    when 'retention_policie', 'retention_policies' then
      select e.company_id into v_company_id from public.retention_policies e where e.id = p_entity_id;
    when 'consent_audit_log', 'consent_audit_logs' then
      select e.company_id into v_company_id from public.consent_audit_logs e where e.id = p_entity_id;
    when 'job_queue' then
      select e.company_id into v_company_id from public.job_queue e where e.id = p_entity_id;
    when 'job_attempt', 'job_attempts' then
      select jq.company_id into v_company_id from public.job_attempts e join public.job_queue jq on jq.id = e.job_queue_id where e.id = p_entity_id;
    when 'idempotency_key', 'idempotency_keys' then
      select e.company_id into v_company_id from public.idempotency_keys e where e.id = p_entity_id;
    when 'outbox_event', 'outbox_events' then
      select e.company_id into v_company_id from public.outbox_events e where e.id = p_entity_id;
    when 'dead_letter_event', 'dead_letter_events' then
      select e.company_id into v_company_id from public.dead_letter_events e where e.id = p_entity_id;
    when 'ai_prompt', 'ai_prompts' then
      select e.company_id into v_company_id from public.ai_prompts e where e.id = p_entity_id;
    when 'ai_run', 'ai_runs' then
      select e.company_id into v_company_id from public.ai_runs e where e.id = p_entity_id;
    when 'ai_output', 'ai_outputs' then
      select e.company_id into v_company_id from public.ai_outputs e where e.id = p_entity_id;
    when 'ai_usage_record', 'ai_usage_records' then
      select e.company_id into v_company_id from public.ai_usage_records e where e.id = p_entity_id;
    when 'ai_feedback' then
      select e.company_id into v_company_id from public.ai_feedback e where e.id = p_entity_id;
    else
      v_company_id := null;
  end case;

  return v_company_id;
end;
$$;

create or replace function app_private.entity_belongs_to_company(p_entity_type text, p_entity_id uuid, p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_company_id is not null
     and app_private.company_for_entity(p_entity_type, p_entity_id) = p_company_id;
$$;

create or replace function app_private.null_or_entity_belongs_to_company(p_entity_type text, p_entity_id uuid, p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_entity_id is null
      or app_private.entity_belongs_to_company(p_entity_type, p_entity_id, p_company_id);
$$;

revoke all on all functions in schema app_private from public;
grant execute on all functions in schema app_private to authenticated, service_role;

-- Authenticated grants. Secret and worker-private tables intentionally receive no client grants.
grant select, insert, update, delete on public.platform_roles to authenticated;
grant select, insert, update, delete on public.platform_permissions to authenticated;
grant select, insert, update, delete on public.platform_role_permissions to authenticated;
grant select, insert on public.user_profiles to authenticated;
grant select, insert, update, delete on public.platform_admins to authenticated;
grant select, insert, update, delete on public.plans to authenticated;
grant select, insert, update, delete on public.features to authenticated;
grant select, insert, update, delete on public.plan_features to authenticated;
grant select, update on public.companies to authenticated;
grant select, insert, update, delete on public.billing_accounts to authenticated;
grant select, insert, update, delete on public.company_subscriptions to authenticated;
grant select, insert, update, delete on public.subscription_items to authenticated;
grant select, insert, update, delete on public.company_feature_entitlements to authenticated;
grant select, insert, update, delete on public.usage_limits to authenticated;
grant select on public.usage_counters to authenticated;
grant select on public.usage_records to authenticated;
grant select, insert, update, delete on public.tenant_invoices to authenticated;
grant select, insert, update, delete on public.company_settings to authenticated;
grant select, insert, update, delete on public.company_branding to authenticated;
grant select, insert, update, delete on public.company_locations to authenticated;
grant select, insert, update, delete on public.roles to authenticated;
grant select, insert, update, delete on public.permissions to authenticated;
grant select, insert, update, delete on public.role_permissions to authenticated;
grant select, insert, update, delete on public.company_members to authenticated;
grant select, insert, update, delete on public.company_invitations to authenticated;
grant select on public.user_sessions_audit to authenticated;
grant select, insert, update, delete on public.platform_admin_audit_logs to authenticated;
grant select, insert, update, delete on public.staff_profiles to authenticated;
grant select, insert, update, delete on public.staff_working_hours to authenticated;
grant select, insert, update, delete on public.staff_time_off to authenticated;
grant select, insert, update, delete on public.api_clients to authenticated;
grant select, insert, update, delete on public.service_accounts to authenticated;
grant select, insert, update, delete on public.customers to authenticated;
grant select, insert, update, delete on public.customer_addresses to authenticated;
grant select, insert, update, delete on public.customer_notes to authenticated;
grant select, insert, update, delete on public.customer_tags to authenticated;
grant select, insert, update, delete on public.customer_tag_assignments to authenticated;
grant select, insert, update, delete on public.customer_consents to authenticated;
grant select, insert, update, delete on public.service_categories to authenticated;
grant select, insert, update, delete on public.services to authenticated;
grant select, insert, update, delete on public.service_resources to authenticated;
grant select, insert, update, delete on public.service_staff_assignments to authenticated;
grant select, insert, update, delete on public.recurring_appointment_rules to authenticated;
grant select, insert, update, delete on public.appointments to authenticated;
grant select, insert, update, delete on public.appointment_services to authenticated;
grant select, insert, update, delete on public.appointment_participants to authenticated;
grant select on public.appointment_status_history to authenticated;
grant select on public.appointment_reminders to authenticated;
grant select, insert, update, delete on public.appointment_waitlists to authenticated;
grant select, insert, update, delete on public.resource_bookings to authenticated;
grant select, insert, update, delete on public.booking_holds to authenticated;
grant select, insert, update, delete on public.calendar_connections to authenticated;
grant select, insert, update, delete on public.calendar_event_mappings to authenticated;
grant select, insert, update, delete on public.crm_pipelines to authenticated;
grant select, insert, update, delete on public.crm_stages to authenticated;
grant select, insert, update, delete on public.crm_deals to authenticated;
grant select, insert, update, delete on public.crm_activities to authenticated;
grant select, insert, update, delete on public.crm_external_mappings to authenticated;
grant select, insert, update, delete on public.files to authenticated;
grant select, insert, update, delete on public.media_assets to authenticated;
grant select, insert, update, delete on public.document_templates to authenticated;
grant select, insert, update, delete on public.file_links to authenticated;
grant select, insert, update, delete on public.message_templates to authenticated;
grant select, insert, update, delete on public.marketing_audiences to authenticated;
grant select, insert, update, delete on public.marketing_campaigns to authenticated;
grant select, insert, update, delete on public.marketing_messages to authenticated;
grant select on public.marketing_deliveries to authenticated;
grant select, insert, update, delete on public.conversations to authenticated;
grant select, insert, update, delete on public.conversation_participants to authenticated;
grant select, insert, update, delete on public.messages to authenticated;
grant select, insert, update, delete on public.message_attachments to authenticated;
grant select, insert, update, delete on public.message_status_events to authenticated;
grant select, insert, update, delete on public.notification_preferences to authenticated;
grant select, insert, update, delete on public.integration_connections to authenticated;
grant select on public.integration_sync_jobs to authenticated;
grant select on public.webhook_events to authenticated;
grant select, insert, update, delete on public.automation_workflows to authenticated;
grant select, insert, update, delete on public.automation_triggers to authenticated;
grant select, insert, update, delete on public.automation_steps to authenticated;
grant select on public.automation_events to authenticated;
grant select on public.automation_runs to authenticated;
grant select on public.automation_run_steps to authenticated;
grant select, insert, update, delete on public.payment_customers to authenticated;
grant select, insert, update, delete on public.subscriptions to authenticated;
grant select, insert, update, delete on public.invoices to authenticated;
grant select, insert, update, delete on public.invoice_items to authenticated;
grant select, insert, update, delete on public.payments to authenticated;
grant select, insert, update, delete on public.refunds to authenticated;
grant select, insert, update, delete on public.report_definitions to authenticated;
grant select on public.report_snapshots to authenticated;
grant select on public.metric_daily_rollups to authenticated;
grant select on public.audit_logs to authenticated;
grant select, insert, update, delete on public.data_subject_requests to authenticated;
grant select, insert, update, delete on public.data_exports to authenticated;
grant select, insert, update, delete on public.data_deletion_jobs to authenticated;
grant select, insert, update, delete on public.retention_policies to authenticated;
grant select on public.consent_audit_logs to authenticated;
grant select, insert, update, delete on public.ai_prompts to authenticated;
grant select, insert, update, delete on public.ai_runs to authenticated;
grant select, insert, update, delete on public.ai_outputs to authenticated;
grant select on public.ai_usage_records to authenticated;
grant select, insert, update, delete on public.ai_feedback to authenticated;
revoke update on public.user_profiles from authenticated;
grant update (full_name, phone, avatar_url, locale, timezone, preferences, updated_at) on public.user_profiles to authenticated;

-- Platform administration policies.
drop policy if exists "platform_admin_select" on public.platform_admin_audit_logs;
create policy "platform_admin_select" on public.platform_admin_audit_logs for select to authenticated using (app_private.is_platform_admin());
drop policy if exists "platform_admin_select" on public.platform_admins;
create policy "platform_admin_select" on public.platform_admins for select to authenticated using (app_private.is_platform_admin());
drop policy if exists "platform_admin_insert" on public.platform_admins;
create policy "platform_admin_insert" on public.platform_admins for insert to authenticated with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_update" on public.platform_admins;
create policy "platform_admin_update" on public.platform_admins for update to authenticated using (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review')) with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_delete" on public.platform_admins;
create policy "platform_admin_delete" on public.platform_admins for delete to authenticated using (app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_admin_select" on public.platform_permissions;
create policy "platform_admin_select" on public.platform_permissions for select to authenticated using (app_private.is_platform_admin());
drop policy if exists "platform_admin_insert" on public.platform_permissions;
create policy "platform_admin_insert" on public.platform_permissions for insert to authenticated with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_update" on public.platform_permissions;
create policy "platform_admin_update" on public.platform_permissions for update to authenticated using (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review')) with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_delete" on public.platform_permissions;
create policy "platform_admin_delete" on public.platform_permissions for delete to authenticated using (app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_admin_select" on public.platform_role_permissions;
create policy "platform_admin_select" on public.platform_role_permissions for select to authenticated using (app_private.is_platform_admin());
drop policy if exists "platform_admin_insert" on public.platform_role_permissions;
create policy "platform_admin_insert" on public.platform_role_permissions for insert to authenticated with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_update" on public.platform_role_permissions;
create policy "platform_admin_update" on public.platform_role_permissions for update to authenticated using (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review')) with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_delete" on public.platform_role_permissions;
create policy "platform_admin_delete" on public.platform_role_permissions for delete to authenticated using (app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_admin_select" on public.platform_roles;
create policy "platform_admin_select" on public.platform_roles for select to authenticated using (app_private.is_platform_admin());
drop policy if exists "platform_admin_insert" on public.platform_roles;
create policy "platform_admin_insert" on public.platform_roles for insert to authenticated with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_update" on public.platform_roles;
create policy "platform_admin_update" on public.platform_roles for update to authenticated using (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review')) with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_admin_delete" on public.platform_roles;
create policy "platform_admin_delete" on public.platform_roles for delete to authenticated using (app_private.has_platform_permission('platform.manage'));

-- Platform catalog and permission catalog policies.
drop policy if exists "catalog_select" on public.plans;
create policy "catalog_select" on public.plans for select to authenticated using (app_private.is_platform_admin() or status = 'active');
drop policy if exists "platform_insert" on public.plans;
create policy "platform_insert" on public.plans for insert to authenticated with check (app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_update" on public.plans;
create policy "platform_update" on public.plans for update to authenticated using (app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage')) with check (app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_delete" on public.plans;
create policy "platform_delete" on public.plans for delete to authenticated using (app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "catalog_select" on public.features;
create policy "catalog_select" on public.features for select to authenticated using (app_private.is_platform_admin() or status = 'active');
drop policy if exists "platform_insert" on public.features;
create policy "platform_insert" on public.features for insert to authenticated with check (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_update" on public.features;
create policy "platform_update" on public.features for update to authenticated using (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('platform.manage')) with check (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_delete" on public.features;
create policy "platform_delete" on public.features for delete to authenticated using (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "catalog_select" on public.plan_features;
create policy "catalog_select" on public.plan_features for select to authenticated using (app_private.is_platform_admin() or (app_private.company_for_entity('plans', plan_id) is null and exists (select 1 from public.plans p where p.id = plan_id and p.status = 'active')));
drop policy if exists "platform_insert" on public.plan_features;
create policy "platform_insert" on public.plan_features for insert to authenticated with check (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_update" on public.plan_features;
create policy "platform_update" on public.plan_features for update to authenticated using (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage')) with check (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "platform_delete" on public.plan_features;
create policy "platform_delete" on public.plan_features for delete to authenticated using (app_private.has_platform_permission('features.manage') or app_private.has_platform_permission('plans.manage') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "permission_catalog_select" on public.permissions;
create policy "permission_catalog_select" on public.permissions for select to authenticated using (auth.uid() is not null);
drop policy if exists "platform_insert" on public.permissions;
create policy "platform_insert" on public.permissions for insert to authenticated with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_update" on public.permissions;
create policy "platform_update" on public.permissions for update to authenticated using (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review')) with check (app_private.has_platform_permission('platform.manage') or app_private.has_platform_permission('security.review'));
drop policy if exists "platform_delete" on public.permissions;
create policy "platform_delete" on public.permissions for delete to authenticated using (app_private.has_platform_permission('platform.manage'));

-- User profile policies.
drop policy if exists "profile_select" on public.user_profiles;
create policy "profile_select" on public.user_profiles for select to authenticated using (app_private.is_platform_admin() or id = app_private.current_user_profile_id() or app_private.profile_shares_company(id));
drop policy if exists "profile_insert_self" on public.user_profiles;
create policy "profile_insert_self" on public.user_profiles for insert to authenticated with check (auth.uid() is not null and auth_user_id = auth.uid() and status = 'active');
drop policy if exists "profile_update_self" on public.user_profiles;
create policy "profile_update_self" on public.user_profiles for update to authenticated using (id = app_private.current_user_profile_id()) with check (id = app_private.current_user_profile_id() and auth_user_id = auth.uid() and status = 'active');
drop policy if exists "session_audit_select" on public.user_sessions_audit;
create policy "session_audit_select" on public.user_sessions_audit for select to authenticated using (app_private.is_platform_admin() or user_profile_id = app_private.current_user_profile_id() or app_private.profile_shares_company(user_profile_id));

-- Company root and RBAC membership policies.
drop policy if exists "company_select" on public.companies;
create policy "company_select" on public.companies for select to authenticated using (app_private.is_platform_admin() or app_private.is_company_member(id));
drop policy if exists "company_update" on public.companies;
create policy "company_update" on public.companies for update to authenticated using (app_private.is_platform_admin() or app_private.can_company(id, 'companies', 'update') or app_private.has_company_permission_key(id, 'settings.configure')) with check (app_private.is_platform_admin() or app_private.can_company(id, 'companies', 'update') or app_private.has_company_permission_key(id, 'settings.configure'));
drop policy if exists "company_insert_platform" on public.companies;
create policy "company_insert_platform" on public.companies for insert to authenticated with check (app_private.has_platform_permission('platform.manage'));
drop policy if exists "company_delete_platform" on public.companies;
create policy "company_delete_platform" on public.companies for delete to authenticated using (app_private.has_platform_permission('companies.suspend') or app_private.has_platform_permission('platform.manage'));
drop policy if exists "tenant_select" on public.roles;
create policy "tenant_select" on public.roles for select to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_member(company_id)));
drop policy if exists "tenant_insert" on public.roles;
create policy "tenant_insert" on public.roles for insert to authenticated with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_update" on public.roles;
create policy "tenant_update" on public.roles for update to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['roles.assign', 'users.manage']))) with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_delete" on public.roles;
create policy "tenant_delete" on public.roles for delete to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_select" on public.role_permissions;
create policy "tenant_select" on public.role_permissions for select to authenticated using (app_private.is_platform_admin() or (app_private.company_for_entity('role_permissions', id) is not null and app_private.is_company_member(app_private.company_for_entity('role_permissions', id))));
drop policy if exists "tenant_insert" on public.role_permissions;
create policy "tenant_insert" on public.role_permissions for insert to authenticated with check (app_private.is_platform_admin() or (app_private.company_for_entity('roles', role_id) is not null and app_private.is_company_active(app_private.company_for_entity('roles', role_id)) and app_private.has_any_company_permission_key(app_private.company_for_entity('roles', role_id), array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_update" on public.role_permissions;
create policy "tenant_update" on public.role_permissions for update to authenticated using (app_private.is_platform_admin() or (app_private.company_for_entity('role_permissions', id) is not null and app_private.has_any_company_permission_key(app_private.company_for_entity('role_permissions', id), array['roles.assign', 'users.manage']))) with check (app_private.is_platform_admin() or (app_private.company_for_entity('roles', role_id) is not null and app_private.is_company_active(app_private.company_for_entity('roles', role_id)) and app_private.has_any_company_permission_key(app_private.company_for_entity('roles', role_id), array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_delete" on public.role_permissions;
create policy "tenant_delete" on public.role_permissions for delete to authenticated using (app_private.is_platform_admin() or (app_private.company_for_entity('role_permissions', id) is not null and app_private.has_any_company_permission_key(app_private.company_for_entity('role_permissions', id), array['roles.assign', 'users.manage'])));
drop policy if exists "tenant_select" on public.company_members;
create policy "tenant_select" on public.company_members for select to authenticated using (app_private.is_platform_admin() or app_private.is_company_member(company_id));
drop policy if exists "tenant_insert" on public.company_members;
create policy "tenant_insert" on public.company_members for insert to authenticated with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign']) and app_private.role_belongs_to_company(role_id, company_id)));
drop policy if exists "tenant_update" on public.company_members;
create policy "tenant_update" on public.company_members for update to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign', 'members.remove']))) with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign', 'members.remove']) and app_private.role_belongs_to_company(role_id, company_id)));
drop policy if exists "tenant_delete" on public.company_members;
create policy "tenant_delete" on public.company_members for delete to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['members.remove', 'users.manage'])));
drop policy if exists "tenant_select" on public.company_invitations;
create policy "tenant_select" on public.company_invitations for select to authenticated using (app_private.is_platform_admin() or app_private.is_company_member(company_id));
drop policy if exists "tenant_insert" on public.company_invitations;
create policy "tenant_insert" on public.company_invitations for insert to authenticated with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign']) and app_private.role_belongs_to_company(role_id, company_id)));
drop policy if exists "tenant_update" on public.company_invitations;
create policy "tenant_update" on public.company_invitations for update to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign']))) with check (app_private.is_platform_admin() or (company_id is not null and app_private.is_company_active(company_id) and app_private.has_any_company_permission_key(company_id, array['users.manage', 'roles.assign']) and app_private.role_belongs_to_company(role_id, company_id)));
drop policy if exists "tenant_delete" on public.company_invitations;
create policy "tenant_delete" on public.company_invitations for delete to authenticated using (app_private.is_platform_admin() or (company_id is not null and app_private.has_any_company_permission_key(company_id, array['users.manage', 'members.remove'])));

-- Policies for public.billing_accounts (billing).
drop policy if exists "tenant_select" on public.billing_accounts;
create policy "tenant_select" on public.billing_accounts for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.billing_accounts;
create policy "tenant_insert" on public.billing_accounts for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_update" on public.billing_accounts;
create policy "tenant_update" on public.billing_accounts for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.billing_accounts;
create policy "tenant_delete" on public.billing_accounts for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')));

-- Policies for public.company_subscriptions (billing).
drop policy if exists "tenant_select" on public.company_subscriptions;
create policy "tenant_select" on public.company_subscriptions for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.company_subscriptions;
create policy "tenant_insert" on public.company_subscriptions for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_update" on public.company_subscriptions;
create policy "tenant_update" on public.company_subscriptions for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.company_subscriptions;
create policy "tenant_delete" on public.company_subscriptions for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')));

-- Policies for public.subscription_items (billing).
drop policy if exists "tenant_select" on public.subscription_items;
create policy "tenant_select" on public.subscription_items for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(app_private.company_for_entity('subscription_items', id)) and (app_private.has_any_company_permission_key(app_private.company_for_entity('subscription_items', id), array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(app_private.company_for_entity('subscription_items', id)))));
drop policy if exists "tenant_insert" on public.subscription_items;
create policy "tenant_insert" on public.subscription_items for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('subscription_items', id), 'billing', 'manage')));
drop policy if exists "tenant_update" on public.subscription_items;
create policy "tenant_update" on public.subscription_items for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('subscription_items', id), 'billing', 'manage'))) with check ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('subscription_items', id), 'billing', 'manage')));
drop policy if exists "tenant_delete" on public.subscription_items;
create policy "tenant_delete" on public.subscription_items for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('subscription_items', id), 'billing', 'manage')));

-- Policies for public.company_feature_entitlements (billing).
drop policy if exists "tenant_select" on public.company_feature_entitlements;
create policy "tenant_select" on public.company_feature_entitlements for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.company_feature_entitlements;
create policy "tenant_insert" on public.company_feature_entitlements for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_update" on public.company_feature_entitlements;
create policy "tenant_update" on public.company_feature_entitlements for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.company_feature_entitlements;
create policy "tenant_delete" on public.company_feature_entitlements for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')));

-- Policies for public.usage_limits (billing).
drop policy if exists "tenant_select" on public.usage_limits;
create policy "tenant_select" on public.usage_limits for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.usage_limits;
create policy "tenant_insert" on public.usage_limits for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_update" on public.usage_limits;
create policy "tenant_update" on public.usage_limits for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.usage_limits;
create policy "tenant_delete" on public.usage_limits for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'billing', 'manage')));

-- Policies for public.usage_counters (billing).
drop policy if exists "tenant_select" on public.usage_counters;
create policy "tenant_select" on public.usage_counters for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));

-- Policies for public.usage_records (billing).
drop policy if exists "tenant_select" on public.usage_records;
create policy "tenant_select" on public.usage_records for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and (app_private.has_any_company_permission_key(company_id, array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(company_id))));

-- Policies for public.tenant_invoices (billing).
drop policy if exists "tenant_select" on public.tenant_invoices;
create policy "tenant_select" on public.tenant_invoices for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(app_private.company_for_entity('tenant_invoices', id)) and (app_private.has_any_company_permission_key(app_private.company_for_entity('tenant_invoices', id), array['billing.read', 'billing.manage', 'payments.read', 'settings.configure']) or app_private.is_company_member(app_private.company_for_entity('tenant_invoices', id)))));
drop policy if exists "tenant_insert" on public.tenant_invoices;
create policy "tenant_insert" on public.tenant_invoices for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('tenant_invoices', id), 'billing', 'manage')));
drop policy if exists "tenant_update" on public.tenant_invoices;
create policy "tenant_update" on public.tenant_invoices for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('tenant_invoices', id), 'billing', 'manage'))) with check ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('tenant_invoices', id), 'billing', 'manage')));
drop policy if exists "tenant_delete" on public.tenant_invoices;
create policy "tenant_delete" on public.tenant_invoices for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(app_private.company_for_entity('tenant_invoices', id), 'billing', 'manage')));

-- Policies for public.company_settings (companies).
drop policy if exists "tenant_select" on public.company_settings;
create policy "tenant_select" on public.company_settings for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.company_settings;
create policy "tenant_insert" on public.company_settings for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.company_settings;
create policy "tenant_update" on public.company_settings for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.company_settings;
create policy "tenant_delete" on public.company_settings for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'delete')));

-- Policies for public.company_branding (companies).
drop policy if exists "tenant_select" on public.company_branding;
create policy "tenant_select" on public.company_branding for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.company_branding;
create policy "tenant_insert" on public.company_branding for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.company_branding;
create policy "tenant_update" on public.company_branding for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.company_branding;
create policy "tenant_delete" on public.company_branding for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'delete')));

-- Policies for public.company_locations (companies).
drop policy if exists "tenant_select" on public.company_locations;
create policy "tenant_select" on public.company_locations for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.company_locations;
create policy "tenant_insert" on public.company_locations for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.company_locations;
create policy "tenant_update" on public.company_locations for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.company_locations;
create policy "tenant_delete" on public.company_locations for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'companies', 'delete')));

-- Policies for public.staff_profiles (users).
drop policy if exists "tenant_select" on public.staff_profiles;
create policy "tenant_select" on public.staff_profiles for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.staff_profiles;
create policy "tenant_insert" on public.staff_profiles for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.staff_profiles;
create policy "tenant_update" on public.staff_profiles for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.staff_profiles;
create policy "tenant_delete" on public.staff_profiles for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'delete')));

-- Policies for public.staff_working_hours (users).
drop policy if exists "tenant_select" on public.staff_working_hours;
create policy "tenant_select" on public.staff_working_hours for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.staff_working_hours;
create policy "tenant_insert" on public.staff_working_hours for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.staff_working_hours;
create policy "tenant_update" on public.staff_working_hours for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.staff_working_hours;
create policy "tenant_delete" on public.staff_working_hours for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'delete')));

-- Policies for public.staff_time_off (users).
drop policy if exists "tenant_select" on public.staff_time_off;
create policy "tenant_select" on public.staff_time_off for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.staff_time_off;
create policy "tenant_insert" on public.staff_time_off for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.staff_time_off;
create policy "tenant_update" on public.staff_time_off for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.staff_time_off;
create policy "tenant_delete" on public.staff_time_off for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'users', 'delete')));

-- Policies for public.api_clients (integrations).
drop policy if exists "tenant_select" on public.api_clients;
create policy "tenant_select" on public.api_clients for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.api_clients;
create policy "tenant_insert" on public.api_clients for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.api_clients;
create policy "tenant_update" on public.api_clients for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.api_clients;
create policy "tenant_delete" on public.api_clients for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')));

-- Policies for public.service_accounts (integrations).
drop policy if exists "tenant_select" on public.service_accounts;
create policy "tenant_select" on public.service_accounts for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.service_accounts;
create policy "tenant_insert" on public.service_accounts for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.service_accounts;
create policy "tenant_update" on public.service_accounts for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', created_by_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.service_accounts;
create policy "tenant_delete" on public.service_accounts for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'manage')));

-- Policies for public.customers (customers).
drop policy if exists "tenant_select" on public.customers;
create policy "tenant_select" on public.customers for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.customers;
create policy "tenant_insert" on public.customers for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.customers;
create policy "tenant_update" on public.customers for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.customers;
create policy "tenant_delete" on public.customers for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'delete')));

-- Policies for public.customer_addresses (customers).
drop policy if exists "tenant_select" on public.customer_addresses;
create policy "tenant_select" on public.customer_addresses for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.customer_addresses;
create policy "tenant_insert" on public.customer_addresses for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.customer_addresses;
create policy "tenant_update" on public.customer_addresses for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.customer_addresses;
create policy "tenant_delete" on public.customer_addresses for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'delete')));

-- Policies for public.customer_notes (customers).
drop policy if exists "tenant_select" on public.customer_notes;
create policy "tenant_select" on public.customer_notes for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.customer_notes;
create policy "tenant_insert" on public.customer_notes for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.customer_notes;
create policy "tenant_update" on public.customer_notes for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.customer_notes;
create policy "tenant_delete" on public.customer_notes for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'delete')));

-- Policies for public.customer_tags (customers).
drop policy if exists "tenant_select" on public.customer_tags;
create policy "tenant_select" on public.customer_tags for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.customer_tags;
create policy "tenant_insert" on public.customer_tags for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.customer_tags;
create policy "tenant_update" on public.customer_tags for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.customer_tags;
create policy "tenant_delete" on public.customer_tags for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'delete')));

-- Policies for public.customer_tag_assignments (customers).
drop policy if exists "tenant_select" on public.customer_tag_assignments;
create policy "tenant_select" on public.customer_tag_assignments for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.customer_tag_assignments;
create policy "tenant_insert" on public.customer_tag_assignments for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.customer_tag_assignments;
create policy "tenant_update" on public.customer_tag_assignments for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.customer_tag_assignments;
create policy "tenant_delete" on public.customer_tag_assignments for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'customers', 'delete')));

-- Policies for public.customer_consents (customers).
drop policy if exists "tenant_select" on public.customer_consents;
create policy "tenant_select" on public.customer_consents for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));
drop policy if exists "tenant_insert" on public.customer_consents;
create policy "tenant_insert" on public.customer_consents for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'customers', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.customer_consents;
create policy "tenant_update" on public.customer_consents for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'customers', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'customers', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.customer_consents;
create policy "tenant_delete" on public.customer_consents for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'customers', 'manage')));

-- Policies for public.service_categories (services).
drop policy if exists "tenant_select" on public.service_categories;
create policy "tenant_select" on public.service_categories for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.service_categories;
create policy "tenant_insert" on public.service_categories for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.service_categories;
create policy "tenant_update" on public.service_categories for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.service_categories;
create policy "tenant_delete" on public.service_categories for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'delete')));

-- Policies for public.services (services).
drop policy if exists "tenant_select" on public.services;
create policy "tenant_select" on public.services for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.services;
create policy "tenant_insert" on public.services for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_categories', service_category_id, company_id)));
drop policy if exists "tenant_update" on public.services;
create policy "tenant_update" on public.services for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_categories', service_category_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_categories', service_category_id, company_id)));
drop policy if exists "tenant_delete" on public.services;
create policy "tenant_delete" on public.services for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'delete')));

-- Policies for public.service_resources (services).
drop policy if exists "tenant_select" on public.service_resources;
create policy "tenant_select" on public.service_resources for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.service_resources;
create policy "tenant_insert" on public.service_resources for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_update" on public.service_resources;
create policy "tenant_update" on public.service_resources for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_delete" on public.service_resources;
create policy "tenant_delete" on public.service_resources for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'delete')));

-- Policies for public.service_staff_assignments (services).
drop policy if exists "tenant_select" on public.service_staff_assignments;
create policy "tenant_select" on public.service_staff_assignments for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.service_staff_assignments;
create policy "tenant_insert" on public.service_staff_assignments for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.service_staff_assignments;
create policy "tenant_update" on public.service_staff_assignments for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.service_staff_assignments;
create policy "tenant_delete" on public.service_staff_assignments for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'services', 'delete')));

-- Policies for public.recurring_appointment_rules (appointments).
drop policy if exists "tenant_select" on public.recurring_appointment_rules;
create policy "tenant_select" on public.recurring_appointment_rules for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.recurring_appointment_rules;
create policy "tenant_insert" on public.recurring_appointment_rules for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.recurring_appointment_rules;
create policy "tenant_update" on public.recurring_appointment_rules for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.recurring_appointment_rules;
create policy "tenant_delete" on public.recurring_appointment_rules for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.appointments (appointments).
drop policy if exists "tenant_select" on public.appointments;
create policy "tenant_select" on public.appointments for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.appointments;
create policy "tenant_insert" on public.appointments for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', primary_staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.appointments;
create policy "tenant_update" on public.appointments for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', primary_staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', primary_staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.appointments;
create policy "tenant_delete" on public.appointments for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.appointment_services (appointments).
drop policy if exists "tenant_select" on public.appointment_services;
create policy "tenant_select" on public.appointment_services for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.appointment_services;
create policy "tenant_insert" on public.appointment_services for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_update" on public.appointment_services;
create policy "tenant_update" on public.appointment_services for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_delete" on public.appointment_services;
create policy "tenant_delete" on public.appointment_services for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.appointment_participants (appointments).
drop policy if exists "tenant_select" on public.appointment_participants;
create policy "tenant_select" on public.appointment_participants for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.appointment_participants;
create policy "tenant_insert" on public.appointment_participants for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id)));
drop policy if exists "tenant_update" on public.appointment_participants;
create policy "tenant_update" on public.appointment_participants for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id)));
drop policy if exists "tenant_delete" on public.appointment_participants;
create policy "tenant_delete" on public.appointment_participants for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.appointment_status_history (appointments).
drop policy if exists "tenant_select" on public.appointment_status_history;
create policy "tenant_select" on public.appointment_status_history for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.appointment_reminders (appointments).
drop policy if exists "tenant_select" on public.appointment_reminders;
create policy "tenant_select" on public.appointment_reminders for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.appointment_waitlists (appointments).
drop policy if exists "tenant_select" on public.appointment_waitlists;
create policy "tenant_select" on public.appointment_waitlists for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.appointment_waitlists;
create policy "tenant_insert" on public.appointment_waitlists for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_update" on public.appointment_waitlists;
create policy "tenant_update" on public.appointment_waitlists for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.appointment_waitlists;
create policy "tenant_delete" on public.appointment_waitlists for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.resource_bookings (appointments).
drop policy if exists "tenant_select" on public.resource_bookings;
create policy "tenant_select" on public.resource_bookings for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.resource_bookings;
create policy "tenant_insert" on public.resource_bookings for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_update" on public.resource_bookings;
create policy "tenant_update" on public.resource_bookings for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('service_resources', service_resource_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_delete" on public.resource_bookings;
create policy "tenant_delete" on public.resource_bookings for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.booking_holds (appointments).
drop policy if exists "tenant_select" on public.booking_holds;
create policy "tenant_select" on public.booking_holds for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.booking_holds;
create policy "tenant_insert" on public.booking_holds for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_update" on public.booking_holds;
create policy "tenant_update" on public.booking_holds for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)) and (app_private.null_or_entity_belongs_to_company('staff_profiles', staff_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_delete" on public.booking_holds;
create policy "tenant_delete" on public.booking_holds for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.calendar_connections (appointments).
drop policy if exists "tenant_select" on public.calendar_connections;
create policy "tenant_select" on public.calendar_connections for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.calendar_connections;
create policy "tenant_insert" on public.calendar_connections for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.calendar_connections;
create policy "tenant_update" on public.calendar_connections for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.calendar_connections;
create policy "tenant_delete" on public.calendar_connections for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.calendar_event_mappings (appointments).
drop policy if exists "tenant_select" on public.calendar_event_mappings;
create policy "tenant_select" on public.calendar_event_mappings for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.calendar_event_mappings;
create policy "tenant_insert" on public.calendar_event_mappings for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_update" on public.calendar_event_mappings;
create policy "tenant_update" on public.calendar_event_mappings for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_delete" on public.calendar_event_mappings;
create policy "tenant_delete" on public.calendar_event_mappings for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'appointments', 'delete')));

-- Policies for public.crm_pipelines (crm).
drop policy if exists "tenant_select" on public.crm_pipelines;
create policy "tenant_select" on public.crm_pipelines for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.crm_pipelines;
create policy "tenant_insert" on public.crm_pipelines for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.crm_pipelines;
create policy "tenant_update" on public.crm_pipelines for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.crm_pipelines;
create policy "tenant_delete" on public.crm_pipelines for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'delete')));

-- Policies for public.crm_stages (crm).
drop policy if exists "tenant_select" on public.crm_stages;
create policy "tenant_select" on public.crm_stages for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.crm_stages;
create policy "tenant_insert" on public.crm_stages for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id)));
drop policy if exists "tenant_update" on public.crm_stages;
create policy "tenant_update" on public.crm_stages for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id)));
drop policy if exists "tenant_delete" on public.crm_stages;
create policy "tenant_delete" on public.crm_stages for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'delete')));

-- Policies for public.crm_deals (crm).
drop policy if exists "tenant_select" on public.crm_deals;
create policy "tenant_select" on public.crm_deals for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.crm_deals;
create policy "tenant_insert" on public.crm_deals for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_stages', crm_stage_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.crm_deals;
create policy "tenant_update" on public.crm_deals for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_stages', crm_stage_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_pipelines', crm_pipeline_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_stages', crm_stage_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.crm_deals;
create policy "tenant_delete" on public.crm_deals for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'delete')));

-- Policies for public.crm_activities (crm).
drop policy if exists "tenant_select" on public.crm_activities;
create policy "tenant_select" on public.crm_activities for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.crm_activities;
create policy "tenant_insert" on public.crm_activities for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_deals', crm_deal_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company(related_entity_type, related_entity_id, company_id)));
drop policy if exists "tenant_update" on public.crm_activities;
create policy "tenant_update" on public.crm_activities for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_deals', crm_deal_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company(related_entity_type, related_entity_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('crm_deals', crm_deal_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company(related_entity_type, related_entity_id, company_id)));
drop policy if exists "tenant_delete" on public.crm_activities;
create policy "tenant_delete" on public.crm_activities for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'delete')));

-- Policies for public.crm_external_mappings (crm).
drop policy if exists "tenant_select" on public.crm_external_mappings;
create policy "tenant_select" on public.crm_external_mappings for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.crm_external_mappings;
create policy "tenant_insert" on public.crm_external_mappings for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.crm_external_mappings;
create policy "tenant_update" on public.crm_external_mappings for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.crm_external_mappings;
create policy "tenant_delete" on public.crm_external_mappings for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'crm', 'delete')));

-- Policies for public.files (files).
drop policy if exists "tenant_select" on public.files;
create policy "tenant_select" on public.files for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.files;
create policy "tenant_insert" on public.files for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', uploaded_by_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.files;
create policy "tenant_update" on public.files for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', uploaded_by_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', uploaded_by_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.files;
create policy "tenant_delete" on public.files for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'delete')));

-- Policies for public.media_assets (files).
drop policy if exists "tenant_select" on public.media_assets;
create policy "tenant_select" on public.media_assets for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.media_assets;
create policy "tenant_insert" on public.media_assets for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_update" on public.media_assets;
create policy "tenant_update" on public.media_assets for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_delete" on public.media_assets;
create policy "tenant_delete" on public.media_assets for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'delete')));

-- Policies for public.document_templates (files).
drop policy if exists "tenant_select" on public.document_templates;
create policy "tenant_select" on public.document_templates for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.document_templates;
create policy "tenant_insert" on public.document_templates for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.document_templates;
create policy "tenant_update" on public.document_templates for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.document_templates;
create policy "tenant_delete" on public.document_templates for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'delete')));

-- Policies for public.file_links (files).
drop policy if exists "tenant_select" on public.file_links;
create policy "tenant_select" on public.file_links for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.file_links;
create policy "tenant_insert" on public.file_links for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id)));
drop policy if exists "tenant_update" on public.file_links;
create policy "tenant_update" on public.file_links for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id)));
drop policy if exists "tenant_delete" on public.file_links;
create policy "tenant_delete" on public.file_links for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'files', 'delete')));

-- Policies for public.message_templates (marketing).
drop policy if exists "tenant_select" on public.message_templates;
create policy "tenant_select" on public.message_templates for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.message_templates;
create policy "tenant_insert" on public.message_templates for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.message_templates;
create policy "tenant_update" on public.message_templates for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.message_templates;
create policy "tenant_delete" on public.message_templates for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.marketing_audiences (marketing).
drop policy if exists "tenant_select" on public.marketing_audiences;
create policy "tenant_select" on public.marketing_audiences for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.marketing_audiences;
create policy "tenant_insert" on public.marketing_audiences for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.marketing_audiences;
create policy "tenant_update" on public.marketing_audiences for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.marketing_audiences;
create policy "tenant_delete" on public.marketing_audiences for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.marketing_campaigns (marketing).
drop policy if exists "tenant_select" on public.marketing_campaigns;
create policy "tenant_select" on public.marketing_campaigns for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.marketing_campaigns;
create policy "tenant_insert" on public.marketing_campaigns for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.marketing_campaigns;
create policy "tenant_update" on public.marketing_campaigns for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.marketing_campaigns;
create policy "tenant_delete" on public.marketing_campaigns for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.marketing_messages (marketing).
drop policy if exists "tenant_select" on public.marketing_messages;
create policy "tenant_select" on public.marketing_messages for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.marketing_messages;
create policy "tenant_insert" on public.marketing_messages for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('marketing_campaigns', marketing_campaign_id, company_id)));
drop policy if exists "tenant_update" on public.marketing_messages;
create policy "tenant_update" on public.marketing_messages for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('marketing_campaigns', marketing_campaign_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('marketing_campaigns', marketing_campaign_id, company_id)));
drop policy if exists "tenant_delete" on public.marketing_messages;
create policy "tenant_delete" on public.marketing_messages for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.marketing_deliveries (marketing).
drop policy if exists "tenant_select" on public.marketing_deliveries;
create policy "tenant_select" on public.marketing_deliveries for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.conversations (marketing).
drop policy if exists "tenant_select" on public.conversations;
create policy "tenant_select" on public.conversations for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.conversations;
create policy "tenant_insert" on public.conversations for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.conversations;
create policy "tenant_update" on public.conversations for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.conversations;
create policy "tenant_delete" on public.conversations for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.conversation_participants (marketing).
drop policy if exists "tenant_select" on public.conversation_participants;
create policy "tenant_select" on public.conversation_participants for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.conversation_participants;
create policy "tenant_insert" on public.conversation_participants for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)));
drop policy if exists "tenant_update" on public.conversation_participants;
create policy "tenant_update" on public.conversation_participants for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.conversation_participants;
create policy "tenant_delete" on public.conversation_participants for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.messages (marketing).
drop policy if exists "tenant_select" on public.messages;
create policy "tenant_select" on public.messages for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.messages;
create policy "tenant_insert" on public.messages for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id)));
drop policy if exists "tenant_update" on public.messages;
create policy "tenant_update" on public.messages for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('conversations', conversation_id, company_id)));
drop policy if exists "tenant_delete" on public.messages;
create policy "tenant_delete" on public.messages for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.message_attachments (marketing).
drop policy if exists "tenant_select" on public.message_attachments;
create policy "tenant_select" on public.message_attachments for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.message_attachments;
create policy "tenant_insert" on public.message_attachments for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_update" on public.message_attachments;
create policy "tenant_update" on public.message_attachments for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_delete" on public.message_attachments;
create policy "tenant_delete" on public.message_attachments for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.message_status_events (marketing).
drop policy if exists "tenant_select" on public.message_status_events;
create policy "tenant_select" on public.message_status_events for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.message_status_events;
create policy "tenant_insert" on public.message_status_events for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id)));
drop policy if exists "tenant_update" on public.message_status_events;
create policy "tenant_update" on public.message_status_events for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('messages', message_id, company_id)));
drop policy if exists "tenant_delete" on public.message_status_events;
create policy "tenant_delete" on public.message_status_events for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.notification_preferences (marketing).
drop policy if exists "tenant_select" on public.notification_preferences;
create policy "tenant_select" on public.notification_preferences for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.notification_preferences;
create policy "tenant_insert" on public.notification_preferences for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.notification_preferences;
create policy "tenant_update" on public.notification_preferences for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.notification_preferences;
create policy "tenant_delete" on public.notification_preferences for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'marketing', 'delete')));

-- Policies for public.integration_connections (integrations).
drop policy if exists "tenant_select" on public.integration_connections;
create policy "tenant_select" on public.integration_connections for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.integration_connections;
create policy "tenant_insert" on public.integration_connections for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.integration_connections;
create policy "tenant_update" on public.integration_connections for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.integration_connections;
create policy "tenant_delete" on public.integration_connections for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'integrations', 'delete')));

-- Policies for public.integration_sync_jobs (integrations).
drop policy if exists "tenant_select" on public.integration_sync_jobs;
create policy "tenant_select" on public.integration_sync_jobs for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.webhook_events (integrations).
drop policy if exists "tenant_select" on public.webhook_events;
create policy "tenant_select" on public.webhook_events for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.automation_workflows (automations).
drop policy if exists "tenant_select" on public.automation_workflows;
create policy "tenant_select" on public.automation_workflows for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.automation_workflows;
create policy "tenant_insert" on public.automation_workflows for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.automation_workflows;
create policy "tenant_update" on public.automation_workflows for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.automation_workflows;
create policy "tenant_delete" on public.automation_workflows for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'delete')));

-- Policies for public.automation_triggers (automations).
drop policy if exists "tenant_select" on public.automation_triggers;
create policy "tenant_select" on public.automation_triggers for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.automation_triggers;
create policy "tenant_insert" on public.automation_triggers for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id)));
drop policy if exists "tenant_update" on public.automation_triggers;
create policy "tenant_update" on public.automation_triggers for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id)));
drop policy if exists "tenant_delete" on public.automation_triggers;
create policy "tenant_delete" on public.automation_triggers for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'delete')));

-- Policies for public.automation_steps (automations).
drop policy if exists "tenant_select" on public.automation_steps;
create policy "tenant_select" on public.automation_steps for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.automation_steps;
create policy "tenant_insert" on public.automation_steps for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id)));
drop policy if exists "tenant_update" on public.automation_steps;
create policy "tenant_update" on public.automation_steps for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('automation_workflows', automation_workflow_id, company_id)));
drop policy if exists "tenant_delete" on public.automation_steps;
create policy "tenant_delete" on public.automation_steps for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'automations', 'delete')));

-- Policies for public.automation_events (automations).
drop policy if exists "tenant_select" on public.automation_events;
create policy "tenant_select" on public.automation_events for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.automation_runs (automations).
drop policy if exists "tenant_select" on public.automation_runs;
create policy "tenant_select" on public.automation_runs for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.automation_run_steps (automations).
drop policy if exists "tenant_select" on public.automation_run_steps;
create policy "tenant_select" on public.automation_run_steps for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.payment_customers (payments).
drop policy if exists "tenant_select" on public.payment_customers;
create policy "tenant_select" on public.payment_customers for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.payment_customers;
create policy "tenant_insert" on public.payment_customers for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.payment_customers;
create policy "tenant_update" on public.payment_customers for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.payment_customers;
create policy "tenant_delete" on public.payment_customers for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.subscriptions (payments).
drop policy if exists "tenant_select" on public.subscriptions;
create policy "tenant_select" on public.subscriptions for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.subscriptions;
create policy "tenant_insert" on public.subscriptions for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.subscriptions;
create policy "tenant_update" on public.subscriptions for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.subscriptions;
create policy "tenant_delete" on public.subscriptions for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.invoices (payments).
drop policy if exists "tenant_select" on public.invoices;
create policy "tenant_select" on public.invoices for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.invoices;
create policy "tenant_insert" on public.invoices for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_update" on public.invoices;
create policy "tenant_update" on public.invoices for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('appointments', appointment_id, company_id)));
drop policy if exists "tenant_delete" on public.invoices;
create policy "tenant_delete" on public.invoices for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.invoice_items (payments).
drop policy if exists "tenant_select" on public.invoice_items;
create policy "tenant_select" on public.invoice_items for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.invoice_items;
create policy "tenant_insert" on public.invoice_items for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_update" on public.invoice_items;
create policy "tenant_update" on public.invoice_items for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id)) and (app_private.null_or_entity_belongs_to_company('services', service_id, company_id)));
drop policy if exists "tenant_delete" on public.invoice_items;
create policy "tenant_delete" on public.invoice_items for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.payments (payments).
drop policy if exists "tenant_select" on public.payments;
create policy "tenant_select" on public.payments for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.payments;
create policy "tenant_insert" on public.payments for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id)));
drop policy if exists "tenant_update" on public.payments;
create policy "tenant_update" on public.payments for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)) and (app_private.null_or_entity_belongs_to_company('invoices', invoice_id, company_id)));
drop policy if exists "tenant_delete" on public.payments;
create policy "tenant_delete" on public.payments for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.refunds (payments).
drop policy if exists "tenant_select" on public.refunds;
create policy "tenant_select" on public.refunds for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.refunds;
create policy "tenant_insert" on public.refunds for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('payments', payment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.refunds;
create policy "tenant_update" on public.refunds for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('payments', payment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('payments', payment_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.refunds;
create policy "tenant_delete" on public.refunds for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'payments', 'delete')));

-- Policies for public.report_definitions (reports).
drop policy if exists "tenant_select" on public.report_definitions;
create policy "tenant_select" on public.report_definitions for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));
drop policy if exists "tenant_insert" on public.report_definitions;
create policy "tenant_insert" on public.report_definitions for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'reports', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_update" on public.report_definitions;
create policy "tenant_update" on public.report_definitions for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'reports', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'reports', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('company_members', owner_company_member_id, company_id)));
drop policy if exists "tenant_delete" on public.report_definitions;
create policy "tenant_delete" on public.report_definitions for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'reports', 'delete')));

-- Policies for public.report_snapshots (reports).
drop policy if exists "tenant_select" on public.report_snapshots;
create policy "tenant_select" on public.report_snapshots for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.metric_daily_rollups (reports).
drop policy if exists "tenant_select" on public.metric_daily_rollups;
create policy "tenant_select" on public.metric_daily_rollups for select to authenticated using (app_private.is_platform_admin() or app_private.can_access_company(company_id));

-- Policies for public.audit_logs (audit).
drop policy if exists "tenant_select" on public.audit_logs;
create policy "tenant_select" on public.audit_logs for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['audit.read', 'compliance.manage', 'reports.export'])));

-- Policies for public.data_subject_requests (compliance).
drop policy if exists "tenant_select" on public.data_subject_requests;
create policy "tenant_select" on public.data_subject_requests for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));
drop policy if exists "tenant_insert" on public.data_subject_requests;
create policy "tenant_insert" on public.data_subject_requests for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_update" on public.data_subject_requests;
create policy "tenant_update" on public.data_subject_requests for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('customers', customer_id, company_id)));
drop policy if exists "tenant_delete" on public.data_subject_requests;
create policy "tenant_delete" on public.data_subject_requests for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')));

-- Policies for public.data_exports (compliance).
drop policy if exists "tenant_select" on public.data_exports;
create policy "tenant_select" on public.data_exports for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));
drop policy if exists "tenant_insert" on public.data_exports;
create policy "tenant_insert" on public.data_exports for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_update" on public.data_exports;
create policy "tenant_update" on public.data_exports for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company('company_members', requested_by_company_member_id, company_id)) and (app_private.null_or_entity_belongs_to_company('files', file_id, company_id)));
drop policy if exists "tenant_delete" on public.data_exports;
create policy "tenant_delete" on public.data_exports for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')));

-- Policies for public.data_deletion_jobs (compliance).
drop policy if exists "tenant_select" on public.data_deletion_jobs;
create policy "tenant_select" on public.data_deletion_jobs for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));
drop policy if exists "tenant_insert" on public.data_deletion_jobs;
create policy "tenant_insert" on public.data_deletion_jobs for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id)));
drop policy if exists "tenant_update" on public.data_deletion_jobs;
create policy "tenant_update" on public.data_deletion_jobs for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('data_subject_requests', data_subject_request_id, company_id)) and (app_private.null_or_entity_belongs_to_company(entity_type, entity_id, company_id)));
drop policy if exists "tenant_delete" on public.data_deletion_jobs;
create policy "tenant_delete" on public.data_deletion_jobs for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')));

-- Policies for public.retention_policies (compliance).
drop policy if exists "tenant_select" on public.retention_policies;
create policy "tenant_select" on public.retention_policies for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));
drop policy if exists "tenant_insert" on public.retention_policies;
create policy "tenant_insert" on public.retention_policies for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null));
drop policy if exists "tenant_update" on public.retention_policies;
create policy "tenant_update" on public.retention_policies for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.retention_policies;
create policy "tenant_delete" on public.retention_policies for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company(company_id, 'compliance', 'manage')));

-- Policies for public.consent_audit_logs (compliance).
drop policy if exists "tenant_select" on public.consent_audit_logs;
create policy "tenant_select" on public.consent_audit_logs for select to authenticated using (app_private.is_platform_admin() or (app_private.is_company_member(company_id) and app_private.has_any_company_permission_key(company_id, array['compliance.manage', 'audit.read', 'customers.read'])));

-- Policies for public.ai_prompts (ai).
drop policy if exists "tenant_select" on public.ai_prompts;
create policy "tenant_select" on public.ai_prompts for select to authenticated using (app_private.is_platform_admin() or (app_private.can_access_company(company_id) and (app_private.has_any_company_permission_key(company_id, array['ai.read', 'ai.manage']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.ai_prompts;
create policy "tenant_insert" on public.ai_prompts for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'create')) and (company_id is not null));
drop policy if exists "tenant_update" on public.ai_prompts;
create policy "tenant_update" on public.ai_prompts for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null)) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null));
drop policy if exists "tenant_delete" on public.ai_prompts;
create policy "tenant_delete" on public.ai_prompts for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'delete')));

-- Policies for public.ai_runs (ai).
drop policy if exists "tenant_select" on public.ai_runs;
create policy "tenant_select" on public.ai_runs for select to authenticated using (app_private.is_platform_admin() or (app_private.can_access_company(company_id) and (app_private.has_any_company_permission_key(company_id, array['ai.read', 'ai.manage']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.ai_runs;
create policy "tenant_insert" on public.ai_runs for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_prompts', ai_prompt_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('automation_runs', automation_run_id, company_id)) and (app_private.null_or_entity_belongs_to_company(input_entity_type, input_entity_id, company_id)));
drop policy if exists "tenant_update" on public.ai_runs;
create policy "tenant_update" on public.ai_runs for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_prompts', ai_prompt_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('automation_runs', automation_run_id, company_id)) and (app_private.null_or_entity_belongs_to_company(input_entity_type, input_entity_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_prompts', ai_prompt_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)) and (app_private.null_or_entity_belongs_to_company('automation_runs', automation_run_id, company_id)) and (app_private.null_or_entity_belongs_to_company(input_entity_type, input_entity_id, company_id)));
drop policy if exists "tenant_delete" on public.ai_runs;
create policy "tenant_delete" on public.ai_runs for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'delete')));

-- Policies for public.ai_outputs (ai).
drop policy if exists "tenant_select" on public.ai_outputs;
create policy "tenant_select" on public.ai_outputs for select to authenticated using (app_private.is_platform_admin() or (app_private.can_access_company(company_id) and (app_private.has_any_company_permission_key(company_id, array['ai.read', 'ai.manage']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.ai_outputs;
create policy "tenant_insert" on public.ai_outputs for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_runs', ai_run_id, company_id)));
drop policy if exists "tenant_update" on public.ai_outputs;
create policy "tenant_update" on public.ai_outputs for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_runs', ai_run_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_runs', ai_run_id, company_id)));
drop policy if exists "tenant_delete" on public.ai_outputs;
create policy "tenant_delete" on public.ai_outputs for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'delete')));

-- Policies for public.ai_usage_records (ai).
drop policy if exists "tenant_select" on public.ai_usage_records;
create policy "tenant_select" on public.ai_usage_records for select to authenticated using (app_private.is_platform_admin() or (app_private.can_access_company(company_id) and (app_private.has_any_company_permission_key(company_id, array['ai.read', 'ai.manage']) or app_private.is_company_member(company_id))));

-- Policies for public.ai_feedback (ai).
drop policy if exists "tenant_select" on public.ai_feedback;
create policy "tenant_select" on public.ai_feedback for select to authenticated using (app_private.is_platform_admin() or (app_private.can_access_company(company_id) and (app_private.has_any_company_permission_key(company_id, array['ai.read', 'ai.manage']) or app_private.is_company_member(company_id))));
drop policy if exists "tenant_insert" on public.ai_feedback;
create policy "tenant_insert" on public.ai_feedback for insert to authenticated with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'create')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_outputs', ai_output_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)));
drop policy if exists "tenant_update" on public.ai_feedback;
create policy "tenant_update" on public.ai_feedback for update to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_outputs', ai_output_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id))) with check ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'update')) and (company_id is not null) and (app_private.null_or_entity_belongs_to_company('ai_outputs', ai_output_id, company_id)) and (app_private.null_or_entity_belongs_to_company('user_profiles', user_profile_id, company_id)));
drop policy if exists "tenant_delete" on public.ai_feedback;
create policy "tenant_delete" on public.ai_feedback for delete to authenticated using ((app_private.is_platform_admin() or app_private.can_company_operate(company_id, 'ai', 'delete')));

-- Audit/history tables are append-only from tenant clients: authenticated users get read policies only.
revoke insert, update, delete on public.audit_logs from authenticated;
revoke insert, update, delete on public.consent_audit_logs from authenticated;
revoke insert, update, delete on public.user_sessions_audit from authenticated;
revoke insert, update, delete on public.platform_admin_audit_logs from authenticated;

-- Secret-bearing and worker-private tables intentionally have no authenticated policies.
-- public.api_keys: service_role only; use audited Edge Functions for all access.
-- public.dead_letter_events: service_role only; use audited Edge Functions for all access.
-- public.idempotency_keys: service_role only; use audited Edge Functions for all access.
-- public.job_attempts: service_role only; use audited Edge Functions for all access.
-- public.job_queue: service_role only; use audited Edge Functions for all access.
-- public.oauth_grants: service_role only; use audited Edge Functions for all access.
-- public.outbox_events: service_role only; use audited Edge Functions for all access.
-- public.webhook_signing_secrets: service_role only; use audited Edge Functions for all access.

commit;
