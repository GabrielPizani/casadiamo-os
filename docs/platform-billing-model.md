# Casa Di Amo OS Platform Billing Model

## Purpose

This document defines the platform billing model for Casa Di Amo OS.

Platform billing controls how tenant companies subscribe to Casa Di Amo OS, receive feature access, move through trial and paid lifecycle states, and change plans over time.

This document covers platform billing only. It is separate from tenant customer payments, invoices, and subscriptions managed inside each company.

## Billing Principles

- Billing is tenant-based.
- The billable tenant is `companies`.
- Plans and features are platform-owned.
- Company subscriptions grant access to features.
- Feature entitlements are the runtime source for feature access.
- Billing state must never bypass tenant isolation.
- Payment provider IDs are external references, not internal source-of-truth identifiers.
- Subscription lifecycle changes must be auditable.

## Core Billing Entities

### `plans`

Commercial packages sold to tenant companies.

Responsibilities:

- Define plan name, slug, description, price, currency, billing interval, and status.
- Provide the commercial container for included features.
- Represent the plan selected by a company subscription.

Examples:

- Starter.
- Growth.
- Pro.
- Enterprise.

### `features`

Global product capability catalog.

Responsibilities:

- Define product capabilities that can be enabled or limited.
- Provide stable feature keys for application checks.
- Group capabilities by module.

Example feature keys:

- `customers.manage`.
- `appointments.manage`.
- `crm.pipelines`.
- `marketing.campaigns`.
- `automations.workflows`.
- `payments.enabled`.
- `reports.advanced`.
- `integrations.hubspot`.
- `ai.assistant`.

### `plan_features`

Mapping between plans and features.

Responsibilities:

- Define which features are included in each plan.
- Store default plan-level limits.
- Support packaging differences between plans.

Examples:

- Starter includes basic appointments.
- Growth includes CRM and marketing.
- Pro includes automations and advanced reports.
- Enterprise includes custom limits and priority integrations.

### `billing_accounts`

Billing profile for a tenant company.

Responsibilities:

- Store billing contact information.
- Link the company to an external payment provider customer.
- Hold currency, tax, and billing status metadata.

### `company_subscriptions`

Subscription lifecycle record for a company.

Responsibilities:

- Track selected plan.
- Track status.
- Track billing interval.
- Track trial period.
- Track current billing period.
- Track cancellation state.
- Link to an external provider subscription.

### `subscription_items`

Priced components attached to a company subscription.

Responsibilities:

- Represent base plan, seats, add-ons, or usage-based items.
- Preserve unit price, quantity, currency, and external provider item IDs.
- Support future expansion beyond flat-rate subscriptions.

### `company_feature_entitlements`

Runtime feature access granted to a company.

Responsibilities:

- Determine whether a company can use a feature.
- Store company-specific limits.
- Allow plan-derived, trial-derived, promotional, manual, or enterprise entitlements.
- Provide a direct access layer for application and RLS-adjacent checks.

### `usage_limits`

Configured resource limits for a company.

Responsibilities:

- Store resource limits such as users, appointments, automations, messages, storage, AI usage, and integrations.
- Support plan-level and override-level limits.

### `usage_counters`

Current usage state for limited resources.

Responsibilities:

- Track usage within a billing period.
- Support quick limit checks.
- Reset or roll over according to billing period rules.

### `usage_records`

Immutable usage events.

Responsibilities:

- Record billable or limited usage.
- Support audit, billing reconciliation, and historical analytics.
- Feed usage counters and invoices.

### `tenant_invoices`

Invoices issued by Casa Di Amo OS to tenant companies.

Responsibilities:

- Track tenant billing invoices.
- Store invoice number, status, totals, currency, due date, paid date, and external invoice ID.
- Separate platform invoices from tenant customer invoices.

## Plans

### Plan Structure

Each plan should define:

- Name.
- Slug.
- Description.
- Billing interval.
- Base price.
- Currency.
- Status.
- Included features.
- Included usage limits.

### Plan Status

Recommended statuses:

- `draft`: plan is being configured.
- `active`: plan can be sold.
- `grandfathered`: existing customers can remain, but new customers cannot subscribe.
- `archived`: plan is no longer available.

### Plan Rules

- Existing subscriptions should not break when a plan is archived.
- Grandfathered plans should preserve current entitlements until migration.
- Enterprise plans may use custom pricing and custom entitlements.
- Plan changes must create auditable subscription lifecycle events.

## Features

### Feature Types

