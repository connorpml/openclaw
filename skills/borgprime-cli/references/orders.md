# Orders

All orders follow the same pattern: list → get → get-<type>-ledger-entries.

Linking rules: `SHIP` entries link to a Sales Order, `RECEIVE` entries link to a Purchase Order, `MAKE` entries link to a Manufacturing Order. `TAKE` entries are NEVER linked to MOs directly (see `references/ledger.md` for the MO/TAKE rule).

## Sales Orders (SO)

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

## Purchase Orders (PO)

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

## Manufacturing Orders (MO)

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

## Shipments

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

## Identifier Zero-Padding

`SO-NNN`, `PO-NNN`, `MO-NNN`, `SHP-NNN` are min 3-wide zero-padded (e.g. `SO-001`, `SO-092`, `SO-1000`). Lookups are strict — `SO-92` will NOT find `SO-092`. Always use the fully padded form. See `references/scripting.md` for the full identifiers table and lpad behavior.
