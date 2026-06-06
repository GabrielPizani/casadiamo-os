# Authentication PRD

## Module

Authentication.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## MVP Launch Scope

- Email and password login.
- Password reset.
- Invitation acceptance for Amo Beauty Lab staff.
- Single active company context by default.
- Role-aware navigation for Owner, Manager, Employee, and Viewer.
- Session persistence and sign out.

## Product Validation

Authentication is successful when Amo Beauty Lab staff can get into the app without help, land in the correct company context, and see only the navigation their role allows.

## Business Objective

Give Amo Beauty Lab staff secure access to Casa Di Amo OS with the correct company context, role, and session state before they can use operational modules.

The MVP must be simple enough for daily salon operations while preserving the multi-tenancy and RBAC model already defined in the database.

## User Personas

- Company Owner: owns Amo Beauty Lab, invites team members, and controls access.
- Manager: supervises day-to-day operations and needs broad access without ownership controls.
- Employee: serves customers and needs quick access to daily work.
- Viewer: reviews permitted information without editing records.

## User Stories

- As a staff user, I want to sign in with email and password so I can start work quickly.
- As a staff user, I want to reset my password so I can recover access without admin help.
- As a staff user, I want my session to persist across browser refreshes so I do not lose work.
- As an Amo Beauty Lab user, I want the app to open directly in Amo Beauty Lab so there is no tenant-selection friction in V1.
- As a Company Owner, I want to invite staff by email and role so new team members receive the correct access.
- As an invited staff member, I want to accept an invitation and complete my profile so I can join Amo Beauty Lab.
- As a Company Owner, I want suspended or removed staff to lose access immediately.
- As a user, I want navigation to match my role so I see only relevant actions.

## Acceptance Criteria

- Users can sign in, sign out, and reset passwords through Supabase Auth.
- A signed-in user cannot enter the app without an active `user_profiles` record.
- A signed-in user cannot view tenant data without an active `company_members` record.
- Amo Beauty Lab is selected automatically when it is the user's only active company.
- Multi-company switching is not required for the first launch, but all access checks still use `company_members`.
- The active company context is validated against server-side membership data, not only client state.
- Role-based navigation is derived from `roles`, `permissions`, and `role_permissions`.
- Pending, expired, suspended, removed, or archived memberships cannot access tenant modules.
- Company invitations can be created only by users with member invitation permission.
- Accepted invitations create or connect a `user_profiles` record and an active `company_members` record.
- Authentication-sensitive events are recorded in `user_sessions_audit`.
- Frontend route guards are treated as UX only; database and API checks remain authoritative.

## Navigation

- Public routes:
  - `/login`
  - `/forgot-password`
  - `/reset-password`
  - `/accept-invitation`
- Authenticated shell:
  - default company context for Amo Beauty Lab
  - profile menu with profile settings and sign out
- Owner and Manager access:
  - team invitation entry point
- Blocked states:
  - no active company access
  - invitation expired
  - membership suspended
  - company inactive

## Required Database Entities

- `auth.users`
- `user_profiles`
- `companies`
- `company_members`
- `company_invitations`
- `roles`
- `permissions`
- `role_permissions`
- `user_sessions_audit`

## API Requirements

- Use Supabase Auth client APIs for sign-in, sign-out, session refresh, and password reset.
- Provide a current-user query returning:
  - application profile
  - active Amo Beauty Lab membership
  - effective role and permissions
- Provide invitation management APIs:
  - create invitation
  - list pending invitations
  - revoke invitation
  - accept invitation
- All tenant-scoped API responses must require a validated company context.
- Permission checks must be enforced server-side for invitation and access-management actions.
- APIs must never expose service-role credentials, password hashes, or raw authentication secrets.
- APIs must return safe blocked-state errors without disclosing unrelated tenant data.

## Edge Function Requirements

Keep Edge Functions limited to flows that need trusted server-side logic. Use Supabase Auth and RLS directly wherever possible.

- `accept-company-invitation`
  - validates invitation token, expiration, invitation status, and target company status
  - creates or links `user_profiles`
  - creates or activates `company_members`
  - records the session event when needed
- `resolve-current-user`
  - validates the Supabase JWT when the frontend needs a single boot payload
  - returns the active profile, membership, role, and permissions
  - rejects inactive company or membership states
- `record-session-event`
  - records sign-in, sign-out, failed login, and password reset events in `user_sessions_audit`

## Future Roadmap

- Multi-factor authentication readiness.
- Device and session management for staff users.
- Multi-company switcher when the second tenant is onboarded.
- Company-level password and session policies.
- Owner screen for reviewing active users and recent sign-ins.