Recommended feature categories:

- Core operations.
- Team management.
- Scheduling.
- CRM.
- Marketing.
- Automations.
- Payments.
- Reports.
- Integrations.
- AI.
- Storage.
- Support.

### Feature Key Rules

Feature keys should be:

- Stable.
- Lowercase.
- Dot-separated.
- Module-prefixed.
- Safe to reference in application checks.

Examples:

- `appointments.recurring`.
- `marketing.whatsapp`.
- `automations.publish`.
- `reports.export`.
- `integrations.calendly`.

### Feature Limits

Features can be:

- Boolean: enabled or disabled.
- Quantitative: limited by count, storage, messages, users, appointments, automations, or AI usage.
- Tiered: different limits by plan.
- Add-on eligible: purchasable outside the base plan.

## Subscription Lifecycle

### Lifecycle States

Recommended subscription statuses:

- `trialing`.
- `active`.
- `past_due`.
- `paused`.
- `canceled`.
- `expired`.

### Lifecycle Flow

Default flow:

1. Company is created.
2. Billing account is created.
3. Trial subscription is created.
4. Trial entitlements are granted.
5. Company upgrades to paid plan or trial expires.
6. Subscription becomes active, past due, canceled, or expired.

### Source of Truth

Casa Di Amo OS is the internal source of truth for:

- Company subscription state.
- Feature entitlements.
- Usage limits.
- Usage counters.

The external billing provider is the source of truth for:

- Payment collection.
- External invoices.
- Payment method state.
- Provider subscription IDs.

Provider state must sync into Casa Di Amo OS through controlled integration jobs and webhook events.

## Trial Period

### Trial Creation

When a company is created:

- Create `billing_accounts`.
- Create `company_subscriptions` with status `trialing`.
- Set `trial_end`.
- Create trial-derived `company_feature_entitlements`.
- Create default `usage_limits`.
- Initialize `usage_counters`.

### Trial Access

Trial access should grant enough product capability for evaluation while protecting platform cost.

Trial limits may include:

- Maximum team members.
- Maximum customers.
- Maximum appointments.
- Maximum marketing messages.
- Maximum automations.
- Maximum AI usage.
- Limited integrations.

### Trial Expiration

When trial expires:

- If payment method and paid plan exist, activate subscription.
- If not, move subscription to `expired` or restricted mode.
- Disable non-free entitlements.
- Preserve tenant data.
- Prevent destructive deletion.
- Allow owner access to billing and upgrade screens.

## Upgrade

### Upgrade Definition

An upgrade moves a company from a lower plan to a higher plan or adds paid capabilities.

Examples:

- Starter to Growth.
- Growth to Pro.
- Add advanced reports.
- Add AI assistant.
- Increase team member limit.

### Upgrade Behavior

On upgrade:

- Update `company_subscriptions.plan_id`.
- Create or update `subscription_items`.
- Grant new `company_feature_entitlements`.
- Increase `usage_limits`.
- Keep existing usage counters.
- Apply billing proration according to provider policy.
- Record audit event.

### Access Timing

Recommended default:

- Grant upgraded features immediately after provider confirmation.
- If payment confirmation is asynchronous, use a pending state until webhook confirmation.

## Downgrade

### Downgrade Definition

A downgrade moves a company from a higher plan to a lower plan or removes paid capabilities.

Examples:

- Pro to Growth.
- Growth to Starter.
- Remove AI add-on.
- Reduce team member limit.

### Downgrade Behavior

Recommended default:

- Schedule downgrade at the end of the current billing period.
- Preserve current entitlements until period end.
- Show warnings for features and limits that will be lost.
- Block downgrade if current usage exceeds target limits unless the owner resolves overages.

### Over-Limit Handling

If current usage exceeds the target plan:

- Do not delete data automatically.
- Restrict creation of new over-limit records.
- Keep read access to existing records.
- Require owner action to archive, remove, or upgrade.

Examples:

- Too many team members.
- Too many active automations.
- Too many integrations.
- Storage exceeds lower plan limit.

## Cancellation

### Cancellation Types

Supported cancellation modes:

- End-of-period cancellation.
- Immediate cancellation.
- Non-payment cancellation.
- Administrative cancellation.

### End-of-Period Cancellation

Recommended default:

- Set `cancel_at`.
- Keep subscription active until current period end.
- Preserve entitlements until cancellation date.
- Notify Company Owner.

### Immediate Cancellation

Immediate cancellation should be limited to:

