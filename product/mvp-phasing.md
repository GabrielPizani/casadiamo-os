# Amo Beauty Lab MVP Phasing

## Purpose

This document translates the current Casa Di Amo OS architecture into a buildable MVP plan for launching Amo Beauty Lab as fast as possible.

The goal is not to improve UX. The goal is to reduce scope until the first customer can run daily operations on the product with acceptable security, data integrity, and operational reliability.

## Source documents reviewed

- `README.md`
- `database/database-architecture.md`
- `database/erd.md`
- `database/rls-strategy.md`
- `database/schema-review.md`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`
- `docs/platform-billing-model.md`
- `docs/compliance-lgpd.md`

The requested `/product/mvp-ux-specification.md` was not present in this checkout. This plan therefore phases the product by the architectural modules and first-customer operating needs already documented in the repository.

## Executive recommendation

Launch Amo Beauty Lab with an owner-operated, staff-assisted internal system first.

The first version should let the business:

1. Sign in securely.
2. Manage one company tenant.
3. Manage customers.
4. Manage services.
5. Manage staff availability.
6. Create, update, cancel, and complete appointments.
7. Track basic notes, consent, and follow-up tasks.
8. View a simple operational dashboard.

Everything else should either be manual, external, or delayed until the first customer is actively using the product.

## Recommended MVP scope

### In scope for first customer

- Supabase Auth.
- One production company tenant for Amo Beauty Lab.
- Company Owner, Manager, and Employee roles.
- Customer profiles with phone, email, notes, tags, source, and consent.
- Service catalog with duration and price.
- Staff profiles, working hours, and time off.
- Internal appointment creation and calendar/list views.
- Appointment status lifecycle: scheduled, confirmed, completed, canceled, no-show.
- Appointment-to-customer, appointment-to-staff, and appointment-to-service links.
- Basic CRM activity tracking for follow-ups.
- Consent capture for WhatsApp, SMS, email, and phone.
- Minimal audit logs for membership, settings, customer export/delete, appointment status, and consent changes.
- Basic reports from transactional queries: appointments, revenue estimate, customer count, upcoming schedule.
- Manual export by administrator where required.

### Explicitly out of first-customer MVP

- Self-serve tenant signup and SaaS billing.
- Public marketplace or multi-business discovery.
- Advanced white-label domains.
- Full automation workflow builder.
- AI assistant, AI content generation, AI recommendations, and AI analytics.
- HubSpot sync.
- ManyChat sync.
- WhatsApp sending infrastructure.
- Google Calendar or Calendly two-way sync.
- Online customer booking portal.
- Payment processing, refunds, customer subscriptions, and invoice reconciliation.
- Advanced marketing campaigns and audience builder.
- Advanced reports, rollups, report snapshots, and scheduled exports.
- Platform admin console beyond direct database/admin maintenance.
- Full LGPD self-service portal.

## P0 - Required for first customer

| Feature | Complexity | Business impact | Dependencies | Database dependencies | AI dependencies | Integration dependencies |
| --- | --- | --- | --- | --- | --- | --- |
| Single Amo Beauty Lab company tenant | Low | High | Supabase project, seed process, owner account | `companies`, `company_settings`, `company_branding`, `company_locations` | None | None |
| Authentication and session handling | Medium | High | Supabase Auth, frontend auth flow | `auth.users`, `user_profiles`, `user_sessions_audit` | None | Supabase Auth |
| Minimal RBAC | Medium | High | Auth, tenant membership | `company_members`, `roles`, `permissions`, `role_permissions` | None | None |
| Tenant isolation and baseline RLS | High | High | Auth, membership, role model | RLS policies for P0 tables, tenant-safe `company_id` constraints | None | None |
| Customer management | Medium | High | Tenant context, RBAC | `customers`, `customer_notes`, `customer_tags`, `customer_tag_assignments`, `customer_consents` | None | None |
| Service catalog | Low | High | Tenant context, RBAC | `service_categories`, `services`, `service_staff_assignments` | None | None |
| Staff setup and availability | Medium | High | Members, services | `staff_profiles`, `staff_working_hours`, `staff_time_off` | None | None |
| Internal appointment scheduling | High | High | Customers, services, staff availability | `appointments`, `appointment_services`, `appointment_status_history` | None | None |
| Appointment conflict checks | Medium | High | Staff availability, appointment lifecycle | Tenant-aware indexes, same-company references, application conflict validation | None | None |
| Calendar/list operational views | Medium | High | Appointment scheduling | Query indexes on `appointments(company_id, start_time/status)` | None | None |
| Basic CRM follow-up tracking | Low | Medium | Customers, staff users | `crm_activities`; defer full pipelines and deals if possible | None | None |
| Consent baseline | Medium | High | Customers, LGPD rules | `customer_consents`, minimal `consent_audit_logs` or `audit_logs` | None | None |
| Basic operational dashboard | Low | Medium | Customers, appointments, services | Transactional queries; no rollups in P0 | None | None |
| Minimal audit trail | Medium | High | Auth, RBAC, key workflows | `audit_logs`, `user_sessions_audit` | None | None |
| Company settings and branding basics | Low | Medium | Tenant setup | `company_settings`, `company_branding`, `company_locations` | None | None |
| Admin-only data export path | Medium | Medium | RBAC, audit | `data_subject_requests`, `data_exports`, `files` can be deferred if export is manual; audit required | None | None |

## P1 - Required after first customer

| Feature | Complexity | Business impact | Dependencies | Database dependencies | AI dependencies | Integration dependencies |
| --- | --- | --- | --- | --- | --- | --- |
| Team invitations | Medium | Medium | RBAC, email delivery | `company_invitations`, `company_members` | None | Email provider or Supabase invite flow |
| Full CRM pipeline | Medium | Medium | Customers, staff ownership | `crm_pipelines`, `crm_stages`, `crm_deals`, `crm_activities` | None | None |
| Online booking portal | High | High | Services, staff availability, conflict checks | `booking_holds`, `appointments`, `appointment_services`, optional `appointment_reminders` | None | Optional Calendly or custom booking |
| Appointment reminders | Medium | High | Appointments, consent, message templates | `appointment_reminders`, `message_templates`, `marketing_deliveries` or `messages` | None | WhatsApp/SMS/email provider |
| Google Calendar or Calendly sync | High | Medium | Appointments, staff calendars, webhook security | `calendar_connections`, `calendar_event_mappings`, `webhook_events`, `integration_connections` | None | Google Calendar or Calendly |
| WhatsApp messaging via provider | High | High | Consent, templates, conversations | `conversations`, `messages`, `message_status_events`, `message_templates`, `webhook_events` | None | WhatsApp provider or ManyChat |
| HubSpot contact/deal sync | High | Medium | Customers, CRM pipeline, integration framework | `crm_external_mappings`, `integration_connections`, `integration_sync_jobs`, `webhook_events` | None | HubSpot |
| Simple marketing campaigns | Medium | Medium | Customers, consent, message templates | `marketing_audiences`, `marketing_campaigns`, `marketing_messages`, `marketing_deliveries` | None | Messaging/email provider |
| Limited automations | High | Medium | Events, messaging, CRM tasks | `automation_workflows`, `automation_triggers`, `automation_steps`, `automation_events`, `automation_runs` | None | Messaging and CRM integrations if enabled |
| Payments and invoices | High | Medium | Customers, services, appointments, permissions | `invoices`, `invoice_items`, `payments`, `payment_customers` | None | Payment provider |
| Files and attachments | Medium | Medium | Customers, appointments, storage permissions | `files`, `file_links`, storage bucket policies | None | Supabase Storage |
| Improved reports | Medium | Medium | Transactional data, permissions | `report_definitions`, optional `metric_daily_rollups` | None | None |
| SaaS trial and entitlements | Medium | Medium | Multi-tenant readiness, billing model | `plans`, `features`, `company_subscriptions`, `company_feature_entitlements`, `usage_limits` | None | Payment provider later |
| LGPD request workflow | High | Medium | RBAC, audit, export/delete logic | `data_subject_requests`, `data_exports`, `data_deletion_jobs`, `retention_policies` | None | Storage/email optional |

## P2 - Required after product-market fit

| Feature | Complexity | Business impact | Dependencies | Database dependencies | AI dependencies | Integration dependencies |
| --- | --- | --- | --- | --- | --- | --- |
| Full automation builder with branching | High | High | Stable P1 automations, event reliability | Versioned `automation_workflows`, `automation_steps`, `automation_runs`, `automation_run_steps`, `outbox_events`, `dead_letter_events` | Optional for generated steps | Messaging, CRM, calendar, payments |
| AI assistant and AI operations | High | Medium | Stable customer, CRM, appointment, marketing data | `ai_prompts`, `ai_runs`, `ai_outputs`, `ai_usage_records`, `ai_feedback` | Claude or selected model provider | Optional tool integrations |
| AI-generated marketing content | Medium | Medium | Marketing templates, consent workflow, approval flow | `ai_runs`, `ai_outputs`, `marketing_messages`, `message_templates` | Required | Messaging and campaign providers |
| Advanced analytics and rollups | High | High | Stable transactional model, enough usage volume | `metric_daily_rollups`, `report_snapshots`, partitioned event tables | Optional insights generation | None |
| Platform admin console | High | Medium | Multi-tenant operations, support workflows | `platform_admins`, `platform_roles`, `platform_permissions`, `platform_admin_audit_logs` | Optional support summaries | Internal operations only |
| Full platform billing and usage billing | High | High | Pricing validation, entitlements, usage tracking | `billing_accounts`, `subscription_items`, `usage_counters`, `usage_records`, `tenant_invoices` | Optional usage summaries | Stripe or local provider |
| Multi-business self-serve onboarding | High | High | Tenant templates, billing, invitations, support | Tenant initialization jobs, plans, entitlements, default roles/settings | Optional onboarding assistant | Billing, email, analytics |
| Advanced white-label domains | High | Medium | Stable tenant model, DNS/security operations | `company_branding`, domain verification fields, audit logs | None | Vercel/domain provider |
| Multi-location enterprise operations | High | Medium | Proven single-location workflows | Expanded `company_locations`, staff/location permissions, reporting dimensions | Optional forecasting | Calendar/payment providers |
| Dedicated tenant tiering and sharding | High | Medium | Usage scale, enterprise demand | Tenant routing, partitioning, archival, migration tooling | None | Infrastructure providers |
| Full compliance portal | High | Medium | Proven LGPD workflows, audit requirements | Compliance tables, export/delete jobs, legal hold, retention policies | Optional request summarization | Storage/email |

## Features to remove from MVP

Remove these from first-customer scope because they slow launch without proving the core operating workflow:

- AI assistant and AI-generated operational recommendations.
- Full automation workflow builder.
- HubSpot integration.
- ManyChat integration.
- WhatsApp delivery automation.
- Google Calendar and Calendly two-way synchronization.
- Payments, refunds, subscriptions, and financial reconciliation.
- SaaS self-service billing.
- Advanced reports and metric rollups.
- Platform admin console.
- Multi-tenant public signup.
- Advanced white-label domain setup.
- Customer self-service compliance portal.
- Marketplace-style public discovery.

## Features that can be delayed

- Team invitations can be delayed if the first customer starts with manually created staff accounts.
- CRM deals and pipelines can be delayed if follow-up activities and notes are enough.
- Online booking can be delayed if staff continue booking through WhatsApp/phone and enter appointments internally.
- Appointment reminders can be delayed if staff send reminders manually.
- Calendar integration can be delayed if internal calendar views are reliable.
- Marketing audiences and campaigns can be delayed until the customer base is actively managed in the product.
- Data export UI can be delayed if administrator-assisted exports are documented and audited.
- SaaS plan entitlements can be delayed while Amo Beauty Lab is the only production tenant.

## Highest engineering risks

| Risk | Why it matters | Mitigation |
| --- | --- | --- |
| Incorrect tenant isolation or RLS | A cross-tenant leak is existential for a multi-tenant SaaS | Keep P0 table set small, write negative RLS tests, use direct `company_id`, avoid service-role shortcuts |
| Appointment scheduling correctness | Double booking breaks daily operations immediately | Start with simple staff/service conflict checks, avoid resources/recurrence/waitlists in P0 |
| Overbuilt database scope | Implementing the full ERD before launch will delay customer usage | Build only P0 tables/policies first; leave P1/P2 tables out until needed |
| Integration webhook misrouting | Provider events can mutate wrong tenant data | Delay integrations; when added, use signed webhooks, `integration_connections`, `webhook_events`, idempotency |
| Messaging compliance | Marketing or reminder messages without consent create legal and trust risk | Capture consent in P0, delay automated sends until consent checks are enforced |
| Service-role misuse | Supabase service role bypasses RLS | Use service role only in server-side jobs; audit every privileged path |
| AI data leakage | AI prompts can expose personal or cross-tenant data | Delay AI until tenant-scoped AI governance tables and audit are implemented |
| Scope coupling across modules | Payments, marketing, CRM, automations, and reports all depend on customers/appointments | Ship core operational records first, then attach dependent modules one at a time |

## Recommended build order

1. Create the Supabase project, environments, migration structure, and seed process.
2. Implement P0 database schema only: companies, profiles, memberships, roles, customers, services, staff, appointments, consent, CRM activities, and audit logs.
3. Add tenant-safe constraints and indexes for P0 relationships.
4. Implement Supabase Auth, session handling, and owner bootstrap.
5. Implement RLS policies and negative cross-tenant tests for P0 tables.
6. Build the internal app shell: sign in, tenant context, navigation, role-aware access.
7. Build customer management.
8. Build service catalog.
9. Build staff profiles, working hours, and time off.
10. Build appointment creation, editing, cancellation, completion, and no-show handling.
11. Build appointment calendar/list views and conflict validation.
12. Build notes, tags, consent capture, and follow-up activities.
13. Build basic dashboard and administrator export path.
14. Run a production pilot with Amo Beauty Lab using real daily operations.
15. Add the most painful P1 module based on pilot evidence, not architectural enthusiasm.

## Engineering roadmap

### Foundation: make the first tenant safe

- Create the smallest production schema that supports P0.
- Enforce `company_id` ownership on every P0 operational row.
- Add RLS before exposing tenant-owned data through the frontend.
- Add seed data for Amo Beauty Lab roles, services, staff, and initial settings.
- Establish migration discipline before adding modules.

### Core operations: make the business usable

- Build customer, service, staff, and appointment workflows.
- Prefer internal staff workflows over public customer-facing workflows.
- Keep appointment scheduling simple: no recurrence, no waitlists, no resources, no external calendar sync.
- Make status changes and consent changes auditable.
- Add operational dashboard queries only after write flows are stable.

### First-customer pilot: learn from real usage

- Run Amo Beauty Lab on the P0 system for live customer, service, and appointment management.
- Track manual workarounds for reminders, messaging, payments, and reporting.
- Promote only the highest-friction workaround into P1.
- Avoid adding integrations until the internal source-of-truth data is clean.

### Post-first-customer expansion: remove manual bottlenecks

- Add reminders and messaging after consent is reliable.
- Add online booking only after internal scheduling is trusted.
- Add calendar sync only after appointment ownership and conflicts are stable.
- Add CRM pipelines when activities and customer lifecycle tracking are proven useful.
- Add payments when operational booking and service pricing are stable.

### Product-market-fit expansion: scale the platform

- Add AI only after tenant-scoped retrieval, logging, usage tracking, and human approval patterns exist.
- Add full automations after event reliability and message delivery are proven.
- Add platform billing and self-serve onboarding after packaging is validated.
- Add advanced reports after the transactional model and user questions stabilize.
- Add platform administration and tenant tiering when multiple paying tenants create operational support load.

## Final CTO call

The buildable MVP is not the full Casa Di Amo OS architecture. It is a narrow operating system for one beauty business:

- customers,
- services,
- staff,
- appointments,
- consent,
- basic follow-up,
- basic reporting,
- secure tenant access.

That is enough to get Amo Beauty Lab live, collect real operating feedback, and avoid spending the pre-customer phase on integrations, AI, billing, automation, and analytics that depend on clean operational data anyway.
