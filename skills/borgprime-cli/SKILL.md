---
name: borgprime-cli
description: How to use the borgprime CLI to query and mutate BorgPrime data from the shell. Use this when writing scripts, automating tasks, or performing multi-step data operations against the live BorgPrime app. Includes the BizBot operating principles for business-flow reasoning.
---

> **Source of truth:** `c:\Users\conno\Desktop\BorgPrime\.claude\skills\borgprime-cli.md` (CLI reference) and `c:\Users\conno\Desktop\BorgPrime\bizbot\CLAUDE.md` (operating principles).
> This file is a **copy** kept here so openclaw sessions can use the borgprime CLI. Re-sync from source if stale.

---

# Operating Principles (BizBot Goal-Set)

## ⚠️ CRITICAL: PML Context
**You ARE Powder Motion Labs (PML).** This changes decision-making:
- **Never create a Sales Order with PML as the customer** — PML is the business itself, not a customer.
- **Never schedule a SHIP to PML** — that would be shipping to yourself. If someone asks to "add it as an SO for PML", clarify who the *actual* customer is (the party receiving the goods).
- **Do not buy from PML and make the same part** — consolidate to either RECEIVE or MAKE, not both.
- **PML is the primary internal manufacturer** — prefer MAKEs for custom components; only RECEIVE for external vendors (MCMASTER, HIVOLT-DE, etc.).

## The Core Mission
Keep the business flowing. No duplicate orders, no wasted makes, no "well that was silly" moments. You are the schedule master, parts master, and PO/SO/MO guardian.

YOU ARE NOT DONE UNTIL LIST-ISSUES RETURNS ZERO ISSUES OR YOU ARE BLOCKED FROM PROCEEDING. BEFORE FINISHING, ALWAYS ALWAYS ALWAYS CHECK LIST-ISSUES AUTOMATICALLY TO DETECT ANY NEW ISSUES WHICH CAN APPEAR AT ANY TIME.

**Goal #1 — Zero Issues:** `list-issues` is the compiler. Iterate until it returns empty. Non-negotiable.
**Goal #2 — Clean Data:** Every draft you touch is fully populated and makes sense on its own.
**Goal #3 — Smart Schedule:** Consolidate, shift dates, pad quantities. Optimize.

## Wrapping Up Work
When ledger entries, MAKEs, or RECEIVEs are created, link them to their order records:
* **MAKEs** → link to a Manufacturing Order (`create-draft-manufacturing-order`, then `update-draft-manufacturing-order --add-ledger-entry-ids`)
* **RECEIVEs** → link to a Purchase Order (`create-draft-purchase-order`, then `update-draft-purchase-order --add-ledger-entry-ids`)
* **SHIPs** → link to a Sales Order
* Group by vendor — one PO per vendor, one MO per production run where practical.

## Baseline System Mechanics
* **The Ledger is Truth:** Every movement of physical goods is a Ledger Entry (`MAKE`, `TAKE`, `RECEIVE`, `SHIP`, `ADJUST`).
* **BOM Explosions:** Creating a `MAKE` (Finished Good) automatically generates child `TAKE` (Component) entries.
* **The Chain of Dates:** Supply must precede Demand. Logistics follow this logic: `RECEIVE` (Parts) -> `MAKE` (Assembly) -> `SHIP` (Customer).
* **Issues are Triggers:** The `list-issues` command is your primary sensor for identifying stock shortfalls, overdue entries, and date violations.

## Strategic Guidelines (How to Reason)
When solving for "Continuous Flow," prioritize these strategies over creating new records:

### 1. The Principle of Consolidation
Before adding new entries, look for ways to expand existing ones.
* **Temporal Shifts:** If you need a part on Monday, and we have some arriving Friday, move the Friday order up.
* **Quantity Padding:** If an existing order doesn't cover a new shortfall, increase the quantity of the existing draft or pending order.
* **Vendor Grouping:** Keep Vendors happy — merge separate `RECEIVE` needs into a single Purchase Order whenever possible.

### 2. The Cascade Effect
When a `MAKE` entry has issues (like being overdue), prioritize fixing the `MAKE` first. The backend often cascades updates (like date shifts) to the child `TAKE` entries automatically. Fix the root (the Parent) before chasing the branches (the Children).

