# Casa Di Amo OS Database Architecture

## 1. Entities

### Authentication

#### `auth.users`

Supabase Auth identity record.

- Owns login identity, verified email, verified phone, authentication providers, and session lifecycle.
- Must not be used as the business user profile.
- Referenced by `user_profiles`.

#### `user_profiles`

Application profile for a human user.

- Stores name, contact details, avatar, locale, timezone, user status, and profile preferences.
- Links one application profile to one Supabase Auth identity.
- Can access one or more companies through `company_members`.

#### `roles`

Role definitions for platform and company access.

- Stores role name, role scope, description, status, and optional company ownership.
- Supports platform roles and company-specific roles.

#### `permissions`

Atomic permission catalog.

- Stores permission key, module, action, and description.
- Defines the stable permission vocabulary used by the application.

#### `role_permissions`

Role-to-permission assignment.

- Connects roles to the permissions they grant.
- Enables reusable role templates and company-specific permission sets.

#### `user_sessions_audit`

Security history for authentication-sensitive activity.

- Tracks login, logout, failed login, password reset, MFA changes, and suspicious access events.
- Used for account security review and compliance reporting.

### Companies

#### `companies`

Primary tenant boundary.

- Stores legal name, trading name, slug, industry, status, default locale, default timezone, and lifecycle timestamps.
- Owns all operational records for a tenant.
- Represents the white-label business account.

#### `company_settings`

Company-level operational configuration.

- Stores scheduling, CRM, marketing, notification, payment, report, and data-retention preferences.
- Keeps tenant configuration separate from the core company identity.

#### `company_branding`

White-label branding configuration.

- Stores logo, colors, domain configuration, public profile settings, and customer-facing brand metadata.
- Supports white-label UI and communication channels.

#### `company_locations`

Physical or virtual service locations.

- Stores address, contact details, timezone, availability status, and location metadata.
- Used by appointments, services, staff availability, and reports.

#### `company_members`

Tenant membership record.

- Connects a `user_profile` to a `company`.
- Stores role, membership status, invitation status, join date, and access state.
- Determines which tenant context a user may operate within.

#### `company_invitations`

Pending company access invitation.

- Stores invited email, invited role, invitation status, inviter, expiration, and acceptance state.
- Supports secure onboarding before a user profile exists.

### Users

#### `staff_profiles`

Company-specific staff metadata.

- Extends a `company_member` with staff-specific details such as job title, public bio, booking visibility, service capacity, and staff status.
- Allows some users to be bookable service providers.

#### `staff_working_hours`

Recurring staff schedule.

- Stores regular working days, start time, end time, break windows, location, and effective date range.
- Used to calculate appointment availability.

#### `staff_time_off`

Staff unavailability.

- Stores vacations, sick leave, blocked time, and other exceptions.
- Prevents booking during unavailable periods.

### Customers

#### `customers`

Primary customer record owned by a company.

- Stores name, email, phone, birthdate, lifecycle status, source, preferred channel, lead status, customer type, and summary notes.
- Anchors appointments, CRM, marketing, automations, payments, and reports.

#### `customer_addresses`

Customer address book.

- Stores billing, service, and mailing addresses.
- Supports companies that provide on-site services or require billing details.

#### `customer_notes`

Internal customer notes.

- Stores author, note body, visibility, pinned state, and timestamps.
- Supports staff collaboration and customer history.

#### `customer_tags`

Company-defined customer labels.

- Stores tag name, color, description, and status.
- Used for segmentation, CRM, filtering, automations, and reports.

#### `customer_tag_assignments`

Customer-to-tag join entity.

- Connects customers to one or more company tags.

#### `customer_consents`

Customer consent record.

- Stores channel, purpose, consent status, capture source, capture timestamp, revocation timestamp, and proof metadata.
- Required for compliant marketing and messaging.

### Services

#### `service_categories`

Company service grouping.

- Stores category name, description, display order, and active status.
- Organizes customer-facing service catalogs.

#### `services`

Service offered by a company.

- Stores name, description, duration, base price, category, tax behavior, booking status, and active status.
- Used by appointments, staff assignment, invoices, marketing, and reports.

#### `service_staff_assignments`

Service eligibility by staff member.

- Connects services to staff who can perform them.
- Can include location, price override, duration override, and active status.

#### `service_resources`

Resources required to provide a service.

- Stores rooms, equipment, seats, or other constrained resources.
- Prevents overbooking shared resources.

### Appointments

#### `appointments`

Scheduled booking.

- Stores customer, company, location, assigned staff, status, source, start time, end time, cancellation reason, no-show status, and lifecycle timestamps.
- Central record for scheduling, reminders, payments, reporting, and automations.

