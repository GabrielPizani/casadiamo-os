# Casa Di Amo OS — MVP UX Specification

**Version:** 1.0  
**Status:** Draft for MVP implementation  
**Audience:** Product, design, engineering, QA  
**Scope:** MVP modules — Authentication, Dashboard, Customers, Appointments, CRM, Marketing, Automations, Analytics, Settings  

---

## Document purpose

This specification translates Casa Di Amo OS philosophy into a concrete software experience. It defines how users move through the product, what they see, and how the interface should feel — without wireframes or visual mockups.

**Source inputs:**

- `product/casa-di-amo-os-brand-core-v2.md` — brand philosophy, House Model, Memory Driven Hospitality, Casa Filter, AI philosophy
- Architecture and domain docs — ERD, RBAC, multi-tenancy, LGPD compliance
- Planned modules from product vision and README

**Note on missing inputs:** `product/design-direction.md` and `product/experience-principles.md` are not yet in the repository. Experience principles in Section 2 are derived directly from brand core and architectural constraints. Existing PRD files (`prd-authentication`, `prd-dashboard`, `prd-customers`, `prd-appointments`) are placeholders; this document supersedes them for UX scope until PRDs are populated.

---

## 1. Experience north star

> **Operate like a house, not a dashboard. Remember before being asked.**

The MVP must feel like entering a well-run service business — organized, warm, and attentive — not like operating enterprise software. Every screen should answer two questions:

1. **What needs care right now?**
2. **What do we already know that helps us care better?**

Success is not measured by how many widgets fit on a screen. Success is measured by whether staff feel prepared to serve, customers feel remembered, and owners feel their business is organized without losing humanity.

---

## 2. Philosophical foundations in UX

### 2.1 Remembered Hospitality

**Definition:** The emotional territory where clients feel known, remembered, and valued — not processed.

**UX translation:**

| Principle | In practice |
| --- | --- |
| Recognition over retrieval | Surface what the house already knows before asking staff to search |
| Continuity over cold starts | Every customer, appointment, and deal opens with memory context |
| Warmth over efficiency theater | Language, pacing, and empty states feel human; speed serves care, not the reverse |
| Relationship over record | Primary objects are people and moments, not rows and IDs |

**Anti-patterns to avoid:** Generic CRM tables with no context panel. Blank detail pages that require five clicks to understand a customer. Notifications that announce data changes without human meaning.

### 2.2 Operate like a house, not a dashboard

**Definition:** The product is a hospitality operating system, not a metrics cockpit.

**UX translation:**

- **Primary navigation** uses house rooms (Guests, Schedule, Relationships, Outreach, Rituals, Insights, House Rules) — not admin module names in user-facing copy.
- **Dashboard** is the *House Overview*: today's care priorities, arrivals, follow-ups, and memory signals — not a grid of KPI tiles.
- **Density** increases only when the user enters a focused room; the overview stays calm.
- **Metrics** live in Analytics (Insights room), not as the homepage hero.

### 2.3 Memory Driven Hospitality™

**Definition:** Operational records become living memory — preferences, history, behaviors, frequency, relationships, conversations, important dates, relevant moments.

**UX translation:**

- Every customer profile includes a **Memory Layer**: preferences, visit rhythm, last meaningful interaction, open commitments, consent state, and suggested next care actions.
- Memory is **written intentionally**: quick capture after appointments, note templates that ask "What should we remember?", AI-assisted summarization with human approval.
- Memory **surfaces proactively**: before check-in, before outbound messages, before stage changes in CRM.
- System prompt for all memory UI: *"How can this help someone care better for this client?"*

**Memory types in MVP:**

| Type | Examples | Primary surfaces |
| --- | --- | --- |
| Preferences | Preferred staff, time of day, communication channel | Customer profile, appointment booking |
| History | Past services, outcomes, notes | Customer profile, appointment detail |
| Rhythm | Visit frequency, no-show pattern, lifetime value signal | CRM, Analytics, Automations triggers |
| Relationships | Assigned staff, deal owner, family/group links | CRM, Appointments |
| Moments | Birthdays, anniversaries, recovery milestones | Marketing, Automations, Dashboard |
| Conversations | Last message thread, sentiment, open questions | Customer profile, CRM activity |

### 2.4 House Model

**Definition:** Each tenant is a unique *casa* — culture, language, rituals, service standards, history, collective memory. The platform provides structure; identity belongs to the business.

**UX translation:**

- **Tenant context is always visible:** house name, location (when multi-location), and white-label branding from `company_branding`.
- **House Setup (Settings)** configures rituals, tone, templates, and service standards — not just technical toggles.
- **No Casa Di Amo identity in customer-facing flows** when white-label is configured; staff-facing chrome may show platform attribution only in footer/legal contexts.
- **Multi-company users** switch houses explicitly; switching feels like entering a different home, with distinct branding and memory isolation.
- **Language and locale** respect `company_settings` defaults; user profile locale is secondary.

### 2.5 Casa Filter

**Definition:** Every action must pass: *"Would I sign my name under this experience?"* If no — do not send, automate, publish, or recommend.

**UX translation:**

