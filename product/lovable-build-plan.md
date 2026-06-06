# Casa Di Amo OS MVP Lovable Build Plan

## 0. Source and scope guardrails

This blueprint is optimized for building the Casa Di Amo OS MVP in Lovable.

Requested product source files were not present in this checkout:

- `/product/mvp-phasing.md`
- `/product/mvp-ux-specification.md`
- `/product/casa-di-amo-os-brand-core-v2.md`
- `/product/design-direction.md`

Available sources used:

- `README.md`
- `database/schema.sql`
- `database/erd.md`
- `database/database-architecture.md`
- `database/rls-strategy.md`
- `docs/multi-tenancy-strategy.md`
- `docs/rbac-model.md`
- `docs/compliance-lgpd.md`

P0 includes only the minimum tenant-facing operating system needed to run customer and appointment workflows:

- Supabase Auth.
- Company tenant context.
- Dashboard.
- Customers.
- Appointments.
- Customer Memory Card.
- Casa Filter.
- Basic profile and sign-out.
- Operational empty, loading, success, and error states.

P0 excludes CRM pipelines, marketing campaigns, automations, payments, reports builder, files, platform admin, external integrations, AI generation, billing screens, compliance workflows, team management UI, and advanced settings.

## 1. MVP P0 product definition

### P0 user roles

Use the existing RBAC model, but expose only these P0 behaviors:

- Company Owner: can read, create, and update P0 customers and appointments.
- Manager: can read, create, and update P0 customers and appointments.
- Employee: can read records, create customers, create appointments, and update assigned appointments if assignment data exists.
- Viewer: can read records only.

### P0 success path

1. User signs in.
2. App resolves their active `company_members` record.
3. User lands on Dashboard.
4. User reviews today's appointments and customer activity.
5. User creates or opens a customer.
6. User uses Memory Card to understand the customer quickly.
7. User schedules, reschedules, completes, cancels, or marks no-show for an appointment.
8. User uses Casa Filter to narrow customer and appointment lists.

## 2. Application sitemap

- Public auth
  - Sign in
  - Sign up
  - Forgot password
  - Reset password
- App shell
  - Dashboard
  - Customers
    - Customer list
    - New customer
    - Customer detail
    - Edit customer
  - Appointments
    - Appointment calendar/list
    - New appointment
    - Appointment detail
    - Edit appointment
  - Profile menu
    - Basic profile summary
    - Sign out

## 3. Route structure

Use React Router inside Lovable.

| Route | Screen | Access |
| --- | --- | --- |
| `/auth/sign-in` | Sign In | Public |
| `/auth/sign-up` | Sign Up | Public |
| `/auth/forgot-password` | Forgot Password | Public |
| `/auth/reset-password` | Reset Password | Public |
| `/app` | Redirect to `/app/dashboard` | Authenticated |
| `/app/dashboard` | Dashboard | Authenticated company member |
| `/app/customers` | Customer List | Authenticated company member |
| `/app/customers/new` | New Customer | Create permission |
| `/app/customers/:customerId` | Customer Detail | Read permission |
| `/app/customers/:customerId/edit` | Edit Customer | Update permission |
| `/app/appointments` | Appointment Calendar/List | Authenticated company member |
| `/app/appointments/new` | New Appointment | Create permission |
| `/app/appointments/:appointmentId` | Appointment Detail | Read permission |
| `/app/appointments/:appointmentId/edit` | Edit Appointment | Update permission |

Route rules:

- Redirect unauthenticated users to `/auth/sign-in`.
- Redirect authenticated users without active company membership to an access error state.
- Never trust a URL `company_id`; derive company context from authenticated membership.
- Use one active company context for all P0 queries.

## 4. Layout structure

### Auth layout

Purpose: focused entry into the product.

Components:

- Centered auth card.
- Casa Di Amo wordmark.
- Short promise line: "Run customers and appointments from one calm workspace."
- Form content.
- Footer link between sign-in, sign-up, and password recovery.

Behavior:

- Full viewport.
- No sidebar.
- Mobile-first card width.

### App layout

Purpose: persistent operational shell for daily work.

Components:

- Left sidebar.
- Top bar.
- Page header.
- Content container.
- Toast notification region.
- Modal/drawer host.

Top bar:

- Current company trading name.
- Global quick action: "New appointment".
- Profile menu with user name and sign out.

Content rules:

- Desktop max width: fluid content with comfortable spacing.
- Tables convert to cards on small screens.
- Primary actions stay visible near page title.

## 5. Sidebar navigation

