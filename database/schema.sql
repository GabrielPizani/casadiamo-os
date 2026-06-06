-- Casa Di Amo OS - Supabase PostgreSQL schema
-- Conceptual source: database/database-architecture.md and database/erd.md
-- RLS policies are intentionally not included in this file.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Platform administration

create table public.platform_roles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_roles_name_key unique (name)
);

create table public.platform_permissions (
  id uuid primary key default gen_random_uuid(),
  permission_key text not null,
  module text not null,
  action text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_permissions_permission_key_key unique (permission_key)
);

create table public.platform_role_permissions (
  id uuid primary key default gen_random_uuid(),
  platform_role_id uuid not null references public.platform_roles (id) on delete cascade,
  platform_permission_id uuid not null references public.platform_permissions (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_role_permissions_role_permission_key unique (platform_role_id, platform_permission_id)
);

create table public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth.users (id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text,
  avatar_url text,
  locale text not null default 'en',
  timezone text not null default 'UTC',
  status text not null default 'active',
  preferences jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_profiles_auth_user_id_key unique (auth_user_id),
  constraint user_profiles_email_key unique (email)
);

create table public.platform_admins (
  id uuid primary key default gen_random_uuid(),
  user_profile_id uuid not null references public.user_profiles (id) on delete cascade,
  platform_role_id uuid not null references public.platform_roles (id) on delete restrict,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint platform_admins_user_profile_id_key unique (user_profile_id)
);

-- SaaS billing, entitlements, and tenant root

create table public.plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  description text,
  status text not null default 'active',
  billing_interval text not null default 'month',
  base_price numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint plans_slug_key unique (slug)
);

create table public.features (
  id uuid primary key default gen_random_uuid(),
  feature_key text not null,
  name text not null,
  description text,
  module text not null,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint features_feature_key_key unique (feature_key)
);

create table public.plan_features (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans (id) on delete cascade,
  feature_id uuid not null references public.features (id) on delete cascade,
  included boolean not null default true,
  limit_value integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint plan_features_plan_feature_key unique (plan_id, feature_id)
);

create table public.companies (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  trading_name text,
  slug text not null,
  industry text,
  status text not null default 'active',
  default_locale text not null default 'en',
  default_timezone text not null default 'UTC',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint companies_slug_key unique (slug)
);

create table public.billing_accounts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  billing_email text not null,
  billing_name text,
  tax_id text,
  currency text not null default 'USD',
  provider text,
  external_customer_id text,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint billing_accounts_company_id_key unique (company_id)
);

create table public.company_subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  plan_id uuid not null references public.plans (id) on delete restrict,
  status text not null default 'trialing',
  billing_interval text not null default 'month',
  current_period_start timestamptz,
  current_period_end timestamptz,
  trial_end timestamptz,
  cancel_at timestamptz,
  canceled_at timestamptz,
  external_subscription_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.subscription_items (
  id uuid primary key default gen_random_uuid(),
  company_subscription_id uuid not null references public.company_subscriptions (id) on delete cascade,
  feature_id uuid references public.features (id) on delete restrict,
  item_type text not null,
  quantity integer not null default 1,
  unit_amount numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  external_item_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.company_feature_entitlements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  feature_id uuid not null references public.features (id) on delete cascade,
  source text not null default 'plan',
  enabled boolean not null default true,
  limit_value integer,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint company_feature_entitlements_company_feature_key unique (company_id, feature_id)
);

create table public.usage_limits (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  feature_id uuid references public.features (id) on delete cascade,
  resource_key text not null,
  limit_value integer not null,
  period text not null default 'month',
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint usage_limits_company_resource_period_key unique (company_id, resource_key, period)
);

create table public.usage_counters (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  resource_key text not null,
  period text not null default 'month',
  period_start timestamptz not null,
  period_end timestamptz not null,
  current_value integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint usage_counters_company_resource_period_key unique (company_id, resource_key, period, period_start)
);

create table public.usage_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  feature_id uuid references public.features (id) on delete set null,
  resource_key text not null,
  quantity integer not null default 1,
  occurred_at timestamptz not null default now(),
  source_entity_type text,
  source_entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tenant_invoices (
  id uuid primary key default gen_random_uuid(),
  billing_account_id uuid not null references public.billing_accounts (id) on delete cascade,
  company_subscription_id uuid references public.company_subscriptions (id) on delete set null,
  invoice_number text not null,
  status text not null default 'draft',
  subtotal numeric(12, 2) not null default 0,
  tax_total numeric(12, 2) not null default 0,
  total numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  due_at timestamptz,
  paid_at timestamptz,
  external_invoice_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tenant_invoices_invoice_number_key unique (invoice_number)
);

-- Company configuration and tenant users

create table public.company_settings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  scheduling_settings jsonb not null default '{}'::jsonb,
  crm_settings jsonb not null default '{}'::jsonb,
  marketing_settings jsonb not null default '{}'::jsonb,
  notification_settings jsonb not null default '{}'::jsonb,
  payment_settings jsonb not null default '{}'::jsonb,
  report_settings jsonb not null default '{}'::jsonb,
  data_retention_settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint company_settings_company_id_key unique (company_id)
);

create table public.company_branding (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  logo_url text,
  primary_color text,
  secondary_color text,
  domain text,
  public_profile jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint company_branding_company_id_key unique (company_id),
  constraint company_branding_domain_key unique (domain)
);

create table public.company_locations (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  address_line1 text,
  address_line2 text,
  city text,
  region text,
  postal_code text,
  country text,
  phone text,
  email text,
  timezone text not null default 'UTC',
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  name text not null,
  description text,
  scope text not null default 'company',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint roles_company_name_key unique (company_id, name)
);

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  permission_key text not null,
  module text not null,
  action text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint permissions_permission_key_key unique (permission_key)
);

create table public.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references public.roles (id) on delete cascade,
  permission_id uuid not null references public.permissions (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint role_permissions_role_permission_key unique (role_id, permission_id)
);

