# Casa Di Amo OS — Design Direction

**Positioning:** The Operating System for Beautiful Businesses

**Version:** 1.0  
**Status:** Approved design language foundation  
**Audience:** Product Builder, UX Specification authors, Lovable implementers, interface designers

---

## 1. Purpose

This document defines the Casa Di Amo OS design language — a SaaS experience that feels as considered as the businesses it serves.

It translates inspiration from **gentle luxury**, **craft-forward restraint**, **members-club warmth**, and **editorial retail calm** into a multi-tenant operating system. It does not prescribe copying any reference brand’s visual assets, layouts, or identity marks.

**Use this document to:**

- Write UX Specifications and screen inventories
- Brief Lovable builds with consistent tokens and patterns
- Evaluate interface decisions against a shared north star
- Extend white-label tenant branding without breaking platform coherence

**Out of scope:** Business rules, database structure, architecture, and RBAC logic. Those remain defined in approved PRDs and platform docs.

---

## 2. Positioning & North Star

### Tagline

**The Operating System for Beautiful Businesses**

### What we mean by “beautiful”

Beautiful does not mean decorative. It means:

- **Craft** — every interaction feels intentional, never rushed
- **Care** — people (staff and customers) are treated with dignity in the interface
- **Calm** — complexity is absorbed by the system, not dumped on the user
- **Timelessness** — the UI ages well; it does not chase UI trends

### Product promise (experience level)

Casa Di Amo OS should feel like entering a well-run house — not a software factory.

Users should sense:

> “This system respects my business the way I respect my clients.”

### Primary reference lens

| Reference | What we extract | What we do not copy |
| --- | --- | --- |
| **Brunello Cucinelli** (primary) | Gentle luxury, human dignity, timeless neutrals, craftsmanship, emotional connection, taste over logos | Fashion layouts, campaign photography, brand marks, retail merchandising |
| **Loro Piana** | Material honesty, understated excellence, soft natural warmth, quiet confidence | Product grids, heritage campaign art, textile textures as decoration |
| **Soho House** | Belonging, curated warmth, editorial personality, members-only calm | Club interiors, literal furniture motifs, vintage eclectic clutter |
| **Amen Store** | Editorial restraint, generous space, monochrome calm, fluid mobile journey | E-commerce checkout patterns, product-card merchandising |

---

## 3. Design Philosophy

### 3.1 Gentle Luxury for SaaS

Luxury in Casa Di Amo OS is **gentle**, not loud.

Inspired by Cucinelli’s distinction: the product should feel **timeless and human**, not merely “quiet” or trend-driven. The interface earns trust through proportion, clarity, and care — never through ornament, badges, or visual noise.

**Principles:**

1. **Human first** — Software serves people running service businesses. Copy, pacing, and defaults honor their time and dignity.
2. **Craft over spectacle** — Fewer elements, executed well. One excellent empty state beats five mediocre widgets.
3. **Taste over branding** — Platform identity is expressed through typography, spacing, and behavior — not oversized logos or decorative chrome.
4. **Timeless over trendy** — Avoid glassmorphism cycles, neon gradients, and “startup SaaS” visual clichés.
5. **Emotional connection** — Users should feel the product understands the rhythm of service work: appointments, follow-ups, relationships, reputation.

### 3.2 The House Metaphor

Casa Di Amo (“House of Love”) implies an **operating environment**, not a tool collection.

| House concept | SaaS expression |
| --- | --- |
| Foyer | Authentication, company selection — welcoming, unhurried |
| Living room | Dashboard — orientation, today’s rhythm, calm overview |
| Study | Customers, CRM — relationship depth, notes, history |
| Calendar room | Appointments — time as a precious resource |
| Back office | Settings, billing, integrations — competent, discreet |

Navigation should feel like **moving through rooms**, not drilling into modules.

### 3.3 Beautiful Businesses, Practical Work

Target operators run clinics, aesthetics studios, pet care, consultancies, and local service brands. They are aesthetic-aware but time-poor.

The design language balances:

- **Elevated** enough to match a premium service brand
- **Practical** enough for daily high-volume use
- **MVP-appropriate** — no enterprise complexity in visual or interaction layers

### 3.4 Multi-Tenant Coherence

