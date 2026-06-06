# Casa Di Amo OS LGPD Compliance Model

## Purpose

This document defines the LGPD compliance model for Casa Di Amo OS.

LGPD compliance must be designed into the platform architecture because Casa Di Amo OS stores and processes customer, staff, appointment, communication, payment, marketing, integration, and analytics data for multiple tenant companies.

This document is an architectural model and does not replace legal review.

## Compliance Principles

- Privacy by design.
- Tenant isolation by default.
- Data minimization.
- Purpose limitation.
- Consent traceability.
- Controlled retention.
- Auditable access.
- Secure handling of sensitive data.
- No cross-tenant data sharing by default.

## Data Roles

### Casa Di Amo OS

Casa Di Amo OS acts as the platform operator and processor for most tenant business data.

Responsibilities:

- Provide secure platform infrastructure.
- Enforce tenant isolation.
- Provide consent, export, deletion, retention, and audit capabilities.
- Protect platform-level billing, security, and operational data.

### Tenant Companies

Tenant companies act as controllers for their customers' operational data in most business workflows.

Responsibilities:

- Define lawful basis for processing.
- Collect customer consent when required.
- Configure retention policies.
- Respond to customer privacy requests.
- Ensure staff access is appropriate.

### Data Subjects

Data subjects may include:

- Customers.
- Staff users.
- Company owners.
- Platform users.
- Leads and prospects.

## Data Classification

### Personal Data

Examples:

- Name.
- Email.
- Phone.
- Address.
- Birthdate.
- Customer notes.
- Appointment history.
- CRM activity.
- Messages.
- Marketing delivery history.
- Payment references.
- Files attached to customer records.

### Sensitive or High-Risk Data

Examples:

- Health-related notes.
- Beauty, clinic, or treatment information.
- Documents containing personal identifiers.
- Free-form notes with sensitive context.
- Payment dispute information.
- Staff access logs.
- Support access logs.
- AI prompts or outputs containing customer data.

### Operational Metadata

Examples:

- Audit logs.
- Webhook events.
- Integration sync jobs.
- Automation events.
- Usage records.
- Report snapshots.

Operational metadata may still contain personal data and must be retained, exported, or deleted according to policy.

## 1. Consent Management

### Consent Entities

Primary entities:

- `customer_consents`.
- `consent_audit_logs`.
- `marketing_deliveries`.
- `message_templates`.
- `marketing_campaigns`.

### Consent Scope

Consent must be tracked by:

- Company.
- Customer.
- Channel.
- Purpose.
- Status.
- Capture source.
- Capture timestamp.
- Revocation timestamp.
- Proof metadata.

Recommended channels:

- WhatsApp.
- SMS.
- Email.
- Phone.
- In-app.

Recommended purposes:

- Transactional communication.
- Appointment reminders.
- Marketing campaigns.
- Promotions.
- Customer support.
- Research or feedback.

### Consent States

Recommended states:

- `unknown`.
- `granted`.
- `revoked`.
- `expired`.

### Consent Rules

- Marketing messages require valid consent for the channel and purpose.
- Consent revocation must block future marketing delivery for that channel and purpose.
- Transactional communications should be separated from marketing communications.
- Consent changes must write `consent_audit_logs`.
- Consent proof must be retained even when marketing access is revoked.
- Consent must be tenant-scoped and must not transfer across companies.

### Consent Revocation Flow

When a customer revokes consent:

1. Update `customer_consents`.
2. Write `consent_audit_logs`.
3. Stop future marketing deliveries for that channel and purpose.
4. Preserve historical delivery and consent audit records.
5. Trigger automation events only if the workflow is compliant.

## 2. Data Retention

### Retention Entities

Primary entities:

- `retention_policies`.
- `data_deletion_jobs`.
- `audit_logs`.
- `webhook_events`.
- `automation_events`.
- `marketing_deliveries`.
- `messages`.
- `report_snapshots`.

