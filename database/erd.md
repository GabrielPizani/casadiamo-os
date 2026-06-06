# Casa Di Amo OS ERD Description

## Purpose

This document describes the entity relationship design for Casa Di Amo OS.
It is a conceptual ERD description only and contains no database implementation.

Casa Di Amo OS uses `companies` as the tenant root. Business records are company-scoped unless explicitly defined as platform-level records.

## Cardinality Notation

- `one-to-one`: one record relates to exactly one corresponding record.
- `one-to-many`: one record owns or relates to many child records.
- `many-to-many`: records are connected through a join entity.
- `optional`: the relationship can be absent.
- `polymorphic reference`: the relationship can point to more than one entity type and must be governed carefully.

## Entity Catalog

### Platform Administration

- `platform_admins`: platform-level operators who can administer Casa Di Amo OS outside a tenant context.
- `platform_roles`: platform-level roles for internal administrators.
- `platform_permissions`: platform-level permission catalog.
- `platform_role_permissions`: join entity between platform roles and platform permissions.
- `platform_admin_audit_logs`: audit history for platform-level administrative actions.

### SaaS Billing and Entitlements

- `plans`: commercial SaaS plans sold to companies.
- `plan_features`: features included in each SaaS plan.
- `features`: product capability catalog.
- `billing_accounts`: billing profile for a company.
- `company_subscriptions`: active SaaS subscription for a company.
- `subscription_items`: priced items attached to a company subscription.
- `company_feature_entitlements`: feature access granted to a company.
- `usage_limits`: plan or company-specific usage limits.
- `usage_counters`: current usage counters for limited resources.
- `usage_records`: immutable usage events for billable or metered activity.
- `tenant_invoices`: invoices issued by Casa Di Amo OS to tenant companies.

### Authentication and Identity

- `auth.users`: Supabase Auth identity.
- `user_profiles`: application profile for a human user.
- `roles`: tenant-level role definitions.
- `permissions`: tenant-level permission catalog.
- `role_permissions`: join entity between tenant roles and tenant permissions.
- `user_sessions_audit`: authentication-sensitive session and access history.
- `api_clients`: registered API clients owned by a company or platform context.
- `api_keys`: API credentials issued to API clients.
- `service_accounts`: non-human identities for trusted automation or integration workers.
- `oauth_grants`: OAuth grant records for connected providers and delegated access.

### Companies

- `companies`: tenant root for a service business.
- `company_settings`: tenant-level operational settings.
- `company_branding`: white-label branding configuration.
- `company_locations`: physical or virtual business locations.
- `company_members`: user membership inside a company.
- `company_invitations`: pending invitations to join a company.

### Users and Staff

- `staff_profiles`: company-specific staff profile attached to a company member.
- `staff_working_hours`: recurring staff availability.
- `staff_time_off`: staff unavailability exceptions.

### Customers

- `customers`: primary customer record owned by a company.
- `customer_addresses`: customer address records.
- `customer_notes`: internal customer notes.
- `customer_tags`: company-defined customer labels.
- `customer_tag_assignments`: join entity between customers and tags.
- `customer_consents`: customer consent by purpose and channel.

### Services

- `service_categories`: service catalog grouping.
- `services`: service offered by a company.
- `service_staff_assignments`: join entity between services and staff.
- `service_resources`: rooms, equipment, seats, or other constrained resources.

### Appointments

- `appointments`: scheduled booking.
- `appointment_services`: join entity between appointments and services.
- `appointment_participants`: additional staff, guests, or resources for an appointment.
- `appointment_status_history`: status transition history for an appointment.
- `appointment_reminders`: reminder schedule and delivery state for an appointment.
- `appointment_waitlists`: customers waiting for a service, staff member, or time slot.
- `recurring_appointment_rules`: recurrence rules for repeated appointments.
- `resource_bookings`: reserved service resources for a specific appointment window.
- `booking_holds`: temporary slot holds before an appointment is confirmed.
- `calendar_connections`: external calendar account connection.
- `calendar_event_mappings`: mapping between appointments and external calendar events.

