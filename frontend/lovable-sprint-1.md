# Casa Di Amo OS - Lovable Sprint 1 Build Guide

## Scope lock

Sprint 1 is P0 only. Build only:

1. Authentication
2. Dashboard
3. Customers
4. Appointments

Do not add extra navigation rooms, placeholder modules, roadmap links, outbound messaging builders, bulk-send surfaces, metric surfaces, future builders, or helper surfaces. The product should feel like a calm operating house for customers and appointments, with all data scoped to the active company from `company_members`.

## Lovable build principles

- Use React Router routes exactly as listed.
- Use Supabase Auth for sessions.
- Resolve tenant context after auth from `user_profiles -> company_members -> companies -> roles`.
- Never accept `company_id` from the URL or user input; derive it from the active company membership.
- Use the public Supabase client only with publishable/anon credentials.
- Use Edge Functions for transactional writes and aggregate reads that would otherwise be brittle in the client.
- Keep P0 language warm and operational: house, guests, schedule, memory, care, prepared.
- Use restrained visual direction: warm linen background, white cards, soft borders, one primary action per screen, generous spacing, sentence case.
- Mobile behavior is first-class: bottom navigation, card lists, single-column forms, and full-screen filter drawers.

## Shared app shell

### Auth layout

- Full viewport warm linen background.
- Centered card with Casa Di Amo wordmark, one-line promise, form, and footer links.
- No sidebar, top bar, or app navigation.
- Card max width: 440px desktop; full width with 24px margin on mobile.

### App layout

- Desktop: left sidebar, top bar, page header, content area, toast region, modal/drawer host.
- Tablet: collapsible sidebar.
- Mobile: bottom navigation with Dashboard, Customers, Appointments.
- Top bar shows company trading name, primary quick action `New appointment`, and profile menu with signed-in user and sign out.
- Hide actions the current role cannot perform. If a user is read-only, show a calm read-only note where actions would normally appear.

### Shared components

- `ProtectedRoute`: blocks unauthenticated access and redirects to `/auth/sign-in`.
- `TenantProvider`: loads profile, active membership, role, permissions, company, branding, and company settings.
- `AppShell`: owns navigation, top bar, responsive layout, and profile menu.
- `PageHeader`: title, description, primary action, optional secondary action.
- `StateView`: reusable empty, loading, error, and success state surface.
- `CasaFilter`: reusable URL-driven filter panel for Customers and Appointments.
- `MemoryCard`: compact customer context used on Customer Detail, New Appointment, and Appointment Detail.
- `StatusPill`: shared appointment and lifecycle status display.
- `PermissionGate`: hides or disables role-restricted actions.

## Shared Supabase guardrails

### Required tenant context queries

- `getCurrentUserProfile`: select `user_profiles` where `auth_user_id = auth.uid()`.
- `getActiveCompanyMembership`: select active `company_members` joined to `companies` and `roles`.
- `getUserPermissions`: select permissions through `role_permissions`.
- `getCompanyBranding`: select `company_branding` for the active company.
- `getCompanySettings`: select `company_settings` for scheduling defaults and locale/timezone.

### Required Edge Functions

- `create-company-owner-profile`: creates the first user profile, company, defaults, owner role, permissions, and membership after sign-up.
- `get-dashboard-summary`: returns dashboard counts, upcoming appointments, and attention items for the active company.
- `get-customer-memory-card`: returns customer identity, tags, notes summary, consent chips, latest past appointment, and next appointment.
- `create-appointment-with-services`: inserts appointment, service rows, and initial status history in one transaction.
- `update-appointment-with-services`: updates appointment fields, replaces service rows if needed, and appends status history when status changes.
- `update-appointment-status`: transitions appointment status and appends `appointment_status_history`.

### Status values to support

- Appointment: `scheduled`, `confirmed`, `completed`, `canceled`, `no_show`.
- Customer lifecycle: use existing values from data, default new customers to `lead`.
- Consent: show `granted`, `revoked`, `unknown` as chips only; no outbound messaging in Sprint 1.

---

# Module 1: Authentication

## Objective

Let users securely enter the right company workspace, create the first owner workspace for MVP testing, recover access, and sign out without exposing tenant data before membership is resolved.

## Routes

