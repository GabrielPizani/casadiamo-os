# Authentication PRD

## Module

Authentication.

## MVP Version

V1 for Amo Beauty Lab as the first tenant of Casa Di Amo OS.

## Business Objective

Give Amo Beauty Lab staff secure access to Casa Di Amo OS with the correct tenant context, role, and session state before they can use operational modules.

The MVP must make authentication simple enough for daily salon operations while preserving the multi-tenant security model already defined in the database architecture.

## User Personas

- Company Owner: owns Amo Beauty Lab, manages access, and needs full tenant control.
- Manager: supervises day-to-day operations and needs broad access without ownership controls.
- Employee: serves customers and needs access to assigned operational work.
- Viewer: reviews operational information without editing records.
- Platform Operator: supports tenant setup and security review through separate platform access.

## User Stories

- As a staff user, I want to sign in with email and password so I can access Casa Di Amo OS.
- As a staff user, I want password reset support so I can recover access without platform intervention.
- As a staff user, I want to remain signed in safely across browser refreshes so I do not lose work.
- As a user with access to one company, I want Amo Beauty Lab selected automatically so I can start work quickly.
- As a user with access to more than one company, I want to choose the active company before viewing tenant data.
- As a Company Owner, I want to invite staff by email and role so new team members receive the correct access.
- As an invited staff member, I want to accept an invitation and complete my profile so I can join Amo Beauty Lab.
- As a Company Owner, I want suspended or removed staff to lose access immediately.
- As a Platform Operator, I want tenant support access separated from company roles so tenant access remains auditable.

## Acceptance Criteria

- Users can sign in, sign out, and reset passwords through Supabase Auth.
- A signed-in user cannot enter the app without an active `user_profiles` record.
- A signed-in user cannot view tenant data without an active `company_members` record.
- Amo Beauty Lab is selected automatically when it is the user's only active company.
- A user with multiple active companies must choose an active tenant context before module access.
- The active tenant context is validated against server-side membership data, not only client state.
- Role-based navigation is derived from `roles`, `permissions`, and `role_permissions`.
- Pending, expired, suspended, removed, or archived memberships cannot access tenant modules.
- Company invitations can be created only by users with member invitation permission.
- Accepted invitations create or connect a `user_profiles` record and an active `company_members` record.
- Authentication-sensitive events are recorded in `user_sessions_audit`.
- Privileged access changes are recorded in `audit_logs`.
- Frontend route guards are treated as UX only; database and API checks remain authoritative.

## Navigation

- Public routes:
  - `/login`
  - `/forgot-password`
  - `/reset-password`
  - `/accept-invitation`
- Authenticated shell:
  - tenant selector when more than one company is available
  - profile menu with profile settings and sign out
- Owner and Manager access:
  - team invitation entry point from settings or team area
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
- `audit_logs`

## API Requirements

- Use Supabase Auth client APIs for sign-in, sign-out, session refresh, and password reset.
- Provide a current-user endpoint or query bundle returning:
  - application profile
  - active company memberships
  - available tenant contexts
  - effective role and permissions for the selected company
- Provide invitation management APIs:
  - create invitation
  - list pending invitations
  - resend invitation
  - revoke invitation
  - accept invitation
- All tenant-scoped API responses must require a validated company context.
- Permission checks must be enforced server-side for invitation and access-management actions.
- APIs must never expose service-role credentials, password hashes, or raw authentication secrets.
- APIs must return safe blocked-state errors without disclosing unrelated tenant data.

## Edge Function Requirements

- `accept-company-invitation`
  - validates invitation token, expiration, invitation status, and target company status
  - creates or links `user_profiles`
  - creates or activates `company_members`
  - records invitation acceptance in `audit_logs`
- `resolve-auth-context`
  - validates the Supabase JWT
  - returns the active profile, memberships, role, and permissions
  - rejects inactive company or membership states
- `record-session-event`
  - records sign-in, sign-out, failed login, password reset, and suspicious access events in `user_sessions_audit`
- `manage-company-invitation`
  - creates, resends, or revokes invitations after membership and permission validation
  - records privileged invitation activity in `audit_logs`

## Future Roadmap

- Multi-factor authentication readiness.
- OAuth sign-in after identity rules are finalized.
- Device and session management for staff users.
- Company-level password and session policies.
- Stronger support tooling for reason-bound tenant access.
- Expanded security review screens for owners and platform operators.