#### `appointment_services`

Services included in an appointment.

- Connects appointments to one or more services.
- Preserves price, duration, and service name at booking time.

#### `appointment_participants`

Additional appointment participants.

- Tracks extra staff, guests, or resources involved in an appointment.
- Supports group services and multi-staff service delivery.

#### `appointment_status_history`

Appointment lifecycle audit.

- Stores status changes, actor, reason, and timestamps.
- Supports operational traceability and reporting.

#### `calendar_connections`

External calendar account connection.

- Stores provider, connected account, owner, sync status, and last sync time.
- Supports Google Calendar, Calendly, and future providers.

#### `calendar_event_mappings`

Internal-to-external calendar mapping.

- Connects an appointment to external calendar event IDs.
- Tracks sync direction, sync state, and conflict state.

### CRM

#### `crm_pipelines`

Company-defined pipeline.

- Stores pipeline name, description, module context, and active status.
- Supports sales, lead nurturing, and customer lifecycle management.

#### `crm_stages`

Pipeline stage.

- Stores stage name, order, probability, win status, lost status, and active status.
- Defines progression inside a pipeline.

#### `crm_deals`

Opportunity or commercial relationship record.

- Stores customer, pipeline, stage, owner, title, value, expected close date, status, source, and loss reason.
- Connects customer acquisition, follow-up, and revenue forecasting.

#### `crm_activities`

CRM task or interaction.

- Stores customer, deal, owner, activity type, subject, body, due date, completion state, and outcome.
- Tracks calls, messages, meetings, tasks, notes, and follow-ups.

#### `crm_external_mappings`

External CRM mapping.

- Connects internal CRM entities to HubSpot or future CRM provider object IDs.
- Tracks sync status, sync direction, conflict state, and last sync time.

### Marketing

#### `marketing_audiences`

Audience or customer segment.

- Stores name, description, segment rules, status, and refresh behavior.
- Used to target campaigns and automations.

#### `marketing_campaigns`

Campaign definition.

- Stores audience, channel, objective, status, schedule, owner, budget metadata, and performance metadata.
- Supports WhatsApp, ManyChat, Meta Ads, email, SMS, and future channels.

#### `marketing_messages`

Campaign message content.

- Stores channel, subject, body, template variables, approval status, and version.
- Keeps message content separate from delivery events.

#### `marketing_deliveries`

Per-recipient campaign delivery.

- Stores customer, campaign, message, provider, delivery status, sent time, opened time, clicked time, failed time, and provider response metadata.
- Supports attribution, compliance, and reporting.

#### `message_templates`

Reusable message template.

- Stores template name, channel, body, variables, approval state, language, and provider template ID.
- Used by marketing campaigns and automations.

### Automations

#### `automation_workflows`

Automation workflow definition.

- Stores name, description, trigger type, status, version, owner, and publish state.
- Represents a reusable business process.

#### `automation_triggers`

Workflow trigger configuration.

- Stores event type, filters, schedule rules, and trigger status.
- Defines when a workflow should start.

#### `automation_steps`

Workflow step definition.

- Stores workflow, step type, configuration, order, branching rules, and retry behavior.
- Defines actions such as send message, create CRM task, update deal, wait, or notify staff.

#### `automation_events`

System event stream.

- Stores event type, company, related entity type, related entity ID, event payload summary, occurred time, and processing state.
- Decouples transactional modules from automation execution.

#### `automation_runs`

Workflow execution instance.

- Stores workflow, triggering event, status, start time, finish time, and error summary.
- Provides operational observability.

#### `automation_run_steps`

Step-level execution record.

- Stores automation run, step, status, attempt count, start time, finish time, and error summary.
- Supports retry and debugging.

### Payments

#### `payment_customers`

Payment provider customer mapping.

- Connects an internal customer to a payment provider customer ID.
- Stores provider, external customer ID, sync status, and metadata summary.

#### `invoices`

Customer invoice.

- Stores customer, appointment, invoice number, status, subtotal, discount total, tax total, total, currency, due date, issued time, and paid time.
- Represents the billable business document.

#### `invoice_items`

Invoice line item.

- Stores invoice, service, description, quantity, unit price, discount, tax, and total.
- Preserves billing details at the time of invoice creation.

#### `payments`

Payment transaction.

- Stores invoice, customer, provider, method, status, amount, currency, paid time, external payment ID, and failure reason.
- Tracks money movement without storing raw card data.

#### `refunds`

Payment refund.

- Stores payment, amount, reason, status, external refund ID, requester, and timestamps.
- Supports financial auditability.