| Route | Screen | Access |
| --- | --- | --- |
| `/auth/sign-in` | Sign In | Public |
| `/auth/sign-up` | Sign Up | Public |
| `/auth/forgot-password` | Forgot Password | Public |
| `/auth/reset-password` | Reset Password | Public recovery session |
| `/app` | App redirect | Authenticated |
| `/app/no-access` | No Active Workspace | Authenticated without active membership |

## Layout

- Auth card centered on warm linen canvas.
- Use display serif for greeting headline and clean sans for form labels.
- Form fields are single column.
- Footer links connect sign in, sign up, and password recovery.
- After authentication, show a tenant-loading skeleton before rendering app chrome.

## Components

- `AuthLayout`
- `SignInForm`
- `SignUpForm`
- `ForgotPasswordForm`
- `ResetPasswordForm`
- `TenantLoadingState`
- `NoAccessState`
- `ProfileMenu`
- `SignOutButton`

## Supabase tables used

- `auth.users`
- `user_profiles`
- `companies`
- `company_settings`
- `company_branding`
- `roles`
- `permissions`
- `role_permissions`
- `company_members`
- `user_sessions_audit` optional for login/logout audit events

## Queries required

- `supabase.auth.signInWithPassword`
- `supabase.auth.signUp`
- `supabase.auth.resetPasswordForEmail`
- `supabase.auth.updateUser`
- `supabase.auth.signOut`
- `getCurrentUserProfile`
- `getActiveCompanyMembership`
- `getUserPermissions`
- `create-company-owner-profile`

## Empty states

- No active membership: "You do not have active workspace access yet." Include sign out action.
- Company inactive: "This workspace is unavailable right now." Include sign out action.
- Single active membership: skip company selection and enter Dashboard.

## Loading states

- Auth submit buttons disable and show "Signing in...", "Creating workspace...", or "Sending reset link...".
- App shell shows skeleton company name, sidebar, and page header while tenant context resolves.

## Success states

- Sign in redirects to `/app/dashboard`.
- Sign up shows "Workspace created. Welcome home." then redirects to `/app/dashboard`.
- Forgot password shows "Check your email for a secure reset link."
- Reset password shows "Password updated. You can continue."
- Sign out returns to `/auth/sign-in`.

## Error states

- Invalid credentials: inline form error.
- Weak password: field-level password error.
- Expired recovery link: show link back to Forgot Password.
- Profile exists but no active membership: route to `/app/no-access`.
- Tenant query failure: show retry and sign out actions.

## Mobile behavior

- Auth cards fill the viewport with comfortable 24px padding.
- Inputs and buttons are at least 44px high.
- Footer links stack.
- No bottom nav appears until authenticated app routes load.

## Acceptance criteria

- Unauthenticated users cannot access `/app/*`.
- Authenticated users without active membership cannot see app data.
- `company_id` is never accepted from route params.
- Owner sign-up creates a company workspace through the Edge Function.
- Every auth mutation has loading, success, and error states.

## Screens

### Sign In

**Exact Lovable prompt**

"Build the Casa Di Amo OS Sign In screen for P0. Use a centered warm, premium auth card on a linen background. Include the Casa Di Amo wordmark, headline 'Welcome back to your house', subcopy 'Run customers and appointments from one calm workspace.', email and password fields, primary button 'Sign in', forgot password link, and sign up link. Connect the form to Supabase Auth `signInWithPassword`. After sign-in, load `user_profiles`, active `company_members`, joined `companies`, `roles`, and permissions through `role_permissions`; then redirect to `/app/dashboard`. If there is no active membership, redirect to `/app/no-access`. Show inline errors, disabled loading state, and no app navigation on this public route."

**Data model dependencies**

- `auth.users`
- `user_profiles.auth_user_id`
- `company_members.user_profile_id`, `company_members.status`
- `companies.status`, `companies.trading_name`
- `roles.name`
- `role_permissions`, `permissions.permission_key`

**Required actions**

- Submit credentials.
- Resolve active tenant.
- Redirect on success.
- Link to Forgot Password.
- Link to Sign Up.

**Navigation behavior**

- Success: `/app/dashboard`.
- Forgot password: `/auth/forgot-password`.
- Sign up: `/auth/sign-up`.
- No access: `/app/no-access`.

### Sign Up

**Exact Lovable prompt**

"Build the P0 Sign Up screen for creating the first owner workspace. Use the same AuthLayout as Sign In. Fields: full name, work email, password, company name. Submit creates a Supabase Auth user, then calls the Edge Function `create-company-owner-profile` with full name, email, company name, and authenticated user id. The function creates `user_profiles`, `companies`, `company_settings`, `company_branding`, owner `roles`, permission mappings, and `company_members`. On success show a toast 'Workspace created. Welcome home.' and redirect to `/app/dashboard`. Keep the screen focused; do not add onboarding wizards or extra modules."

