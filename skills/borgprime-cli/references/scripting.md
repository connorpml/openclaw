# Scripting Patterns & Identifiers

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