P0 sidebar items:

1. Dashboard: `/app/dashboard`
2. Customers: `/app/customers`
3. Appointments: `/app/appointments`

Sidebar footer:

- Signed-in user name.
- Active role label.
- Sign out action.

Do not show disabled roadmap navigation items in P0. Avoid teasing CRM, Marketing, Automations, Reports, Integrations, or Billing.

## 6. Dashboard widgets

### Dashboard screen

Purpose: provide the daily operating command center after sign-in.

Components:

- Page header with date-aware greeting.
- Today Snapshot widget.
- Upcoming Appointments widget.
- Customer Activity widget.
- Attention Needed widget.
- Primary action button: "New appointment".
- Secondary action button: "New customer".

Actions:

- Open today's appointment list.
- Open an upcoming appointment.
- Open a filtered customer list.
- Create appointment.
- Create customer.

Data dependencies:

- `appointments`
- `appointment_services`
- `customers`
- `customer_tags`
- `customer_tag_assignments`
- `services`
- `staff_profiles`

### Widget 1: Today Snapshot

Purpose: show the operating status for the current day.

Components:

- Total appointments today.
- Scheduled count.
- Completed count.
- Canceled/no-show count.

Actions:

- Click widget to open `/app/appointments?date=today`.

Data dependencies:

- `appointments`
- `appointment_services`
- `customers`

### Widget 2: Upcoming Appointments

Purpose: give staff the next work items.

Components:

- Next 5 appointments.
- Time.
- Customer name.
- Service name.
- Status pill.

Actions:

- Open appointment detail.
- Create appointment.

Data dependencies:

- `appointments`
- `appointment_services`
- `customers`
- `services`

### Widget 3: Customer Activity

Purpose: show lightweight CRM without adding CRM scope.

Components:

- New customers this week.
- Recently updated customers.
- Customers missing phone or email.

Actions:

- Open filtered customer list.
- Create customer.

Data dependencies:

- `customers`
- `customer_tags`
- `customer_tag_assignments`

### Widget 4: Attention Needed

Purpose: highlight records that need operational action.

Components:

- Appointments without assigned staff.
- Customers without preferred channel.
- Appointments canceled today.

Actions:

- Open matching Casa Filter result.

Data dependencies:

- `appointments`
- `customers`
- `staff_profiles`

## 7. Shared P0 components

### Memory Card

Purpose: a compact customer intelligence card shown on customer detail, appointment detail, and appointment creation.

Components:

- Customer identity: full name, lifecycle status, customer type.
- Contact row: phone, email, preferred channel.
- Tags row.
- Notes summary.
- Last appointment.
- Next appointment.
- Pinned note.
- Consent chips for P0 communication context.

Actions:

- Call customer.
- Email customer.
- Open full customer profile.
- Add note.
- Edit summary fields.

Data dependencies:

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `appointments`
- `appointment_services`

Implementation:

- Build `MemoryCard` as a reusable component.
- Accept `customerId` and optional preloaded `customer`.
- Fetch related data with `get-customer-memory-card`.
- Keep summary manual in P0 using `customers.notes_summary`; do not generate AI summaries.
- Show skeleton rows while loading.
- Show "No customer memory yet" when there are no notes, tags, or appointments.

### Casa Filter

Purpose: reusable filter panel for P0 list screens.

Components:

- Search input.
- Status select.
- Date range picker for appointment screens.
- Customer type select.
- Lifecycle status select.
- Tag multi-select.
- Staff select for appointment screens.
- Service select for appointment screens.
- Clear filters button.
- Applied filter chips.

Actions:

- Apply filters.
- Clear one filter.
- Clear all filters.
- Persist list filter state in URL query params.

Data dependencies:

- `customers`
- `customer_tags`
- `staff_profiles`
- `services`
- `appointments`

Implementation:

- Build `CasaFilter` as a shared component.
- Use route-specific filter config.
- Use URL params as the source of truth.
- Debounce text search.
- Never construct SQL strings in the client; map params to Supabase query builder calls or Edge Function request bodies.

## 8. Authentication screens

### Sign In

Purpose: let existing users enter the tenant app.

Components:

- Email field.
- Password field.
- Submit button.
- Forgot password link.
- Sign up link.

Actions:

- Sign in with Supabase Auth.
- Resolve active `user_profiles` and `company_members`.
- Redirect to `/app/dashboard`.

Data dependencies:

- Supabase Auth session.
- `user_profiles`
- `company_members`
- `companies`
- `roles`

### Sign Up