#### `subscriptions`

Recurring customer billing relationship.

- Stores customer, plan, status, billing interval, amount, currency, start date, end date, renewal date, and external subscription ID.
- Supports packages, memberships, and recurring services.

### Reports

#### `report_definitions`

Saved report configuration.

- Stores name, module, metrics, filters, visibility, owner, and schedule.
- Defines reusable operational and executive reports.

#### `report_snapshots`

Generated report output.

- Stores report definition, reporting period, snapshot summary, generated time, and generation status.
- Provides repeatable historical reporting.

#### `metric_daily_rollups`

Daily aggregated metrics.

- Stores metric date, metric key, dimension key, dimension value, and metric value.
- Supports scalable dashboards without overloading transactional records.

#### `audit_logs`

System and business audit trail.

- Stores actor, company, action, entity type, entity ID, metadata summary, IP context, user agent context, and timestamp.
- Records sensitive changes and privileged activity.

### Integrations

#### `integration_connections`

Company integration connection.

- Stores provider, connection status, connected account, owner, health status, and last health check.
- Represents tenant-owned connections to HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, Meta Ads, and payment providers.

#### `integration_sync_jobs`

Integration sync execution.

- Stores connection, job type, status, start time, finish time, processed count, failed count, and error summary.
- Tracks background synchronization work.

#### `webhook_events`

Inbound webhook event ledger.

- Stores provider, event type, external event ID, receipt time, processing status, related entity, and deduplication state.
- Supports reliable external event processing.

## 2. Relationships

### Tenant and Identity

- One `company` has many `company_members`.
- One `user_profile` can belong to many `companies` through `company_members`.
- One `company_member` belongs to one `company` and one `user_profile`.
- One `company_member` has one active `role` per company context.
- One `role` has many `permissions` through `role_permissions`.
- One `company` has one `company_settings` record.
- One `company` has one `company_branding` record.
- One `company` has many `company_locations`.
- One `company` has many `company_invitations`.

### Users and Staff

- One `company_member` may have one `staff_profile`.
- One `staff_profile` has many `staff_working_hours`.
- One `staff_profile` has many `staff_time_off` records.
- One `staff_profile` can be assigned to many `services`.
- One `staff_profile` can own many `appointments`, `crm_deals`, `crm_activities`, campaigns, workflows, and reports.

### Customers

- One `company` has many `customers`.
- One `customer` belongs to exactly one `company`.
- One `customer` has many `customer_addresses`.
- One `customer` has many `customer_notes`.
- One `customer` has many `customer_consents`.
- One `customer` has many `customer_tags` through `customer_tag_assignments`.
- One `customer` can have many `appointments`, `crm_deals`, `marketing_deliveries`, `invoices`, `payments`, and `subscriptions`.

### Services and Appointments

- One `company` has many `service_categories`.
- One `service_category` has many `services`.
- One `service` belongs to one `company`.
- One `service` can require many `service_resources`.
- One `service` can be performed by many staff members through `service_staff_assignments`.
- One `appointment` belongs to one `company`, one `customer`, and optionally one `company_location`.
- One `appointment` has one primary assigned staff member and may have many additional participants.
- One `appointment` contains one or more `services` through `appointment_services`.
- One `appointment` has many `appointment_status_history` records.
- One `appointment` can map to many external calendar events through `calendar_event_mappings`.

### CRM

- One `company` has many `crm_pipelines`.
- One `crm_pipeline` has many `crm_stages`.
- One `customer` has many `crm_deals`.
- One `crm_deal` belongs to one `crm_pipeline` and one current `crm_stage`.
- One `crm_deal` has many `crm_activities`.
- One `crm_activity` can relate to a customer, deal, appointment, or campaign.
- One internal CRM entity can have many `crm_external_mappings` for external providers.

### Marketing

- One `company` has many `marketing_audiences`.
- One `marketing_audience` can be used by many `marketing_campaigns`.
- One `marketing_campaign` has many `marketing_messages`.
- One `marketing_campaign` has many `marketing_deliveries`.
- One `marketing_delivery` targets one `customer`.
- One `marketing_delivery` references the consent state required for the channel and purpose.
- One `message_template` can be reused by many campaigns and automation steps.

### Automations

- One `company` has many `automation_workflows`.
- One `automation_workflow` has one or more `automation_triggers`.
- One `automation_workflow` has many `automation_steps`.
- One `automation_event` can start one or more `automation_runs`.
- One `automation_run` belongs to one workflow and one triggering event.
- One `automation_run` has many `automation_run_steps`.
- Automation events can reference customers, appointments, CRM deals, marketing deliveries, payments, webhook events, and integration sync jobs.

