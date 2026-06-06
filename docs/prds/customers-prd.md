# Customers PRD

## Module

Customers.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## Business Objective

Create a reliable customer record that Amo Beauty Lab can use as the source of truth for client identity, contact details, visit context, notes, tags, and appointment history.

The MVP must help staff find and update customers quickly while enforcing tenant isolation, role permissions, and privacy controls.

## User Personas

- Company Owner: needs complete visibility into the customer base and operational data quality.
- Manager: manages customer records, corrects details, and reviews customer history.
- Employee: creates and updates customers during service delivery.
- Viewer: reads customer information without changing it.

## User Stories

- As a front desk user, I want to create a customer quickly so I can book or manage a visit.
- As a staff user, I want to search customers by name, phone, or email so I can avoid duplicate records.
- As a Manager, I want to edit customer details so operational information stays current.
- As a staff user, I want to view a customer profile with contact details, notes, tags, and appointments so I understand the customer before service.
- As a staff user, I want to add internal notes so the team can share service-relevant context.
- As a Manager, I want to pin important notes so critical context is visible.
- As a Manager, I want to tag customers so staff can identify VIPs, preferences, or special handling needs.
- As a Company Owner, I want inactive customers archived instead of casually deleted so records remain traceable.
- As a Viewer, I want read-only customer access so I can review information without risk of accidental edits.

## Acceptance Criteria

- Users with customer read permission can view customer lists and customer detail pages for their active company.
- Users without customer read permission cannot view customer records.
- Users with customer create permission can create a customer with first name or display name plus at least one contact method when available.
- Customer create and update forms validate email format, phone format, and required fields.
- Customer list supports search by name, email, and phone within the active company.
- Customer list supports filtering by status and tag.
- Customer detail page shows contact details, lifecycle status, source, preferred channel, notes, tags, addresses, and related appointments.
- Staff can add notes when their role allows customer update or assigned customer update.
- Note visibility rules are respected so restricted notes are hidden from roles without permission.
- Tags are company-scoped and cannot be shared across tenants.
- Archiving a customer changes status without hard deletion.
- Duplicate detection warns when a matching email or phone already exists in the active company.
- Customer data never crosses company boundaries in list, search, detail, or counts.
- Sensitive customer updates are written to `audit_logs` when required by policy.

## Navigation

- Primary navigation:
  - `/customers`
  - `/customers/new`
  - `/customers/:customerId`
  - `/customers/:customerId/edit`
- Customer detail tabs:
  - Overview
  - Notes
  - Tags
  - Appointments
  - Contact Preferences
- Contextual actions:
  - create customer
  - edit customer
  - add note
  - pin note
  - assign tag
  - archive customer
  - create appointment from customer profile

## Required Database Entities

- `customers`
- `customer_addresses`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `appointments`
- `appointment_services`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`
- `audit_logs`

## API Requirements

- Provide customer list API with tenant-scoped search, pagination, status filter, and tag filter.
- Provide customer detail API returning customer profile, notes, tags, addresses, contact preferences, and related appointment summary.
- Provide create customer API with duplicate warning by normalized email or phone within the active company.
- Provide update customer API with field-level validation and permission enforcement.
- Provide archive customer API that uses status changes rather than hard deletion.
- Provide customer notes APIs:
  - create note
  - update own note where allowed
  - pin or unpin note where allowed
  - list notes with visibility filtering
- Provide customer tags APIs:
  - list company tags
  - create company tag where allowed
  - assign tag to customer
  - remove tag from customer
- Provide customer contact preference APIs for channel and purpose consent status.
- All APIs must validate active company membership and customer module permissions.
- All APIs must apply tenant-safe filters and never trust a client-supplied company id without membership validation.

## Edge Function Requirements

- `customer-write`
  - performs create, update, and archive operations that require additional validation
  - checks tenant membership, role permission, and customer company ownership
  - normalizes email and phone fields before write
  - records sensitive changes in `audit_logs`
- `customer-duplicate-check`
  - checks possible duplicate customers inside one company only
  - returns warning candidates without exposing inaccessible records
- `customer-note-write`
  - validates note author membership
  - applies note visibility rules
  - records privileged note actions where required
- `customer-contact-preference-write`
  - records communication preference changes with capture source and timestamp
  - preserves revocation history where supported by the schema

## Future Roadmap

- Customer merge workflow with audit trail.
- Advanced duplicate management.
- Customer import with preview and validation.
- Customer export for authorized roles.
- Rich service preference profile.
- File attachments for customer documents and images.
- Privacy request workflows for access, correction, and deletion handling.