Purpose: create the first owner user and first company for MVP testing.

Components:

- Full name field.
- Work email field.
- Password field.
- Company name field.
- Submit button.

Actions:

- Create Supabase Auth user.
- Call `create-company-owner-profile`.
- Redirect to dashboard after session and tenant are ready.

Data dependencies:

- Supabase Auth.
- `user_profiles`
- `companies`
- `company_settings`
- `company_branding`
- `roles`
- `permissions`
- `role_permissions`
- `company_members`

### Forgot Password

Purpose: start password recovery.

Components:

- Email field.
- Submit button.
- Return to sign in link.

Actions:

- Call Supabase password reset email.
- Show success confirmation.

Data dependencies:

- Supabase Auth.

### Reset Password

Purpose: complete password recovery.

Components:

- New password field.
- Confirm password field.
- Submit button.

Actions:

- Update Supabase Auth password.
- Redirect to sign in or dashboard based on session.

Data dependencies:

- Supabase Auth recovery session.

## 9. Customer screens

### Customer List

Purpose: browse and find customers fast.

Components:

- Page header with "New customer".
- Casa Filter configured for customers.
- Customer cards/table.
- Status chips.
- Tag chips.
- Pagination or "Load more".

Actions:

- Search customers.
- Filter by lifecycle, customer type, tags, missing contact details.
- Open customer detail.
- Create customer.

Data dependencies:

- `customers`
- `customer_tags`
- `customer_tag_assignments`

### New Customer

Purpose: create a clean company-scoped customer record.

Components:

- Full name.
- Email.
- Phone.
- Birthdate.
- Lifecycle status.
- Source.
- Preferred channel.
- Customer type.
- Notes summary.
- Tags selector.
- Save button.

Actions:

- Insert customer.
- Attach selected tags.
- Redirect to customer detail.

Data dependencies:

- `customers`
- `customer_tags`
- `customer_tag_assignments`

### Customer Detail

Purpose: provide the operational home for a customer.

Components:

- Customer header.
- Memory Card.
- Contact details panel.
- Tags panel.
- Notes list.
- Upcoming appointments.
- Past appointments.

Actions:

- Edit customer.
- Add note.
- Add/remove tag.
- Create appointment for this customer.
- Open appointment detail.

Data dependencies:

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `appointments`
- `appointment_services`
- `services`

### Edit Customer

Purpose: update customer profile fields safely.

Components:

- Same fields as New Customer.
- Save button.
- Cancel button.

Actions:

- Update customer.
- Update tag assignments.
- Return to detail.

Data dependencies:

- `customers`
- `customer_tags`
- `customer_tag_assignments`

## 10. Appointment screens

### Appointment Calendar/List

Purpose: manage the operating schedule.

Components:

- Page header with "New appointment".
- View toggle: Day, Week, List.
- Casa Filter configured for appointments.
- Appointment list or calendar cards.
- Status pills.

Actions:

- Filter by date, status, customer, staff, service.
- Open appointment detail.
- Create appointment.
- Move between day/week ranges.

Data dependencies:

- `appointments`
- `appointment_services`
- `customers`
- `services`
- `staff_profiles`
- `company_locations`

### New Appointment

Purpose: schedule an appointment for an existing or newly created customer.

Components:

- Customer picker.
- Inline Memory Card preview.
- Service picker.
- Staff picker.
- Location picker.
- Start date/time.
- End date/time or duration.
- Source.
- Status defaulted to `scheduled`.
- Save button.

Actions:

- Search/select customer.
- Create customer if needed through a lightweight modal.
- Select service and calculate default end time.
- Insert appointment transaction.
- Insert appointment service rows.
- Insert initial appointment status history.
- Redirect to appointment detail.

Data dependencies:

- `customers`
- `services`
- `staff_profiles`
- `company_locations`
- `appointments`
- `appointment_services`
- `appointment_status_history`

### Appointment Detail

Purpose: show one booking and allow operational status changes.

Components:

- Appointment summary.
- Status pill.
- Customer Memory Card.
- Service details.
- Staff/location details.
- Status history.

Actions:

- Edit appointment.
- Mark completed.
- Cancel appointment.
- Mark no-show.
- Open customer profile.

Data dependencies:

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `services`
- `staff_profiles`
- `company_locations`

### Edit Appointment

Purpose: reschedule or update appointment details.

Components:

- Same fields as New Appointment.
- Current status.
- Save button.
- Cancel button.

Actions:

- Update appointment.
- Replace appointment service rows if service changes.
- Append status history when status changes.
- Return to detail.

