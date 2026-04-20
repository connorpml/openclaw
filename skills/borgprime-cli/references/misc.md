# Misc

## Universal Options

These appear on every listing/read command:

| Flag | Description |
|------|-------------|
| `--fields <name,...>` | Return only named fields. Comma-separated or repeat flag. e.g. `--fields part_number,description` |
| `--sort-by <field>` | Sort by field (must be in visible_fields for that entity) |
| `--sort-order asc\|desc` | Default `asc` |
| `--limit <n>` | Max results (default 20 for most list commands) |

## Output / Error Behavior

- **Success:** JSON string on stdout, exit 0. No pretty-printing.
- **App-level errors** (entity not found, validation failures): `{"error": "..."}` on stdout, exit 0. Always check for an `error` key when scripting.
- **Connection / capability errors** (`BorgPrimeError`): `{"error": "..."}` on stderr, non-zero exit. Pipelines (`borgprime ... | jq ...`) fail cleanly.

## list-businesses & list-issues

```bash
borgprime list-businesses [--fields ...] [--sort-by ...]    # no --limit; returns all
borgprime list-issues [--entity-type <type>] [--limit N] [--fields ...]
# entity-type: ledger | part | sales_order | purchase_order | manufacturing_order | shipment
# stock_shortfall issues live on entity_type=ledger, not part
```

## Array Options: Two Equivalent Forms

```bash
# Comma-separated (one flag)
borgprime create-draft-ledger-entry --tag-names "BEEHIVE,SAM"

# Multiple flags
borgprime create-draft-ledger-entry --tag-names BEEHIVE --tag-names SAM

# Explicit empty = clear all (not the same as omitting the flag)
borgprime update-draft-sales-order --so-number SO-5 --remove-ledger-entry-ids ""
```