## Iterative Workflow
1. **Assess:** Check `list-issues` to see where the "flow" is broken (shortfalls or lates).
2. **Trace:** Use `get-part-children` or `get-ledger-entry` to understand the dependencies of the troubled parts.
3. **Optimize:** Apply **Consolidation** and **Temporal Shifts** to fix as much as possible with existing orders.
4. **Execute:** Create the minimum necessary `MAKE`, `RECEIVE`, or `SHIP` entries to bridge the remaining gaps.
5. **Loop:** Go back to step 1 and re-assess `list-issues`. New issues may appear due to automatic subcomponent ledger generation in the backend. Loop until done.
6. **Report:** Summarize your reasoning and the resulting drafts for the user.

*Note: You are a reasoning agent. If a situation arises where moving a date is better than ordering new, or where a slight overstock is better than a late shipment, use your judgment to suggest that path.*

The user can easily accept or reject your drafts. When in doubt — take a stab at it and create something that makes sense. Then point out areas of concern to the user.

YOU ARE NOT DONE UNTIL LIST-ISSUES RETURNS ZERO ISSUES OR YOU ARE BLOCKED FROM PROCEEDING!

---

# BorgPrime CLI

The `borgprime` CLI exposes the same whitelisted agent tools the in-app AI uses. Every subcommand outputs raw JSON to stdout and funnels through the capability kernel — no parallel safeguard layer.

## Invocation

```bash
borgprime [--url <base-url>] <command> [OPTIONS]
```

`borgprime` is on PATH inside the openclaw gateway container. `BORGPRIME_URL` is preset to `http://host.docker.internal:5000` (the BorgPrime backend on the host). Override with `--url` or by setting `BORGPRIME_URL` when needed.

## Output / Error Behavior

- **Success:** JSON string on stdout, exit 0. No pretty-printing.
- **App-level errors** (entity not found, validation failures): `{"error": "..."}` on stdout, exit 0. Always check for an `error` key when scripting.
- **Connection / capability errors** (`BorgPrimeError`): `{"error": "..."}` on stderr, non-zero exit. Pipelines (`borgprime ... | jq ...`) fail cleanly.

## Universal Options

These appear on every listing/read command:

| Flag | Description |
|------|-------------|
| `--fields <name,...>` | Return only named fields. Comma-separated or repeat flag. e.g. `--fields part_number,description` |
| `--sort-by <field>` | Sort by field (must be in visible_fields for that entity) |
| `--sort-order asc\|desc` | Default `asc` |
| `--limit <n>` | Max results (default 20 for most list commands) |

## Command Reference

### Parts

```bash
borgprime search-parts --query <text> [--mfg-part-number <mpn>] [--limit N] [--fields ...]
borgprime get-part --part-number <PRT-NNN> [--fields ...]
borgprime get-part-children --part-number <PRT-NNN> [--fields ...]   # BOM children + qty
borgprime get-part-parents  --part-number <PRT-NNN> [--fields ...]   # Where-used + qty
borgprime list-prefixes                                               # All part-number prefix codes
borgprime list-tags                                                   # All tag names + IDs

borgprime create-draft-part  --name <n> --prefix <PREFIX> [--description <d>] [--mfg-part-number <m>]
borgprime update-draft-part  --part-number <PRT-NNN> [--name ...] [--description ...] [--mfg-part-number ...]
borgprime delete-draft-part  --part-number <PRT-NNN>
# Drafts: hard-delete. Live parts: soft-delete (pending_delete=true, requires user approval).
```

### Ledger (Inventory Transactions)

Entry types: `MAKE` (+), `TAKE` (−), `RECEIVE` (+), `SHIP` (−), `ADJUST` (±).

**MO / TAKE relationship:** Only `MAKE` entries are linked to Manufacturing Orders (`--ledger-entry-ids` on MO commands). `TAKE` entries are never linked directly to an MO — they are auto-created as BOM children of a `MAKE` entry (via `parent_id`) when the MAKE is created. Never manually link a TAKE to an MO.

Every ledger entry has a DB-generated `ledger_number` combining type prefix + integer id:
`MAKE` → `MK-<id>`, `TAKE` → `TK-<id>`, `RECEIVE` → `RC-<id>`, `SHIP` → `SH-<id>`, `ADJUST` → `AJ-<id>`.
It is never zero-padded and is the identifier used by all agent tools. Lookups are case-insensitive.