- **Pre-send review** for marketing messages, automation actions affecting customers, and AI-generated outbound content.
- **Casa Filter checkpoint** appears as a deliberate pause — not a legal checkbox — showing recipient context, tone preview, and memory justification.
- **Quality gates before scale:** first campaign send, first automation publish, and bulk actions require explicit confirmation with recipient count and sample preview.
- **AI outputs** default to draft; never auto-send customer communications without human approval in MVP.
- **Blocked actions** explain why in human terms: consent missing, tone mismatch, no memory context, or policy restriction.

### 2.6 Experience principles (derived)

Until dedicated experience-principles documentation lands, these six principles govern all MVP decisions:

1. **Prepare before interrupt** — Show context before asking for action.
2. **One guest, one story** — Unify customer, appointment, CRM, and message context on a single narrative thread.
3. **Rituals over routines** — Encode before / arrival / experience / closure / continuity stages in key workflows.
4. **Concierge, not chatbot** — AI anticipates and drafts; humans decide.
5. **Calm by default, depth on demand** — Progressive disclosure; never overwhelm the overview.
6. **Trust is visible** — Consent, audit, and data boundaries are transparent to staff, not hidden in admin.

---

## 3. Global UX architecture

### 3.1 Primary navigation structure

The application shell has three layers:

```
┌─────────────────────────────────────────────────────────────┐
│  House switcher · Location (optional) · Search · Profile    │
├──────────────┬──────────────────────────────────────────────┤
│              │                                              │
│  House       │  Room content                                │
│  navigation  │  (module primary workspace)                  │
│              │                                              │
│  · Overview  │                                              │
│  · Guests    │                                              │
│  · Schedule  │                                              │
│  · Relations │                                              │
│  · Outreach  │                                              │
│  · Rituals   │                                              │
│  · Insights  │                                              │
│  · House     │                                              │
│    Rules     │                                              │
│              │                                              │
└──────────────┴──────────────────────────────────────────────┘
```

**Internal module mapping (engineering):**

| User-facing room | Module | Route prefix (suggested) |
| --- | --- | --- |
| Overview | Dashboard | `/` or `/overview` |
| Guests | Customers | `/guests` |
| Schedule | Appointments | `/schedule` |
| Relationships | CRM | `/relationships` |
| Outreach | Marketing | `/outreach` |
| Rituals | Automations | `/rituals` |
| Insights | Analytics | `/insights` |
| House Rules | Settings | `/house` |

Secondary navigation within each room uses tabs, sub-nav, or contextual side panels — never a second persistent global nav.

### 3.2 Information hierarchy (global)

**Level 0 — House context:** Which casa, which location, who is signed in, role implications.  
**Level 1 — Today's care:** What needs attention now (Overview, notifications).  
**Level 2 — People and time:** Guests and Schedule as operational spine.  
**Level 3 — Relationship depth:** CRM, conversations, memory.  
**Level 4 — Outreach and scale:** Marketing and Automations with Casa Filter gates.  
**Level 5 — Reflection:** Analytics.  
**Level 6 — Identity and governance:** Settings, team, integrations, compliance.

### 3.3 Role-based experience

RBAC shapes visibility and defaults, not separate products.

| Role | Overview emphasis | Restrictions surfaced in UX |
| --- | --- | --- |
| Company Owner | Full house health, revenue signals, compliance | None within tenant |
| Manager | Operations, team workload, pipeline | No ownership transfer, no refund unless granted |
| Employee | My day, my guests, my appointments | No settings, no automation publish, limited exports |
| Viewer | Read-only house snapshot | All actions hidden, explanatory read-only banners |

Employees land on **My Day** variant of Overview; Owners/Managers land on **House Overview**.

### 3.4 Ritual framework in interaction design

Every major workflow maps to hospitality stages:

| Stage | UX intent | Example touchpoints |
| --- | --- | --- |
| Before | Prepare context | Pre-appointment brief, pre-send memory panel |
| Arrival | Welcome and orient | Check-in, guest recognition, day-start overview |
| Experience | Deliver service | Appointment in progress, note capture, CRM update |
| Closure | Gratitude and clarity | Checkout summary, follow-up prompt, receipt |
| Continuity | Stay remembered | Follow-up tasks, campaigns, automations, rebooking |

### 3.5 Concierge AI (global behavior)

AI behaves as a **digital concierge**, not a generic assistant.

**MVP AI capabilities:**

- Memory summarization (customer, appointment, deal)
- Draft messages and follow-ups in house tone
- Suggest next best care action
- Prepare pre-appointment briefs
- Explain Analytics insights in plain language

**MVP AI constraints:**

- Never auto-executes customer-facing actions
- Always shows sources (which memory, which record)
- Offers "Refine tone" and "Make warmer / shorter" controls
- Logs runs for audit (`ai_runs`, `ai_feedback`)
- Passes Casa Filter before any draft becomes sendable

**AI entry points:** persistent Concierge entry in shell (secondary), contextual "Prepare" actions on records, Overview "Suggested care" strip.

### 3.6 Mobile behavior (global)

Mobile is a **care device** for staff on the floor — not a shrunken desktop admin.

- **Bottom navigation** on mobile: Overview, Schedule, Guests, Messages (CRM conversations shortcut), More (remaining rooms).
- **Thumb-first** primary actions: check-in, add note, send message, call, reschedule.
- **Offline-tolerant read** where feasible for today's schedule and guest profiles; write actions queue with clear status.
- **Progressive forms:** minimal fields on mobile; defer non-essential capture to desktop or post-service moment.
- **Push notifications** for arrival reminders, appointment changes, tasks — never for raw system events.

