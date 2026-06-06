# Casa Di Amo OS Database Architecture

## Purpose

This document defines the initial database architecture for Casa Di Amo OS.
It is intentionally conceptual and does not include SQL implementation.

Casa Di Amo OS is a multi-tenant SaaS platform for service businesses. The database must support white-label companies, role-based access, customer management, scheduling, CRM, marketing, automations, payments, and reporting while preserving strict data isolation between companies.

## Architectural Principles

- Multi-tenant first: every business-owned record must belong to a company tenant.
- Security first: access must be enforced with role permissions and PostgreSQL Row Level Security.
- Supabase native: authentication should integrate with Supabase Auth while business profiles live in application tables.
- Integration ready: external systems such as HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly, and payment providers must map to internal entities without becoming the source of truth by default.
- Auditability: important business events, automation actions, payment changes, and integration syncs must be traceable.
- Scalability: high-volume records such as messages, automation events, appointment history, and report snapshots should be modeled separately from core operational records.

## Tenant Model

The company is the primary tenant boundary.

All operational modules should be scoped by `company_id`, either directly or through a parent entity that is scoped to a company. Cross-company access should be avoided except for platform-level administration.

Recommended tenant hierarchy:

1. Platform
2. Company
3. Company member
4. Role and permissions
5. Business records owned by the company

## Entities

### 1. Authentication and Identity

#### `auth.users`

Supabase-managed authentication identity.

Responsibilities:

- Login identity.
- Email and phone verification.
- Password and OAuth lifecycle.
- Session and token issuance.

Notes:

- This should not store business profile data beyond authentication metadata.
- Application records should reference this identity through an application user profile.

#### `user_profiles`

Application-level user profile linked to Supabase Auth.

Core attributes:

- User profile ID.
- Auth user ID.
- Full name.
- Email.
- Phone.
- Avatar URL.
- Locale and timezone.
- Account status.
- Created and updated timestamps.

Tenant behavior:

- A user profile may belong to multiple companies through memberships.

#### `roles`

Reusable role definitions.

Core attributes:

- Role ID.
- Company ID for tenant-specific roles, nullable for platform roles.
- Name.
- Description.
- Scope.
- Active status.

Examples:

- Owner.
- Admin.
- Manager.
- Staff.
- Finance.
- Marketing.
- Viewer.

#### `permissions`

Atomic permission definitions.

Core attributes:

- Permission ID.
- Permission key.
- Module.
- Description.

Examples:

- `customers.read`.
- `appointments.manage`.
- `payments.refund`.
- `reports.view`.
- `automations.publish`.

#### `role_permissions`

Join entity between roles and permissions.

Core attributes:

- Role ID.
- Permission ID.

### 2. Companies

#### `companies`

Primary tenant entity.

Core attributes:

- Company ID.
- Legal name.
- Trading name.
- Slug.
- Industry.
- Company status.
- Default locale.
- Default timezone.
- Created and updated timestamps.

Responsibilities:

- Defines tenant boundary.
- Owns customers, services, appointments, CRM, marketing, automations, payments, and reports.

#### `company_settings`

Configurable company preferences.

Core attributes:

- Company ID.
- Scheduling settings.
- Notification settings.
- CRM settings.
- Payment settings.
- Marketing settings.
- Data retention settings.

#### `company_branding`

White-label branding configuration.

Core attributes:

- Company ID.
- Logo URL.
- Primary color.
- Secondary color.
- Domain settings.
- Public business profile settings.

#### `company_locations`

Physical or operational service locations.

Core attributes:

- Location ID.
- Company ID.
- Name.
- Address.
- Phone.
- Email.
- Timezone.
- Active status.

#### `company_members`

Membership between a user profile and a company.

Core attributes:

- Company member ID.
- Company ID.
- User profile ID.
- Role ID.
- Membership status.
- Invitation status.
- Joined timestamp.

Responsibilities:

- Determines which companies a user can access.
- Provides tenant-specific role assignment.

### 3. Customers

#### `customers`

Primary customer record owned by a company.

Core attributes:

- Customer ID.
- Company ID.
- Full name.
- Email.
- Phone.
- Birthdate.
- Customer status.
- Preferred channel.
- Source.
- Tags.
- Notes summary.
- Created and updated timestamps.