**Data model dependencies**

- `auth.users`
- `user_profiles`
- `companies`
- `company_settings`
- `company_branding`
- `roles`
- `permissions`
- `role_permissions`
- `company_members`

**Required actions**

- Create auth user.
- Create owner workspace through Edge Function.
- Resolve tenant context.
- Redirect to Dashboard.

**Navigation behavior**

- Success: `/app/dashboard`.
- Existing account link: `/auth/sign-in`.
- Failure after auth user creation: keep user on page with retry guidance.

### Forgot Password

**Exact Lovable prompt**

"Build the Forgot Password screen in the P0 auth layout. Include headline 'Reset your access', email field, primary button 'Send reset link', and return link to Sign In. Use Supabase Auth `resetPasswordForEmail` with redirect URL `/auth/reset-password`. On submit, disable the button and show loading. On success replace the form with a calm confirmation telling the user to check email. Do not reveal whether an email exists."

**Data model dependencies**

- Supabase Auth only.

**Required actions**

- Request reset email.
- Show success confirmation.
- Return to Sign In.

**Navigation behavior**

- Return link: `/auth/sign-in`.
- Recovery email deep link: `/auth/reset-password`.

### Reset Password

**Exact Lovable prompt**

"Build the Reset Password screen for a Supabase recovery session. Include new password, confirm password, primary button 'Update password', and link back to Sign In. Validate matching passwords client-side. Use `supabase.auth.updateUser({ password })`. Show expired-session error with an action to request a new reset link. On success show 'Password updated. You can continue.' and route authenticated users to `/app/dashboard`, otherwise to `/auth/sign-in`."

**Data model dependencies**

- Supabase Auth recovery session.

**Required actions**

- Validate password confirmation.
- Update password.
- Route based on session state.

**Navigation behavior**

- Success with session: `/app/dashboard`.
- Success without session: `/auth/sign-in`.
- Expired link action: `/auth/forgot-password`.

### No Active Workspace

**Exact Lovable prompt**

"Build a protected No Active Workspace state at `/app/no-access`. Show a simple centered card inside the app-safe background with title 'No active workspace access', body copy explaining the account is signed in but is not connected to an active house, and a primary action 'Sign out'. Do not show sidebar navigation or any tenant data. Use Supabase Auth sign out and clear tenant context."

**Data model dependencies**

- `user_profiles`
- `company_members`
- `companies`

**Required actions**

- Sign out.
- Retry tenant lookup.

**Navigation behavior**

- Sign out: `/auth/sign-in`.
- Retry success: `/app/dashboard`.

---

# Module 2: Dashboard

## Objective

Give authenticated company members a calm daily operating view: today's appointments, upcoming care, lightweight customer activity, and operational attention items.

## Routes

| Route | Screen | Access |
| --- | --- | --- |
| `/app/dashboard` | Dashboard | Authenticated company member |

## Layout

- App shell with sidebar on desktop and bottom nav on mobile.
- Page header with date-aware greeting and actions `New appointment` and `New customer`.
- Desktop content uses a 2x2 widget grid plus upcoming list.
- Mobile content stacks cards in this order: next appointment, today snapshot, upcoming appointments, customer activity, attention needed.

## Components

- `DashboardPage`
- `TodaySnapshotCard`
- `UpcomingAppointmentsCard`
- `CustomerActivityCard`
- `AttentionNeededCard`
- `DashboardQuickActions`
- `AppointmentPreviewRow`
- `EmptyDashboardState`

## Supabase tables used

- `appointments`
- `appointment_services`
- `customers`
- `customer_tags`
- `customer_tag_assignments`
- `services`
- `staff_profiles`
- `company_locations`

## Queries required

- `get-dashboard-summary`: aggregate counts for today, new customers this week, and attention items.
- `getUpcomingAppointments`: next 5 scheduled or confirmed appointments joined to customers, appointment services, staff, and location.
- `getCustomerActivity`: new customers this week, recently updated customers, customers missing phone/email/preferred channel.
- `getAttentionNeeded`: appointments without staff, canceled today, no-shows today, customers missing preferred channel.

## Empty states