Data dependencies:

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `services`
- `staff_profiles`
- `company_locations`

## 11. Required Supabase tables for P0

### Auth and tenant context

- `auth.users`
- `user_profiles`
- `companies`
- `company_settings`
- `company_branding`
- `roles`
- `permissions`
- `role_permissions`
- `company_members`

### Customers

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`

### Appointments and service catalog

- `company_locations`
- `staff_profiles`
- `staff_working_hours`
- `services`
- `service_categories`
- `service_staff_assignments`
- `appointments`
- `appointment_services`
- `appointment_status_history`

### Optional P0 audit support

- `audit_logs`
- `user_sessions_audit`

Do not require P0 UI for tables outside this list.

## 12. Required Supabase queries

All queries must be scoped to the active company derived from `company_members`.

### Session and tenant

- `getCurrentUserProfile`: select `user_profiles` by `auth_user_id = auth.uid()`.
- `getActiveCompanyMembership`: select active `company_members` with joined `companies` and `roles`.
- `getUserPermissions`: select permissions through `role_permissions`.

### Dashboard

- `getDashboardSummary`: counts appointments by status for today and counts new customers for current week.
- `getUpcomingAppointments`: next 5 scheduled appointments with customer and service data.
- `getAttentionNeeded`: appointments missing staff, customers missing preferred channel, canceled appointments today.

### Customers

- `listCustomers`: filter by search, lifecycle status, customer type, tag, and missing contact fields.
- `getCustomerDetail`: fetch customer, tags, notes, upcoming appointments, and past appointments.
- `createCustomer`: insert into `customers`; insert `customer_tag_assignments` when selected.
- `updateCustomer`: update allowed customer fields; replace tag assignments when changed.
- `createCustomerNote`: insert into `customer_notes`.

### Memory Card

- `getCustomerMemoryCard`: fetch customer summary, tags, latest pinned note, latest past appointment, next appointment, and consent chips.

### Appointments

- `listAppointments`: filter by date range, status, customer, staff, service, and search.
- `getAppointmentDetail`: fetch appointment with customer, services, staff, location, and status history.
- `createAppointmentWithServices`: create appointment plus related service and history rows.
- `updateAppointmentWithServices`: update appointment, services, and status history when status changes.
- `setAppointmentStatus`: update status and append `appointment_status_history`.

### Casa Filter option loaders

- `getCustomerFilterOptions`: lifecycle values from current records, customer types from current records, active tags.
- `getAppointmentFilterOptions`: appointment statuses, active staff, active services, active locations.

## 13. Required Edge Functions

Use Edge Functions for transactional writes, aggregate data, and service-role work. Do not expose service-role keys to Lovable frontend code.

### `create-company-owner-profile`

Purpose: create the initial tenant after sign-up.

Inputs:

- `auth_user_id`
- `full_name`
- `email`
- `company_name`

Work:

- Validate authenticated user.
- Create `user_profiles`.
- Create `companies`.
- Create default `company_settings`.
- Create default `company_branding`.
- Create default Company Owner role and permission mappings.
- Create `company_members`.

Returns:

- `company_id`
- `company_member_id`
- `role`

### `get-dashboard-summary`

Purpose: return P0 dashboard aggregates without heavy client-side counting.

Inputs:

- Active company context.
- Optional date.

Work:

- Validate membership.
- Count today appointments by status.
- Count new customers this week.
- Return upcoming appointment preview.

Returns:

- Dashboard summary object.

### `get-customer-memory-card`

Purpose: return the compact customer context used across screens.

Inputs:

- `customer_id`

Work:

- Validate membership and customer company ownership.
- Fetch customer, tags, pinned note, latest past appointment, next appointment, and consent chips.

Returns:

- Memory Card payload.

### `create-appointment-with-services`

Purpose: safely create an appointment and required child records in one transaction.

Inputs:

- `customer_id`
- `service_ids`
- `primary_staff_profile_id`
- `company_location_id`
- `starts_at`
- `ends_at`
- `source`

Work:

- Validate membership and appointment create permission.
- Validate all referenced records belong to the same company.
- Insert `appointments`.
- Insert `appointment_services`.
- Insert initial `appointment_status_history`.

Returns:

- `appointment_id`

### `update-appointment-status`

Purpose: perform status transitions consistently.

Inputs:

- `appointment_id`
- `to_status`
- `reason`

Work:

- Validate membership and update permission.
- Validate appointment ownership.
- Update appointment status, `cancellation_reason`, and `no_show` as applicable.
- Insert `appointment_status_history`.

Returns:

- Updated appointment summary.

## 14. Responsive behavior

### Desktop

- Sidebar remains visible.
- Dashboard uses 2x2 widget grid.
- Customer and appointment list use table layout.
- Detail pages use two columns: primary content and Memory Card side panel.

### Tablet

- Sidebar can collapse to icons.
- Dashboard uses two columns.
- Detail pages stack secondary panels below primary header.

### Mobile

- Sidebar becomes bottom navigation with Dashboard, Customers, Appointments.
- Top bar keeps company name and profile menu.
- Lists render as cards.
- Casa Filter opens as a full-screen drawer.
- Forms use single column.
- Primary save action is sticky at bottom when form is dirty.
- Memory Card appears near the top and collapses to sections.

## 15. Empty states

### Dashboard

- No appointments today: "No appointments today. Create the first booking."
- No customers yet: "Add your first customer to start building memory."

### Customers

- No customers: show create customer CTA.
- No filter results: show clear filters action.
- No notes: show add note CTA.
- No tags: show tag creation prompt only inside customer flow.

### Appointments

- No appointments in date range: show create appointment CTA.
- No filter results: show clear filters action.
- No services configured: show message that a service is required before booking.
- No staff configured: allow appointment creation without assigned staff, but flag it in Attention Needed.

### Memory Card

- No memory yet: show "No notes, tags, or appointment history yet."

## 16. Loading states

- Auth forms: disable submit and show button spinner.
- App shell: show tenant context skeleton until profile and membership resolve.
- Dashboard: show widget skeletons.
- Lists: show 5 skeleton rows/cards.
- Detail pages: show header skeleton and content skeleton.
- Memory Card: show compact skeleton lines.
- Casa Filter option loaders: show disabled filter fields with spinner.
- Mutations: disable duplicate submits and show "Saving..." state.

## 17. Success states

- Sign in: redirect to dashboard.
- Sign up: show short "Workspace created" toast, then dashboard.
- Customer created: redirect to detail and show toast.
- Customer updated: stay on detail and show toast.
- Note added: append note and show toast.
- Appointment created: redirect to detail and show toast.
- Appointment updated: stay on detail and show toast.
- Appointment status changed: update status pill, append history row, and show toast.
- Filters applied: update URL chips and list results without toast.

## 18. Error states

### Auth errors

- Invalid credentials: show inline form error.
- Password reset expired: show reset link action.

### Tenant access errors

- No active membership: show "No active workspace access" with sign out action.
- Company inactive: show "Workspace unavailable" with sign out action.
- Missing permission: show read-only fallback where possible; otherwise show access denied.

### Data errors

- Not found: show record not found and return action.
- Cross-tenant or unauthorized response: show access denied without record details.
- Validation error: show field-level errors.
- Mutation failure: keep user input and show retry CTA.
- Edge Function failure: show friendly message and log correlation id when available.

## 19. Build order for Lovable

1. Create project theme, auth layout, app layout, and route skeletons.
2. Connect Supabase client using public project URL and publishable/anon key.
3. Build Supabase Auth screens.
4. Build tenant context provider from `user_profiles`, `company_members`, `companies`, and `roles`.
5. Build sidebar, top bar, protected route guard, and permission helper.
6. Build Customer List with Casa Filter.
7. Build New Customer and Edit Customer forms.
8. Build Customer Detail with Memory Card and notes.
9. Build Appointment Calendar/List with Casa Filter.
10. Build New Appointment flow with Memory Card preview.
11. Build Appointment Detail and status transitions.
12. Build Dashboard widgets from real Supabase data.
13. Add Edge Functions for transactional appointment creation and status updates.
14. Add empty, loading, success, and error states across all P0 screens.
15. Test responsive behavior on desktop, tablet, and mobile.
16. Remove placeholder content and hidden roadmap links before MVP handoff.

## 20. Lovable implementation prompt

Use this prompt inside Lovable after Supabase is connected:

"Build Casa Di Amo OS P0 only. Create a tenant-scoped service business operating system with Supabase Auth, protected app shell, Dashboard, Customers, Appointments, Memory Card, and Casa Filter. Do not add CRM, Marketing, Automations, Reports, Payments, Integrations, Billing, Platform Admin, or AI generation screens. Use the routes, tables, queries, edge functions, states, and responsive behavior from `/product/lovable-build-plan.md`. Keep all data scoped to the active company from `company_members`. Never expose service-role credentials in frontend code."