Responsibilities:

- Central record for service history, CRM activity, marketing segmentation, appointments, and payments.

#### `customer_addresses`

Customer address records.

Core attributes:

- Address ID.
- Company ID.
- Customer ID.
- Address type.
- Address fields.
- Default status.

#### `customer_notes`

Internal notes about a customer.

Core attributes:

- Note ID.
- Company ID.
- Customer ID.
- Author company member ID.
- Note body.
- Visibility.
- Created timestamp.

#### `customer_tags`

Tenant-defined customer classification tags.

Core attributes:

- Tag ID.
- Company ID.
- Name.
- Color.

#### `customer_tag_assignments`

Join entity between customers and tags.

Core attributes:

- Customer ID.
- Tag ID.

### 4. Services

#### `services`

Services offered by a company.

Core attributes:

- Service ID.
- Company ID.
- Name.
- Description.
- Category ID.
- Duration.
- Base price.
- Active status.

#### `service_categories`

Groups of services.

Core attributes:

- Category ID.
- Company ID.
- Name.
- Display order.
- Active status.

#### `service_staff_assignments`

Join entity between services and company members who can perform them.

Core attributes:

- Service ID.
- Company member ID.
- Location ID.
- Active status.

### 5. Appointments

#### `appointments`

Scheduled service booking.

Core attributes:

- Appointment ID.
- Company ID.
- Customer ID.
- Location ID.
- Assigned company member ID.
- Appointment status.
- Start timestamp.
- End timestamp.
- Source.
- Cancellation reason.
- Created and updated timestamps.

Responsibilities:

- Central scheduling record.
- Connects customers, services, staff, locations, payments, calendar sync, reminders, and reports.

#### `appointment_services`

Join entity between appointments and one or more services.

Core attributes:

- Appointment ID.
- Service ID.
- Price at booking.
- Duration at booking.

#### `staff_availability`

Recurring or ad hoc staff availability.

Core attributes:

- Availability ID.
- Company ID.
- Company member ID.
- Location ID.
- Day or date rule.
- Start time.
- End time.
- Active status.

#### `appointment_blocks`

Unavailable time blocks.

Core attributes:

- Block ID.
- Company ID.
- Company member ID.
- Location ID.
- Start timestamp.
- End timestamp.
- Reason.

#### `calendar_sync_connections`

External calendar connection configuration.

Core attributes:

- Connection ID.
- Company ID.
- Company member ID.
- Provider.
- External account ID.
- Sync status.
- Last synced timestamp.

#### `calendar_sync_events`

Mapping between internal appointments and external calendar events.

Core attributes:

- Sync event ID.
- Company ID.
- Appointment ID.
- Connection ID.
- External event ID.
- Sync direction.
- Sync status.

### 6. CRM

#### `crm_pipelines`

Tenant-defined sales or relationship pipeline.

Core attributes:

- Pipeline ID.
- Company ID.
- Name.
- Description.
- Active status.

#### `crm_stages`

Pipeline stages.

Core attributes:

- Stage ID.
- Company ID.
- Pipeline ID.
- Name.
- Display order.
- Win status.
- Lost status.

#### `crm_deals`

Sales or opportunity record.

Core attributes:

- Deal ID.
- Company ID.
- Customer ID.
- Pipeline ID.
- Stage ID.
- Owner company member ID.
- Title.
- Value.
- Deal status.
- Expected close date.
- Source.

#### `crm_activities`

Tracked CRM interactions.

Core attributes:

- Activity ID.
- Company ID.
- Customer ID.
- Deal ID.
- Owner company member ID.
- Activity type.
- Subject.
- Body.
- Due timestamp.
- Completed timestamp.

#### `crm_external_mappings`

Mapping to external CRM providers such as HubSpot.

Core attributes:

- Mapping ID.
- Company ID.
- Provider.
- Internal entity type.
- Internal entity ID.
- External object ID.
- Sync status.
- Last synced timestamp.

### 7. Marketing

#### `marketing_audiences`

Customer audience or segment.

Core attributes:

- Audience ID.
- Company ID.
- Name.
- Description.
- Segment rules.
- Active status.

#### `marketing_campaigns`

Campaign definition.

Core attributes:

- Campaign ID.
- Company ID.
- Audience ID.
- Name.
- Channel.
- Campaign status.
- Objective.
- Start timestamp.
- End timestamp.

#### `marketing_messages`

Campaign message content.

Core attributes:

- Message ID.
- Company ID.
- Campaign ID.
- Channel.
- Subject.
- Body.
- Template variables.
- Approval status.

#### `marketing_deliveries`

Per-recipient delivery tracking.

Core attributes:

- Delivery ID.
- Company ID.
- Campaign ID.
- Message ID.
- Customer ID.
- Provider.
- Delivery status.
- Sent timestamp.
- Opened timestamp.
- Clicked timestamp.

#### `marketing_consents`

Customer consent by channel and purpose.

Core attributes:

- Consent ID.
- Company ID.
- Customer ID.
- Channel.
- Purpose.
- Consent status.
- Captured timestamp.
- Source.

### 8. Automations

#### `automation_workflows`

Automation workflow definition.

Core attributes:

- Workflow ID.
- Company ID.
- Name.
- Description.
- Trigger type.
- Workflow status.
- Version.
- Created by company member ID.

#### `automation_steps`

Steps inside an automation workflow.

Core attributes:

- Step ID.
- Company ID.
- Workflow ID.
- Step type.
- Configuration.
- Display order.

#### `automation_runs`

Execution instance of an automation workflow.

Core attributes:

- Run ID.
- Company ID.
- Workflow ID.
- Trigger entity type.
- Trigger entity ID.
- Run status.
- Started timestamp.
- Finished timestamp.

#### `automation_run_steps`

Execution tracking for each workflow step.

Core attributes:

- Run step ID.
- Company ID.
- Run ID.
- Step ID.
- Step status.
- Attempt count.
- Error summary.
- Started timestamp.
- Finished timestamp.

#### `automation_events`

Event stream used to trigger automations.

Core attributes:

- Event ID.
- Company ID.
- Event type.
- Entity type.
- Entity ID.
- Payload summary.
- Occurred timestamp.
- Processed status.

### 9. Payments

#### `payment_customers`

Payment-provider customer mapping.

Core attributes:

- Payment customer ID.
- Company ID.
- Customer ID.
- Provider.
- External customer ID.

#### `invoices`

Customer invoice.

Core attributes:

- Invoice ID.
- Company ID.
- Customer ID.
- Appointment ID.
- Invoice number.
- Invoice status.
- Subtotal.
- Discount total.
- Tax total.
- Total.
- Due date.
- Issued timestamp.

#### `invoice_items`

Invoice line item.

Core attributes:

- Invoice item ID.
- Company ID.
- Invoice ID.
- Service ID.
- Description.
- Quantity.
- Unit price.
- Total.

#### `payments`

Payment transaction.

Core attributes:

- Payment ID.
- Company ID.
- Customer ID.
- Invoice ID.
- Provider.
- Payment method.
- Payment status.
- Amount.
- Currency.
- Paid timestamp.
- External payment ID.

#### `refunds`

Refund transaction.

Core attributes:

- Refund ID.
- Company ID.
- Payment ID.
- Amount.
- Reason.
- Refund status.
- External refund ID.
- Created timestamp.

#### `subscriptions`

Recurring customer subscription or service package.

Core attributes:

- Subscription ID.
- Company ID.
- Customer ID.
- Plan name.
- Subscription status.
- Billing interval.
- Amount.
- Start date.
- End date.
- External subscription ID.

### 10. Reports and Analytics

#### `report_definitions`

Saved report configuration.

Core attributes:

- Report definition ID.
- Company ID.
- Name.
- Module.
- Metrics.
- Filters.
- Visibility.

#### `report_snapshots`

Materialized report output for repeatable analytics.

Core attributes:

- Snapshot ID.
- Company ID.
- Report definition ID.
- Period start.
- Period end.
- Snapshot data summary.
- Generated timestamp.

#### `metric_daily_rollups`

Aggregated daily metrics.

Core attributes:

- Rollup ID.
- Company ID.
- Metric date.
- Metric key.
- Dimension key.
- Dimension value.
- Metric value.

#### `audit_logs`

Security and business audit trail.

Core attributes:

- Audit log ID.
- Company ID.
- Actor user profile ID.
- Actor company member ID.
- Action.
- Entity type.
- Entity ID.
- Metadata summary.
- Created timestamp.

### 11. Integrations

#### `integration_connections`

Tenant-level external integration configuration.

Core attributes:

- Connection ID.
- Company ID.
- Provider.
- Connection status.
- Connected by company member ID.
- External account ID.
- Last health check timestamp.

Examples:

- HubSpot.
- ManyChat.
- WhatsApp.
- Google Calendar.
- Calendly.
- Meta Ads.
- Payment provider.

#### `integration_sync_jobs`

Background sync job tracking.

Core attributes:

- Sync job ID.
- Company ID.
- Connection ID.
- Job type.
- Job status.
- Started timestamp.
- Finished timestamp.
- Error summary.

#### `webhook_events`

Inbound webhook event log.

Core attributes:

- Webhook event ID.
- Company ID.
- Provider.
- Event type.
- External event ID.
- Processing status.
- Received timestamp.
- Processed timestamp.

## Relationships

### Tenant and Identity Relationships

- One company has many company members.
- One user profile can belong to many companies through company members.
- One company member has one role within a company.
- One role has many permissions through role permissions.
- One company has one company settings record.
- One company has one company branding record.
- One company has many locations.

### Customer Relationships

- One company has many customers.
- One customer has many addresses.
- One customer has many notes.
- One customer has many tag assignments.
- One company has many customer tags.
- One customer can have many appointments, CRM deals, marketing deliveries, invoices, payments, and subscriptions.

### Service and Scheduling Relationships

- One company has many service categories.
- One service category has many services.
- One company has many services.
- One service can be assigned to many staff members through service staff assignments.
- One appointment belongs to one company, one customer, and optionally one location and assigned staff member.
- One appointment can contain many services through appointment services.
- One company member has many availability records and appointment blocks.
- One appointment can map to many external calendar sync events.

### CRM Relationships

- One company has many CRM pipelines.
- One pipeline has many stages.
- One customer can have many deals.
- One deal belongs to one pipeline and one stage.
- One deal can have many CRM activities.
- One CRM entity can have external mappings to HubSpot or future CRM providers.

### Marketing Relationships

- One company has many marketing audiences.
- One audience can be used by many campaigns.
- One campaign has many messages.
- One campaign has many deliveries.
- One delivery targets one customer.
- One customer has many marketing consent records.

### Automation Relationships

- One company has many automation workflows.
- One workflow has many automation steps.
- One workflow has many automation runs.
- One automation run has many automation run steps.
- One automation event can trigger one or more workflow runs.
- Automation events may reference customers, appointments, CRM deals, payments, marketing deliveries, or integration events.

### Payment Relationships

- One company has many invoices.
- One customer has many invoices.
- One appointment can have one or many invoices depending on billing model.
- One invoice has many invoice items.
- One invoice can have many payments.
- One payment can have many refunds.
- One customer can have many subscriptions.
- One payment customer maps an internal customer to an external payment provider.

### Reporting Relationships

- One company has many report definitions.
- One report definition has many report snapshots.
- One company has many metric rollups.
- Audit logs may reference any major entity by entity type and entity ID.

### Integration Relationships

- One company has many integration connections.
- One integration connection has many sync jobs.
- One integration connection can create external mappings for CRM, calendar, marketing, messaging, and payment records.
- One webhook event may create automation events, CRM activities, marketing delivery updates, payment updates, or calendar sync updates.

## Module Responsibilities

### Authentication

Responsibilities:

- Manage user authentication through Supabase Auth.
- Maintain application-level user profiles.
- Support invitation and membership lifecycle.
- Enforce role-based permissions.
- Provide secure company context switching for multi-company users.

Primary entities:

- `auth.users`
- `user_profiles`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`

### Companies

Responsibilities:

- Define tenant boundaries.
- Store company identity, settings, branding, locations, and membership.
- Provide white-label configuration.
- Own all company-scoped operational data.

Primary entities:

- `companies`
- `company_settings`
- `company_branding`
- `company_locations`
- `company_members`

### Users

Responsibilities:

- Store application user profiles separate from authentication records.
- Support users who belong to one or more companies.
- Track profile preferences such as timezone, locale, and status.

Primary entities:

- `user_profiles`
- `company_members`
- `roles`

### Customers

Responsibilities:

- Maintain the tenant-owned customer record.
- Centralize customer profile, contact details, addresses, notes, tags, and consent.
- Serve as the anchor for appointments, CRM, marketing, payments, and reports.

Primary entities:

- `customers`
- `customer_addresses`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `marketing_consents`

### Services

Responsibilities:

- Define company service catalog.
- Manage service categories, pricing, duration, and staff eligibility.
- Provide service data for appointments, invoices, reporting, and marketing.

Primary entities:

- `services`
- `service_categories`
- `service_staff_assignments`

### Appointments

Responsibilities:

- Manage scheduling lifecycle from booking to completion or cancellation.
- Link customers, staff, services, locations, calendar integrations, reminders, and billing.
- Provide operational metrics for utilization, revenue, and attendance.

Primary entities:

- `appointments`
- `appointment_services`
- `staff_availability`
- `appointment_blocks`
- `calendar_sync_connections`
- `calendar_sync_events`

### CRM

Responsibilities:

- Manage pipelines, stages, deals, and sales or relationship activities.
- Track customer progression from lead to retained customer.
- Synchronize selected records with HubSpot while preserving internal ownership.

Primary entities:

- `crm_pipelines`
- `crm_stages`
- `crm_deals`
- `crm_activities`
- `crm_external_mappings`

### Marketing

Responsibilities:

- Manage audiences, campaigns, message content, and delivery outcomes.
- Respect customer consent by channel and purpose.
- Integrate with ManyChat, WhatsApp, Meta Ads, and future marketing providers.

Primary entities:

- `marketing_audiences`
- `marketing_campaigns`
- `marketing_messages`
- `marketing_deliveries`
- `marketing_consents`

### Automations

Responsibilities:

- Define workflow triggers, steps, versions, and execution history.
- React to system events such as new customer, appointment booked, payment received, CRM stage changed, or message delivered.
- Provide reliable retry, observability, and audit history for automated actions.

Primary entities:

- `automation_workflows`
- `automation_steps`
- `automation_events`
- `automation_runs`
- `automation_run_steps`

### Payments

Responsibilities:

- Track invoices, line items, payments, refunds, subscriptions, and provider mappings.
- Link revenue to customers, appointments, services, and reports.
- Preserve external payment provider IDs without making providers the canonical business record.

Primary entities:

- `payment_customers`
- `invoices`
- `invoice_items`
- `payments`
- `refunds`
- `subscriptions`

### Reports

Responsibilities:

- Provide saved reports, snapshots, metric rollups, and audit visibility.
- Support dashboards for revenue, appointments, customer growth, marketing performance, CRM conversion, and team utilization.
- Separate analytical aggregates from transactional tables for scalability.

Primary entities:

- `report_definitions`
- `report_snapshots`
- `metric_daily_rollups`
- `audit_logs`

## Security and Data Isolation Requirements

- Every tenant-owned table must include or derive company ownership.
- Row Level Security should enforce company-scoped access.
- Platform administrator access should be explicitly modeled and audited.
- Sensitive integration credentials should not be stored in plain application tables.
- Webhook events should be validated, deduplicated, and traceable.
- Payment data should store provider references and business transaction metadata, not raw card data.
- Audit logs should capture privileged actions, permission changes, payment changes, integration changes, and automation state changes.

## Source of Truth Guidelines

- Casa Di Amo OS should be the source of truth for companies, users, customers, services, appointments, internal CRM state, internal marketing state, automations, payments, and reports.
- Supabase Auth should be the source of truth for authentication identity and sessions.
- External providers should be treated as integration systems unless a documented module decision assigns source-of-truth ownership differently.
- Integration mapping tables should preserve external IDs and sync state without leaking provider-specific structure into core business tables.

## Open Architecture Decisions

- Confirm whether customers can belong to multiple companies or must be duplicated per company.
- Confirm whether staff members are always authenticated users or whether non-login staff records are required.
- Select the payment provider and subscription billing model.
- Define the white-label domain strategy.
- Define the exact role and permission matrix.
- Define retention policies for webhook events, automation runs, delivery events, and audit logs.
- Decide which analytics should be real-time and which should use scheduled rollups.