### 3.7 Accessibility, privacy, and trust

- WCAG 2.1 AA target for color contrast (respect white-label within safe ranges), focus order, and screen reader labels.
- Consent state visible wherever outreach is possible.
- LGPD-aligned flows for export/deletion initiated from Settings; staff see status, not backend job IDs.
- Sensitive notes visually distinct with access implications per RBAC.

---

## 4. Cross-module UX patterns

### 4.1 Memory surfacing pattern

When opening any primary record (guest, appointment, deal), show a **Memory Card** at top:

- **Known for:** 2–3 high-signal facts
- **Since last visit:** summary line
- **Open care:** tasks, unanswered messages, upcoming dates
- **Consent:** channel icons with status

Memory Card is collapsible on mobile; expanded by default on desktop for appointment and guest contexts.

### 4.2 Empty state philosophy

Empty states teach the house how to build memory — never shame for "no data."

Structure: **Warm acknowledgment → Why this matters → One primary action → Optional learn link**

Example tone: *"No guests yet. When someone walks in, capturing who they are — and what matters to them — is how your house begins to remember."*

### 4.3 Success state philosophy

Success confirms **care outcome**, not database writes.

- Prefer: *"Maria will receive a warm reminder tomorrow."*
- Avoid: *"Record updated successfully."*

Include optional next care step: add note, schedule follow-up, send thank-you.

### 4.4 Hospitality moments (global catalog)

Reusable moments injected across modules:

| Moment | Trigger | Experience |
| --- | --- | --- |
| Welcome home | First login / first house setup | Guided house setup, not feature tour |
| Guest recognized | Returning customer check-in | Name, last visit, preference highlight |
| Thoughtful pause | Pre-send / pre-publish | Casa Filter review |
| Gratitude beat | Appointment completed | Thank-you prompt, memory capture |
| Continuity cue | Lapsed guest detected | Suggested re-engagement with memory context |
| House milestone | Team achievement | Quiet celebration copy in Insights, not gamification badges |

### 4.5 AI moments (global catalog)

| Moment | Surface | Behavior |
| --- | --- | --- |
| Morning brief | Overview | AI-prepared day summary with care priorities |
| Guest brief | Appointment detail | Pre-arrival context packet |
| Memory stitch | Customer profile | Summarize scattered notes into memory |
| Tone assist | Marketing / messages | Draft in house voice; user edits |
| Next care | CRM / Overview | Suggest next action with rationale |
| Insight narrator | Analytics | Plain-language explanation of trend |

All AI moments include feedback control: helpful / not helpful / inaccurate.

### 4.6 Search and command palette

Global search finds **guests, appointments, deals, conversations** — ranked by recency and relevance. Results show memory snippet, not just title. Command palette (desktop) for quick navigation and "Create guest," "Book appointment," "Add note."

---

## 5. Module specifications

Each module follows the same ten-part structure required for MVP implementation alignment.

---

## 5.1 Authentication

### User goals

- Sign in securely and reach the right house quickly.
- Accept invitations and join a casa with appropriate role.
- Recover access without losing trust in the platform.
- Switch between houses when belonging to multiple companies.
- Manage personal profile preferences (locale, timezone, notifications).

### Primary workflows

1. **Sign in** — Email/password or configured OAuth → resolve user profile → select or auto-enter last active house.
2. **Accept invitation** — Email link → authenticate or create account → land in invited house with role-appropriate Overview.
3. **First house creation (Owner onboarding)** — Sign up → create casa → House Setup wizard → Overview.
4. **Switch house** — House switcher → confirm context change → reload tenant branding and navigation.
5. **Password reset / session recovery** — Standard Supabase Auth flows with Casa Di Amo tone.
6. **Sign out** — Clear tenant context; return to branded login.

### Navigation structure

- **Unauthenticated:** Login, Sign up, Forgot password, Accept invitation (standalone flows).
- **Authenticated shell:** House switcher in top bar; profile menu for account settings, house list, sign out.
- **No module nav** until authenticated and house context resolved.

### Information hierarchy

1. Trust and house branding on login
2. Authentication credentials
3. House selection (if multiple memberships)
4. Profile and security settings (secondary, via profile menu)

### Key screens

| Screen | Purpose |
| --- | --- |
| Login | Branded entry; email/password; OAuth if enabled |
| Sign up | Account creation for new owners or invited users |
| Forgot password | Recovery flow |
| Accept invitation | Role, house name, inviter; accept CTA |
| Select house | List of memberships with role badge; last active highlighted |
| Account profile | Name, avatar, locale, timezone, password, sessions |
| Session expired | Re-auth without losing deep link return path |

### Empty states

- **Select house (single membership):** Skip screen; auto-enter.
- **Select house (no memberships):** *"You're not part of a house yet"* with invitation guidance or create-house path for eligible users.

### AI moments

- None at login (trust-sensitive). Post-onboarding, optional Concierge welcome on first Overview only.

### Hospitality moments

- **Welcome home:** Subtle greeting using time of day and house name on first daily login.
- **Invitation warmth:** Copy references inviter and house by name: *"[Name] invited you to join [House]."*

### Success states