### Payments

- One `customer` can have many `payment_customers` across providers.
- One `customer` has many `invoices`.
- One `appointment` can have one or more `invoices`.
- One `invoice` has many `invoice_items`.
- One `invoice_item` can reference a `service`.
- One `invoice` can have many `payments`.
- One `payment` can have many `refunds`.
- One `customer` can have many `subscriptions`.
- One `subscription` can generate many invoices over time.

### Reports and Audit

- One `company` has many `report_definitions`.
- One `report_definition` has many `report_snapshots`.
- One `company` has many `metric_daily_rollups`.
- One `audit_log` belongs to one company and may reference any major entity.
- Report rollups are derived from transactional modules but should not replace transactional source records.

### Integrations

- One `company` has many `integration_connections`.
- One `integration_connection` has many `integration_sync_jobs`.
- One `integration_connection` can produce many provider mappings across CRM, calendar, marketing, messaging, and payment records.
- One `webhook_event` belongs to one provider and one company context after validation.
- One `webhook_event` can create automation events, CRM activities, payment updates, marketing delivery updates, or calendar sync updates.

## 3. Module Responsibilities

### Authentication

- Use Supabase Auth as the source of truth for authentication identity and sessions.
- Maintain application profiles outside `auth.users`.
- Support secure sign-up, sign-in, sign-out, password reset, MFA readiness, and session audit.
- Enforce authenticated access before tenant authorization is evaluated.

Primary entities:

- `auth.users`
- `user_profiles`
- `user_sessions_audit`

### Companies

- Define the tenant boundary for all business data.
- Store company identity, settings, branding, locations, and invitations.
- Support white-label configuration.
- Provide the company context used by authorization and Row Level Security.

Primary entities:

- `companies`
- `company_settings`
- `company_branding`
- `company_locations`
- `company_invitations`

### Users

- Manage company membership, roles, staff profiles, and staff availability.
- Support users who belong to multiple companies.
- Separate global user identity from tenant-specific membership.
- Provide staff data needed by services, scheduling, CRM, automations, and reports.

Primary entities:

- `user_profiles`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`
- `staff_profiles`
- `staff_working_hours`
- `staff_time_off`

### Customers

- Maintain the company-owned customer record.
- Store contact information, addresses, notes, tags, and consent.
- Act as the operational anchor for appointments, CRM, marketing, payments, automations, and reports.
- Preserve customer data isolation between companies.

Primary entities:

- `customers`
- `customer_addresses`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`

### Services

- Maintain the company service catalog.
- Model categories, pricing, duration, resources, and staff eligibility.
- Provide stable service references for appointments, invoices, reports, and campaigns.

Primary entities:

- `service_categories`
- `services`
- `service_staff_assignments`
- `service_resources`

### Appointments

- Manage booking lifecycle from creation to completion, cancellation, or no-show.
- Link customer, staff, location, services, calendar sync, reminders, payments, and reports.
- Preserve appointment status history for audit and analytics.
- Prevent scheduling conflicts for staff, locations, services, and resources.

Primary entities:

- `appointments`
- `appointment_services`
- `appointment_participants`
- `appointment_status_history`
- `calendar_connections`
- `calendar_event_mappings`

### CRM

- Manage sales and relationship pipelines.
- Track stages, deals, tasks, interactions, ownership, and outcomes.
- Integrate with HubSpot without making provider-specific fields part of the core model.
- Feed reports and automations from customer lifecycle changes.

Primary entities:

- `crm_pipelines`
- `crm_stages`
- `crm_deals`
- `crm_activities`
- `crm_external_mappings`

### Marketing

- Manage audiences, campaigns, message templates, campaign messages, and delivery status.
- Enforce customer consent by channel and purpose.
- Support WhatsApp, ManyChat, Meta Ads, email, SMS, and future channels.
- Provide performance data for reports and automation triggers.

Primary entities:

- `marketing_audiences`
- `marketing_campaigns`
- `marketing_messages`
- `marketing_deliveries`
- `message_templates`
- `customer_consents`

### Automations

- Define event-driven and scheduled workflows.
- Decouple business events from workflow execution.
- Track workflow versions, runs, steps, retries, failures, and outcomes.
- Trigger actions across CRM, marketing, appointments, payments, and notifications.

Primary entities:

- `automation_workflows`
- `automation_triggers`
- `automation_steps`
- `automation_events`
- `automation_runs`
- `automation_run_steps`

### Payments

- Manage invoices, invoice items, payments, refunds, provider customer mappings, and subscriptions.
- Link revenue to customers, appointments, services, staff, and reports.
- Store provider references without storing raw card or banking data.
- Support financial auditability and reconciliation.