### CRM

- `crm_pipelines`: company-defined CRM pipeline.
- `crm_stages`: ordered stages inside a pipeline.
- `crm_deals`: opportunity or relationship record.
- `crm_activities`: CRM tasks and interactions.
- `crm_external_mappings`: mappings to HubSpot and future CRM providers.

### Marketing and Messaging

- `marketing_audiences`: segment or audience definition.
- `marketing_campaigns`: campaign definition.
- `marketing_messages`: campaign-specific message content.
- `marketing_deliveries`: per-recipient campaign delivery tracking.
- `message_templates`: reusable channel-specific message templates.
- `conversations`: customer communication thread.
- `conversation_participants`: participants in a conversation.
- `messages`: individual inbound or outbound communication messages.
- `message_attachments`: files attached to messages.
- `message_status_events`: provider delivery, read, failure, and response events.
- `notification_preferences`: user or customer preferences for notification channels.

### Automations

- `automation_workflows`: workflow definition.
- `automation_triggers`: trigger configuration for a workflow.
- `automation_steps`: ordered workflow steps.
- `automation_events`: system event stream.
- `automation_runs`: workflow execution instance.
- `automation_run_steps`: step-level execution history.

### Payments

- `payment_customers`: payment provider customer mapping.
- `invoices`: customer invoice.
- `invoice_items`: invoice line item.
- `payments`: payment transaction.
- `refunds`: refund transaction.
- `subscriptions`: recurring billing relationship between a company and its customer.

### Reports and Audit

- `report_definitions`: saved report configuration.
- `report_snapshots`: generated report output.
- `metric_daily_rollups`: daily aggregated metrics.
- `audit_logs`: tenant-level business and security audit trail.

### Integrations

- `integration_connections`: tenant-owned provider connection.
- `integration_sync_jobs`: background sync execution for an integration.
- `webhook_events`: inbound provider event ledger.
- `webhook_signing_secrets`: signing secret metadata for validating inbound webhooks.

### Files and Documents

- `files`: file metadata for uploaded assets.
- `file_links`: links files to business entities.
- `media_assets`: reusable media for branding, marketing, and service content.
- `document_templates`: reusable document or message document definitions.

### Privacy and Compliance

- `data_subject_requests`: customer or user privacy requests.
- `data_exports`: export jobs for tenant, user, or customer data.
- `data_deletion_jobs`: controlled deletion or anonymization jobs.
- `retention_policies`: retention rules by entity type and company.
- `consent_audit_logs`: historical consent changes.

### Reliability and Events

- `job_queue`: background work item.
- `job_attempts`: execution attempt for a job.
- `idempotency_keys`: deduplication keys for write operations and webhooks.
- `outbox_events`: committed domain events waiting for processing.
- `dead_letter_events`: failed events requiring review or replay.

### AI Governance

- `ai_prompts`: reusable AI prompt definitions.
- `ai_runs`: AI execution instance.
- `ai_outputs`: generated AI output.
- `ai_usage_records`: AI token, cost, and feature usage.
- `ai_feedback`: human feedback on AI output quality.

## Relationship Map

### Platform Administration Relationships

- `platform_admins` to `platform_roles`: many-to-one. Each platform admin has one primary platform role.
- `platform_roles` to `platform_permissions`: many-to-many through `platform_role_permissions`.
- `platform_admins` to `platform_admin_audit_logs`: one-to-many. Each platform admin can generate many audit records.
- `platform_admin_audit_logs` to tenant entities: polymorphic reference. Platform audit logs may reference companies, subscriptions, integrations, or security records.

### SaaS Billing and Entitlement Relationships