- No appointments today: "No appointments today. Create the first booking."
- No customers yet: "Add your first guest so your house can begin to remember."
- No attention items: "You're caught up. The house is ready."

## Loading states

- Skeleton page header.
- Four widget skeleton cards.
- Upcoming appointments skeleton with 5 rows.

## Success states

- Dashboard data loads and reflects active company only.
- Quick actions navigate to creation screens.
- Clicking cards opens filtered list routes.

## Error states

- Aggregate failure: show "We could not load today's overview" with retry.
- Partial widget failure: show inline widget error without breaking whole page.
- Permission issue: show read-only dashboard data where possible.

## Mobile behavior

- Bottom nav highlights Dashboard.
- Cards stack vertically.
- Primary quick action becomes a sticky compact `New appointment` button.
- Appointment rows become tap-friendly cards.

## Acceptance criteria

- Dashboard never shows cross-company records.
- Counts match appointment statuses for the current company and current day in company timezone.
- Empty states provide one clear action.
- Every widget links to the authoritative Customers or Appointments route.
- No non-P0 modules appear in navigation or dashboard cards.

## Screens

### Dashboard

**Exact Lovable prompt**

"Build the P0 Dashboard screen at `/app/dashboard` for Casa Di Amo OS. Use the AppShell with sidebar items only Dashboard, Customers, and Appointments. Page title should greet the user by time of day and show the active company trading name. Add primary action 'New appointment' and secondary action 'New customer'. Build four calm cards: Today Snapshot, Upcoming Appointments, Customer Activity, and Attention Needed. Fetch summary data through `get-dashboard-summary` and list data through Supabase queries scoped by the active `company_id` from `company_members`. Today Snapshot shows appointment counts by status. Upcoming Appointments shows the next 5 appointments with time, guest name, service, staff, and status pill. Customer Activity shows new customers this week, recently updated customers, and missing contact details. Attention Needed shows appointments without staff, canceled today, no-shows today, and customers missing preferred channel. Add skeletons, warm empty states, inline retry errors, and responsive mobile cards. Do not add any extra modules or future widgets."

**Data model dependencies**

- `appointments.company_id`, `starts_at`, `ends_at`, `status`, `primary_staff_profile_id`, `company_location_id`
- `appointment_services.appointment_id`, `service_name`, `duration_at_booking_minutes`
- `customers.company_id`, `full_name`, `email`, `phone`, `preferred_channel`, `updated_at`, `created_at`
- `services.name`
- `staff_profiles.id`, `company_member_id`
- `company_locations.name`, `timezone`

**Required actions**

- Open `/app/appointments?date=today`.
- Open appointment detail.
- Open `/app/customers?missing=contact`.
- Open `/app/customers?missing=preferred_channel`.
- Open `/app/appointments/new`.
- Open `/app/customers/new`.
- Retry failed dashboard query.

**Navigation behavior**

- `New appointment`: `/app/appointments/new`.
- `New customer`: `/app/customers/new`.
- Today Snapshot click: `/app/appointments?date=today`.
- Upcoming appointment click: `/app/appointments/:appointmentId`.
- Customer activity click: `/app/customers` with matching query params.
- Attention item click: matching Customers or Appointments filtered route.

---

# Module 3: Customers

## Objective

Let staff create, find, understand, and update customer records with enough memory context to prepare for appointments.

## Routes

| Route | Screen | Access |
| --- | --- | --- |
| `/app/customers` | Customer List | Authenticated company member |
| `/app/customers/new` | New Customer | Create permission |
| `/app/customers/:customerId` | Customer Detail | Read permission |
| `/app/customers/:customerId/edit` | Edit Customer | Update permission |

## Layout

- Customer list uses page header, Casa Filter, and responsive list/table.
- Customer detail uses two-column layout on desktop: primary profile/timeline and Memory Card side panel.
- Forms are single column with grouped sections: identity, contact, preferences, notes, tags.
- Mobile turns lists into cards and detail into stacked sections.

## Components

- `CustomerListPage`
- `CustomerFormPage`
- `CustomerDetailPage`
- `CustomerForm`
- `CustomerCard`
- `CustomerTable`
- `CustomerStatusChip`
- `CustomerTagChips`
- `CustomerNotesPanel`
- `CustomerAppointmentsPanel`
- `MemoryCard`
- `CasaFilter`

## Supabase tables used

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `appointments`
- `appointment_services`
- `services`

## Queries required