- **Signed in:** Redirect to role-appropriate Overview with house name visible in shell.
- **Invitation accepted:** *"You're home. [House] is ready for you."* → Overview or House Setup if incomplete.
- **House created:** Transition to House Setup wizard, not empty Overview.

### Mobile behavior

- Full-screen auth flows; biometric option (future) placeholder in profile.
- House switcher accessible from profile menu; show current house name persistently in header.
- Deep links from email invitations open mobile web/responsive accept flow.

---

## 5.2 Dashboard (House Overview)

### User goals

- Start the day knowing who needs care and what is happening.
- See memory-driven priorities, not abstract KPIs.
- Act quickly on arrivals, follow-ups, and open tasks.
- Understand house health at a glance without entering admin mode.

### Primary workflows

1. **Morning start** — Open Overview → review AI morning brief → act on priority cards.
2. **Arrival flow** — See today's appointments → tap guest → check in → open appointment detail.
3. **Follow-up sweep** — Review "Open care" queue → complete CRM tasks / send messages.
4. **Memory signal review** — See upcoming important dates → initiate outreach or automation.
5. **Exception handling** — No-shows, cancellations, waitlist openings — resolve from Overview cards.

### Navigation structure

- **Default landing** after auth.
- **Sub-views (tabs or segments):**
  - **Today** (default) — schedule + arrivals + open care
  - **My Day** (Employee default) — assigned appointments and tasks only
  - **House Pulse** (Owner/Manager) — lightweight operational signals linking to Insights

No deep module trees on Overview; every card links to authoritative room.

### Information hierarchy

1. Greeting + date + house/location context
2. Critical now: next arrival, in-progress appointments, urgent tasks
3. Open care queue: unanswered messages, overdue follow-ups, consent gaps
4. Today's schedule timeline (compact)
5. Memory signals: birthdays, lapsed guests, milestones
6. Suggested care (AI, dismissible)
7. Secondary link to Insights for metrics

### Key screens

| Screen | Purpose |
| --- | --- |
| House Overview — Today | Primary operational snapshot |
| My Day | Employee-scoped variant |
| House Pulse | Owner/Manager summary with links to Analytics |
| Priority detail drawer | Expand card without leaving Overview |

### Empty states

| State | Message direction |
| --- | --- |
| New house, no guests | Orient to add first guest and first appointment |
| No appointments today | Encourage booking or review upcoming week in Schedule |
| No open care | Positive rest state: *"You're caught up. Your house is ready."* |
| Employee with no assignments | Clear scope explanation; link to team schedule if permitted |

### AI moments

- **Morning brief:** Narrative summary of day with named guests and care priorities.
- **Suggested care:** 1–3 recommended actions with memory rationale; dismiss or snooze.

### Hospitality moments

- **Arrival recognition:** Next appointment card shows guest memory highlight.
- **Continuity cue:** Lapsed guest card with empathetic re-engagement framing.
- **Gratitude prompt:** Post-completion suggestion surfaced same day.

### Success states

- Checking in guest: *"[Guest] is here. You're prepared."* with link to appointment.
- Task completed: Remove from open care with soft confirmation; offer next task.
- Snoozed suggestion: Hidden for chosen interval with undo.

### Mobile behavior

- Overview is default home tab.
- Cards stack vertically; swipe actions on appointments (check-in, message, reschedule).
- Morning brief collapses to 2 lines with expand.
- Pull to refresh schedule and open care.

---

## 5.3 Customers (Guests)

### User goals

- Know each guest as a whole person, not a contact record.
- Capture and access memory that improves future care.
- Manage consent, tags, addresses, and internal notes responsibly.
- Navigate to appointments, CRM, and conversations from one guest story.

### Primary workflows

1. **Register guest** — Create profile → capture essentials → optional memory seeds → consent.
2. **Prepare for visit** — Open guest → review Memory Card → view upcoming appointment.
3. **Capture memory post-visit** — Add structured note → tag preferences → optional AI summarize.
4. **Find guest** — Search by name, phone, email, tag → recent guests shortcut.
5. **Manage consent** — View/edit channel consents with audit awareness.
6. **Guest continuity** — Identify lapsed rhythm → create follow-up task or outreach draft.

### Navigation structure

- **Guests room**
  - Guest list (default)
  - Segments / tags filter
  - Import (Settings-linked, future MVP boundary)
- **Guest detail** (master-detail on desktop; full page on mobile)
  - Profile
  - Memory
  - Timeline (appointments, CRM, messages, notes)
  - Consent & preferences

### Information hierarchy

**List view:** Name → last visit / next appointment → primary tag → open care indicator.

**Detail view:**

1. Memory Card (known for, rhythm, open care)
2. Identity and contact
3. Upcoming / recent appointments
4. Active deals (CRM link)
5. Conversation preview
6. Notes and files
7. Consent and metadata

### Key screens

| Screen | Purpose |
| --- | --- |
| Guest list | Searchable, filterable roster with memory signals |
| Guest detail | Unified guest story |
| Add / edit guest | Progressive form |
| Memory capture | Note + preference fields + AI summarize |
| Consent management | Channel-purpose matrix with history link |
| Guest timeline | Chronological care history |

### Empty states

| State | Direction |
| --- | --- |
| No guests | Warm onboarding to first guest with memory explanation |
| No memory yet | *"Every great relationship starts with one remembered detail."* prompt after first save |
| No timeline | Suggest first appointment or note |
| Search no results | Offer create guest with pre-filled query if appropriate |