- Fraud.
- Terms violation.
- Explicit owner request.
- Platform administrative action.

Immediate cancellation should:

- Set subscription status to `canceled`.
- Disable paid entitlements.
- Preserve tenant data according to retention policy.
- Keep owner access to billing, export, and compliance actions.

### Non-Payment

Recommended flow:

1. Payment fails.
2. Subscription moves to `past_due`.
3. Grace period starts.
4. Owner receives notifications.
5. If unresolved, paid entitlements are restricted.
6. Subscription becomes `paused`, `canceled`, or `expired`.

### Data Retention

Cancellation must not delete tenant data automatically.

Data deletion must follow:

- Retention policy.
- Compliance workflow.
- Owner request.
- Platform approval when required.

## Feature Entitlements

### Entitlement Sources

Recommended entitlement sources:

- `plan`: granted by current plan.
- `trial`: granted during trial.
- `addon`: granted by paid add-on.
- `promotion`: granted by temporary campaign.
- `manual`: granted by platform administrator.
- `enterprise_contract`: granted by custom contract.

### Entitlement Evaluation

A feature is available when:

- Company is active.
- Subscription status allows access.
- Entitlement exists for the feature.
- Entitlement is enabled.
- Current date is inside entitlement window.
- Usage is below limit when the feature is limited.

### Entitlement Precedence

Recommended precedence:

1. Manual platform override.
2. Enterprise contract.
3. Paid add-on.
4. Active plan.
5. Trial.
6. Promotion.

Manual denials should override grants when explicitly configured.

### Entitlement Sync

Entitlements must be recalculated when:

- Company starts trial.
- Trial expires.
- Subscription activates.
- Subscription renews.
- Plan changes.
- Add-on changes.
- Cancellation starts.
- Cancellation completes.
- Payment becomes past due.
- Platform admin applies override.

## Usage-Based Billing and Limits

### Usage Resources

Potential usage resources:

- Team members.
- Customers.
- Appointments.
- Messages.
- Marketing deliveries.
- Automations.
- Integration connections.
- Storage.
- AI tokens.
- Reports exports.

### Usage Rules

- Write immutable `usage_records` for billable or limited usage.
- Update `usage_counters` for fast limit checks.
- Compare counters against `usage_limits`.
- Enforce limits before creating new resources.
- Keep historical usage for billing disputes and analytics.

## Billing Access Control

### Company Owner

Allowed:

- View billing account.
- Change plan.
- Add or remove add-ons.
- Update payment method through provider flow.
- Cancel subscription.
- View tenant invoices.

### Manager

Allowed by default:

- View plan name.
- View feature availability.
- View usage warnings.

Restricted by default:

- Cannot change plan.
- Cannot cancel subscription.
- Cannot manage payment method.

### Platform Admin

Allowed:

- View tenant billing state.
- Apply manual entitlements.
- Suspend or restore billing access.
- Resolve billing support issues.

Restrictions:

- Must audit billing changes.
- Must not silently modify tenant business data.

## Billing Events and Audit

Audit these events:

- Trial started.
- Trial extended.
- Trial expired.
- Subscription activated.
- Subscription renewed.
- Upgrade requested.
- Upgrade completed.
- Downgrade scheduled.
- Downgrade completed.
- Cancellation requested.
- Cancellation completed.
- Payment failed.
- Payment recovered.
- Entitlement granted.
- Entitlement revoked.
- Usage limit changed.
- Manual override applied.

## Failure Handling

### Webhook Failure

If billing provider webhooks fail:

- Store webhook event.
- Retry processing idempotently.
- Do not duplicate subscriptions or invoices.
- Reconcile with provider state.

### Payment Failure

If payment fails:

- Move subscription to `past_due`.
- Notify Company Owner.
- Start grace period.
- Restrict paid entitlements only after grace period.

### Entitlement Sync Failure

If entitlement recalculation fails:

- Keep previous entitlements temporarily.
- Queue retry job.
- Alert platform operations.
- Avoid accidental tenant lockout.

## Deployment Checklist

Before enabling billing in production:

- Define initial plans.
- Define feature catalog.
- Map plan features and limits.
- Define trial length and trial limits.
- Define upgrade and downgrade proration policy.
- Define cancellation grace period.
- Define past-due grace period.
- Define entitlement recalculation job.
- Define billing webhooks and idempotency keys.
- Define billing audit events.
- Verify Company Owner billing permissions.
- Verify Platform Admin billing override permissions.
