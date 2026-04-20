# Ledger (Inventory Transactions)

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