- `plans` to `plan_features`: one-to-many. A plan includes many plan feature records.
- `features` to `plan_features`: one-to-many. A feature can appear in many plans.
- `companies` to `billing_accounts`: one-to-one. Each company has one tenant billing profile.
- `companies` to `company_subscriptions`: one-to-many. A company can have historical and current SaaS subscriptions.
- `plans` to `company_subscriptions`: one-to-many. Many companies can subscribe to the same plan.
- `company_subscriptions` to `subscription_items`: one-to-many. A subscription can include base plan, add-ons, seats, and usage items.
- `companies` to `company_feature_entitlements`: one-to-many. Each company receives explicit feature access records.
- `features` to `company_feature_entitlements`: one-to-many. One feature can be granted to many companies.
- `companies` to `usage_limits`: one-to-many. A company can have limits for users, messages, AI, appointments, automations, storage, and integrations.
- `companies` to `usage_counters`: one-to-many. A company has counters for limited resources.
- `companies` to `usage_records`: one-to-many. A company generates immutable usage events.
- `billing_accounts` to `tenant_invoices`: one-to-many. A billing account receives many SaaS invoices.

### Authentication and Tenant Access Relationships

- `auth.users` to `user_profiles`: one-to-one. Each application profile maps to one authentication identity.
- `user_profiles` to `company_members`: one-to-many. One user can belong to many companies.
- `companies` to `company_members`: one-to-many. One company has many members.
- `roles` to `company_members`: one-to-many. One role can be assigned to many company members.
- `roles` to `permissions`: many-to-many through `role_permissions`.
- `user_profiles` to `user_sessions_audit`: one-to-many. One user can generate many session audit events.
- `companies` to `api_clients`: one-to-many. A company can register many API clients.
- `api_clients` to `api_keys`: one-to-many. One API client can have multiple active or rotated keys.
- `companies` to `service_accounts`: one-to-many. A company can own non-human service identities.
- `integration_connections` to `oauth_grants`: one-to-many. A provider connection can have many OAuth grant lifecycle records.

### Company Relationships

- `companies` to `company_settings`: one-to-one.
- `companies` to `company_branding`: one-to-one.
- `companies` to `company_locations`: one-to-many.
- `companies` to `company_invitations`: one-to-many.
- `company_invitations` to `roles`: many-to-one. Each invitation grants one intended role.
- `company_invitations` to `company_members`: optional one-to-one. An accepted invitation can create one membership.

### Staff Relationships

- `company_members` to `staff_profiles`: optional one-to-one. Only bookable or staff users need staff profiles.
- `staff_profiles` to `staff_working_hours`: one-to-many.
- `staff_profiles` to `staff_time_off`: one-to-many.
- `staff_profiles` to `service_staff_assignments`: one-to-many.
- `staff_profiles` to `appointments`: one-to-many as primary assigned staff.

### Customer Relationships

- `companies` to `customers`: one-to-many.
- `customers` to `customer_addresses`: one-to-many.
- `customers` to `customer_notes`: one-to-many.
- `customers` to `customer_consents`: one-to-many.
- `customers` to `customer_tags`: many-to-many through `customer_tag_assignments`.
- `company_members` to `customer_notes`: one-to-many as note author.
- `customer_consents` to `marketing_deliveries`: one-to-many by channel and purpose when consent evidence is needed.

### Service Relationships

- `companies` to `service_categories`: one-to-many.
- `service_categories` to `services`: one-to-many.
- `companies` to `services`: one-to-many.
- `services` to `service_staff_assignments`: one-to-many.
- `staff_profiles` to `service_staff_assignments`: one-to-many.
- `services` to `service_resources`: one-to-many.
- `service_resources` to `resource_bookings`: one-to-many.

### Appointment Relationships