create table public.company_members (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  user_profile_id uuid not null references public.user_profiles (id) on delete cascade,
  role_id uuid not null references public.roles (id) on delete restrict,
  status text not null default 'active',
  invitation_status text,
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint company_members_company_user_key unique (company_id, user_profile_id)
);

create table public.company_invitations (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  invited_email text not null,
  role_id uuid not null references public.roles (id) on delete restrict,
  invited_by_company_member_id uuid references public.company_members (id) on delete set null,
  accepted_company_member_id uuid references public.company_members (id) on delete set null,
  status text not null default 'pending',
  expires_at timestamptz not null,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_sessions_audit (
  id uuid primary key default gen_random_uuid(),
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  event_type text not null,
  ip_address inet,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.platform_admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  platform_admin_id uuid references public.platform_admins (id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.staff_profiles (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  company_member_id uuid not null references public.company_members (id) on delete cascade,
  job_title text,
  public_bio text,
  booking_visibility text not null default 'visible',
  service_capacity integer not null default 1,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint staff_profiles_company_member_id_key unique (company_member_id)
);

create table public.staff_working_hours (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  staff_profile_id uuid not null references public.staff_profiles (id) on delete cascade,
  company_location_id uuid references public.company_locations (id) on delete set null,
  day_of_week smallint not null,
  start_time time not null,
  end_time time not null,
  break_windows jsonb not null default '[]'::jsonb,
  effective_start_date date,
  effective_end_date date,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint staff_working_hours_day_check check (day_of_week between 0 and 6)
);

create table public.staff_time_off (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  staff_profile_id uuid not null references public.staff_profiles (id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reason text,
  status text not null default 'approved',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint staff_time_off_range_check check (ends_at > starts_at)
);

-- API access and integration credentials metadata

create table public.api_clients (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  name text not null,
  client_key text not null,
  status text not null default 'active',
  scopes text[] not null default array[]::text[],
  created_by_company_member_id uuid references public.company_members (id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint api_clients_client_key_key unique (client_key)
);

create table public.api_keys (
  id uuid primary key default gen_random_uuid(),
  api_client_id uuid not null references public.api_clients (id) on delete cascade,
  key_prefix text not null,
  key_hash text not null,
  status text not null default 'active',
  expires_at timestamptz,
  last_used_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint api_keys_key_hash_key unique (key_hash)
);

create table public.service_accounts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  name text not null,
  status text not null default 'active',
  scopes text[] not null default array[]::text[],
  created_by_company_member_id uuid references public.company_members (id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Customers

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  full_name text not null,
  email text,
  phone text,
  birthdate date,
  lifecycle_status text not null default 'lead',
  source text,
  preferred_channel text,
  lead_status text,
  customer_type text,
  notes_summary text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  address_type text not null default 'billing',
  address_line1 text,
  address_line2 text,
  city text,
  region text,
  postal_code text,
  country text,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customer_notes (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  author_company_member_id uuid references public.company_members (id) on delete set null,
  body text not null,
  visibility text not null default 'internal',
  is_pinned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customer_tags (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  color text,
  description text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint customer_tags_company_name_key unique (company_id, name)
);

create table public.customer_tag_assignments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  customer_tag_id uuid not null references public.customer_tags (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint customer_tag_assignments_customer_tag_key unique (customer_id, customer_tag_id)
);

create table public.customer_consents (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  channel text not null,
  purpose text not null,
  status text not null default 'unknown',
  capture_source text,
  captured_at timestamptz,
  revoked_at timestamptz,
  proof_metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint customer_consents_customer_channel_purpose_key unique (customer_id, channel, purpose)
);

-- Services and resources

create table public.service_categories (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  description text,
  display_order integer not null default 0,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint service_categories_company_name_key unique (company_id, name)
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  service_category_id uuid references public.service_categories (id) on delete set null,
  name text not null,
  description text,
  duration_minutes integer not null,
  base_price numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  tax_behavior text not null default 'exclusive',
  booking_status text not null default 'bookable',
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint services_duration_check check (duration_minutes > 0)
);

create table public.service_resources (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  service_id uuid references public.services (id) on delete cascade,
  company_location_id uuid references public.company_locations (id) on delete set null,
  name text not null,
  resource_type text not null,
  capacity integer not null default 1,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.service_staff_assignments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  service_id uuid not null references public.services (id) on delete cascade,
  staff_profile_id uuid not null references public.staff_profiles (id) on delete cascade,
  company_location_id uuid references public.company_locations (id) on delete set null,
  price_override numeric(12, 2),
  duration_override_minutes integer,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint service_staff_assignments_service_staff_location_key unique (service_id, staff_profile_id, company_location_id)
);

-- Appointments and calendars

create table public.recurring_appointment_rules (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  staff_profile_id uuid references public.staff_profiles (id) on delete set null,
  recurrence_rule text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete restrict,
  company_location_id uuid references public.company_locations (id) on delete set null,
  primary_staff_profile_id uuid references public.staff_profiles (id) on delete set null,
  recurring_appointment_rule_id uuid references public.recurring_appointment_rules (id) on delete set null,
  status text not null default 'scheduled',
  source text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  cancellation_reason text,
  no_show boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint appointments_range_check check (ends_at > starts_at)
);

create table public.appointment_services (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  service_id uuid references public.services (id) on delete set null,
  service_name text not null,
  price_at_booking numeric(12, 2) not null default 0,
  duration_at_booking_minutes integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointment_participants (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  participant_type text not null,
  staff_profile_id uuid references public.staff_profiles (id) on delete set null,
  customer_id uuid references public.customers (id) on delete set null,
  service_resource_id uuid references public.service_resources (id) on delete set null,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointment_status_history (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  actor_company_member_id uuid references public.company_members (id) on delete set null,
  from_status text,
  to_status text not null,
  reason text,
  changed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointment_reminders (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  channel text not null,
  scheduled_for timestamptz not null,
  status text not null default 'pending',
  sent_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.appointment_waitlists (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  service_id uuid references public.services (id) on delete set null,
  staff_profile_id uuid references public.staff_profiles (id) on delete set null,
  preferred_start_at timestamptz,
  preferred_end_at timestamptz,
  status text not null default 'waiting',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.resource_bookings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  service_resource_id uuid not null references public.service_resources (id) on delete cascade,
  appointment_id uuid references public.appointments (id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'reserved',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint resource_bookings_range_check check (ends_at > starts_at)
);

create table public.booking_holds (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete set null,
  service_id uuid references public.services (id) on delete set null,
  staff_profile_id uuid references public.staff_profiles (id) on delete set null,
  company_location_id uuid references public.company_locations (id) on delete set null,
  appointment_id uuid references public.appointments (id) on delete set null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  expires_at timestamptz not null,
  status text not null default 'held',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.calendar_connections (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  company_member_id uuid references public.company_members (id) on delete cascade,
  provider text not null,
  external_account_id text not null,
  status text not null default 'active',
  sync_status text not null default 'pending',
  last_synced_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_connections_provider_external_account_key unique (provider, external_account_id)
);

create table public.calendar_event_mappings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  calendar_connection_id uuid not null references public.calendar_connections (id) on delete cascade,
  external_event_id text not null,
  sync_direction text not null default 'bidirectional',
  sync_status text not null default 'synced',
  conflict_status text,
  last_synced_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_event_mappings_connection_external_event_key unique (calendar_connection_id, external_event_id)
);

-- CRM

create table public.crm_pipelines (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  description text,
  module_context text not null default 'crm',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint crm_pipelines_company_name_key unique (company_id, name)
);

create table public.crm_stages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  crm_pipeline_id uuid not null references public.crm_pipelines (id) on delete cascade,
  name text not null,
  display_order integer not null default 0,
  probability integer,
  is_won boolean not null default false,
  is_lost boolean not null default false,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.crm_deals (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  crm_pipeline_id uuid not null references public.crm_pipelines (id) on delete restrict,
  crm_stage_id uuid not null references public.crm_stages (id) on delete restrict,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  title text not null,
  value numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  expected_close_date date,
  status text not null default 'open',
  source text,
  loss_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.crm_activities (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete cascade,
  crm_deal_id uuid references public.crm_deals (id) on delete cascade,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  activity_type text not null,
  subject text not null,
  body text,
  due_at timestamptz,
  completed_at timestamptz,
  outcome text,
  related_entity_type text,
  related_entity_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.crm_external_mappings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  provider text not null,
  internal_entity_type text not null,
  internal_entity_id uuid not null,
  external_object_id text not null,
  sync_status text not null default 'pending',
  sync_direction text not null default 'bidirectional',
  conflict_status text,
  last_synced_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint crm_external_mappings_provider_object_key unique (provider, external_object_id)
);

-- Marketing, messaging, files, and documents

create table public.files (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  storage_bucket text not null,
  storage_path text not null,
  file_name text not null,
  content_type text,
  size_bytes bigint,
  checksum text,
  uploaded_by_company_member_id uuid references public.company_members (id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint files_bucket_path_key unique (storage_bucket, storage_path)
);

create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  file_id uuid references public.files (id) on delete set null,
  name text not null,
  asset_type text not null,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.document_templates (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  template_type text not null,
  body text not null,
  variables jsonb not null default '[]'::jsonb,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.file_links (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  file_id uuid not null references public.files (id) on delete cascade,
  entity_type text not null,
  entity_id uuid not null,
  link_type text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.message_templates (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  channel text not null,
  body text not null,
  variables jsonb not null default '[]'::jsonb,
  approval_status text not null default 'draft',
  language text not null default 'en',
  provider_template_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.marketing_audiences (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  description text,
  segment_rules jsonb not null default '{}'::jsonb,
  refresh_behavior text not null default 'dynamic',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.marketing_campaigns (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  marketing_audience_id uuid references public.marketing_audiences (id) on delete set null,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  name text not null,
  channel text not null,
  objective text,
  status text not null default 'draft',
  scheduled_start_at timestamptz,
  scheduled_end_at timestamptz,
  budget_amount numeric(12, 2),
  currency text not null default 'USD',
  performance_metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.marketing_messages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  marketing_campaign_id uuid not null references public.marketing_campaigns (id) on delete cascade,
  message_template_id uuid references public.message_templates (id) on delete set null,
  channel text not null,
  subject text,
  body text not null,
  template_variables jsonb not null default '{}'::jsonb,
  approval_status text not null default 'draft',
  version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.marketing_deliveries (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  marketing_campaign_id uuid not null references public.marketing_campaigns (id) on delete cascade,
  marketing_message_id uuid references public.marketing_messages (id) on delete set null,
  customer_id uuid not null references public.customers (id) on delete cascade,
  customer_consent_id uuid references public.customer_consents (id) on delete set null,
  provider text,
  status text not null default 'pending',
  sent_at timestamptz,
  opened_at timestamptz,
  clicked_at timestamptz,
  failed_at timestamptz,
  provider_response jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete set null,
  channel text not null,
  subject text,
  status text not null default 'open',
  last_message_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.conversation_participants (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  participant_type text not null,
  customer_id uuid references public.customers (id) on delete set null,
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  company_member_id uuid references public.company_members (id) on delete set null,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_participant_id uuid references public.conversation_participants (id) on delete set null,
  direction text not null,
  channel text not null,
  body text,
  provider text,
  provider_message_id text,
  status text not null default 'created',
  sent_at timestamptz,
  received_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.message_attachments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  message_id uuid not null references public.messages (id) on delete cascade,
  file_id uuid not null references public.files (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.message_status_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  message_id uuid not null references public.messages (id) on delete cascade,
  provider text,
  event_type text not null,
  status text,
  occurred_at timestamptz not null default now(),
  provider_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  user_profile_id uuid references public.user_profiles (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete cascade,
  channel text not null,
  enabled boolean not null default true,
  preferences jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Integrations and OAuth grants

create table public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  provider text not null,
  status text not null default 'active',
  connected_account_id text,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  health_status text,
  last_health_check_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.oauth_grants (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  integration_connection_id uuid references public.integration_connections (id) on delete cascade,
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  provider text not null,
  external_subject_id text,
  scopes text[] not null default array[]::text[],
  status text not null default 'active',
  granted_at timestamptz,
  revoked_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.integration_sync_jobs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  integration_connection_id uuid not null references public.integration_connections (id) on delete cascade,
  job_type text not null,
  status text not null default 'queued',
  started_at timestamptz,
  finished_at timestamptz,
  processed_count integer not null default 0,
  failed_count integer not null default 0,
  error_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.webhook_signing_secrets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  integration_connection_id uuid references public.integration_connections (id) on delete cascade,
  provider text not null,
  secret_name text not null,
  secret_hash text not null,
  status text not null default 'active',
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  integration_connection_id uuid references public.integration_connections (id) on delete set null,
  provider text not null,
  event_type text not null,
  external_event_id text not null,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  status text not null default 'received',
  related_entity_type text,
  related_entity_id uuid,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint webhook_events_provider_external_event_key unique (provider, external_event_id)
);

-- Automations

create table public.automation_workflows (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  description text,
  trigger_type text,
  status text not null default 'draft',
  version integer not null default 1,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  published_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_triggers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  automation_workflow_id uuid not null references public.automation_workflows (id) on delete cascade,
  event_type text,
  filters jsonb not null default '{}'::jsonb,
  schedule_rule text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_steps (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  automation_workflow_id uuid not null references public.automation_workflows (id) on delete cascade,
  message_template_id uuid references public.message_templates (id) on delete set null,
  step_type text not null,
  configuration jsonb not null default '{}'::jsonb,
  display_order integer not null default 0,
  branching_rules jsonb not null default '{}'::jsonb,
  retry_behavior jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  webhook_event_id uuid references public.webhook_events (id) on delete set null,
  integration_sync_job_id uuid references public.integration_sync_jobs (id) on delete set null,
  event_type text not null,
  related_entity_type text,
  related_entity_id uuid,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_runs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  automation_workflow_id uuid not null references public.automation_workflows (id) on delete cascade,
  automation_event_id uuid references public.automation_events (id) on delete set null,
  status text not null default 'queued',
  started_at timestamptz,
  finished_at timestamptz,
  error_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_run_steps (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  automation_run_id uuid not null references public.automation_runs (id) on delete cascade,
  automation_step_id uuid references public.automation_steps (id) on delete set null,
  status text not null default 'queued',
  attempt_count integer not null default 0,
  error_summary text,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Payments

create table public.payment_customers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  provider text not null,
  external_customer_id text not null,
  sync_status text not null default 'synced',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payment_customers_provider_external_customer_key unique (provider, external_customer_id)
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  plan_name text not null,
  status text not null default 'active',
  billing_interval text not null default 'month',
  amount numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  start_date date not null,
  end_date date,
  renewal_date date,
  external_subscription_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete restrict,
  appointment_id uuid references public.appointments (id) on delete set null,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  invoice_number text not null,
  status text not null default 'draft',
  subtotal numeric(12, 2) not null default 0,
  discount_total numeric(12, 2) not null default 0,
  tax_total numeric(12, 2) not null default 0,
  total numeric(12, 2) not null default 0,
  currency text not null default 'USD',
  due_date date,
  issued_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint invoices_company_invoice_number_key unique (company_id, invoice_number)
);

create table public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  invoice_id uuid not null references public.invoices (id) on delete cascade,
  service_id uuid references public.services (id) on delete set null,
  description text not null,
  quantity numeric(12, 2) not null default 1,
  unit_price numeric(12, 2) not null default 0,
  discount_amount numeric(12, 2) not null default 0,
  tax_amount numeric(12, 2) not null default 0,
  total numeric(12, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete restrict,
  invoice_id uuid references public.invoices (id) on delete set null,
  provider text not null,
  payment_method text,
  status text not null default 'pending',
  amount numeric(12, 2) not null,
  currency text not null default 'USD',
  paid_at timestamptz,
  external_payment_id text,
  failure_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.refunds (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  payment_id uuid not null references public.payments (id) on delete restrict,
  requested_by_company_member_id uuid references public.company_members (id) on delete set null,
  amount numeric(12, 2) not null,
  reason text,
  status text not null default 'pending',
  external_refund_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Reports and audit

create table public.report_definitions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  owner_company_member_id uuid references public.company_members (id) on delete set null,
  name text not null,
  module text not null,
  metrics jsonb not null default '[]'::jsonb,
  filters jsonb not null default '{}'::jsonb,
  visibility text not null default 'private',
  schedule_rule text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.report_snapshots (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  report_definition_id uuid not null references public.report_definitions (id) on delete cascade,
  period_start date not null,
  period_end date not null,
  status text not null default 'generated',
  snapshot_data jsonb not null default '{}'::jsonb,
  generated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.metric_daily_rollups (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  metric_date date not null,
  metric_key text not null,
  dimension_key text,
  dimension_value text,
  metric_value numeric(18, 4) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint metric_daily_rollups_unique_key unique (company_id, metric_date, metric_key, dimension_key, dimension_value)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  actor_user_profile_id uuid references public.user_profiles (id) on delete set null,
  actor_company_member_id uuid references public.company_members (id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Privacy and compliance

create table public.data_subject_requests (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete set null,
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  request_type text not null,
  status text not null default 'open',
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.data_exports (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  data_subject_request_id uuid references public.data_subject_requests (id) on delete cascade,
  requested_by_company_member_id uuid references public.company_members (id) on delete set null,
  status text not null default 'queued',
  file_id uuid references public.files (id) on delete set null,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.data_deletion_jobs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  data_subject_request_id uuid references public.data_subject_requests (id) on delete cascade,
  entity_type text not null,
  entity_id uuid,
  status text not null default 'queued',
  scheduled_for timestamptz,
  completed_at timestamptz,
  error_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.retention_policies (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  entity_type text not null,
  retention_days integer not null,
  action text not null default 'archive',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint retention_policies_company_entity_key unique (company_id, entity_type)
);

create table public.consent_audit_logs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  customer_consent_id uuid references public.customer_consents (id) on delete set null,
  from_status text,
  to_status text not null,
  changed_by_company_member_id uuid references public.company_members (id) on delete set null,
  changed_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Reliability and event processing

create table public.job_queue (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  job_type text not null,
  status text not null default 'queued',
  priority integer not null default 0,
  payload jsonb not null default '{}'::jsonb,
  scheduled_for timestamptz not null default now(),
  locked_at timestamptz,
  locked_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.job_attempts (
  id uuid primary key default gen_random_uuid(),
  job_queue_id uuid not null references public.job_queue (id) on delete cascade,
  attempt_number integer not null,
  status text not null default 'running',
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  key text not null,
  operation text not null,
  request_hash text,
  response_status integer,
  response_body jsonb,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint idempotency_keys_key_operation_key unique (key, operation)
);

create table public.outbox_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  event_type text not null,
  aggregate_type text not null,
  aggregate_id uuid not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.dead_letter_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  outbox_event_id uuid references public.outbox_events (id) on delete set null,
  source_event_type text not null,
  source_event_id uuid,
  reason text not null,
  payload jsonb not null default '{}'::jsonb,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- AI governance

create table public.ai_prompts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  name text not null,
  prompt_key text not null,
  prompt_body text not null,
  version integer not null default 1,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ai_prompts_company_prompt_key_version_key unique (company_id, prompt_key, version)
);

create table public.ai_runs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  ai_prompt_id uuid references public.ai_prompts (id) on delete set null,
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  automation_run_id uuid references public.automation_runs (id) on delete set null,
  model text not null,
  status text not null default 'queued',
  input_entity_type text,
  input_entity_id uuid,
  started_at timestamptz,
  finished_at timestamptz,
  error_summary text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.ai_outputs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  ai_run_id uuid not null references public.ai_runs (id) on delete cascade,
  output_type text not null,
  content text,
  structured_content jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.ai_usage_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  ai_run_id uuid references public.ai_runs (id) on delete cascade,
  model text not null,
  input_tokens integer not null default 0,
  output_tokens integer not null default 0,
  total_tokens integer not null default 0,
  cost_amount numeric(12, 6) not null default 0,
  currency text not null default 'USD',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.ai_feedback (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  ai_output_id uuid not null references public.ai_outputs (id) on delete cascade,
  user_profile_id uuid references public.user_profiles (id) on delete set null,
  rating integer,
  feedback text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ai_feedback_rating_check check (rating is null or rating between 1 and 5)
);

-- Indexes

create index idx_platform_role_permissions_role_id on public.platform_role_permissions (platform_role_id);
create index idx_platform_role_permissions_permission_id on public.platform_role_permissions (platform_permission_id);
create index idx_platform_admins_user_profile_id on public.platform_admins (user_profile_id);
create index idx_platform_admin_audit_logs_admin_id on public.platform_admin_audit_logs (platform_admin_id);
create index idx_platform_admin_audit_logs_entity on public.platform_admin_audit_logs (entity_type, entity_id);

create index idx_plan_features_plan_id on public.plan_features (plan_id);
create index idx_plan_features_feature_id on public.plan_features (feature_id);
create index idx_billing_accounts_company_id on public.billing_accounts (company_id);
create index idx_company_subscriptions_company_id on public.company_subscriptions (company_id);
create index idx_company_subscriptions_plan_id on public.company_subscriptions (plan_id);
create index idx_subscription_items_subscription_id on public.subscription_items (company_subscription_id);
create index idx_company_feature_entitlements_company_id on public.company_feature_entitlements (company_id);
create index idx_usage_limits_company_id on public.usage_limits (company_id);
create index idx_usage_counters_company_id on public.usage_counters (company_id);
create index idx_usage_records_company_resource on public.usage_records (company_id, resource_key, occurred_at);
create index idx_tenant_invoices_billing_account_id on public.tenant_invoices (billing_account_id);

create index idx_user_profiles_auth_user_id on public.user_profiles (auth_user_id);
create index idx_company_settings_company_id on public.company_settings (company_id);
create index idx_company_branding_company_id on public.company_branding (company_id);
create index idx_company_locations_company_id on public.company_locations (company_id);
create index idx_roles_company_id on public.roles (company_id);
create index idx_role_permissions_role_id on public.role_permissions (role_id);
create index idx_role_permissions_permission_id on public.role_permissions (permission_id);
create index idx_company_members_company_id on public.company_members (company_id);
create index idx_company_members_user_profile_id on public.company_members (user_profile_id);
create index idx_company_invitations_company_id on public.company_invitations (company_id);
create index idx_user_sessions_audit_user_profile_id on public.user_sessions_audit (user_profile_id);
create index idx_staff_profiles_company_id on public.staff_profiles (company_id);
create index idx_staff_working_hours_staff_profile_id on public.staff_working_hours (staff_profile_id);
create index idx_staff_time_off_staff_profile_id on public.staff_time_off (staff_profile_id, starts_at, ends_at);
create index idx_api_clients_company_id on public.api_clients (company_id);
create index idx_api_keys_api_client_id on public.api_keys (api_client_id);
create index idx_service_accounts_company_id on public.service_accounts (company_id);

create index idx_customers_company_id on public.customers (company_id);
create index idx_customers_company_email on public.customers (company_id, email);
create index idx_customers_company_phone on public.customers (company_id, phone);
create index idx_customer_addresses_customer_id on public.customer_addresses (customer_id);
create index idx_customer_notes_customer_id on public.customer_notes (customer_id);
create index idx_customer_tags_company_id on public.customer_tags (company_id);
create index idx_customer_tag_assignments_customer_id on public.customer_tag_assignments (customer_id);
create index idx_customer_tag_assignments_tag_id on public.customer_tag_assignments (customer_tag_id);
create index idx_customer_consents_customer_id on public.customer_consents (customer_id);

create index idx_service_categories_company_id on public.service_categories (company_id);
create index idx_services_company_id on public.services (company_id);
create index idx_services_category_id on public.services (service_category_id);
create index idx_service_resources_company_id on public.service_resources (company_id);
create index idx_service_staff_assignments_service_id on public.service_staff_assignments (service_id);
create index idx_service_staff_assignments_staff_id on public.service_staff_assignments (staff_profile_id);

create index idx_recurring_appointment_rules_company_id on public.recurring_appointment_rules (company_id);
create index idx_appointments_company_start on public.appointments (company_id, starts_at);
create index idx_appointments_customer_id on public.appointments (customer_id);
create index idx_appointments_staff_start on public.appointments (primary_staff_profile_id, starts_at);
create index idx_appointment_services_appointment_id on public.appointment_services (appointment_id);
create index idx_appointment_participants_appointment_id on public.appointment_participants (appointment_id);
create index idx_appointment_status_history_appointment_id on public.appointment_status_history (appointment_id);
create index idx_appointment_reminders_scheduled_for on public.appointment_reminders (scheduled_for, status);
create index idx_appointment_waitlists_company_id on public.appointment_waitlists (company_id);
create index idx_resource_bookings_resource_time on public.resource_bookings (service_resource_id, starts_at, ends_at);
create index idx_booking_holds_company_expires on public.booking_holds (company_id, expires_at);
create index idx_calendar_connections_company_id on public.calendar_connections (company_id);
create index idx_calendar_event_mappings_appointment_id on public.calendar_event_mappings (appointment_id);

create index idx_crm_pipelines_company_id on public.crm_pipelines (company_id);
create index idx_crm_stages_pipeline_id on public.crm_stages (crm_pipeline_id);
create index idx_crm_deals_company_stage on public.crm_deals (company_id, crm_stage_id);
create index idx_crm_deals_customer_id on public.crm_deals (customer_id);
create index idx_crm_activities_company_due on public.crm_activities (company_id, due_at);
create index idx_crm_activities_customer_id on public.crm_activities (customer_id);
create index idx_crm_external_mappings_internal_entity on public.crm_external_mappings (internal_entity_type, internal_entity_id);

create index idx_files_company_id on public.files (company_id);
create index idx_file_links_entity on public.file_links (entity_type, entity_id);
create index idx_media_assets_company_id on public.media_assets (company_id);
create index idx_document_templates_company_id on public.document_templates (company_id);
create index idx_message_templates_company_id on public.message_templates (company_id);
create index idx_marketing_audiences_company_id on public.marketing_audiences (company_id);
create index idx_marketing_campaigns_company_id on public.marketing_campaigns (company_id);
create index idx_marketing_messages_campaign_id on public.marketing_messages (marketing_campaign_id);
create index idx_marketing_deliveries_campaign_id on public.marketing_deliveries (marketing_campaign_id);
create index idx_marketing_deliveries_customer_id on public.marketing_deliveries (customer_id);
create index idx_conversations_company_id on public.conversations (company_id);
create index idx_conversations_customer_id on public.conversations (customer_id);
create index idx_conversation_participants_conversation_id on public.conversation_participants (conversation_id);
create index idx_messages_conversation_id on public.messages (conversation_id);
create index idx_messages_provider_message_id on public.messages (provider, provider_message_id);
create index idx_message_status_events_message_id on public.message_status_events (message_id);
create index idx_notification_preferences_user_profile_id on public.notification_preferences (user_profile_id);
create index idx_notification_preferences_customer_id on public.notification_preferences (customer_id);

create index idx_integration_connections_company_id on public.integration_connections (company_id);
create index idx_oauth_grants_connection_id on public.oauth_grants (integration_connection_id);
create index idx_integration_sync_jobs_connection_id on public.integration_sync_jobs (integration_connection_id);
create index idx_webhook_signing_secrets_connection_id on public.webhook_signing_secrets (integration_connection_id);
create index idx_webhook_events_company_id on public.webhook_events (company_id);
create index idx_webhook_events_provider_event on public.webhook_events (provider, event_type, received_at);

create index idx_automation_workflows_company_id on public.automation_workflows (company_id);
create index idx_automation_triggers_workflow_id on public.automation_triggers (automation_workflow_id);
create index idx_automation_steps_workflow_id on public.automation_steps (automation_workflow_id);
create index idx_automation_events_company_type on public.automation_events (company_id, event_type, occurred_at);
create index idx_automation_runs_workflow_id on public.automation_runs (automation_workflow_id);
create index idx_automation_run_steps_run_id on public.automation_run_steps (automation_run_id);

create index idx_payment_customers_customer_id on public.payment_customers (customer_id);
create index idx_subscriptions_customer_id on public.subscriptions (customer_id);
create index idx_invoices_company_id on public.invoices (company_id);
create index idx_invoices_customer_id on public.invoices (customer_id);
create index idx_invoice_items_invoice_id on public.invoice_items (invoice_id);
create index idx_payments_company_id on public.payments (company_id);
create index idx_payments_invoice_id on public.payments (invoice_id);
create index idx_refunds_payment_id on public.refunds (payment_id);

create index idx_report_definitions_company_id on public.report_definitions (company_id);
create index idx_report_snapshots_definition_id on public.report_snapshots (report_definition_id);
create index idx_metric_daily_rollups_company_date on public.metric_daily_rollups (company_id, metric_date);
create index idx_audit_logs_company_created_at on public.audit_logs (company_id, created_at);
create index idx_audit_logs_entity on public.audit_logs (entity_type, entity_id);

create index idx_data_subject_requests_company_id on public.data_subject_requests (company_id);
create index idx_data_exports_request_id on public.data_exports (data_subject_request_id);
create index idx_data_deletion_jobs_request_id on public.data_deletion_jobs (data_subject_request_id);
create index idx_retention_policies_company_id on public.retention_policies (company_id);
create index idx_consent_audit_logs_customer_id on public.consent_audit_logs (customer_id);

create index idx_job_queue_status_scheduled on public.job_queue (status, scheduled_for);
create index idx_job_attempts_job_id on public.job_attempts (job_queue_id);
create index idx_idempotency_keys_company_id on public.idempotency_keys (company_id);
create index idx_outbox_events_status_created_at on public.outbox_events (status, created_at);
create index idx_dead_letter_events_company_id on public.dead_letter_events (company_id);

create index idx_ai_prompts_company_id on public.ai_prompts (company_id);
create index idx_ai_runs_company_id on public.ai_runs (company_id);
create index idx_ai_runs_prompt_id on public.ai_runs (ai_prompt_id);
create index idx_ai_outputs_run_id on public.ai_outputs (ai_run_id);
create index idx_ai_usage_records_run_id on public.ai_usage_records (ai_run_id);
create index idx_ai_feedback_output_id on public.ai_feedback (ai_output_id);

-- updated_at triggers

create trigger set_platform_roles_updated_at before update on public.platform_roles for each row execute function public.set_updated_at();
create trigger set_platform_permissions_updated_at before update on public.platform_permissions for each row execute function public.set_updated_at();
create trigger set_platform_role_permissions_updated_at before update on public.platform_role_permissions for each row execute function public.set_updated_at();
create trigger set_user_profiles_updated_at before update on public.user_profiles for each row execute function public.set_updated_at();
create trigger set_platform_admins_updated_at before update on public.platform_admins for each row execute function public.set_updated_at();
create trigger set_plans_updated_at before update on public.plans for each row execute function public.set_updated_at();
create trigger set_features_updated_at before update on public.features for each row execute function public.set_updated_at();
create trigger set_plan_features_updated_at before update on public.plan_features for each row execute function public.set_updated_at();
create trigger set_companies_updated_at before update on public.companies for each row execute function public.set_updated_at();
create trigger set_billing_accounts_updated_at before update on public.billing_accounts for each row execute function public.set_updated_at();
create trigger set_company_subscriptions_updated_at before update on public.company_subscriptions for each row execute function public.set_updated_at();
create trigger set_subscription_items_updated_at before update on public.subscription_items for each row execute function public.set_updated_at();
create trigger set_company_feature_entitlements_updated_at before update on public.company_feature_entitlements for each row execute function public.set_updated_at();
create trigger set_usage_limits_updated_at before update on public.usage_limits for each row execute function public.set_updated_at();
create trigger set_usage_counters_updated_at before update on public.usage_counters for each row execute function public.set_updated_at();
create trigger set_usage_records_updated_at before update on public.usage_records for each row execute function public.set_updated_at();
create trigger set_tenant_invoices_updated_at before update on public.tenant_invoices for each row execute function public.set_updated_at();
create trigger set_company_settings_updated_at before update on public.company_settings for each row execute function public.set_updated_at();
create trigger set_company_branding_updated_at before update on public.company_branding for each row execute function public.set_updated_at();
create trigger set_company_locations_updated_at before update on public.company_locations for each row execute function public.set_updated_at();
create trigger set_roles_updated_at before update on public.roles for each row execute function public.set_updated_at();
create trigger set_permissions_updated_at before update on public.permissions for each row execute function public.set_updated_at();
create trigger set_role_permissions_updated_at before update on public.role_permissions for each row execute function public.set_updated_at();
create trigger set_company_members_updated_at before update on public.company_members for each row execute function public.set_updated_at();
create trigger set_company_invitations_updated_at before update on public.company_invitations for each row execute function public.set_updated_at();
create trigger set_user_sessions_audit_updated_at before update on public.user_sessions_audit for each row execute function public.set_updated_at();
create trigger set_platform_admin_audit_logs_updated_at before update on public.platform_admin_audit_logs for each row execute function public.set_updated_at();
create trigger set_staff_profiles_updated_at before update on public.staff_profiles for each row execute function public.set_updated_at();
create trigger set_staff_working_hours_updated_at before update on public.staff_working_hours for each row execute function public.set_updated_at();
create trigger set_staff_time_off_updated_at before update on public.staff_time_off for each row execute function public.set_updated_at();
create trigger set_api_clients_updated_at before update on public.api_clients for each row execute function public.set_updated_at();
create trigger set_api_keys_updated_at before update on public.api_keys for each row execute function public.set_updated_at();
create trigger set_service_accounts_updated_at before update on public.service_accounts for each row execute function public.set_updated_at();
create trigger set_customers_updated_at before update on public.customers for each row execute function public.set_updated_at();
create trigger set_customer_addresses_updated_at before update on public.customer_addresses for each row execute function public.set_updated_at();
create trigger set_customer_notes_updated_at before update on public.customer_notes for each row execute function public.set_updated_at();
create trigger set_customer_tags_updated_at before update on public.customer_tags for each row execute function public.set_updated_at();
create trigger set_customer_tag_assignments_updated_at before update on public.customer_tag_assignments for each row execute function public.set_updated_at();
create trigger set_customer_consents_updated_at before update on public.customer_consents for each row execute function public.set_updated_at();
create trigger set_service_categories_updated_at before update on public.service_categories for each row execute function public.set_updated_at();
create trigger set_services_updated_at before update on public.services for each row execute function public.set_updated_at();
create trigger set_service_resources_updated_at before update on public.service_resources for each row execute function public.set_updated_at();
create trigger set_service_staff_assignments_updated_at before update on public.service_staff_assignments for each row execute function public.set_updated_at();
create trigger set_recurring_appointment_rules_updated_at before update on public.recurring_appointment_rules for each row execute function public.set_updated_at();
create trigger set_appointments_updated_at before update on public.appointments for each row execute function public.set_updated_at();
create trigger set_appointment_services_updated_at before update on public.appointment_services for each row execute function public.set_updated_at();
create trigger set_appointment_participants_updated_at before update on public.appointment_participants for each row execute function public.set_updated_at();
create trigger set_appointment_status_history_updated_at before update on public.appointment_status_history for each row execute function public.set_updated_at();
create trigger set_appointment_reminders_updated_at before update on public.appointment_reminders for each row execute function public.set_updated_at();
create trigger set_appointment_waitlists_updated_at before update on public.appointment_waitlists for each row execute function public.set_updated_at();
create trigger set_resource_bookings_updated_at before update on public.resource_bookings for each row execute function public.set_updated_at();
create trigger set_booking_holds_updated_at before update on public.booking_holds for each row execute function public.set_updated_at();
create trigger set_calendar_connections_updated_at before update on public.calendar_connections for each row execute function public.set_updated_at();
create trigger set_calendar_event_mappings_updated_at before update on public.calendar_event_mappings for each row execute function public.set_updated_at();
create trigger set_crm_pipelines_updated_at before update on public.crm_pipelines for each row execute function public.set_updated_at();
create trigger set_crm_stages_updated_at before update on public.crm_stages for each row execute function public.set_updated_at();
create trigger set_crm_deals_updated_at before update on public.crm_deals for each row execute function public.set_updated_at();
create trigger set_crm_activities_updated_at before update on public.crm_activities for each row execute function public.set_updated_at();
create trigger set_crm_external_mappings_updated_at before update on public.crm_external_mappings for each row execute function public.set_updated_at();
create trigger set_files_updated_at before update on public.files for each row execute function public.set_updated_at();
create trigger set_media_assets_updated_at before update on public.media_assets for each row execute function public.set_updated_at();
create trigger set_document_templates_updated_at before update on public.document_templates for each row execute function public.set_updated_at();
create trigger set_file_links_updated_at before update on public.file_links for each row execute function public.set_updated_at();
create trigger set_message_templates_updated_at before update on public.message_templates for each row execute function public.set_updated_at();
create trigger set_marketing_audiences_updated_at before update on public.marketing_audiences for each row execute function public.set_updated_at();
create trigger set_marketing_campaigns_updated_at before update on public.marketing_campaigns for each row execute function public.set_updated_at();
create trigger set_marketing_messages_updated_at before update on public.marketing_messages for each row execute function public.set_updated_at();
create trigger set_marketing_deliveries_updated_at before update on public.marketing_deliveries for each row execute function public.set_updated_at();
create trigger set_conversations_updated_at before update on public.conversations for each row execute function public.set_updated_at();
create trigger set_conversation_participants_updated_at before update on public.conversation_participants for each row execute function public.set_updated_at();
create trigger set_messages_updated_at before update on public.messages for each row execute function public.set_updated_at();
create trigger set_message_attachments_updated_at before update on public.message_attachments for each row execute function public.set_updated_at();
create trigger set_message_status_events_updated_at before update on public.message_status_events for each row execute function public.set_updated_at();
create trigger set_notification_preferences_updated_at before update on public.notification_preferences for each row execute function public.set_updated_at();
create trigger set_integration_connections_updated_at before update on public.integration_connections for each row execute function public.set_updated_at();
create trigger set_oauth_grants_updated_at before update on public.oauth_grants for each row execute function public.set_updated_at();
create trigger set_integration_sync_jobs_updated_at before update on public.integration_sync_jobs for each row execute function public.set_updated_at();
create trigger set_webhook_signing_secrets_updated_at before update on public.webhook_signing_secrets for each row execute function public.set_updated_at();
create trigger set_webhook_events_updated_at before update on public.webhook_events for each row execute function public.set_updated_at();
create trigger set_automation_workflows_updated_at before update on public.automation_workflows for each row execute function public.set_updated_at();
create trigger set_automation_triggers_updated_at before update on public.automation_triggers for each row execute function public.set_updated_at();
create trigger set_automation_steps_updated_at before update on public.automation_steps for each row execute function public.set_updated_at();
create trigger set_automation_events_updated_at before update on public.automation_events for each row execute function public.set_updated_at();
create trigger set_automation_runs_updated_at before update on public.automation_runs for each row execute function public.set_updated_at();
create trigger set_automation_run_steps_updated_at before update on public.automation_run_steps for each row execute function public.set_updated_at();
create trigger set_payment_customers_updated_at before update on public.payment_customers for each row execute function public.set_updated_at();
create trigger set_subscriptions_updated_at before update on public.subscriptions for each row execute function public.set_updated_at();
create trigger set_invoices_updated_at before update on public.invoices for each row execute function public.set_updated_at();
create trigger set_invoice_items_updated_at before update on public.invoice_items for each row execute function public.set_updated_at();
create trigger set_payments_updated_at before update on public.payments for each row execute function public.set_updated_at();
create trigger set_refunds_updated_at before update on public.refunds for each row execute function public.set_updated_at();
create trigger set_report_definitions_updated_at before update on public.report_definitions for each row execute function public.set_updated_at();
create trigger set_report_snapshots_updated_at before update on public.report_snapshots for each row execute function public.set_updated_at();
create trigger set_metric_daily_rollups_updated_at before update on public.metric_daily_rollups for each row execute function public.set_updated_at();
create trigger set_audit_logs_updated_at before update on public.audit_logs for each row execute function public.set_updated_at();
create trigger set_data_subject_requests_updated_at before update on public.data_subject_requests for each row execute function public.set_updated_at();
create trigger set_data_exports_updated_at before update on public.data_exports for each row execute function public.set_updated_at();
create trigger set_data_deletion_jobs_updated_at before update on public.data_deletion_jobs for each row execute function public.set_updated_at();
create trigger set_retention_policies_updated_at before update on public.retention_policies for each row execute function public.set_updated_at();
create trigger set_consent_audit_logs_updated_at before update on public.consent_audit_logs for each row execute function public.set_updated_at();
create trigger set_job_queue_updated_at before update on public.job_queue for each row execute function public.set_updated_at();
create trigger set_job_attempts_updated_at before update on public.job_attempts for each row execute function public.set_updated_at();
create trigger set_idempotency_keys_updated_at before update on public.idempotency_keys for each row execute function public.set_updated_at();
create trigger set_outbox_events_updated_at before update on public.outbox_events for each row execute function public.set_updated_at();
create trigger set_dead_letter_events_updated_at before update on public.dead_letter_events for each row execute function public.set_updated_at();
create trigger set_ai_prompts_updated_at before update on public.ai_prompts for each row execute function public.set_updated_at();
create trigger set_ai_runs_updated_at before update on public.ai_runs for each row execute function public.set_updated_at();
create trigger set_ai_outputs_updated_at before update on public.ai_outputs for each row execute function public.set_updated_at();
create trigger set_ai_usage_records_updated_at before update on public.ai_usage_records for each row execute function public.set_updated_at();
create trigger set_ai_feedback_updated_at before update on public.ai_feedback for each row execute function public.set_updated_at();