### Retention Scope

Retention policies should be configurable by:

- Company.
- Entity type.
- Data category.
- Retention period.
- Retention action.
- Legal hold status.

Recommended retention actions:

- Keep.
- Archive.
- Anonymize.
- Delete.

### Default Retention Strategy

Recommended defaults:

- Customer operational data: controlled by tenant policy.
- Audit logs: retain for security and compliance minimum period.
- Financial records: retain according to accounting requirements.
- Consent audit logs: retain as proof of consent history.
- Webhook events: retain short term unless needed for disputes.
- Automation runs: retain medium term for observability.
- Report snapshots: retain according to plan and tenant policy.
- AI runs and outputs: retain only as long as needed for product function and audit.

### Retention Rules

- Deletion must not bypass audit requirements.
- Financial and audit records should not be hard-deleted casually.
- Retention jobs must be tenant-scoped.
- Retention actions must be idempotent.
- Retention failures must be visible to platform operations.
- Legal hold must override normal deletion schedules.

## 3. Data Export

### Export Entities

Primary entities:

- `data_subject_requests`.
- `data_exports`.
- `files`.
- `file_links`.
- `audit_logs`.

### Export Request Types

Recommended request types:

- Customer export.
- User export.
- Company export.
- Compliance export.
- Audit export.

### Export Flow

When an export is requested:

1. Create `data_subject_requests`.
2. Validate requester authorization.
3. Resolve tenant context.
4. Identify data subject scope.
5. Queue `data_exports`.
6. Generate export file.
7. Store file metadata securely.
8. Link export file to request.
9. Notify authorized requester.
10. Audit the export.

### Export Contents

Customer exports may include:

- Customer profile.
- Addresses.
- Notes where legally exportable.
- Consent history.
- Appointment history.
- CRM activity.
- Messages.
- Marketing delivery history.
- Payment references.
- Files linked to the customer.

Exports should not include:

- Other customers' data.
- Internal platform secrets.
- Raw provider credentials.
- Data outside the tenant boundary.
- Security-sensitive operational metadata unless legally required.

### Export Security

- Export files must be access-controlled.
- Export links must expire.
- Export access must be audited.
- Export files must be deleted or archived according to retention policy.
- Large exports should run asynchronously.

## 4. Data Deletion

### Deletion Entities

Primary entities:

- `data_subject_requests`.
- `data_deletion_jobs`.
- `retention_policies`.
- `audit_logs`.

### Deletion Types

Supported deletion approaches:

- Hard deletion.
- Soft deletion.
- Anonymization.
- Archival.
- Restricted processing.

### Deletion Flow

When deletion is requested:

1. Create `data_subject_requests`.
2. Validate requester identity and authority.
3. Resolve tenant context.
4. Check legal, financial, audit, and operational retention requirements.
5. Create `data_deletion_jobs`.
6. Execute deletion or anonymization by entity type.
7. Preserve required audit and legal records.
8. Mark request complete.
9. Audit the deletion.

### Deletion Rules

- Do not delete records required for legal, financial, fraud, or security retention.
- Prefer anonymization where business history must remain.
- Delete or anonymize child records consistently.
- Remove customer from future marketing audiences.
- Revoke active marketing consent.
- Stop automations that target deleted or anonymized data.
- Preserve minimal audit trail showing that deletion occurred.

### Anonymization Strategy

For records that must remain:

- Replace direct identifiers with neutral values.
- Remove contact details.
- Remove free-form personal notes where possible.
- Preserve aggregate metrics.
- Preserve financial totals without personal identifiers when legally acceptable.

## 5. Audit Requirements

### Audit Entities

Primary entities:

- `audit_logs`.
- `platform_admin_audit_logs`.
- `consent_audit_logs`.
- `user_sessions_audit`.

### Actions That Must Be Audited

Audit these actions:

- Consent grant.
- Consent revocation.
- Customer data export.
- Customer data deletion.
- Customer anonymization.
- Retention policy changes.
- Company settings changes.
- Role assignment.
- Member invitation, suspension, or removal.
- Integration credential changes.
- API key creation or revocation.
- Platform support access.
- Tenant impersonation.
- Payment refund.
- Invoice adjustment.
- Bulk marketing send.
- Automation publish.
- AI-assisted action involving personal data.

### Audit Record Requirements

Audit records should include:

- Company.
- Actor.
- Actor role.
- Action.
- Entity type.
- Entity ID.
- Timestamp.
- Request context.
- IP address where available.
- User agent where available.
- Reason or justification for sensitive actions.

### Audit Rules

- Audit logs should be append-only from the application perspective.
- Platform admin audit must be separate from tenant audit.
- Audit logs must be protected from normal tenant deletion flows.
- Audit exports must require elevated permission.
- Audit records must not expose secrets.

## 6. Sensitive Data Handling

### Sensitive Data Sources

Sensitive data can appear in:

- Customer notes.
- Appointment notes.
- CRM activities.
- Messages.
- Files.
- AI prompts.
- AI outputs.
- Integration payloads.
- Webhook payloads.
- Support tickets.

### Handling Rules

- Minimize collection of sensitive data.
- Avoid storing unnecessary sensitive data in free-form fields.
- Restrict access to sensitive notes and files by role.
- Do not store raw payment credentials.
- Do not store raw integration secrets in business tables.
- Do not expose sensitive provider payloads to normal users.
- Mask sensitive fields in logs and support tools.
- Use secure storage for files.
- Use short retention for raw webhook payloads when possible.

### AI-Specific Rules

AI workflows must treat personal data as sensitive.

Rules:

- Do not send unnecessary personal data to AI providers.
- Prefer summarized context over raw records.
- Store AI usage records for billing and audit.
- Review AI outputs before using them for high-impact customer actions.
- Allow AI output deletion or retention according to tenant policy.

### Payment Data Rules

Payment handling must avoid storing raw card or banking data.

Allowed:

- Provider customer ID.
- Provider payment ID.
- Payment status.
- Amount.
- Currency.
- Reconciliation metadata.

Not allowed:

- Raw card number.
- CVV.
- Raw bank credentials.
- Payment provider secrets in business tables.

## Tenant Isolation and LGPD

LGPD workflows must respect tenant boundaries.

Rules:

- A company can only export, delete, or process data it owns.
- Platform Admin access to tenant personal data must be justified and audited.
- Cross-company customer matching is not allowed by default.
- Data subject requests must include tenant context.
- Service-role jobs must validate tenant ownership before processing.

## Operational Responsibilities

### Company Owner

Can:

- Configure retention preferences.
- Respond to customer data requests.
- Request exports.
- Request deletion or anonymization.
- Review consent state.

Cannot:

- Bypass platform retention safeguards.
- Delete protected audit or financial records.

### Manager

Can:

- View and update customer data where operationally required.
- Assist with customer requests if granted permission.

Cannot by default:

- Export full customer datasets.
- Delete customer records.
- Change retention policies.

### Platform Admin

Can:

- Support compliance workflows.
- Investigate security incidents.
- Run platform-approved exports or deletion jobs.
- Apply legal hold.

Must:

- Provide reason for sensitive access.
- Generate audit logs.
- Avoid silent tenant data changes.

## Deployment Checklist

Before production:

- Define default retention policies.
- Define consent purposes and channels.
- Implement consent audit logging.
- Implement data subject request workflow.
- Implement export job workflow.
- Implement deletion and anonymization job workflow.
- Define legal hold behavior.
- Restrict sensitive notes and files by RBAC.
- Audit platform support access.
- Mask secrets and sensitive fields in logs.
- Validate tenant ownership in all compliance jobs.
- Test cross-tenant denial for exports and deletions.