- `companies` to `appointments`: one-to-many.
- `customers` to `appointments`: one-to-many.
- `company_locations` to `appointments`: optional one-to-many.
- `staff_profiles` to `appointments`: optional one-to-many as primary assigned staff.
- `appointments` to `services`: many-to-many through `appointment_services`.
- `appointments` to `appointment_participants`: one-to-many.
- `appointments` to `appointment_status_history`: one-to-many.
- `appointments` to `appointment_reminders`: one-to-many.
- `appointments` to `resource_bookings`: one-to-many.
- `recurring_appointment_rules` to `appointments`: one-to-many. A recurrence rule can generate many appointments.
- `customers` to `appointment_waitlists`: one-to-many.
- `services` to `appointment_waitlists`: one-to-many.
- `booking_holds` to `appointments`: optional one-to-one. A confirmed hold can become one appointment.
- `calendar_connections` to `calendar_event_mappings`: one-to-many.
- `appointments` to `calendar_event_mappings`: one-to-many.

### CRM Relationships

- `companies` to `crm_pipelines`: one-to-many.
- `crm_pipelines` to `crm_stages`: one-to-many.
- `customers` to `crm_deals`: one-to-many.
- `crm_pipelines` to `crm_deals`: one-to-many.
- `crm_stages` to `crm_deals`: one-to-many as current stage.
- `company_members` to `crm_deals`: one-to-many as owner.
- `crm_deals` to `crm_activities`: one-to-many.
- `customers` to `crm_activities`: one-to-many.
- `company_members` to `crm_activities`: one-to-many as owner.
- `crm_deals` to `crm_external_mappings`: one-to-many.
- `customers` to `crm_external_mappings`: one-to-many when customers sync to external CRM contacts.

### Marketing and Messaging Relationships

- `companies` to `marketing_audiences`: one-to-many.
- `marketing_audiences` to `marketing_campaigns`: one-to-many.
- `marketing_campaigns` to `marketing_messages`: one-to-many.
- `marketing_campaigns` to `marketing_deliveries`: one-to-many.
- `marketing_messages` to `marketing_deliveries`: one-to-many.
- `customers` to `marketing_deliveries`: one-to-many.
- `message_templates` to `marketing_messages`: optional one-to-many.
- `message_templates` to `automation_steps`: optional one-to-many.
- `companies` to `conversations`: one-to-many.
- `customers` to `conversations`: one-to-many.
- `conversations` to `conversation_participants`: one-to-many.
- `conversations` to `messages`: one-to-many.
- `messages` to `message_attachments`: one-to-many.
- `messages` to `message_status_events`: one-to-many.
- `files` to `message_attachments`: one-to-many.
- `user_profiles` to `notification_preferences`: one-to-many.
- `customers` to `notification_preferences`: one-to-many.

### Automation Relationships

- `companies` to `automation_workflows`: one-to-many.
- `automation_workflows` to `automation_triggers`: one-to-many.
- `automation_workflows` to `automation_steps`: one-to-many.
- `automation_events` to `automation_runs`: one-to-many.
- `automation_workflows` to `automation_runs`: one-to-many.
- `automation_runs` to `automation_run_steps`: one-to-many.
- `automation_steps` to `automation_run_steps`: one-to-many.
- `automation_events` to business entities: polymorphic reference. Events can reference customers, appointments, deals, payments, messages, deliveries, webhook events, and sync jobs.

### Payment Relationships

- `customers` to `payment_customers`: one-to-many.
- `customers` to `invoices`: one-to-many.
- `appointments` to `invoices`: optional one-to-many.
- `invoices` to `invoice_items`: one-to-many.
- `services` to `invoice_items`: optional one-to-many.
- `invoices` to `payments`: one-to-many.
- `customers` to `payments`: one-to-many.
- `payments` to `refunds`: one-to-many.
- `customers` to `subscriptions`: one-to-many.
- `subscriptions` to `invoices`: one-to-many over time.

### Reports and Audit Relationships