White-label tenants bring their logo, colors, and customer-facing tone. The **platform shell** remains architecturally consistent — like a beautifully built house where each business hangs its own art.

Tenant branding applies to:

- Customer-facing surfaces (booking, communications, portals)
- Accent color and logo placement in app chrome
- Optional typography pairing within defined constraints

Tenant branding must **not** break:

- Spacing system
- Core component behavior
- Accessibility baselines
- Information hierarchy rules

---

## 4. Interaction Principles

Interactions should feel **unhurried, confident, and considerate**.

### 4.1 Core interaction tenets

| Principle | Definition | SaaS application |
| --- | --- | --- |
| **Intentional pacing** | Nothing jumps, shouts, or nags | Subtle transitions (150–250ms); no aggressive modals on login |
| **Progressive disclosure** | Show what’s needed for the step | Advanced filters collapsed; power features behind clear affordances |
| **Generous feedback** | Every action has a dignified response | Toast confirmations are brief and calm; errors explain and guide |
| **Respectful defaults** | Smart starting points reduce decisions | Pre-filled timezone, locale, sensible list sort, today-centric views |
| **Touch-friendly calm** | Mobile is not a degraded experience | 44px minimum targets; bottom sheets over tiny popovers on small screens |
| **Forgiving flows** | Mistakes are recoverable | Undo for destructive actions; draft states; clear cancel paths |

### 4.2 Navigation behavior

- **Persistent orientation** — Users always know: which company, which section, which record.
- **Shallow paths** — Primary tasks ≤ 3 clicks from dashboard.
- **One primary action per view** — Secondary actions visually subordinate.
- **Sidebar as spine** — Stable left navigation on desktop; bottom nav or drawer on mobile for MVP modules.
- **Company switcher as ritual** — Switching tenant context is deliberate, confirmed, and visually distinct (not a hidden debug menu).

### 4.3 Data interaction patterns

| Pattern | Direction |
| --- | --- |
| **Lists** | Spacious rows, restrained metadata, inline status — not dense spreadsheets |
| **Search** | Prominent but quiet; instant results; remembers recent context |
| **Forms** | Single-column primary path; labels above fields; helper text sparse |
| **Tables** | Use only when comparison is the task; otherwise prefer cards or list rows |
| **Modals** | For focused decisions; never stack; prefer side panels for detail on desktop |
| **Empty states** | Editorial tone — one line of guidance, one action, optional soft illustration |

### 4.4 Motion

Motion expresses **craft**, not playfulness.

- **Duration:** 150ms (micro), 200ms (standard), 300ms (page-level)
- **Easing:** `cubic-bezier(0.4, 0, 0.2, 1)` — ease-out for entrances, ease-in for exits
- **Allowed:** Fade, subtle slide (8–16px), skeleton shimmer
- **Avoid:** Bounce, elastic, parallax, celebratory confetti, excessive stagger

### 4.5 Copy & tone

Voice is **warm, clear, and professional** — like a gracious host, not a chatbot or a compliance manual.

- Prefer: “Add your first client” over “No records found”
- Prefer: “Appointment updated” over “Success!!!”
- Prefer: “You don’t have access to this” + next step over silent disabled controls

---

## 5. Typography Direction

Typography carries the brand more than color or illustration.

### 5.1 Typographic character

Combine:

- **Refined serif or humanist serif** for display and page titles — warmth, heritage, editorial quality (Cucinelli / Loro Piana lens)
- **Clean geometric or neo-grotesque sans** for UI, labels, and data — clarity, modern utility (Amen Store lens)

The pairing should feel **curated**, not template-default.

### 5.2 Recommended font stacks (implementation)

**Primary sans (UI):** `Inter`, `Source Sans 3`, or `DM Sans`  
**Display serif (headlines):** `Fraunces`, `Cormorant Garamond`, or `Libre Baskerville`  
**Monospace (codes, IDs):** `JetBrains Mono` or `IBM Plex Mono`

> Final font selection may be locked in Lovable build plan. Maintain the **role split** (serif = presence, sans = work) even if families change.

### 5.3 Type scale

Base size: **16px** (never 14px as default body — luxury reads larger)