### AI moments

- **Memory stitch:** Consolidate notes into structured memory suggestions; user confirms each fact.
- **Next care:** Recommend follow-up based on visit rhythm and open items.
- **Profile completeness:** Non-naggy hint for missing consent or contact method before outreach.

### Hospitality moments

- **Guest recognized:** Returning guest badge on list and detail header.
- **Remembered detail surfaced:** Show preference in list without opening detail (e.g., "Prefers Ana · mornings").

### Success states

- Guest created: Offer book appointment or add first memory note.
- Memory saved: *"Your house will remember this."* with view on profile.
- Consent updated: Clear channel summary; block outreach if revoked.

### Mobile behavior

- List with large tap targets; sticky search.
- Detail with tab swipe: Profile | Timeline | Memory.
- Floating action: Add note, Book, Message.
- Click-to-call and click-to-WhatsApp where integrated and consented.

---

## 5.4 Appointments (Schedule)

### User goals

- See time as the house's rhythm — who is coming, when, and with what context.
- Book, reschedule, and check in without losing memory context.
- Manage staff, services, locations, reminders, and waitlists.
- Close each appointment with gratitude and continuity prompts.

### Primary workflows

1. **View schedule** — Day / week / staff views → select slot or appointment.
2. **Book appointment** — Guest + service + staff + location + time → confirm → optional reminder config.
3. **Check in (Arrival)** — From Overview or Schedule → mark arrived → surface guest brief.
4. **In progress (Experience)** — Status update → capture service notes.
5. **Complete (Closure)** — Mark complete → gratitude prompt → rebook suggestion → memory capture.
6. **Reschedule / cancel** — Reason capture → notify guest if consented → free slot / waitlist offer.
7. **Waitlist match** — Slot opens → notify waitlisted guest → book.

### Navigation structure

- **Schedule room**
  - Calendar (day default, week secondary)
  - List (agenda)
  - Staff (filter dimension)
  - Locations (filter dimension)
- **Appointment detail** — Side panel desktop; full page mobile.

### Information hierarchy

**Calendar:** Time grid → appointment blocks show guest name, service, staff, status color.

**Appointment detail:**

1. Guest Memory Card
2. Date/time, status, location, staff
3. Services and resources
4. Reminders and calendar sync status
5. Notes and history
6. Actions (check-in, complete, reschedule, cancel, message)

### Key screens

| Screen | Purpose |
| --- | --- |
| Schedule calendar | Primary time view |
| Agenda list | Dense chronological list |
| Book appointment | Guided booking flow |
| Appointment detail | Full context and actions |
| Check-in confirmation | Arrival ritual |
| Completion flow | Closure + continuity |
| Waitlist | Queue management |

### Empty states

| State | Direction |
| --- | --- |
| No services configured | Link to House Rules → Services setup |
| Empty day | Encourage booking or switch to week view |
| No staff availability | Explain hours/time-off; link to settings |
| Waitlist empty | Explain how waitlist helps guests get remembered when slots open |

### AI moments

- **Pre-arrival brief:** Guest + appointment summary on detail and morning of visit.
- **Smart slot suggest:** When booking, propose times matching guest rhythm and preferences.
- **Cancellation recovery:** Draft rebooking message for guest.

### Hospitality moments

- **Before:** Pre-arrival brief notification to assigned staff.
- **Arrival:** Check-in animation/copy; guest preference visible immediately.
- **Closure:** Gratitude screen with thank-you message draft.
- **Continuity:** Rebook prompt with preferred slot pre-selected when known.

### Success states

- Booked: Show appointment on calendar with guest memory snippet; offer send confirmation.
- Checked in: Status visible on Overview and Schedule; staff brief pinned.
- Completed: Move to gratitude/continuity step; update guest timeline.

### Mobile behavior

- Day view default; pinch or toggle for week.
- Swipe appointment for check-in / message / call.
- Booking flow optimized: guest search → service → next available slots.
- Reminder push to assigned staff 15 minutes before (configurable in House Rules).

---

## 5.5 CRM (Relationships)

### User goals

- Track relationship opportunities without reducing guests to pipeline objects.
- See deals in context of guest memory and appointment history.
- Manage pipelines, stages, and activities with hospitality language.
- Prepare for conversations and follow-through with continuity.

### Primary workflows

1. **Pipeline review** — Kanban or list by stage → open deal with guest context.
2. **Create deal** — Link guest → pipeline/stage → owner → initial memory note.
3. **Advance stage** — Move deal → capture activity → optional Casa Filter if communication triggered.
4. **Activity management** — Tasks, calls, meetings linked to guest/deal.
5. **Handoff** — Reassign owner with memory summary for continuity.
6. **HubSpot sync** — View sync status (integration in Settings); resolve conflicts.

### Navigation structure

- **Relationships room**
  - Pipeline (default kanban)
  - Deals list
  - Activities (tasks)
  - Pipelines admin (Manager/Owner)

### Information hierarchy

**Pipeline card:** Guest name → deal title → stage → owner → last activity → memory signal.

**Deal detail:**

1. Guest Memory Card (embedded)
2. Deal stage and value
3. Next activity
4. Activity timeline
5. Related appointments and messages
6. External sync indicator

