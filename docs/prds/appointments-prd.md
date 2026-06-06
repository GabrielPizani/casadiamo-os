# Appointments PRD

## Module

Appointments.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## MVP Launch Scope

- Daily and weekly appointment calendar.
- Create appointment.
- Edit and reschedule appointment.
- Assign customer, service, staff member, date, time, and location.
- Change appointment status.
- View appointment detail.
- Open customer profile from appointment.

## Product Validation

Appointments is successful when Amo Beauty Lab can run a normal business day from the calendar without relying on a separate manual agenda.

## Business Objective

Give Amo Beauty Lab a dependable internal scheduling system for booking services, assigning staff, managing appointment status, and viewing the daily calendar.

The MVP must reduce manual scheduling errors, keep customer visit history accurate, and prevent staff or location conflicts inside the active tenant.

## User Personas

- Company Owner: needs full visibility and control over schedule operations.
- Manager: manages the daily schedule, staff assignments, and service capacity.
- Employee: books and updates assigned appointments.
- Service Provider: views assigned appointments and updates visit status where allowed.
- Viewer: reads schedule information without editing it.

## User Stories

- As a front desk user, I want to create an appointment for a customer so the visit is scheduled in the system.
- As a staff user, I want to choose services, staff, date, time, and location so the appointment is complete.
- As a Manager, I want basic conflict checks so staff are not double-booked.
- As a Manager, I want to reschedule appointments so customer needs can be handled.
- As a Service Provider, I want to see my appointments for today so I know my workload.
- As a staff user, I want to update appointment status so the team knows whether a customer is scheduled, confirmed, arrived, completed, cancelled, or no-show.
- As a Manager, I want status history so appointment changes are traceable.
- As a staff user, I want to open the customer profile from the appointment so I can review customer context.
- As a Company Owner, I want schedule views by day, week, staff, and location so operations are easy to supervise.

## Acceptance Criteria

- Users with appointment read permission can view the schedule for their active company.
- Users without appointment read permission cannot view appointment records.
- Users with appointment create permission can create appointments for customers in the active company.
- Appointment creation requires customer, service, staff member, start time, and end time.
- Appointment creation validates that selected services belong to the active company.
- Appointment creation validates that selected staff belong to the active company and are eligible where service assignment data exists.
- Appointment creation validates that selected location belongs to the active company when a location is selected.
- Appointment creation blocks staff time conflicts for active appointment statuses.
- Appointment rescheduling updates start time, end time, staff, and location only when the user has update permission.
- Appointment status changes create an `appointment_status_history` record.
- Cancelled and no-show states preserve reason or note when provided.
- Appointment list and calendar views support filters by date, staff, location, status, and customer.
- Service price and duration snapshots are preserved in `appointment_services`.
- Customer appointment history appears on the customer detail page.
- All appointment queries and writes enforce tenant isolation.
- Public online booking is not part of V1.

## Navigation

- Primary navigation:
  - `/appointments`
  - `/appointments/calendar`
  - `/appointments/new`
  - `/appointments/:appointmentId`
  - `/appointments/:appointmentId/edit`
- Schedule views:
  - Today
  - Day
  - Week
  - Staff
- Contextual actions:
  - create appointment
  - reschedule appointment
  - change appointment status
  - cancel appointment
  - mark no-show
  - open customer profile
  - create customer during booking

## Required Database Entities

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `service_categories`
- `services`
- `service_staff_assignments`
- `staff_profiles`
- `staff_working_hours`
- `staff_time_off`
- `company_locations`
- `company_members`
- `roles`
- `permissions`
- `role_permissions`

## API Requirements

- Provide appointment calendar API with tenant-scoped date range, staff, location, and status filters.
- Provide appointment detail API returning customer summary, services, assigned staff, location, status history, and timing details.
- Provide lightweight availability API that evaluates staff working hours, time off, service duration, and existing appointments.
- Provide create appointment API that writes `appointments`, `appointment_services`, and initial status history in one transaction.
- Provide update appointment API for rescheduling, service changes, staff changes, and location changes.
- Provide status transition API with allowed status transitions and reason capture.
- Provide cancellation API with cancellation reason and actor tracking.
- Provide no-show API with actor tracking.
- All APIs must validate active company membership and appointment module permissions.
- All APIs must reject cross-company references between appointment, customer, service, staff, and location records.
- APIs should be idempotent for create and update submissions where the frontend may retry.

## Edge Function Requirements

Use Edge Functions only for scheduling actions that need transactional conflict checks. Simple reads should use Supabase queries with RLS.

- `appointment-availability`
  - calculates available slots for a company, date, service, staff, and location
  - validates user membership and appointment read or create permission
  - excludes staff time off and existing conflicting appointments
  - returns only tenant-owned staff, services, and slots
- `appointment-write`
  - creates and updates appointments in a database transaction
  - validates tenant ownership for customer, services, staff, and location
  - blocks double-booking for active appointment statuses
  - writes service snapshots to `appointment_services`
  - writes status history entries
- `appointment-status-transition`
  - validates allowed status transitions
  - captures actor, reason, previous status, and new status
  - writes `appointment_status_history`

## Future Roadmap

- Recurring appointments.
- Waitlist management.
- Resource and room booking.
- Public booking flow.
- Calendar provider sync.
- Advanced availability rules by service, staff, and location.
- Customer self-rescheduling.
- Schedule capacity analytics.
