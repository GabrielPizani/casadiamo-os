# Casa Di Amo OS RBAC Model

## Purpose

This document defines the Role Based Access Control model for Casa Di Amo OS.

RBAC must be evaluated inside an active tenant context unless the actor is a Platform Admin performing platform-level administration.

## Access Principles

- Authentication is handled by Supabase Auth.
- Tenant access is granted through `company_members`.
- Company roles apply only inside one company.
- A user may hold different roles in different companies.
- Platform Admin is separate from company membership.
- Permissions should be enforced in the application and in Row Level Security policies.
- Sensitive actions must be audited.

## Modules

Core modules:

- Authentication.
- Companies.
- Users and Team.
- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- Settings.
- Integrations.
- Files and Documents.
- Audit and Compliance.
- Platform Administration.

## Permission Actions

Standard actions:

- `read`: view records.
- `create`: create records.
- `update`: edit records.
- `delete`: delete or archive records.
- `manage`: full operational control for a module.
- `approve`: approve sensitive changes.
- `export`: export data.
- `configure`: change settings.
- `impersonate`: access support context for a tenant.

## Role Summary

| Role | Scope | Access Level |
| --- | --- | --- |
| Platform Admin | Platform | Platform operations, tenant lifecycle, support, billing, and security administration |
| Company Owner | Company | Full tenant control and business ownership |
| Manager | Company | Operational management without ownership-level destructive controls |
| Employee | Company | Day-to-day operational work for assigned modules |
| Viewer | Company | Read-only access to permitted company modules |

## 1. Platform Admin

### Scope

Platform-wide.

Platform Admin is not a normal company role. Platform Admin access must be modeled separately from company membership and audited independently.

### Accessible Modules

- Platform Administration.
- Companies.
- SaaS Plans and Entitlements.
- Tenant Billing.
- Integrations Health.
- Audit and Compliance.
- Reports and Operational Monitoring.
- User Security Review.
- Support Tools.

### Permissions

- `platform.read`.
- `platform.manage`.
- `companies.read`.
- `companies.create`.
- `companies.update`.
- `companies.suspend`.
- `companies.restore`.
- `plans.manage`.
- `features.manage`.
- `entitlements.manage`.
- `tenant_billing.read`.
- `tenant_billing.manage`.
- `integrations.health.read`.
- `integrations.health.manage`.
- `audit.read`.
- `compliance.manage`.
- `support.access`.
- `support.impersonate`.
- `security.review`.

### Actions Allowed

- Create, suspend, restore, and administratively manage companies.
- Manage platform roles, platform permissions, SaaS plans, features, and entitlements.
- Review tenant billing state and subscription health.
- Inspect integration health and background job failures.
- Access audit logs for platform and security investigations.
- Trigger tenant export, retention, or deletion workflows when authorized.
- Perform support access only with explicit reason and audit trail.

### Restrictions

- Must not be treated as a company member by default.
- Must not silently edit tenant business data.
- Must not bypass audit logging.
- Must not access tenant data without support, security, compliance, or billing justification.
- Must not use tenant impersonation without a time-bound reason.
- Must not expose service-role credentials.

## 2. Company Owner

### Scope

Single company tenant.

The Company Owner is the top business role inside a company.

### Accessible Modules

- Authentication profile.
- Companies.
- Users and Team.
- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- Settings.
- Integrations.
- Files and Documents.
- Audit and Compliance.

### Permissions

- `company.read`.
- `company.update`.
- `company.configure`.
- `members.read`.
- `members.invite`.
- `members.update`.
- `members.remove`.
- `roles.assign`.
- `customers.manage`.
- `services.manage`.
- `appointments.manage`.
- `crm.manage`.
- `marketing.manage`.
- `automations.manage`.
- `payments.read`.
- `payments.manage`.
- `payments.refund`.
- `reports.read`.
- `reports.export`.
- `settings.configure`.
- `integrations.manage`.
- `files.manage`.
- `audit.read`.
- `compliance.manage`.

### Actions Allowed