Use **relationship** language in UI: "Active conversations," "Next step," "Care commitment" — not "SQL," "won/lost" unless house configures sales terminology.

### Key screens

| Screen | Purpose |
| --- | --- |
| Pipeline board | Stage columns with deal cards |
| Deal detail | Relationship record with guest context |
| Activity list | Task-focused view with due dates |
| Create / edit deal | Guest-linked form |
| Pipeline settings | Stages, names, order (Manager/Owner) |

### Empty states

| State | Direction |
| --- | --- |
| No pipeline | Owner setup prompt with default template suggestion |
| Empty stage | Encourage linking guest with upcoming opportunity |
| No activities due | Positive: *"No relationship steps overdue."* |
| Deal without guest | Require guest link — avoid orphan deals |

### AI moments

- **Next step suggest:** Based on stage, memory, and last activity.
- **Deal brief:** Before call/meeting, one-page guest + deal summary.
- **Stalled relationship:** Detect inactivity; suggest continuity outreach draft.

### Hospitality moments

- **Continuity handoff:** Owner change shows "What we're caring for" summary.
- **Stage advancement:** Acknowledge progress in relationship terms, not sales jargon.

### Success states

- Deal created: Prompt first activity with guest context.
- Stage moved: Activity completion suggestion.
- Activity done: Update pipeline card; next task offered.

### Mobile behavior

- Pipeline as horizontal scroll columns; tap card for detail sheet.
- Quick add activity from deal detail FAB.
- Swipe activity to complete.
- Call/message actions on deal with consent check.

---

## 5.6 Marketing (Outreach)

### User goals

- Reach guests with relevant, remembered messages — not bulk noise.
- Build audiences from memory and behavior, not just static lists.
- Review every send through Casa Filter before delivery.
- Track delivery and responses in relationship context.

### Primary workflows

1. **Create audience** — Filters (tags, visit rhythm, consent, dates) → preview recipients with memory samples.
2. **Create campaign** — Audience → channel → message template → personalize → Casa Filter review → schedule/send.
3. **Template management** — House-toned reusable templates.
4. **Monitor campaign** — Delivery, opens (where available), replies → link to guest timeline.
5. **Single guest outreach** — From guest profile → draft message → Casa Filter → send.

### Navigation structure

- **Outreach room**
  - Campaigns
  - Audiences
  - Templates
  - Deliveries (log)

### Information hierarchy

**Campaign list:** Name → status → audience size → send date → delivery health.

**Campaign builder (stepped):**

1. Audience (with consent gate)
2. Message (template + personalization tokens from memory)
3. Preview (sample recipients with rendered message)
4. Casa Filter review
5. Schedule / send

Consent failure blocks progression with clear remediation link.

### Key screens

| Screen | Purpose |
| --- | --- |
| Campaign list | All campaigns with status |
| Audience builder | Segment definition + live preview |
| Message editor | Template, tokens, tone preview |
| Casa Filter review | Final gate with sign-your-name framing |
| Campaign detail | Metrics + delivery list |
| Template library | Reusable house messages |

### Empty states

| State | Direction |
| --- | --- |
| No campaigns | Explain relevance over volume; first campaign wizard |
| No audiences | Show example segments (lapsed guests, birthday month) |
| No templates | Offer starter templates in house tone |
| Zero eligible recipients | Explain consent/filter mismatch; how to fix |

### AI moments

- **Tone assist:** Draft campaign copy from brief in house voice.
- **Personalization suggest:** Token recommendations based on memory fields available.
- **Audience narrate:** Explain who is included and why in plain language.

### Hospitality moments

- **Thoughtful pause:** Casa Filter full-screen review before first send.
- **Relevance check:** Show 3 sample rendered messages with real guest names (masked where needed).
- **Continuity:** Post-campaign reply routes to guest conversation, not dead end.

### Success states

- Campaign scheduled: *"[N] guests will hear from your house on [date]."* with edit/cancel window.
- Sent: Link to monitor replies; no confetti — calm confirmation.
- Single message sent: Visible on guest timeline immediately.

### Mobile behavior

- Campaign monitoring and replies prioritized over builder.
- Audience preview and Casa Filter review supported but simplified on mobile.
- Push on meaningful replies, not delivery ticks.

---

## 5.7 Automations (Rituals)

### User goals

- Encode house rituals — reminders, follow-ups, continuity sequences — as attentive automation.
- Build workflows that pass Casa Filter by design.
- Monitor runs without reading raw logs.
- Start from templates reflecting ritual stages (before, arrival, closure, continuity).

### Primary workflows

1. **Browse ritual templates** — Pre-built workflows by stage → customize → publish.
2. **Build workflow** — Trigger → conditions → actions → review → publish (Owner/Manager).
3. **Test run** — Sandbox with sample guest → inspect steps → approve publish.
4. **Monitor runs** — Recent runs with human-readable outcomes.
5. **Pause / edit** — Safe pause with in-flight run handling message.

### Navigation structure

- **Rituals room**
  - Active rituals (workflows)
  - Templates
  - Run history
  - Events (optional advanced view for Owner)

### Information hierarchy

**Workflow list:** Name → trigger summary → status → last run → guest impact count.

**Workflow builder:**