```bash
borgprime get-ledger-entry --ledger-number <MK-N|TK-N|RC-N|SH-N|AJ-N> [--fields ...]
# Fetches a single entry by ledger_number — including child TAKE entries from BOM explosions.
# All ledger responses include a business_name field (vendor/customer from linked PO or SO).

borgprime list-ledger [--part-number <PRT-NNN>] [--type MAKE|TAKE|RECEIVE|SHIP|ADJUST] [--limit N] [--fields ...]

borgprime create-draft-ledger-entry \
  --part-number <PRT-NNN> \
  --quantity <n> \
  --type <MAKE|TAKE|RECEIVE|SHIP|ADJUST> \
  --tag-names <tag1,tag2>     # required; auto-creates new tags; call list-tags first \
  --end-date <YYYY-MM-DD>     # required \
  [--start-date <YYYY-MM-DD>] \
  [--notes <text>] \
  [--unit-price <n>]          # unit price (e.g. line price from customer PO)

borgprime update-draft-ledger-entry --ledger-number <MK-N|TK-N|...> [--quantity ...] [--type ...] [--tag-names ...] [--notes ...] [--start-date ...] [--end-date ...] [--status PENDING|STARTED|FINISHED] [--unit-price <n>]
borgprime delete-draft-ledger-entry --ledger-number <MK-N|TK-N|...>

# Batch stage the same field update on multiple entries at once (e.g. mark 8 TAKEs FINISHED).
# Each entry gets a pre_update_snapshot for independent review. Draft entries are rejected.
# Batch still uses integer IDs (scripted from prior tool outputs), not ledger_number.
borgprime batch-update-draft-ledger-entries \
  --ledger-ids <id1,id2,...>  # required; comma-separated integer IDs \
  [--status PENDING|STARTED|FINISHED] \
  [--quantity <n>] \
  [--start-date <YYYY-MM-DD>] \
  [--end-date <YYYY-MM-DD>] \
  [--notes <text>] \
  [--unit-price <n>]
```

### Orders

All orders follow the same pattern: list → get → get-<type>-ledger-entries.

**Sales Orders (SO)**
```bash
borgprime list-sales-orders [--fields ...] [--sort-by ...] [--sort-order ...] [--limit N]
borgprime get-sales-order --so-number <SO-N> [--fields ...]
borgprime get-sales-order-ledger-entries --so-number <SO-N> [--fields ...]

borgprime create-draft-sales-order \
  --business-name <name>          # required; matched by name in businesses table \
  [--description <text>] \
  [--sales-order-date <YYYY-MM-DD>] \
  [--customer-due-date <YYYY-MM-DD>] \
  [--customer-billing-address <addr>] \
  [--ship-to-address <addr>] \
  [--comments <text>] \
  [--ledger-entry-ids <id1,id2>]  # SHIP entry IDs to link

borgprime update-draft-sales-order --so-number <SO-N> \
  [--description ...] [--business-name ...] [--sales-order-date ...] [--customer-due-date ...] \
  [--customer-billing-address ...] [--ship-to-address ...] [--comments ...] \
  [--add-ledger-entry-ids <id,...>] [--remove-ledger-entry-ids <id,...>]

borgprime delete-draft-sales-order --so-number <SO-N>
```

**Purchase Orders (PO)**
```bash
borgprime list-purchase-orders [--fields ...] [--sort-by ...] [--limit N]
borgprime get-purchase-order --po-number <PO-N> [--fields ...]
borgprime get-purchase-order-ledger-entries --po-number <PO-N> [--fields ...]

borgprime create-draft-purchase-order \
  --business-name <name>          # required \
  [--description ...] [--po-date <YYYY-MM-DD>] [--po-due-date <YYYY-MM-DD>] \
  [--vendor-billing-address ...] [--ship-to-address ...] [--comments ...] \
  [--ledger-entry-ids <id,...>]   # RECEIVE entry IDs to link

borgprime update-draft-purchase-order --po-number <PO-N> [--description ...] [--business-name ...] \
  [--po-date ...] [--po-due-date ...] [--vendor-billing-address ...] [--ship-to-address ...] \
  [--comments ...] [--add-ledger-entry-ids ...] [--remove-ledger-entry-ids ...]

borgprime delete-draft-purchase-order --po-number <PO-N>
```

**Manufacturing Orders (MO)**
```bash
borgprime list-manufacturing-orders [--fields ...] [--sort-by ...] [--limit N]
borgprime get-manufacturing-order --mo-number <MO-N> [--fields ...]
borgprime get-manufacturing-order-ledger-entries --mo-number <MO-N> [--fields ...]

borgprime create-draft-manufacturing-order \
  --description <text>            # required \
  [--start-date <YYYY-MM-DD>] [--target-date <YYYY-MM-DD>] \
  [--comments ...] [--ledger-entry-ids <id,...>]   # MAKE entry IDs to link

borgprime update-draft-manufacturing-order --mo-number <MO-N> [...]
borgprime delete-draft-manufacturing-order --mo-number <MO-N>
```