| Token | Size | Line height | Weight | Use |
| --- | --- | --- | --- | --- |
| `text-xs` | 12px | 16px | 400–500 | Metadata, timestamps |
| `text-sm` | 14px | 20px | 400–500 | Secondary labels, table meta |
| `text-base` | 16px | 24px | 400 | Body, inputs |
| `text-lg` | 18px | 28px | 400–500 | Lead paragraphs, section intros |
| `text-xl` | 20px | 28px | 500 | Card titles |
| `text-2xl` | 24px | 32px | 500–600 | Page sections |
| `text-3xl` | 30px | 36px | 500–600 | Page titles (sans) |
| `text-display` | 36–48px | 1.1–1.2 | 500 | Hero headlines (serif) |

### 5.4 Typographic rules

- **Sentence case** for UI labels and buttons — not ALL CAPS navigation
- **Max line length:** 65–75 characters for prose blocks
- **Letter-spacing:** Default for body; slight tracking (`0.02em`) only on small caps / badges
- **Weight restraint:** Regular and Medium dominate; Semibold for emphasis only
- **Numbers:** Tabular lining figures for tables, metrics, and dashboards

---

## 6. Color System

Color expresses **natural materials** — stone, linen, cashmere, warm wood, soft leather — not startup primaries.

### 6.1 Palette philosophy

- **Neutrals carry the brand** — backgrounds and typography do the work
- **Accent is scarce** — one primary accent, used with intention
- **Semantic colors are muted** — success/error never scream
- **Dark mode is optional for MVP** — light mode is the reference; dark may follow post-MVP

### 6.2 Core tokens (light mode)

#### Foundations

| Token | Hex | Role |
| --- | --- | --- |
| `background` | `#FAF8F5` | Primary app canvas — warm linen |
| `surface` | `#FFFFFF` | Cards, panels, modals |
| `surface-subtle` | `#F3F0EB` | Secondary panels, sidebars |
| `border` | `#E8E4DD` | Dividers, input borders |
| `border-strong` | `#D4CEC4` | Focus rings, emphasized separators |

#### Text

| Token | Hex | Role |
| --- | --- | --- |
| `text-primary` | `#1C1917` | Headlines, primary content — warm near-black |
| `text-secondary` | `#57534E` | Supporting copy, labels |
| `text-tertiary` | `#A8A29E` | Placeholders, disabled, meta |
| `text-inverse` | `#FAF8F5` | Text on dark accent surfaces |

#### Accent (platform default)

| Token | Hex | Role |
| --- | --- | --- |
| `accent` | `#6B5B4D` | Primary actions — warm umber/bronze |
| `accent-hover` | `#574A3F` | Hover state |
| `accent-subtle` | `#F0EBE6` | Soft fills, selected nav background |

> Tenant white-label may override `accent`, `accent-hover`, and `accent-subtle` only. Foundation and text tokens remain platform-locked for accessibility and coherence.

#### Semantic (muted)

| Token | Hex | Role |
| --- | --- | --- |
| `success` | `#4A6B5A` | Confirmations, completed states |
| `success-subtle` | `#EEF4F0` | Success backgrounds |
| `warning` | `#8B7355` | Attention without alarm |
| `warning-subtle` | `#F7F2EC` | Warning backgrounds |
| `error` | `#8B5A5A` | Errors — dusty rose/terracotta, not pure red |
| `error-subtle` | `#F9F0F0` | Error backgrounds |
| `info` | `#5A6B7A` | Informational notes |
| `info-subtle` | `#EEF2F6` | Info backgrounds |

### 6.3 Color usage rules

1. **80/15/5 rule** — ~80% neutrals, ~15% text hierarchy, ~5% accent
2. **No gradient CTAs** — solid fills with subtle hover shift only
3. **No rainbow status** — one semantic color per state; never combine badge colors competitively
4. **Charts** — monochromatic or analogous palette derived from accent; avoid default chart junk colors
5. **Contrast** — WCAG AA minimum for all text; AAA preferred for small text on tinted surfaces

### 6.4 White-label overlay

Tenant branding maps to:

```
tenant.logo        → Header / customer-facing surfaces
tenant.accent      → Replaces accent tokens
tenant.accent-hover
tenant.accent-subtle
```

Platform neutrals and typography **do not** change per tenant in MVP.

---

## 7. Spacing System

Space is a **luxury cue**. Generous margins signal confidence and calm.

### 7.1 Base unit