1. Trigger (appointment completed, lapsed guest, date, deal stage, etc.)
2. Conditions (consent, tags, staff)
3. Actions (send message, create task, wait, notify staff, AI draft)
4. Casa Filter policy (require approval for outbound, max frequency)
5. Publish gate

### Key screens

| Screen | Purpose |
| --- | --- |
| Ritual library | Active and paused workflows |
| Template gallery | Stage-organized starters |
| Workflow builder | Visual step editor |
| Test sandbox | Simulated run with guest picker |
| Run detail | Human-readable trace |
| Publish confirmation | Casa Filter + impact summary |

### Empty states

| State | Direction |
| --- | --- |
| No automations | Introduce rituals concept; offer 3 starter templates |
| Paused house | Explain pause; no silent failures |
| No runs yet | After publish, set expectation for first trigger |

### AI moments

- **Draft ritual:** Describe intent in natural language → proposed workflow steps for edit.
- **Explain run failure:** Plain language diagnosis + fix suggestion.

### Hospitality moments

- **Ritual framing:** Templates named by stage: "Before visit reminder," "Continuity — 30 day check-in."
- **Publish gate:** *"Would you sign your name under this ritual?"* with affected guest count.

### Success states

- Published: *"This ritual is now caring for guests when [trigger]."*
- Test passed: Highlight guest experience path step-by-step.
- Paused: Confirm in-flight runs complete gracefully.

### Mobile behavior

- Monitor-first: active status, recent runs, pause toggle.
- Builder read-only preview on mobile; edit on desktop recommended with explicit UX messaging.
- Alert staff on failed runs requiring human care.

---

## 5.8 Analytics (Insights)

### User goals

- Understand house health and relationship quality without dashboard overload.
- Connect metrics to care decisions — not vanity reporting.
- Export data when permitted (Owner) for accounting or planning.
- See trends that suggest ritual or outreach adjustments.

### Primary workflows

1. **Review house pulse** — Default Insights summary → drill into metric.
2. **Explore metric** — Time range, location, staff filters → narrative + chart.
3. **Act on insight** — Link from metric to Guests, Schedule, Outreach, or Rituals.
4. **Export report** — Owner-initiated export with audit acknowledgment.
5. **Compare periods** — Week/month trend with concierge explanation.

### Navigation structure

- **Insights room**
  - House Pulse (default)
  - Guests & memory
  - Schedule & utilization
  - Relationships (CRM)
  - Outreach performance
  - Custom reports (MVP: saved definitions light)

### Information hierarchy

**House Pulse:**

1. Narrative summary (AI optional)
2. 4–6 core metrics maximum
3. Signals requiring care (e.g., rising no-shows, lapsed guest count)
4. Links to act

**Metric detail:** Definition → chart → breakdown → recommended action.

Metrics must map to care: *return rhythm, show rate, response rate, relationship progression* — not only revenue.

### Key screens

| Screen | Purpose |
| --- | --- |
| House Pulse | Entry Insights view |
| Metric detail | Single metric deep dive |
| Guest analytics | Cohort, lapsed, new |
| Schedule analytics | Utilization, no-shows |
| CRM analytics | Pipeline velocity, stage conversion |
| Outreach analytics | Delivery, reply, opt-out |
| Export flow | Permission-gated with audit |

### Empty states

| State | Direction |
| --- | --- |
| Insufficient data | *"Your house is still gathering memory. Insights appear as your rhythm builds."* |
| New house | Show sample outline ghost charts with explanation |
| Export none | Explain minimum data threshold |

### AI moments

- **Insight narrator:** Plain-language summary on House Pulse.
- **Suggested action:** Link metric change to specific ritual or campaign idea.

### Hospitality moments

- **Celebrate quietly:** Positive trends framed as *"Your guests are returning more often"* not *"+12% retention."*
- **Care alert:** Negative signals framed as guests needing attention, not failures.

### Success states

- Export started: Email/download when ready; audit logged.
- Insight acted: Deep link pre-fills Outreach or Ritual creation.

### Mobile behavior

- House Pulse as vertical cards; charts simplified sparklines.
- Drill-down supported; export Owner-only with confirmation.
- Weekly summary push optional (House Rules).

---

## 5.9 Settings (House Rules)

### User goals

- Configure the house identity, team, services, integrations, and policies.
- Establish rituals defaults, tone, and consent frameworks.
- Manage team access without breaking trust.
- Connect external tools (HubSpot, calendars, messaging) safely.

### Primary workflows

1. **House Setup wizard (first run)** — Branding → locations → services → hours → team invite → consent defaults.
2. **Update branding** — Logo, colors, customer-facing tone preview.
3. **Manage team** — Invite → assign role → staff profile → working hours.
4. **Configure services & catalog** — Categories, services, staff assignments, resources.
5. **Integrations** — Connect HubSpot, Google Calendar, Calendly, WhatsApp/ManyChat → test → sync status.
6. **Compliance** — Retention, export/deletion requests, audit log access (Owner).
7. **Notifications & rituals defaults** — Reminder timing, Casa Filter strictness, AI toggle.

### Navigation structure

- **House Rules room** (sectioned settings, left sub-nav on desktop)