- `companies` to `report_definitions`: one-to-many.
- `report_definitions` to `report_snapshots`: one-to-many.
- `companies` to `metric_daily_rollups`: one-to-many.
- `companies` to `audit_logs`: one-to-many.
- `user_profiles` to `audit_logs`: optional one-to-many as actor.
- `company_members` to `audit_logs`: optional one-to-many as tenant actor.
- `audit_logs` to business entities: polymorphic reference for audited entity.

### Integration Relationships

- `companies` to `integration_connections`: one-to-many.
- `integration_connections` to `integration_sync_jobs`: one-to-many.
- `integration_connections` to `webhook_signing_secrets`: one-to-many.
- `integration_connections` to `webhook_events`: one-to-many after provider validation.
- `webhook_events` to `automation_events`: optional one-to-many.
- `integration_sync_jobs` to `automation_events`: optional one-to-many.
- `integration_connections` to provider mapping entities: one-to-many across CRM, calendar, marketing, messaging, and payment mappings.

### Files and Documents Relationships

- `companies` to `files`: one-to-many.
- `files` to `file_links`: one-to-many.
- `file_links` to business entities: polymorphic reference. Files can attach to customers, services, appointments, invoices, messages, campaigns, company branding, or staff profiles.
- `companies` to `media_assets`: one-to-many.
- `companies` to `document_templates`: one-to-many.
- `document_templates` to invoices, messages, or campaigns: optional one-to-many depending on template type.

### Privacy and Compliance Relationships

- `companies` to `data_subject_requests`: one-to-many.
- `customers` to `data_subject_requests`: optional one-to-many.
- `user_profiles` to `data_subject_requests`: optional one-to-many.
- `data_subject_requests` to `data_exports`: optional one-to-many.
- `data_subject_requests` to `data_deletion_jobs`: optional one-to-many.
- `companies` to `retention_policies`: one-to-many.
- `customer_consents` to `consent_audit_logs`: one-to-many.
- `customers` to `consent_audit_logs`: one-to-many.

### Reliability and Event Relationships

- `companies` to `job_queue`: one-to-many when a job is tenant-scoped.
- `job_queue` to `job_attempts`: one-to-many.
- `companies` to `idempotency_keys`: one-to-many when an operation is tenant-scoped.
- `companies` to `outbox_events`: one-to-many.
- `outbox_events` to `dead_letter_events`: optional one-to-one or one-to-many depending on retry policy.
- `webhook_events` to `idempotency_keys`: optional one-to-one for provider event deduplication.
- `payments`, `appointments`, `messages`, and `automation_runs` to `idempotency_keys`: optional one-to-one for operation deduplication.

### AI Governance Relationships

- `companies` to `ai_prompts`: one-to-many for tenant-owned prompt templates.
- `ai_prompts` to `ai_runs`: one-to-many.
- `ai_runs` to `ai_outputs`: one-to-many.
- `ai_runs` to `ai_usage_records`: one-to-many.
- `ai_outputs` to `ai_feedback`: one-to-many.
- `user_profiles` to `ai_runs`: optional one-to-many as initiating user.
- `automation_runs` to `ai_runs`: optional one-to-many when automation invokes AI.
- `customers`, `crm_deals`, `marketing_messages`, and `reports` to `ai_runs`: optional polymorphic references when AI assists business workflows.

## Tenant Boundary Summary

- Tenant root: `companies`.
- Tenant membership: `company_members`.
- Tenant authorization: `roles`, `permissions`, and `role_permissions`.
- Tenant operations: customers, services, appointments, CRM, marketing, automations, payments, reports, integrations, files, privacy, reliability, and AI records.
- Platform operations: platform administration, SaaS plans, global feature catalog, and platform billing configuration.

## Polymorphic Reference Controls

Polymorphic references are useful for audit, events, files, AI runs, and automation triggers, but they must remain controlled.

- Each polymorphic reference must include entity type and entity identifier.
- Tenant-scoped polymorphic references must include or derive `company_id`.
- Security policies must validate that the referenced entity belongs to the same tenant.
- Polymorphic references should not replace direct relationships for core workflows.