- `listCustomers`: search by name/email/phone; filter by lifecycle status, customer type, tag, missing contact fields, and missing preferred channel.
- `getCustomerFilterOptions`: load active tags and distinct lifecycle/customer type values from current company records.
- `getCustomerDetail`: fetch customer, tags, notes, consent chips, upcoming appointments, and past appointments.
- `getCustomerMemoryCard`: compact customer context.
- `createCustomer`: insert customer and selected tag assignments.
- `updateCustomer`: update allowed fields and replace tag assignments.
- `createCustomerNote`: insert customer note with author membership.

## Empty states

- No customers: "Add your first guest so your house can begin to remember."
- No filter results: "No guests match these filters." Include clear filters action.
- No notes: "Every great relationship starts with one remembered detail." Include add note CTA.
- No appointment history: "No appointments yet." Include book appointment CTA.

## Loading states

- List: 5 skeleton rows/cards.
- Detail: header skeleton, Memory Card skeleton, notes skeleton.
- Form: disabled save button while mutation runs.
- Filter options: disabled selects with spinner.

## Success states

- Customer created: redirect to detail and toast "Guest added. Your house can remember them now."
- Customer updated: return to detail and toast "Guest details updated."
- Note added: append note and toast "Memory saved."
- Filters applied: update URL chips without toast.

## Error states

- List load failure: inline retry state.
- Customer not found: "We could not find this guest." Link to Customers.
- Validation failure: field-level errors.
- Mutation failure: keep user input and show retry.
- Unauthorized: show access denied without record details.

## Mobile behavior

- Sticky search at top of list.
- Casa Filter opens as full-screen drawer.
- Customer rows render as cards with phone/email, tags, and next appointment.
- Detail stacks Memory Card near top and collapses sections.
- Dirty forms show sticky bottom save action.

## Acceptance criteria

- Customer queries are always scoped to active company.
- Users can create a customer with name only; email and phone remain optional.
- Duplicate prevention is soft: show existing matches while typing email/phone, but do not block unless exact policy exists.
- Detail shows Memory Card, tags, notes, and appointments.
- Tag assignments are updated without orphaning cross-company data.

## Screens

### Customer List

**Exact Lovable prompt**

"Build the P0 Customer List screen at `/app/customers`. Use AppShell and PageHeader with title 'Customers', description 'People your house is learning to remember.', and primary action 'New customer'. Add a `CasaFilter` configured for customer search, lifecycle status, customer type, tags, missing contact details, and missing preferred channel. Persist filters in URL query params. Display customers as a spacious table on desktop and cards on mobile with full name, phone/email, lifecycle status, customer type, tags, and last updated date. Fetch `customers` joined through `customer_tag_assignments` and `customer_tags`, scoped to the active company. Add skeleton rows, no-customers empty state with CTA, no-results empty state with clear filters, and inline retry errors. Do not add import, segments, or any non-P0 actions."

**Data model dependencies**

- `customers.id`, `company_id`, `full_name`, `email`, `phone`, `lifecycle_status`, `customer_type`, `preferred_channel`, `updated_at`, `created_at`
- `customer_tags.id`, `name`, `color`, `status`
- `customer_tag_assignments.customer_id`, `customer_tag_id`

**Required actions**

- Search customers.
- Apply filters.
- Clear filters.
- Open customer detail.
- Navigate to New Customer.

**Navigation behavior**

- Primary action: `/app/customers/new`.
- Customer row/card click: `/app/customers/:customerId`.
- Filter changes stay on `/app/customers` and update query params.

### New Customer

**Exact Lovable prompt**

"Build the P0 New Customer screen at `/app/customers/new`. Use PageHeader title 'New customer' and a single-column form. Fields: full name required, email optional, phone optional, birthdate optional, lifecycle status default `lead`, source optional, preferred channel optional, customer type optional, notes summary optional, and tags selector from active `customer_tags`. On save, insert into `customers` with active `company_id`; then insert selected `customer_tag_assignments`. Show duplicate hints while typing email or phone by searching current-company customers. Disable save while submitting. On success redirect to the new customer detail and show toast 'Guest added. Your house can remember them now.'"

**Data model dependencies**

- `customers`
- `customer_tags`
- `customer_tag_assignments`

**Required actions**

- Create customer.
- Attach selected tags.
- Show duplicate hints.
- Cancel creation.

**Navigation behavior**