**4px grid** with emphasis on **8px multiples** for layout.

### 7.2 Spacing scale

| Token | Value | Typical use |
| --- | --- | --- |
| `space-1` | 4px | Tight icon gaps |
| `space-2` | 8px | Inline element gaps |
| `space-3` | 12px | Compact padding |
| `space-4` | 16px | Standard inner padding |
| `space-5` | 20px | Form field vertical rhythm |
| `space-6` | 24px | Card padding (compact) |
| `space-8` | 32px | Card padding (standard), section gaps |
| `space-10` | 40px | Large section separation |
| `space-12` | 48px | Page section margins |
| `space-16` | 64px | Hero / major breaks |
| `space-20` | 80px | Marketing-style page padding (rare in app) |

### 7.3 Layout spacing

| Context | Direction |
| --- | --- |
| **Page padding** | 24px mobile, 32–48px desktop |
| **Card padding** | 24px minimum; 32px for primary content cards |
| **List row height** | 56–64px touch rows; never sub-44px interactive |
| **Sidebar width** | 256–280px expanded; icons-only at ≤1024px if needed |
| **Content max-width** | 1200px app shell; 720px for forms and detail prose |
| **Grid gap** | 16px mobile, 24px desktop |

### 7.4 Density modes

MVP ships **comfortable density only**.

| Mode | Status |
| --- | --- |
| Comfortable (default) | MVP |
| Compact | Post-MVP — for power users |

Never ship “compact” to satisfy more columns. Prefer horizontal scroll or column chooser over crushing row height.

---

## 8. Visual Hierarchy

Hierarchy is established through **type, space, and contrast** — not boxes, shadows, and badges.

### 8.1 Hierarchy stack (strongest → weakest)

1. **Page intent** — serif or large sans headline + one-line description
2. **Primary action** — single accent button, right-aligned or F-pattern placement
3. **Content groups** — titled sections with `space-8` separation
4. **Interactive records** — list rows / cards with clear title + 1–2 meta fields
5. **Tertiary meta** — timestamps, IDs, subtle captions

### 8.2 Elevation & depth

| Level | Treatment |
| --- | --- |
| **Base** | Flat on `background` — no shadow |
| **Raised** | `surface` card + `border` + optional `shadow-sm` |
| **Overlay** | Modals, popovers — `shadow-md` + subtle backdrop `rgba(28, 25, 23, 0.4)` |
| **Focus** | 2px ring `border-strong` or accent — never glow halos |

**Shadow tokens:**

- `shadow-sm`: `0 1px 2px rgba(28, 25, 23, 0.04)`
- `shadow-md`: `0 4px 12px rgba(28, 25, 23, 0.06)`
- `shadow-lg`: `0 12px 32px rgba(28, 25, 23, 0.08)`

### 8.3 Borders & dividers

- Prefer **whitespace separation** over lines
- When needed, use `border` at 1px — never heavy 2px rules except active states
- Hairline dividers in lists only when row height exceeds 72px

### 8.4 Iconography

- **Stroke icons** — 1.5px stroke, rounded caps (Lucide-style)
- **Sizes:** 16px inline, 20px nav, 24px empty states
- **Color:** `text-secondary` default; `text-primary` on active; never multicolor icon sets in app chrome

### 8.5 Imagery & illustration

- **Avatars** — soft circles, initials fallback on `surface-subtle`
- **Empty states** — minimal line illustration or none; photography reserved for marketing
- **Tenant logos** — displayed with clear space; never stretched or placed on busy backgrounds
- **No stock-photo hero banners** inside the authenticated app

---

## 9. Emotional Experience

### 9.1 Emotional journey map

| Stage | User feeling | Design response |
| --- | --- | --- |
| **Arrival** (login / company pick) | Welcomed, not processed | Warm background, generous space, human copy |
| **Orientation** (dashboard) | Calm control | Clear “today” summary, no alert wall |
| **Operation** (customers, appointments) | Flow, competence | Fast paths, readable lists, forgiving edits |
| **Growth** (marketing, reports) | Confidence, not overwhelm | Guided summaries, plain language metrics |
| **Administration** (settings) | Trust, safety | Discreet danger zones, confirmation rituals |
| **Error / block** | Respected, not blamed | Clear reason, next action, no technical dumps |

