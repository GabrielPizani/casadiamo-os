# Dashboard PRD

## Module

Dashboard.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## Business Objective

Give Amo Beauty Lab a fast operational overview of today's business activity, upcoming appointments, customer activity, staff workload, and data that needs attention.

The MVP dashboard must help owners and managers understand daily operations without requiring them to open every module.

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
- As a Company Owner, I want to see staff workload by day so I can understand capacity.
- As a Viewer, I want dashboard cards to respect read-only permissions.
- As any user, I want dashboard data to match the active company so tenant data never mixes.

## Acceptance Criteria

- Dashboard is available only to authenticated users with an active company membership.
- Dashboard cards render according to the user's effective permissions.
- Users without appointment read permission cannot see appointment cards.
- Users without customer read permission cannot see customer cards.
- Dashboard defaults to Amo Beauty Lab when it is the user's only active company.
- Dashboard supports a date selector for today, tomorrow, and custom single-day view.
- Appointment summary shows total appointments, scheduled, confirmed, completed, cancelled, and no-show counts for the selected day.
- Upcoming appointments card shows the next appointments with time, customer, service summary, staff, location, and status.
- Staff workload card shows appointment count and booked time by staff member for the selected day.
- Customer activity card shows new customers created in the selected period and recently updated customers where permitted.
- Attention card highlights incomplete customer contact information and appointments missing staff or service details.
- Dashboard queries are tenant-scoped and cannot aggregate across companies.
- Dashboard responses are optimized for first-page load and do not require broad scans of transactional tables when rollups exist.

## Navigation

- Primary navigation:
  - `/dashboard`
- Dashboard cards:
  - Today Summary
  - Upcoming Appointments
  - Appointment Status
  - Staff Workload
  - Customer Activity
  - Needs Attention
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
- `metric_daily_rollups`
- `report_definitions`
- `report_snapshots`
- `audit_logs`

## API Requirements

- Provide dashboard summary API with date, company context, and permission-aware card payloads.
- Provide upcoming appointments API with limit, date range, staff filter, and status filter.
- Provide appointment status summary API grouped by status for a selected day.
- Provide staff workload API grouped by staff member for a selected day.
- Provide customer activity API for new and recently updated customers where permitted.
- Provide needs-attention API for incomplete customer records and incomplete appointment setup.
- APIs must return only cards the user may read.
- APIs must validate active company membership and module-level read permissions.
- APIs must use `company_id` and date filters in every dashboard query.
- APIs must prefer `metric_daily_rollups` or cached snapshots where available for summary cards.
- APIs must return fresh transactional data for short-range operational cards such as upcoming appointments.

## Edge Function Requirements

- `dashboard-summary`
  - validates Supabase JWT, active company membership, and effective read permissions
  - returns a card-based payload tailored to the user role
  - reads rollups where available and transactional records where current-day freshness is required
  - prevents cross-company aggregation
- `dashboard-rollup-refresh`
  - refreshes daily operational rollups for customers, appointments, staff workload, and attention counts
  - processes one company at a time
  - stores results in `metric_daily_rollups` or `report_snapshots`
  - records failures with enough context for support without exposing customer-sensitive details
- `dashboard-attention-check`
  - calculates incomplete customer and appointment setup counts
  - validates that returned record links belong to the active company

## Future Roadmap

- Customizable dashboard cards by role.
- Saved dashboard views.
- Multi-location dashboard filters.
- Staff utilization trends.
- Service mix trends.
- Deeper operational reporting.
- Owner-level export for dashboard summaries.
- Benchmarks against historical operating periods.