| Section | Contents |
| --- | --- |
| House profile | Name, industry, locale, timezone |
| Branding | White-label visual and tone |
| Locations | Addresses, hours |
| Team | Members, invitations, roles, staff profiles |
| Services | Catalog, categories, resources |
| Scheduling | Booking rules, reminders, waitlist |
| Integrations | Connections, sync health |
| Privacy & consent | Defaults, LGPD tools |
| Notifications | Staff and system alerts |
| Billing & plan | Subscription (Owner) |
| Audit | Activity log (Owner) |

Employees see **Account only** (profile, notifications) — not House Rules sections.

### Information hierarchy

Settings prioritize **identity and care policy** before **technical integration**. Order sections to match House Setup wizard flow for cognitive consistency.

### Key screens

| Screen | Purpose |
| --- | --- |
| House Setup wizard | First-run guided configuration |
| Branding editor | Live preview of customer-facing tone |
| Team management | Members, invites, roles |
| Staff profile & hours | Availability configuration |
| Services catalog | CRUD services and categories |
| Integration hub | Provider cards with status |
| Consent & privacy | LGPD tools, retention |
| Audit log | Filterable security/business events |

### Empty states

| State | Direction |
| --- | --- |
| Setup incomplete | Overview banner + resume wizard |
| No team | Owner invite prompt |
| No integrations | Explain benefits; connect most critical first (calendar) |
| Audit empty | Normal for new house; explain what gets logged |

### AI moments

- **Tone calibration:** Upload sample messages → AI infers house voice for drafts (Owner opt-in).
- **Setup guide:** Concierge answers "what should I configure first?" in wizard.

### Hospitality moments

- **House naming:** Prompt uses *"What do you call your casa?"*
- **Invite warmth:** Invitation preview shows how teammate will be welcomed.

### Success states

- Setup complete: Overview unlocks full experience; wizard never nags again.
- Integration connected: Test sync success with next expected sync time.
- Role changed: Audit entry confirmation; affected user session refresh notice.

### Mobile behavior

- Settings accessible via More tab; Account always available in profile menu.
- Mobile-friendly: notifications, profile, quick team view.
- Complex config (integrations, catalog) desktop-preferred with responsive fallback.

---

## 6. MVP scope boundaries

### In scope for UX MVP

- Full module navigation and primary workflows above
- Memory Card pattern across guest, appointment, deal contexts
- Casa Filter on outbound marketing and automation publish
- Concierge AI drafts and briefs (human approval required)
- Role-based Overview variants
- White-label branding in auth and shell
- LGPD consent visibility and Owner compliance flows
- Mobile-first Schedule and Guest workflows

### Out of scope / future (UX placeholders only)

- Platform Admin console (separate product surface)
- Payments module deep UX (referenced in architecture, not in MVP module list)
- Native mobile apps (responsive web first)
- Customer self-service portal
- Advanced custom report builder
- Real-time collaborative editing
- Biometric auth

---

## 7. UX acceptance criteria (MVP)

The MVP UX is complete when:

1. A new Owner can complete House Setup and reach a meaningful Overview without empty-dashboard confusion.
2. An Employee can run **My Day** — check in guest, complete appointment, capture memory — on mobile.
3. Every outbound guest communication path passes Casa Filter review.
4. Guest detail unifies timeline across appointments, CRM, and messages without module hopping.
5. AI never sends customer communication without explicit human approval.
6. Switching houses changes branding, data, and navigation context with zero cross-tenant leakage in UI.
7. Empty and success states use hospitality language throughout — verified by content audit.
8. RBAC hides destructive and configuration actions with clear explanation, not silent omission.

---

## 8. Content and terminology glossary

| Use | Avoid (staff-facing) |
| --- | --- |
| House / Casa | Tenant, account |
| Guest | Lead, contact (except CRM stage config) |
| Overview | Dashboard |
| Schedule | Calendar module |
| Relationships | CRM pipeline |
| Outreach | Marketing blast |
| Rituals | Automations / workflows |
| Insights | Reports / analytics dashboard |
| House Rules | Settings / admin |
| Memory | Metadata, custom fields |
| Open care | Pending tasks (generic) |
| Casa Filter | Compliance modal |

Customer-facing copy uses the house's configured brand voice, not Casa Di Amo terminology.

---

## 9. Open questions for product resolution

1. **Portuguese vs English default UI** — Brand core is PT; architecture docs mixed. Confirm MVP locale strategy.
2. **Messaging module** — Conversations span CRM and Marketing; confirm whether Messages gets a primary nav item in MVP or remains contextual.
3. **Payments** — Architecture includes payments; user module list excludes it. Confirm post-MVP.
4. **HubSpot** — Bi-directional sync UX depth for MVP vs read-only status.
5. **Design direction artifacts** — `design-direction.md` and `experience-principles.md` should be authored to complement this spec with visual language.

---

## 10. Document maintenance

| Change | Owner | Action |
| --- | --- | --- |
| New module | Product | Add Section 5 module block with ten subsections |
| RBAC change | Product + Eng | Update Section 3.3 and module restrictions |
| AI capability | Product | Update Sections 3.5, 4.5, and affected modules |
| Brand philosophy | Brand | Sync Section 2 with brand core revisions |

**Related documents:** `product/casa-di-amo-os-brand-core-v2.md`, `docs/rbac-model.md`, `database/erd.md`, `docs/multi-tenancy-strategy.md`, `docs/compliance-lgpd.md`

---

*Casa Di Amo OS — Operate like a house, not a dashboard. Remember before being asked.*
