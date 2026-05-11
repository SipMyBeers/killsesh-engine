# KillSesh Engine: Deterministic Quality Gates for AI Legacy Translation

> A pipeline that refuses to let an LLM hallucinate a COBOL translation.

KillSesh Engine is the open architecture spec behind [killsesh.com](https://killsesh.com) —
a deterministic gate system that wraps a local LLM to translate COBOL
copybooks into typed TypeScript / Zod schemas, and **rejects any output
whose field count, structural shape, or REDEFINES handling does not match
the source AST byte-for-byte**.

The engine never trusts the model. It treats every LLM response as untrusted
input that must pass five hard gates before it can ship. When a gate fails,
the pipeline consults a corpus of historical hallucinations — the *Burned
Book* — and retries with the matching anti-patterns explicitly injected into
the next prompt.

The result: **same input → same output, every run. Zero hallucinations on
nested REDEFINES. Zero data egress.**

---

## Quick Start

The engine ships as an 840 KB air-gapped Docker tarball. No cloud. No API keys.

```bash
# Download and verify
curl -O https://killsesh.com/downloads/killsesh-enterprise-v0.1.0.tar.gz
curl https://killsesh.com/downloads/SHA256SUMS | shasum -a 256 -c

# Run
docker compose up
# → frontend at http://localhost:3000
# → drop any .CPY from samples/ onto the upload zone
```

Watch the live trace of the engine solving ACORD_AL3_NIGHTMARE.CPY:
→ **[killsesh.com/demo](https://killsesh.com/demo)**

---

## Architecture

```
┌────────────────────┐
│  COBOL copybook    │   .CPY / .CBL / .zip ecosystem
│  (untrusted text)  │
└─────────┬──────────┘
          │
          ▼
┌────────────────────────────────────────────────────────┐
│  Tree-sitter — deterministic AST extraction            │
│  • Field offsets, levels, PIC clauses                  │
│  • REDEFINES unions identified                         │
│  • OCCURS DEPENDING ON arrays identified               │
│  No LLM involved. No spatial reasoning by the model.   │
└─────────┬──────────────────────────────────────────────┘
          │   strict JSON map of every field
          ▼
┌────────────────────────────────────────────────────────┐
│  Local LLM (Gemma 12B  →  DeepSeek-Coder 33B fallback) │
│  • Prompted only with the AST JSON, never raw COBOL    │
│  • Drafts TypeScript Zod schema + plain-English doc    │
│  • Runs on your hardware. Zero network egress.         │
└─────────┬──────────────────────────────────────────────┘
          │   candidate output
          ▼
┌────────────────────────────────────────────────────────┐
│  Quality Gates  (deterministic, math-not-vibes)        │
│                                                        │
│   01  PARSER          → AST has fields?                │
│   02  LLM_SANITY      → Output is valid Zod?           │
│   03  FIELD_PARITY    → len(cobol) == len(ts) ?        │
│   04  DARK_CORNER     → REDEFINES → discriminatedUnion?│
│   05  MOCK_STRUCTURE  → Roundtrip mock JSON valid?     │
│                                                        │
│   ALL PASS  ──────────────────────────────────────►    │
│   ANY FAIL  ──┐                                        │
└───────────────┼────────────────────────────────────────┘
                │
                ▼
┌────────────────────────────────────────────────────────┐
│  Burned Book — historical-failure corpus               │
│  • Hash AST shape, look up matching past failures      │
│  • Extract anti-patterns ("do not flatten REDEFINES")  │
│  • Inject anti-patterns into the next prompt           │
│  • Re-run with the larger model                        │
│  • Two-model consensus required before output emits    │
└─────────┬──────────────────────────────────────────────┘
          │   verified output
          ▼
┌────────────────────────────────────────────────────────┐
│  Verified Output                                       │
│  • TypeScript Zod schema (z.object + discriminatedUnion│
│    + dynamic z.array for OCCURS DEPENDING ON)          │
│  • Plain-English documentation                         │
│  • Mock JSON for frontend dev                          │
│  • Engagement hash added to corpus for future runs     │
└────────────────────────────────────────────────────────┘
```

---

## The Burned Book — how past failures become guardrails

Every translation that has ever failed Gate 3 (FIELD_PARITY) or Gate 4
(DARK_CORNER) is anonymized, hashed by AST shape, and stored in a local
corpus we call the Burned Book. The hash captures the *structural
fingerprint* of the failure — the levels, the REDEFINES topology, the
nesting depth of OCCURS clauses — without retaining any of the original
COBOL text. Two different banks running totally different copybooks but
sharing the same nested-REDEFINES shape produce the same Burned Book entry,
so the failure signal compounds across customers without ever leaking one
customer's data to another.

When the engine drafts a candidate translation and a gate fails, it queries
the Burned Book for the closest matching past failures. The corresponding
anti-patterns — literal text fragments like *"do not flatten REDEFINES into
a single object — must use z.discriminatedUnion"* — are injected directly
into the second-pass prompt with a *DO NOT DO THIS* directive. The model is
shown what *not* to write, drawn from real production failures across every
prior engagement. Every customer's failure makes the next customer's
translation safer, and the corpus only ever grows.

---

## The Five Quality Gates

Every translation must pass all five before output emits. Failures escalate
to the Burned Book → Consensus Engine recovery loop described above.

- **01 · `PARSER`** — Tree-sitter must extract a non-empty AST with at least
  one field-bearing record. Fields not present in the AST cannot exist in
  the output. Pure determinism — no LLM involvement.
- **02 · `LLM_SANITY`** — Generated TypeScript must parse cleanly: valid Zod
  imports, no markdown code-fence wrappers, no commentary, no hallucinated
  type imports. Catches the most common class of LLM failure (returning a
  prose explanation instead of code).
- **03 · `FIELD_PARITY`** — Strict count equality:
  `len(cobol_fields) == len(typescript_properties)`. If the count differs by
  even one, the build fails. Math, not judgment. There is no confidence
  threshold and no human-in-the-loop required to interpret the result — the
  diff is the verdict.
- **04 · `DARK_CORNER`** — Every `REDEFINES` clause in the AST must compile
  to a `z.discriminatedUnion` in the output. Every `OCCURS DEPENDING ON`
  must compile to a dynamic `z.array`. Catches the second most common class
  of LLM failure (flattening memory unions into a single record, or mapping
  variable-length arrays to fixed tuples).
- **05 · `MOCK_STRUCTURE`** — The engine generates a mock JSON document
  from the schema, then validates it against the schema again. If the
  round-trip fails, the schema is internally inconsistent regardless of
  what the field-parity gate said.

A sixth phase — `CONSENSUS_ENGINE` — activates only when Gates 3 or 4 fail.
Two independent models must agree on the recovered output (cosine similarity
≥ 0.95) before any code is allowed to emit.

---

## Sample copybooks

The `samples/` directory ships with three real ACORD AL3 / standard
mainframe copybooks used as goldens for the engine's regression suite:

- **`ACORD_AL3_NIGHTMARE.CPY`** — 84 fields, 2 nested `REDEFINES`, 2 nested
  `OCCURS DEPENDING ON`. The hardest known ACORD AL3 transmission record;
  every standard LLM falls apart on it. This is the file in the public
  benchmark at [killsesh.com/benchmark](https://killsesh.com/benchmark).
- **`ACORD_MINI_NIGHTMARE.CPY`** — A reduced version for fast unit tests
  and CI. Same structural classes (REDEFINES + ODO) at smaller scale.
- **`ACCTREC.CPY`** — Standard mainframe account record. The "easy mode"
  baseline — if a translator can't pass this clean, it has no business
  attempting AL3.

---

## What this repo contains

- ✅ Architecture documentation (above)
- ✅ The 5 Quality Gates spec
- ✅ The Burned Book mechanism explained
- ✅ Sample ACORD AL3 copybooks (real, anonymized)
- ✅ MIT-licensed reference material

## What this repo does NOT contain

This is the **open spec**, not the full implementation. Specifically out of
scope here, by design:

- ❌ The model orchestration code, prompt templates, and gate runner
- ❌ The curated Burned Book corpus (12,847 historical failures and growing)
- ❌ The web UI, the live trace player, or the marketing surface

The complete engine ships as an **air-gapped Docker tarball** that runs
entirely inside your VPC — no cloud, no API keys, no telemetry. Get it at:

> **[killsesh.com/downloads](https://killsesh.com/downloads/killsesh-enterprise-v0.1.0.tar.gz)**

Verify it before you run it: every step of the audit trail is documented at
[killsesh.com/demo](https://killsesh.com/demo).

For enterprise pilots (mainframe-scale, $250k+ engagements) →
[enterprise.killsesh.com](https://enterprise.killsesh.com).

---

## Why this exists as an open spec

Banks don't trust black boxes. Every modernization vendor claims their AI
"won't hallucinate" — and every one of them ships output their customers
have to manually audit before merging. KillSesh inverts that contract: the
audit happens *inside* the pipeline, deterministically, before code emits.
The spec is open so any reviewer — your CTO, your security team, an HN
commenter — can verify the architecture is sound *without* trusting us.

The implementation is the moat. The spec is the trust signal.

---

## License

MIT. See [LICENSE](./LICENSE).

The samples are real ACORD AL3 structures; ACORD® is a registered
trademark of ACORD Corporation, used here for interoperability and
reference. Sample copybooks contain no policyholder data, no carrier
identifiers, and no PII.