### 9.2 Emotional keywords

**Seek:** Calm · Warm · Considered · Capable · Timeless · Human · Trustworthy

**Avoid:** Hectic · Cold · Corporate · Flashy · Playful · Aggressive · Generic

### 9.3 The Cucinelli test

Before shipping a screen, ask:

1. Does this respect the user’s time and dignity?
2. Would this still feel appropriate in five years?
3. Is anything here only for show — not for service?
4. Does the beauty come from proportion and care, not decoration?

### 9.4 The Soho House test

Before shipping a collaborative or team-facing screen, ask:

1. Does this feel like a members’ environment — belonging, not bureaucracy?
2. Is personality present in copy and curation, without chaos?

### 9.5 The Amen Store test

Before shipping a list or commerce-adjacent flow, ask:

1. Is there enough space for the content to breathe?
2. Does the layout feel editorially curated — not catalog-cluttered?

---

## 10. Luxury Cues (SaaS-Adapted)

Luxury is communicated through **restraint and precision**, not expensive-looking chrome.

| Cue | Reference inspiration | Casa Di Amo OS expression |
| --- | --- | --- |
| **Material warmth** | Cucinelli, Loro Piana | Linen backgrounds, umber accents, stone neutrals |
| **Craftsmanship** | Cucinelli | Consistent components, aligned grids, no mis-sized controls |
| **Understatement** | Loro Piana | No badges for badges’ sake; status shown with typographic weight |
| **Belonging** | Soho House | Company context visible; team presence on dashboard |
| **Editorial calm** | Amen Store | Page titles as statements; one hero metric per dashboard zone |
| **Exclusivity without ego** | All | Premium feel accessible to small teams; no “enterprise only” visual gates |
| **Time as precious** | Service businesses | Today/this week views default; calendars clean and uncluttered |
| **Human touch** | Cucinelli humanism | Client notes, appointment context, relationship — not ticket numbers |

---

## 11. Anti-Patterns

Never introduce these into Casa Di Amo OS — they break the design language instantly.

### 11.1 Visual anti-patterns

| Anti-pattern | Why it fails |
| --- | --- |
| Bright primary blue / purple SaaS gradients | Reads generic startup, not beautiful business |
| Neon success/error colors | Breaks gentle semantic palette |
| ALL CAPS navigation and buttons | Corporate aggression, not hospitality |
| Dense data tables as default | Excel-at-home; violates craft |
| Floating action buttons everywhere | Mobile cliché; breaks calm hierarchy |
| Illustration-heavy empty states | Childish; distracts from action |
| Dark patterns in upsell or upgrade | Violates humanistic trust |
| Tenant neon logos unconstrained | Breaks platform coherence and accessibility |
| Glassmorphism, heavy blur, neon glow | Trend noise; not timeless |
| Multiple accent colors competing | Visual anxiety; breaks 80/15/5 rule |

### 11.2 Interaction anti-patterns

| Anti-pattern | Why it fails |
| --- | --- |
| Modal on login / surprise popups | Violates intentional pacing |
| Toast spam | Cheapens feedback |
| Infinite scroll without orientation | Users lose place |
| Hidden company context | Multi-tenant disorientation |
| Silent permission denial | Disrespectful; use explicit empty states |
| Destructive actions without confirmation | Breaks trust ritual |
| Fake urgency (“Only 2 slots left!”) in B2B OS | Amen/Soho restraint violated |
| Onboarding tours with 12 steps | Enterprise complexity; MVP violation |

### 11.3 Content anti-patterns

| Anti-pattern | Why it fails |
| --- | --- |
| “Oops!” error messages | Too casual for business operators |
| Robotic “No data” | Missed emotional connection |
| Feature marketing inside app chrome | Breaks house metaphor |
| Jargon-heavy metrics without context | Viewer/employee confusion |

---

## 12. Component Direction (MVP)

High-level component notes for Lovable implementation. Detailed specs belong in per-module UX documents.