Primary entities:

- `payment_customers`
- `invoices`
- `invoice_items`
- `payments`
- `refunds`
- `subscriptions`

### Reports

- Provide saved report definitions, generated report snapshots, daily rollups, and audit logs.
- Support dashboards for revenue, appointments, customers, CRM conversion, marketing performance, staff utilization, and automation health.
- Keep analytical aggregates separate from transactional records.
- Preserve historical reporting consistency.

Primary entities:

- `report_definitions`
- `report_snapshots`
- `metric_daily_rollups`
- `audit_logs`

## 4. Multi-Tenant Strategy

### Tenant Boundary

- `companies` is the tenant root.
- Every tenant-owned entity must include `company_id` directly or derive company ownership through a required parent entity.
- Cross-company records should not exist in operational modules.
- Platform-wide records must be explicitly separated from tenant-owned records.

### User Access Model

- A single `user_profile` can access multiple companies.
- Company access is granted only through `company_members`.
- Effective permissions are calculated from the active company context, membership status, role, and role permissions.
- Users must select or be assigned an active company context before accessing tenant data.

### Data Ownership

- Casa Di Amo OS is the source of truth for companies, users, customers, services, appointments, internal CRM, internal marketing, automations, payments, and reports.
- Supabase Auth is the source of truth for authentication identity and sessions.
- External systems are integration providers unless a specific integration decision declares otherwise.
- External IDs must be stored in mapping entities, not embedded as core identifiers.

### Row Level Security

- Row Level Security must be enabled for tenant-owned tables.
- Policies must restrict access to records whose `company_id` matches an active company membership for the authenticated user.
- Permission-sensitive actions must check both tenant membership and module permissions.
- Service-role access must be reserved for trusted backend jobs, integration workers, migrations, and administrative operations.

### Tenant Lifecycle

- Company creation must initialize settings, branding defaults, default roles, default permissions, and default service/report configuration.
- Company suspension must prevent operational access while preserving records.
- Company deletion should use a controlled retention and deletion workflow instead of immediate destructive removal.
- Tenant exports, retention, and deletion must be auditable.

### Scalability

- High-volume records such as automation events, webhook events, marketing deliveries, audit logs, and metric rollups should be designed for partitioning or archival.
- Transactional tables should stay normalized.
- Reporting should use rollups and snapshots to avoid heavy dashboard queries against operational tables.
- Integration sync jobs should be idempotent and resumable.

## 5. Security Considerations

### Authentication Security

- Supabase Auth should manage credentials, sessions, password resets, OAuth, and MFA readiness.
- Application tables should never store passwords or authentication secrets.
- Security-sensitive authentication events should be captured in `user_sessions_audit`.
- Inactive, suspended, or removed company memberships must immediately lose tenant access.

### Authorization Security

- Authorization must evaluate authentication, active company membership, role, permission, and record ownership.
- Privileged roles such as owner, admin, finance, and platform admin must be explicitly modeled.
- Permission changes must be written to `audit_logs`.
- Platform administrator access must be separate from company user access and heavily audited.

### Data Isolation

- Tenant isolation must be enforced in the database with Row Level Security.
- Application filters alone are insufficient for multi-tenant security.
- No operational query should depend on user-supplied company IDs without membership validation.
- Shared lookup data must be clearly separated from tenant-owned data.

### Integration Security

- Integration credentials must be stored in a secure secrets mechanism, not plain business tables.
- Webhooks must be signature-validated, deduplicated, and recorded before processing.
- Provider payloads should be minimized in operational tables.
- Sync jobs must be idempotent to avoid duplicate customers, payments, appointments, or messages.

### Payment Security

- Raw card, bank, or payment credential data must never be stored.
- Payment records should store business amounts, statuses, provider references, and reconciliation metadata only.
- Refunds and payment status changes must be audited.
- Finance permissions must be separate from general staff permissions.

### Privacy and Compliance

- Customer consent must be recorded before marketing messages are sent.
- Consent revocation must prevent future marketing delivery for that channel and purpose.
- Customer notes and sensitive customer metadata should support restricted visibility where needed.
- Data retention policies must cover customers, audit logs, webhook events, marketing deliveries, automation runs, and report snapshots.

### Auditability

- `audit_logs` must capture privileged actions, permission changes, company settings changes, payment changes, integration changes, automation publication, and destructive operations.
- Audit records should include actor, company, action, entity reference, timestamp, and request context.
- Audit logs should be append-only from the application perspective.
- Reporting should distinguish operational activity from security audit history.