- Manage company profile, settings, branding, locations, and operational configuration.
- Invite, update, suspend, and remove company members.
- Assign company roles.
- Manage customers, notes, tags, consent, services, appointments, CRM, marketing, automations, payments, files, and integrations.
- View financial records, issue refunds, and manage invoices when enabled.
- View and export reports.
- View tenant audit logs.
- Initiate compliance workflows such as data exports and deletion requests.

### Restrictions

- Cannot access other companies unless separately invited.
- Cannot manage platform plans, global features, or platform administrators.
- Cannot bypass RLS or service-role restrictions.
- Cannot delete financial, audit, or compliance records outside approved retention workflows.
- Cannot impersonate other users.

## 3. Manager

### Scope

Single company tenant.

Managers operate the business but do not own tenant-level administration.

### Accessible Modules

- Authentication profile.
- Users and Team.
- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- Files and Documents.

### Permissions

- `company.read`.
- `members.read`.
- `customers.manage`.
- `services.read`.
- `services.update`.
- `appointments.manage`.
- `crm.manage`.
- `marketing.create`.
- `marketing.update`.
- `marketing.read`.
- `automations.read`.
- `automations.update`.
- `payments.read`.
- `reports.read`.
- `reports.export`.
- `files.manage`.

### Actions Allowed

- View company profile and operational settings.
- View team members and staff availability.
- Create, update, and manage customers.
- Manage appointments, staff scheduling, waitlists, reminders, and appointment status.
- Manage CRM pipelines, deals, stages, and activities.
- Create and update marketing campaigns within company rules.
- Update existing automations when permitted by owner policy.
- View payments, invoices, and revenue reports.
- Export operational reports when allowed.
- Upload and manage operational files.

### Restrictions

- Cannot change company ownership.
- Cannot suspend or remove the Company Owner.
- Cannot assign Owner role.
- Cannot manage billing plans or tenant subscription.
- Cannot configure high-risk integrations without owner approval.
- Cannot issue refunds unless explicitly granted by Company Owner.
- Cannot delete audit logs, compliance records, or financial records.
- Cannot access platform administration.

## 4. Employee

### Scope

Single company tenant.

Employees perform assigned operational work.

### Accessible Modules

- Authentication profile.
- Customers.
- Services.
- Appointments.
- CRM.
- Conversations and Messages.
- Files and Documents.
- Limited Reports.

Optional access by company policy:

- Marketing read.
- Payments read.

### Permissions

- `company.read`.
- `customers.read`.
- `customers.create`.
- `customers.update_assigned`.
- `services.read`.
- `appointments.read`.
- `appointments.create`.
- `appointments.update_assigned`.
- `crm.read`.
- `crm.create_activity`.
- `messages.read`.
- `messages.send`.
- `files.read`.
- `files.create`.
- `reports.read_limited`.

### Actions Allowed

- View company context needed for daily work.
- View services and assigned staff availability.
- Create and update customers when needed for service delivery.
- Create appointments.
- Update assigned appointments.
- Add CRM activities and notes.
- Communicate with customers through approved channels.
- Upload files related to assigned customers or appointments.
- View limited operational reports relevant to their work.

### Restrictions

- Cannot manage company settings.
- Cannot invite, remove, or modify team members.
- Cannot assign roles.
- Cannot manage services catalog unless explicitly elevated.
- Cannot manage marketing campaigns.
- Cannot publish automations.
- Cannot view full financial reports by default.
- Cannot issue refunds.
- Cannot export customer lists by default.
- Cannot access audit logs, compliance workflows, or platform administration.

## 5. Viewer

### Scope

Single company tenant.

Viewer is read-only and should be used for advisors, auditors, or limited stakeholders.

### Accessible Modules

- Authentication profile.
- Companies.
- Customers.
- Services.
- Appointments.
- CRM.
- Marketing.
- Payments.
- Reports.
- Files and Documents.

Access may be narrowed by company policy.

### Permissions

