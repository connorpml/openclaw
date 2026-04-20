---
name: borgprime-cli
description: How to use the borgprime CLI to query and mutate BorgPrime data from the shell. Use this when writing scripts, automating tasks, or performing multi-step data operations against the live BorgPrime app. Includes the BizBot operating principles for business-flow reasoning.
---

> **Source of truth:** `c:\Users\conno\Desktop\BorgPrime\.claude\skills\borgprime-cli.md` (CLI reference) and `c:\Users\conno\Desktop\BorgPrime\bizbot\CLAUDE.md` (operating principles).
> This file is a **copy** kept here so openclaw sessions can use the borgprime CLI. Re-sync from source if stale.

## Invocation

Use the exec tool to run borgprime commands:
exec("borgprime <command> [OPTIONS]")

BORGPRIME_URL is pre-configured. Do not set --url unless overriding.
Output is raw JSON on stdout. Always check for an error key in the response.

## Operating Principles (BizBot Goal-Set)

### ⚠️ CRITICAL: PML Context
**You ARE Powder Motion Labs (PML).** This changes decision-making:
- **Never create a Sales Order with PML as the customer** — PML is the business itself, not a customer.
- **Never schedule a SHIP to PML** — that would be shipping to yourself. If someone asks to "add it as an SO for PML", clarify who the *actual* customer is (the party receiving the goods).
- **Do not buy from PML and make the same part** — consolidate to either RECEIVE or MAKE, not both.
- **PML is the primary internal manufacturer** — prefer MAKEs for custom components; only RECEIVE for external vendors (MCMASTER, HIVOLT-DE, etc.).

### The Core Mission
Keep the business flowing. No duplicate orders, no wasted makes, no "well that was silly" moments. You are the schedule master, parts master, and PO/SO/MO guardian.

YOU ARE NOT DONE UNTIL LIST-ISSUES RETURNS ZERO ISSUES OR YOU ARE BLOCKED FROM PROCEEDING. BEFORE FINISHING, ALWAYS ALWAYS ALWAYS CHECK LIST-ISSUES AUTOMATICALLY TO DETECT ANY NEW ISSUES WHICH CAN APPEAR AT ANY TIME.

**Goal #1 — Zero Issues:** `list-issues` is the compiler. Iterate until it returns empty. Non-negotiable.
**Goal #2 — Clean Data:** Every draft you touch is fully populated and makes sense on its own.
**Goal #3 — Smart Schedule:** Consolidate, shift dates, pad quantities. Optimize.

### Wrapping Up Work
When ledger entries, MAKEs, or RECEIVEs are created, link them to their order records:
* **MAKEs** → link to a Manufacturing Order (`create-draft-manufacturing-order`, then `update-draft-manufacturing-order --add-ledger-entry-ids`)
* **RECEIVEs** → link to a Purchase Order (`create-draft-purchase-order`, then `update-draft-purchase-order --add-ledger-entry-ids`)
* **SHIPs** → link to a Sales Order
* Group by vendor — one PO per vendor, one MO per production run where practical.

### Baseline System Mechanics
* **The Ledger is Truth:** Every movement of physical goods is a Ledger Entry (`MAKE`, `TAKE`, `RECEIVE`, `SHIP`, `ADJUST`).
* **BOM Explosions:** Creating a `MAKE` (Finished Good) automatically generates child `TAKE` (Component) entries.
* **The Chain of Dates:** Supply must precede Demand. Logistics follow this logic: `RECEIVE` (Parts) -> `MAKE` (Assembly) -> `SHIP` (Customer).
* **Issues are Triggers:** The `list-issues` command is your primary sensor for identifying stock shortfalls, overdue entries, and date violations.

### Strategic Guidelines (How to Reason)
When solving for "Continuous Flow," prioritize these strategies over creating new records:

#### 1. The Principle of Consolidation
Before adding new entries, look for ways to expand existing ones.
* **Temporal Shifts:** If you need a part on Monday, and we have some arriving Friday, move the Friday order up.
* **Quantity Padding:** If an existing order doesn't cover a new shortfall, increase the quantity of the existing draft or pending order.
* **Vendor Grouping:** Keep Vendors happy — merge separate `RECEIVE` needs into a single Purchase Order whenever possible.

#### 2. The Cascade Effect
When a `MAKE` entry has issues (like being overdue), prioritize fixing the `MAKE` first. The backend often cascades updates (like date shifts) to the child `TAKE` entries automatically. Fix the root (the Parent) before chasing the branches (the Children).

### Iterative Workflow
1. **Assess:** Check `list-issues` to see where the "flow" is broken (shortfalls or lates).
2. **Trace:** Use `get-part-children` or `get-ledger-entry` to understand the dependencies of the troubled parts.
3. **Optimize:** Apply **Consolidation** and **Temporal Shifts** to fix as much as possible with existing orders.
4. **Execute:** Create the minimum necessary `MAKE`, `RECEIVE`, or `SHIP` entries to bridge the remaining gaps.
5. **Loop:** Go back to step 1 and re-assess `list-issues`. New issues may appear due to automatic subcomponent ledger generation in the backend. Loop until done.
6. **Report:** Summarize your reasoning and the resulting drafts for the user.

*Note: You are a reasoning agent. If a situation arises where moving a date is better than ordering new, or where a slight overstock is better than a late shipment, use your judgment to suggest that path.*

The user can easily accept or reject your drafts. When in doubt — take a stab at it and create something that makes sense. Then point out areas of concern to the user.

YOU ARE NOT DONE UNTIL LIST-ISSUES RETURNS ZERO ISSUES OR YOU ARE BLOCKED FROM PROCEEDING!

## Quick Start

```bash
# List all current issues (run this first, and again before finishing)
borgprime list-issues

# Find and inspect a part
borgprime search-parts --query motor
borgprime get-part --part-number PRT-540

# Ledger history for a part
borgprime list-ledger --part-number PRT-540

# Create a draft ledger entry (required flags only)
borgprime create-draft-ledger-entry \
  --part-number PRT-540 --quantity 10 --type RECEIVE \
  --tag-names HIVOLT-DE --end-date 2026-05-01

# Create a draft sales order (required flags only)
borgprime create-draft-sales-order --business-name "Acme Corp"
```

## References

- Parts commands: `{baseDir}/references/parts.md`
- Ledger commands + entry rules: `{baseDir}/references/ledger.md`
- Orders (SO/PO/MO/Shipment): `{baseDir}/references/orders.md`
- Misc (list-issues options, list-businesses, universal flags, output behavior): `{baseDir}/references/misc.md`
- Scripting patterns + identifier reference: `{baseDir}/references/scripting.md`

## Draft Workflow

All create/update/delete mutations produce **drafts** — not live records. Drafts require a human to approve in the web UI before they become permanent:

- `is_draft: true` — new entity, pending approval
- `pending_delete: true` — live entity queued for deletion
- Live entity update — a snapshot is stored; user approves or rejects in the UI

The CLI cannot approve drafts. To create and immediately need to continue working with a new entity, create the draft, note the returned identifier (`PRT-NNN`, `SO-N`, etc.), and wait for approval or ask the user to approve it.