| Component | Direction |
| --- | --- |
| **App shell** | Left sidebar + top bar with company switcher; `surface-subtle` sidebar on `background` |
| **Primary button** | Filled `accent`, 40–44px height, 8px radius, sentence case |
| **Secondary button** | Ghost or `surface` with `border`, same dimensions |
| **Input** | 44px height, `border` default, clear focus ring, label above |
| **Card** | `surface`, 12px radius, `space-6`–`space-8` padding, minimal shadow |
| **List row** | Title `text-base` medium; meta `text-sm` `text-secondary` |
| **Badge / status** | Pill, `text-xs`, semantic-subtle background — never saturated fills |
| **Nav item** | Icon + label; active = `accent-subtle` bg + `text-primary` weight shift |
| **Dashboard stat** | Large number `text-3xl`; label `text-sm` `text-secondary`; one per card |
| **Avatar** | 32px list, 40px header, 64px profile; initials fallback |
| **Date/time** | Always show local company timezone context |

**Corner radius scale:** 6px (inputs), 8px (buttons), 12px (cards), 16px (modals)

---

## 13. Dashboard Design Direction

The dashboard is the **living room** — the emotional center of the product.

### 13.1 MVP dashboard principles

1. **Today first** — Appointments and tasks for the current day/week above all
2. **One glance, one breath** — 3–5 stat cards maximum on MVP dashboard
3. **Role-aware** — Owner sees revenue hint; Employee sees assigned appointments
4. **No widget marketplace** — Curated layout only; no drag-drop chaos in MVP
5. **Calm notifications** — Summary link to notification center, not a wall of alerts

### 13.2 Suggested zones (MVP)

| Zone | Content |
| --- | --- |
| **Greeting** | “Good morning, [Name]” + company name + date |
| **Today** | Next appointments, confirmations pending |
| **Pulse** | 3 KPIs: appointments today, new clients (7d), outstanding follow-ups |
| **Shortcuts** | New appointment, New client, View calendar |
| **Activity** | Recent client activity stream — 5 items max |

---

## 14. Accessibility & Inclusion

Luxury must be **accessible**, not exclusive in the harmful sense.

- WCAG 2.1 AA minimum
- Focus states always visible
- Color never sole indicator of state
- `prefers-reduced-motion` disables non-essential animation
- Touch targets ≥ 44×44px
- Form errors linked with `aria-describedby`

---

## 15. Implementation Notes for Lovable

### 15.1 Token delivery

Implement design tokens as CSS variables in `:root`:

```css
:root {
  --background: #FAF8F5;
  --surface: #FFFFFF;
  --text-primary: #1C1917;
  --accent: #6B5B4D;
  --space-4: 16px;
  --radius-card: 12px;
  /* ...full set from sections 6–7 */
}
```

### 15.2 Tailwind mapping (if used)

Map tokens to `tailwind.config` theme extension — avoid default Tailwind palette for production UI.

### 15.3 shadcn/ui alignment

shadcn components are acceptable when restyled to match tokens. Replace default radii, shadows, and primary color. Remove heavy ring-offset glow.

### 15.4 Definition of done (visual)

A screen is on-brand when:

- [ ] Uses token colors only (no hardcoded hex in components)
- [ ] Passes Cucinelli, Soho House, and Amen Store tests (Section 9.3–9.5)
- [ ] Has one obvious primary action
- [ ] Meets spacing minimums (Section 7)
- [ ] Avoids all anti-patterns (Section 11)
- [ ] Works at 375px viewport without horizontal scroll

---

## 16. Document Governance

| Action | Owner |
| --- | --- |
| Propose token or pattern changes | Product Builder |
| Approve breaking visual changes | Product + Brand |
| Implement in Lovable | Engineering via Build Plan |
| Validate per screen | UX Specification checklist |

**Related documents:**

- `ai-content/vision` — product vision
- `docs/multi-tenancy-strategy.md` — tenant branding boundaries
- `docs/rbac-model.md` — role-based UI visibility
- `product/prd-*` — module business requirements (UX specs must not alter)

---

## 17. Summary

Casa Di Amo OS design language is **gentle luxury applied to daily operations**.

It is:

- **Warm** like a house, not cold like a database
- **Calm** like an editorial page, not loud like a growth dashboard
- **Crafted** like Cucinelli and Loro Piana, not branded like fast fashion
- **Welcoming** like Soho House, not gated like enterprise software
- **Curated** like Amen Store, not cluttered like a marketplace

**The Operating System for Beautiful Businesses** is not a slogan layered on generic SaaS. It is the standard every screen must meet.