### Shipments

```bash
borgprime list-shipments [--fields ...] [--sort-by ...] [--limit N]   # sorted most-recent first
borgprime get-shipment --shipment-number <SHP-N> [--fields ...]
borgprime get-shipment-ledger-entries --shipment-number <SHP-N> [--fields ...]

borgprime create-draft-shipment \
  --business-name <name>          # required \
  [--ship-date <YYYY-MM-DD>] [--tracking-number ...] \
  [--ship-to-address ...] [--ship-from-address ...] \
  [--comments ...] [--ledger-entry-ids <id,...>]   # SHIP entry IDs to link

borgprime update-draft-shipment --shipment-number <SHP-N> [...]
borgprime delete-draft-shipment --shipment-number <SHP-N>
```

### Misc

```bash
borgprime list-businesses [--fields ...] [--sort-by ...]    # no --limit; returns all
borgprime list-issues [--entity-type <type>] [--limit N] [--fields ...]
# entity-type: ledger | part | sales_order | purchase_order | manufacturing_order | shipment
# stock_shortfall issues live on entity_type=ledger, not part
```

## Draft Workflow

All create/update/delete mutations produce **drafts** — not live records. Drafts require a human to approve in the web UI before they become permanent:

- `is_draft: true` — new entity, pending approval
- `pending_delete: true` — live entity queued for deletion
- Live entity update — a snapshot is stored; user approves or rejects in the UI

The CLI cannot approve drafts. To create and immediately need to continue working with a new entity, create the draft, note the returned identifier (`PRT-NNN`, `SO-N`, etc.), and wait for approval or ask the user to approve it.

## Array Options: Two Equivalent Forms

```bash
# Comma-separated (one flag)
borgprime create-draft-ledger-entry --tag-names "BEEHIVE,SAM"

# Multiple flags
borgprime create-draft-ledger-entry --tag-names BEEHIVE --tag-names SAM

# Explicit empty = clear all (not the same as omitting the flag)
borgprime update-draft-sales-order --so-number SO-5 --remove-ledger-entry-ids ""
```

## Common Scripting Patterns

```bash
# Find overdue items
borgprime list-issues --entity-type ledger --fields entity_id,part_number,ledger_type,issues \
  | python -c "import sys,json; [print(e['part_number'], e['issues']) for e in json.load(sys.stdin)['entities']]"

# Stock check for a specific part
borgprime get-part --part-number PRT-540 --fields part_number,description,current_stock

# Find all parts matching a keyword, get part numbers only
borgprime search-parts --query "motor" --fields part_number,description --limit 50

# List recent SOs sorted by due date ascending
borgprime list-sales-orders --sort-by customer_due_date --sort-order asc \
  --fields so_number,description,customer_due_date --limit 20

# Get ledger history for a part
borgprime list-ledger --part-number PRT-540 --sort-by start_date --sort-order desc

# Walk a BOM
borgprime get-part-children --part-number PRT-628 --fields part_number,description,quantity
```

## Error Checking in Scripts

```bash
result=$(borgprime get-part --part-number "$PN")
if echo "$result" | python -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)"; then
  echo "Found: $result"
else
  echo "Error: $result" >&2
fi
```

## Identifiers Quick Reference

| Entity | Identifier format | Flag |
|--------|------------------|------|
| Part | `PRT-NNN`, `FAB-NNN`, etc. | `--part-number` |
| Sales Order | `SO-NNN` (min 3-wide zero pad, e.g. `SO-001`, `SO-092`, `SO-1000`) | `--so-number` |
| Purchase Order | `PO-NNN` (min 3-wide zero pad) | `--po-number` |
| Manufacturing Order | `MO-NNN` (min 3-wide zero pad) | `--mo-number` |
| Shipment | `SHP-NNN` (min 3-wide zero pad) | `--shipment-number` |
| Ledger entry | `MK-N` / `TK-N` / `RC-N` / `SH-N` / `AJ-N` (type prefix + integer id, not zero-padded) | `--ledger-number` |
| Business | name string | `--business-name` |

**Padding note:** SO/PO/MO/SHP numbers are DB-generated with `lpad(id::text, greatest(3, length(id::text)), '0')`. Lookups are strict — `SO-92` will NOT find `SO-092`. Always use the fully padded form.
