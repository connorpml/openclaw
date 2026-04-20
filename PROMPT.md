Prompt for Claude Code

You are restructuring an existing OpenClaw skill file for the borgprime-cli skill.

The current skill is a single monolithic SKILL.md file located at:
~/.openclaw/skills/borgprime-cli/SKILL.md

Your task is to split it into a lean index SKILL.md + multiple reference files, following the OpenClaw progressive disclosure pattern. Do NOT change the content — restructure and redistribute it.

---

### Target directory structure:

~/.openclaw/skills/borgprime-cli/
├── SKILL.md
└── references/
    ├── parts.md
    ├── ledger.md
    ├── orders.md
    ├── misc.md
    └── scripting.md

---

### SKILL.md requirements:

Keep the existing YAML frontmatter exactly as-is (name + description).

Body must contain in this order:

1. **## Invocation** section — include this exact block:
Use the exec tool to run borgprime commands:
exec("borgprime <command> [OPTIONS]")

BORGPRIME_URL is pre-configured. Do not set --url unless overriding.
Output is raw JSON on stdout. Always check for an error key in the response.

2. **## Operating Principles** section — copy the entire Operating Principles section verbatim from the current SKILL.md, including all subsections (CRITICAL: PML Context, The Core Mission, Wrapping Up Work, Baseline System Mechanics, Strategic Guidelines, Iterative Workflow). Do not summarize or shorten it.

3. **## Quick Start** section — inline examples for the 5 most common operations only:
- list-issues
- search-parts / get-part
- list-ledger
- create-draft-ledger-entry (minimal required flags only)
- create-draft-sales-order (minimal required flags only)

4. **## References** section — pointers to each reference file using {baseDir}:
Parts commands: {baseDir}/references/parts.md
Ledger commands + entry rules: {baseDir}/references/ledger.md
Orders (SO/PO/MO/Shipment): {baseDir}/references/orders.md
Misc (list-issues options, list-businesses, universal flags, output behavior): {baseDir}/references/misc.md
Scripting patterns + identifier reference: {baseDir}/references/scripting.md

5. **## Draft Workflow** section — keep the existing Draft Workflow explanation (is_draft, pending_delete, cannot approve from CLI).

---

### Reference file requirements:

**references/parts.md** — Extract from current SKILL.md:
- All Parts commands: search-parts, get-part, get-part-children, get-part-parents, list-prefixes, list-tags
- Draft part mutations: create-draft-part, update-draft-part, delete-draft-part
- The note about soft-delete vs hard-delete behavior

**references/ledger.md** — Extract from current SKILL.md:
- Entry types explanation (MAKE/TAKE/RECEIVE/SHIP/ADJUST, + or −)
- The MO/TAKE relationship rule (TAKEs auto-created via parent_id, never link manually)
- ledger_number format rules (type prefix + integer id, not zero-padded, case-insensitive)
- All ledger commands: get-ledger-entry, list-ledger, create-draft-ledger-entry, update-draft-ledger-entry, delete-draft-ledger-entry, batch-update-draft-ledger-entries
- Tag requirement note (--tag-names required, auto-creates, call list-tags first)

**references/orders.md** — Extract from current SKILL.md:
- All four order types: Sales Orders (SO), Purchase Orders (PO), Manufacturing Orders (MO), Shipments
- All list/get/create/update/delete commands for each
- Linking rules: SHIPs→SO, RECEIVEs→PO, MAKEs→MO — and the rule that TAKEs are NEVER linked to MOs directly
- Identifier zero-padding rules (SO/PO/MO/SHP are min 3-wide zero-padded; lookups are strict)

**references/misc.md** — Extract from current SKILL.md:
- Universal options table (--fields, --sort-by, --sort-order, --limit)
- Output/error behavior section (stdout JSON exit 0, error key, stderr on BorgPrimeError)
- list-businesses and list-issues commands with all options
- Array option syntax (comma-separated vs repeat flag vs explicit empty to clear)

**references/scripting.md** — Extract from current SKILL.md:
- All entries from the "Common Scripting Patterns" section
- The error checking pattern
- The full Identifiers Quick Reference table
- The padding note about lpad behavior

---

### Rules:
- Do not invent, summarize, or rewrite any content. Redistribute existing content only.
- Every piece of content from the current SKILL.md must appear in exactly one place in the new structure (no duplication).
- The source-of-truth note at the top of the current SKILL.md (the "> **Source of truth:**" block) should be kept at the top of the new SKILL.md body, below the frontmatter.
- Use proper markdown headers (## for top-level in SKILL.md, ## or ### in reference files as appropriate).
- Reference files should start with a # Title header.
- Do not add any content that isn't already in the current SKILL.md.
That prompt is tight enough that Claude Code shouldn't improvise. Feed it the current file contents if it needs them — it should read ~/.openclaw/skills/borgprime-cli/SKILL.md first before writing anything.
