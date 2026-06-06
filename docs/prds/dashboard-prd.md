# Dashboard PRD

## Module

Dashboard.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## MVP Launch Scope

- Today summary.
- Upcoming appointments.
- Appointment status counts.
- Staff workload for the selected day.
- Recent customer activity.
- Quick actions for creating customers and appointments.

## Product Validation

Dashboard is successful when the Owner or Manager can understand today's operations in under 30 seconds and take the next action without searching through multiple pages.

## Business Objective

Give Amo Beauty Lab a fast operational overview of today's business activity, upcoming appointments, customer activity, staff workload, and data that needs attention.

The MVP dashboard must help owners and managers run the day without requiring complex reporting infrastructure.

## User Personas

- Company Owner: needs a concise view of business activity and operational health.
- Manager: needs to monitor today's schedule, customer activity, and team workload.
- Employee: needs a focused view of assigned appointments and quick actions.
- Viewer: needs read-only visibility into permitted dashboard cards.

## User Stories

- As a Company Owner, I want to see today's appointment volume so I can understand business activity.
- As a Manager, I want to see upcoming appointments so I can prepare the team.
- As a Manager, I want to see appointment status counts so I can identify schedule issues.
- As an Employee, I want to see my assigned appointments so I can start work quickly.
- As a Manager, I want to see recently created customers so I can monitor intake quality.
- As a Company Owner, I want to see staff workload for today so I can understand capacity.
- As a Viewer, I want dashboard cards to respect read-only permissions.
- As any user, I want dashboard data to match the active company so tenant data never mixes.

## Acceptance Criteria

- Dashboard is available only to authenticated users with an active company membership.
- Dashboard cards render according to the user's effective permissions.
- Users without appointment read permission cannot see appointment cards.
- Users without customer read permission cannot see customer cards.
- Dashboard defaults to Amo Beauty Lab when it is the user's only active company.
- Dashboard defaults to today and supports a simple date picker.
- Appointment summary shows total appointments, scheduled, confirmed, completed, cancelled, and no-show counts for the selected day.
- Upcoming appointments card shows the next appointments with time, customer, service summary, staff, location, and status.
- Staff workload card shows appointment count and booked time by staff member for the selected day.
- Customer activity card shows recent customers created in the selected period.
- Quick actions are visible only when the user can create the target record.
- Dashboard queries are tenant-scoped and cannot aggregate across companies.
- Dashboard loads from current operational records for V1.

## Navigation

- Primary navigation:
  - `/dashboard`
- Dashboard cards:
  - Today Summary
  - Upcoming Appointments
  - Appointment Status
  - Staff Workload
  - Customer Activity
- Contextual actions:
  - open appointment
  - create appointment
  - open customer
  - create customer
  - change date
  - switch active company where applicable

## Required Database Entities

- `companies`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`
- `customers`
- `appointments`
- `appointment_services`
- `staff_profiles`
- `services`
- `company_locations`

## API Requirements

- Provide dashboard summary API with date, company context, and permission-aware card payloads.
- Provide upcoming appointments API with limit, date range, staff filter, and status filter.
- Provide appointment status summary API grouped by status for a selected day.
- Provide staff workload API grouped by staff member for a selected day.
- Provide customer activity API for recently created customers where permitted.
- APIs must return only cards the user may read.
- APIs must validate active company membership and module-level read permissions.
- APIs must use `company_id` and date filters in every dashboard query.
- APIs must cap result sizes so the dashboard remains fast.
- APIs must return fresh operational data for upcoming appointments.

## Edge Function Requirements

No custom Edge Function is required for the first dashboard if Supabase queries meet performance targets. Add one thin function only if the frontend needs a single boot payload.

- `dashboard-summary`
  - validates Supabase JWT, active company membership, and effective read permissions
  - returns a card-based payload tailored to the user role
  - reads current operational records for the selected date
  - prevents cross-company aggregation

## Future Roadmap

- Customizable dashboard cards by role.
- Saved dashboard views.
- Multi-location dashboard filters.
- Staff utilization trends.
- Service mix trends.
- Deeper operational reporting.
- Owner-level export for dashboard summaries.
- Benchmarks against historical operating periods.