- `company.read`.
- `members.read_limited`.
- `customers.read`.
- `services.read`.
- `appointments.read`.
- `crm.read`.
- `marketing.read`.
- `payments.read_limited`.
- `reports.read`.
- `files.read`.

### Actions Allowed

- View company information.
- View customers.
- View services.
- View appointments.
- View CRM records.
- View marketing campaigns and delivery summaries.
- View limited payment and invoice information.
- View reports.
- View files.

### Restrictions

- Cannot create, update, delete, archive, export, approve, publish, refund, configure, or manage records.
- Cannot access customer-sensitive notes unless explicitly allowed.
- Cannot view raw integration payloads.
- Cannot view secrets or API keys.
- Cannot invite users or change roles.
- Cannot access platform administration.

## Module Access Matrix

| Module | Platform Admin | Company Owner | Manager | Employee | Viewer |
| --- | --- | --- | --- | --- | --- |
| Platform Administration | Manage | None | None | None | None |
| Companies | Manage platform companies | Manage own company | Read | Read | Read |
| Users and Team | Security review | Manage | Read | None | Limited read |
| Customers | Support access only | Manage | Manage | Limited create/update | Read |
| Services | Support access only | Manage | Update/read | Read | Read |
| Appointments | Support access only | Manage | Manage | Assigned create/update | Read |
| CRM | Support access only | Manage | Manage | Activity create/read | Read |
| Marketing | Support access only | Manage | Create/update/read | Optional read | Read |
| Automations | Support access only | Manage | Update/read | None | None |
| Payments | Billing support | Manage/refund | Read | Optional read | Limited read |
| Reports | Platform monitoring | Read/export | Read/export | Limited read | Read |
| Settings | Platform config | Configure | Read | None | None |
| Integrations | Health/support | Manage | Limited read | None | None |
| Files and Documents | Support access only | Manage | Manage | Create/read assigned | Read |
| Audit and Compliance | Platform audit | Read/manage | None | None | None |

## Sensitive Permission Rules

### Owner-Only by Default

- `settings.configure`.
- `members.remove`.
- `roles.assign`.
- `integrations.manage`.
- `payments.refund`.
- `reports.export`.
- `compliance.manage`.
- `audit.read`.

### Platform-Only by Default

- `platform.manage`.
- `companies.suspend`.
- `companies.restore`.
- `plans.manage`.
- `features.manage`.
- `entitlements.manage`.
- `support.impersonate`.
- `security.review`.

### Explicit Approval Recommended

- Refunds.
- Customer data export.
- Customer data deletion.
- Integration credential rotation.
- Automation publication.
- Bulk customer messaging.
- Company suspension.
- Tenant impersonation.

## RBAC and RLS Alignment

RLS policies should evaluate:

1. Authenticated user.
2. Active `user_profiles` record.
3. Active `company_members` record.
4. Active `companies` record.
5. Role assignment.
6. Permission key.
7. Record `company_id`.

Read policies should require active membership.

Write policies should require active membership plus the appropriate permission key.

Platform Admin policies must be separate from company membership policies.

## Audit Requirements

Audit these actions:

- Role assignment.
- Member invitation.
- Member suspension or removal.
- Company settings changes.
- Integration changes.
- API key creation or revocation.
- Payment refund.
- Invoice adjustment.
- Report export.
- Customer data export.
- Customer deletion or anonymization.
- Automation publish.
- Bulk marketing send.
- Platform support access.
- Tenant impersonation.

## Default Role Assignment

Recommended defaults:

- First company creator: Company Owner.
- Invited operational lead: Manager.
- Invited staff member: Employee.
- External advisor or accountant: Viewer.
- Internal Casa Di Amo operator: Platform Admin.

## Implementation Notes

- Store roles in `roles`.
- Store permissions in `permissions`.
- Store mappings in `role_permissions`.
- Store user-to-company access in `company_members`.
- Store platform roles separately in platform administration tables.
- Do not hard-code permissions only in frontend logic.
- Treat frontend permission checks as UX, not security.
- Enforce permissions in backend functions and RLS policies.
