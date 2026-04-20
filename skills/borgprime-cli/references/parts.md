# Parts Commands

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