- Success: `/app/customers/:customerId`.
- Cancel: `/app/customers`.
- Tag selector remains on page; no tag management screen in Sprint 1.

### Customer Detail

**Exact Lovable prompt**

"Build the P0 Customer Detail screen at `/app/customers/:customerId`. Use a profile header with customer name, lifecycle status, customer type, and primary action 'Book appointment'. Add secondary action 'Edit customer'. Show reusable `MemoryCard` with identity, contact, preferred channel, tags, notes summary, pinned note, last appointment, next appointment, and consent chips. Main content sections: Contact details, Tags, Notes, Upcoming appointments, Past appointments. Notes can be added inline with body, visibility default `internal`, and optional pinned toggle. Appointment rows link to appointment detail. Fetch all data through current-company scoped queries and `get-customer-memory-card`. Add not-found, loading skeleton, no-notes, and no-appointment-history states."

**Data model dependencies**

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `appointments`
- `appointment_services`
- `services`

**Required actions**

- Edit customer.
- Add note.
- Pin/unpin note if permitted.
- Book appointment for this customer.
- Open appointment detail.
- Return to customer list.

**Navigation behavior**

- Edit: `/app/customers/:customerId/edit`.
- Book appointment: `/app/appointments/new?customerId=:customerId`.
- Appointment row: `/app/appointments/:appointmentId`.
- Back: `/app/customers`.

### Edit Customer

**Exact Lovable prompt**

"Build the P0 Edit Customer screen at `/app/customers/:customerId/edit`. Reuse the CustomerForm from New Customer and prefill current customer fields and tag assignments. Fields match New Customer. On save, update allowed `customers` fields for the active company and replace tag assignments only with tags belonging to the same company. Keep user input if save fails. On success return to Customer Detail and show toast 'Guest details updated.' Include Cancel button returning to detail."

**Data model dependencies**

- `customers`
- `customer_tags`
- `customer_tag_assignments`

**Required actions**

- Load existing customer.
- Update customer.
- Replace tag assignments.
- Cancel edit.

**Navigation behavior**

- Success: `/app/customers/:customerId`.
- Cancel: `/app/customers/:customerId`.
- Not found: `/app/customers` link in error state.

---

# Module 4: Appointments

## Objective

Let staff view the operating schedule, book appointments for customers, update appointment details, and move appointments through the P0 status lifecycle.

## Routes

| Route | Screen | Access |
| --- | --- | --- |
| `/app/appointments` | Appointment List/Calendar | Authenticated company member |
| `/app/appointments/new` | New Appointment | Create permission |
| `/app/appointments/:appointmentId` | Appointment Detail | Read permission |
| `/app/appointments/:appointmentId/edit` | Edit Appointment | Update permission |

## Layout

- Appointment list has day/week/list toggle, Casa Filter, and schedule content.
- Appointment form uses a guided order: customer, memory preview, service, staff, location, date/time, source.
- Appointment detail centers the booking summary and customer Memory Card.
- Mobile defaults to day agenda cards.

## Components

- `AppointmentListPage`
- `AppointmentFormPage`
- `AppointmentDetailPage`
- `AppointmentForm`
- `AppointmentCard`
- `AppointmentCalendar`
- `AppointmentAgendaList`
- `AppointmentStatusActions`
- `AppointmentStatusHistory`
- `CustomerPicker`
- `ServicePicker`
- `StaffPicker`
- `LocationPicker`
- `MemoryCard`
- `CasaFilter`

## Supabase tables used

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `services`
- `service_categories`
- `service_staff_assignments`
- `staff_profiles`
- `staff_working_hours`
- `staff_time_off`
- `company_locations`

## Queries required

- `listAppointments`: filter by date range, status, customer search, staff, service, and location.
- `getAppointmentFilterOptions`: statuses, active services, active staff, active locations.
- `getAppointmentDetail`: appointment joined to customer, services, staff, location, and status history.
- `searchCustomersForAppointment`: current-company customer lookup for picker.
- `getBookableServices`: active services where `booking_status = bookable`.
- `getActiveStaff`: active staff profiles joined to company members.
- `getActiveLocations`: active company locations.
- `getCustomerMemoryCard`: preview selected customer in booking and detail.
- `createAppointmentWithServices`: transactional appointment create.
- `updateAppointmentWithServices`: transactional appointment edit.
- `setAppointmentStatus`: status-only transitions.
- `checkAppointmentConflict`: detect overlapping appointments for selected staff before save.

## Empty states

- No appointments in date range: "No appointments here yet. Create the next booking."
- No filter results: "No appointments match these filters." Include clear filters action.
- No services configured: "A service is required before booking." Keep form blocked.
- No staff configured: allow booking without staff, but flag in Attention Needed.
- No locations configured: allow blank location only if company policy permits.

## Loading states

- Schedule: day/week skeleton blocks or 5 list skeleton cards.
- Form: customer/service/staff/location pickers show loading spinners.
- Detail: summary skeleton, Memory Card skeleton, status history skeleton.
- Mutations: disable duplicate submits and show "Saving...".

## Success states

- Appointment created: redirect to detail and toast "Appointment booked."
- Appointment updated: return to detail and toast "Appointment updated."
- Completed: update status pill, append history, toast "Appointment completed."
- Canceled: update status pill, append history, toast "Appointment canceled."
- No-show: update status pill, append history, toast "Marked as no-show."

## Error states

- Conflict: show field-level time/staff error and link to open conflicting appointment if available.
- Missing customer: block save with customer picker error.
- Missing service: block save with service picker error.
- Unauthorized status transition: hide action or show access denied.
- Mutation failure: keep form data and show retry.
- Not found: show "We could not find this appointment." Link to Appointments.

## Mobile behavior

- Bottom nav highlights Appointments.
- Default view is day agenda.
- Filters open as full-screen drawer.
- Appointment detail uses sticky bottom actions for edit, complete, cancel, no-show.
- Booking flow is single column; selected customer Memory Card collapses by default.

## Acceptance criteria

- Users can create, edit, complete, cancel, and mark no-show for appointments.
- Every appointment belongs to the active company and a current-company customer.
- Appointment create/edit writes `appointments`, `appointment_services`, and `appointment_status_history` consistently.
- Staff conflict warnings appear before saving overlapping appointments.
- Lists support date, status, customer, staff, service, and location filters.

## Screens

### Appointment List/Calendar

**Exact Lovable prompt**

"Build the P0 Appointment List/Calendar screen at `/app/appointments`. Use PageHeader title 'Appointments', description 'The rhythm of the house today.', and primary action 'New appointment'. Add view toggle Day, Week, List with Day as mobile default and List as accessible fallback. Add `CasaFilter` configured for date range, status, customer search, staff, service, and location. Persist filters in URL query params. Fetch `appointments` joined to `customers`, `appointment_services`, `services`, `staff_profiles`, and `company_locations`, scoped to active company. Display status pills and appointment cards with time, guest, service, staff, location, and status. Add skeletons, no-appointments empty state, no-results state with clear filters, and inline retry errors. Do not add reminders, waitlists, external calendar sync, or non-P0 schedule features."

**Data model dependencies**

- `appointments.id`, `company_id`, `customer_id`, `company_location_id`, `primary_staff_profile_id`, `status`, `source`, `starts_at`, `ends_at`, `no_show`
- `appointment_services.appointment_id`, `service_id`, `service_name`, `duration_at_booking_minutes`
- `customers.full_name`, `phone`, `preferred_channel`
- `services.name`
- `staff_profiles.id`, `company_member_id`
- `company_locations.name`, `timezone`

**Required actions**

- Toggle day/week/list.
- Change date range.
- Apply filters.
- Clear filters.
- Open appointment detail.
- Create appointment.

**Navigation behavior**

- Primary action: `/app/appointments/new`.
- Appointment click: `/app/appointments/:appointmentId`.
- Customer name click if exposed: `/app/customers/:customerId`.
- Filter changes update `/app/appointments` query params.

### New Appointment

**Exact Lovable prompt**

"Build the P0 New Appointment screen at `/app/appointments/new`. Use a guided single-column form: customer picker, inline customer Memory Card preview, service picker, staff picker optional, location picker optional, start date/time, end date/time or duration, source, and status default `scheduled`. If URL has `customerId`, preselect that customer and load `get-customer-memory-card`. Customer picker searches current-company customers and includes a lightweight 'Create customer' modal with full name, email, and phone only. Service picker loads active bookable services and uses duration to calculate default end time. Before save, check for overlapping appointments for selected staff. On save call `create-appointment-with-services` to insert appointment, appointment service rows, and initial status history. On success redirect to detail with toast 'Appointment booked.'"

**Data model dependencies**

- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `services`
- `staff_profiles`
- `company_locations`
- `appointments`
- `appointment_services`
- `appointment_status_history`

**Required actions**

- Search/select customer.
- Create lightweight customer if needed.
- Load Memory Card for selected customer.
- Select service.
- Calculate end time.
- Select optional staff and location.
- Check conflict.
- Create appointment transaction.

**Navigation behavior**

- Success: `/app/appointments/:appointmentId`.
- Cancel: `/app/appointments`.
- Customer profile link in Memory Card: `/app/customers/:customerId`.

### Appointment Detail

**Exact Lovable prompt**

"Build the P0 Appointment Detail screen at `/app/appointments/:appointmentId`. Show appointment summary with status pill, date/time, service, staff, location, source, and customer. Embed customer `MemoryCard` near the top. Add status history timeline from `appointment_status_history`. Actions: Edit appointment, Mark completed, Cancel appointment, Mark no-show, Open customer profile. Status actions call `update-appointment-status` and append history. Hide invalid actions based on current status: completed/canceled/no-show should not show other terminal transitions. Add loading skeleton, not-found state, unauthorized state, and mutation error retry. Keep copy calm and operational."

**Data model dependencies**

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `customer_notes`
- `customer_tags`
- `customer_tag_assignments`
- `customer_consents`
- `services`
- `staff_profiles`
- `company_locations`

**Required actions**

- Edit appointment.
- Complete appointment.
- Cancel appointment with optional reason.
- Mark no-show.
- Open customer profile.
- Return to schedule.

**Navigation behavior**

- Edit: `/app/appointments/:appointmentId/edit`.
- Open customer: `/app/customers/:customerId`.
- Back: `/app/appointments`.
- Status mutation success remains on detail and refreshes summary/history.

### Edit Appointment

**Exact Lovable prompt**

"Build the P0 Edit Appointment screen at `/app/appointments/:appointmentId/edit`. Reuse the AppointmentForm from New Appointment and prefill customer, services, staff, location, start/end time, source, and current status. Customer can be changed only to another current-company customer. If service changes, replace `appointment_services` with current selected service data. If status changes, append `appointment_status_history`. Before save, run the same staff overlap conflict check excluding the current appointment id. On success return to detail with toast 'Appointment updated.' Include Cancel returning to detail."

**Data model dependencies**

- `appointments`
- `appointment_services`
- `appointment_status_history`
- `customers`
- `services`
- `staff_profiles`
- `company_locations`

**Required actions**

- Load existing appointment.
- Update appointment fields.
- Replace service rows if changed.
- Append status history if status changed.
- Check staff conflict.
- Cancel edit.

**Navigation behavior**

- Success: `/app/appointments/:appointmentId`.
- Cancel: `/app/appointments/:appointmentId`.
- Not found: link to `/app/appointments`.

---

# Sprint 1 Lovable build order

1. Create theme tokens, AuthLayout, AppShell, route skeletons, and navigation with only Dashboard, Customers, and Appointments.
2. Connect Supabase client with public credentials.
3. Build Supabase Auth screens and tenant context provider.
4. Build protected route guard and no-access state.
5. Build shared state components, status pills, permission gate, toast region, and responsive shell.
6. Build Customer List with Casa Filter.
7. Build New Customer and Edit Customer forms.
8. Build Customer Detail, notes, appointments panels, and Memory Card.
9. Build Appointment List/Calendar with Casa Filter.
10. Build New Appointment with customer picker, Memory Card preview, service duration defaults, and conflict warning.
11. Build Appointment Detail and status transitions.
12. Build Edit Appointment.
13. Build Dashboard from real active-company data.
14. Add all empty, loading, success, and error states.
15. Test desktop, tablet, and mobile responsive behavior.
16. Remove any generated nav items, placeholder screens, or future-scope references before handoff.

# Final Lovable master prompt

"Build Casa Di Amo OS Sprint 1 P0 only using `/frontend/lovable-sprint-1.md` as the source of truth. Create a React + TypeScript Lovable app with Supabase Auth, protected tenant-scoped app shell, Dashboard, Customers, and Appointments. Use the exact routes, layouts, components, Supabase tables, queries, states, mobile behavior, and acceptance criteria in the guide. Resolve active company from `company_members`; never trust `company_id` from the URL. Use Edge Functions for owner workspace creation, dashboard summary, customer memory card, appointment create/update, and appointment status transitions. Keep navigation limited to Dashboard, Customers, and Appointments. Do not generate extra modules, placeholders, or future-scope screens."
