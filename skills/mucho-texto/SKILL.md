---
name: mucho-texto
description: Compress a wall of text into actionable bites for a founder running several threads at once. Use when the user says "mucho texto", "too long", "tl;dr this", "summarize that", "give me the bites", or invokes /mucho-texto — and proactively when a report, review, or agent result is about to be delivered as more than ~300 words of prose. Separates what needs a decision from what is merely worth knowing, and always points at the durable artifact.
---

# mucho-texto — decisions first, everything else after

*Mucho texto* is what you say when a wall of words hides the point. This skill exists because
that happened, repeatedly, to the same reader.

**Who reads the output:** a founder running several projects in one session, and returning to
them days later. He does not need to know how you got there. He needs to know **what is his
to decide, what changed in the world, and what is already handled.**

**Rule zero, and it constrains this file too:** a skill about brevity that runs 300 lines is
refuting itself. If you are adding to this document, cut something.

---

## 1. The one hard precondition

**Compression is only safe when the uncompressed version survives somewhere.**

Before you compress, confirm the full content exists in a durable artifact — a report file, a
ledger, a PR body, a decisions log. **End every summary with a pointer to it.**

If there is no artifact, say so in one line and offer to write one. **Never let a summary be
the only surviving record** — that is not compression, it is deletion.

---

## 2. Output shape

Four blocks, in this order, always. Drop a block entirely if it is empty — never write
"None."

```
**<Thread>: <one-line state of the world.>**

**DECIDE — n**
1. **<The question, as a question.>** <Why it is his, in one clause.>
   - **A:** <option> — <what it costs>
   - **B:** <option> — <what it costs>
   - <What waiting costs. Name what is blocked.>

**KNOW — n**
- <Finding that changes his mental model.> `file:line` or the number.

**RUNNING** — <what you are doing without him, one line.>

**PARKED** — <named once, explicitly not blockers.>

Full detail: `<path to the artifact>`
```

**Lead with the thread name** whenever the session has touched more than one project, or the
summary might be read cold days later. "Epic 2 stopped at gate 7.1" is useless in three days
if he cannot tell which repo it belongs to.

---

## 3. Caps — enforceable, not aspirational

| Block | Cap |
|---|---|
| Opening line | 1–2 sentences. State **and** headline. |
| `DECIDE` | **3 items max**, 4 lines each. More than 3? The top 3 surface; the rest live in the artifact and get one line saying how many. |
| `KNOW` | **5 items max**, one line each |
| `RUNNING` / `PARKED` | one line each |
| Whole thing | target **under 250 words**, hard ceiling 400 |

Over the cap means you are ranking badly, not that the work was complex. Rank harder.

---

## 4. Keep / drop

**Keep — the specifics that make an item decidable cold:**
file paths and line numbers · counts, deltas, costs · the exact option names · what breaks if
he does nothing · the artifact path.

**Drop — every time:**
how you found it · what you checked and it was fine · the reasoning chain · process narration
("I then verified…") · caveats that do not change the decision · your own mistakes, unless
they change what he should do. **Log those in the artifact; do not spend his attention on
them.**

**A finding with no consequence is not a finding.** If you cannot say what it changes, cut it.

---

## 5. Sorting, which is the actual work

Every item is exactly one of:

- **DECIDE** — needs him. He is the only one who can answer. Blocks something.
- **KNOW** — changes his model of the world but needs nothing from him today.
- **RUNNING** — you are handling it.
- **PARKED** — real, deliberately not now. **Name once.** Re-raising a parked item every
  session is its own kind of wall.

Most walls are walls because everything was flattened into one urgency. When in doubt an item
is `KNOW`, not `DECIDE` — a false `DECIDE` costs a real decision's attention.

---

## 6. What this skill must not do

- **Do not re-analyse.** You summarise what exists. If compressing reveals the original was
  wrong, say so in one line — do not silently fix it and do not re-litigate it here.
- **Do not soften.** Brevity is not optimism. A held gate is held; a failing test failed.
  If the news is bad, the one-liner says so.
- **Do not hedge to buy safety.** "It appears that possibly" is words he pays for and gets
  nothing back.

---

## 7. Worked example

**Before** — a real orchestrator report, ~650 words across 8 headers: outcome, findings,
decision, three side findings, two self-corrections, artifact paths.

**After:**

> **pokta-care / Epic 2: stopped at gate 7.1.** Wave 0 only, nothing built, 154k tokens
> (~17% of estimate). The spike proved arm 3 as specified is impossible — cheap catch.
>
> **DECIDE — 1**
> 1. **What does arm 3 retrieve with?** Study-design call, not engineering. All of Epic 2 is
>    stalled behind it.
>    - **A:** purpose-built persona-free retrieval — buildable now, but arms 2 and 3 then
>      differ by more than the persona, and the manuscript has to say so.
>    - **B:** keep RheumaAI's tools, inject their persistence — preserves the clean
>      comparison, touches arm 2's code.
>
> **KNOW — 3**
> - A structured call failing on OpenAI silently returns Gemini prose, 200, credited to the
>   wrong model. Benchmark data corruption. `llm/resilient.ts:84`
> - `STRUCTURED_LLM_MODEL=gpt-4o` is interpolated into a *Gemini* URL — the structured path
>   was never wired. `lab-interpretation/index.ts:63`
> - `USE_RERANKING` defaults ON when unset. `embeddings/config.ts:10`
>
> **PARKED** — uncommitted `.gitignore` fix in the fork; my two contract errors, logged in §7.
>
> Full detail: `docs/ultraplan-grader/EPIC-REPORT.md`

~180 words. Same decision, same evidence, nothing that needed the thread to understand.

**What got cut and why it was safe:** the verification narrative (ten claims re-checked — it
changes nothing he does), the autonomy audit, the self-correction section, and the circuit-
breaker list. All four survive in `EPIC-REPORT.md`, which the last line points at.

---

## 8. Proactive mode — the default

Fire without being asked whenever finished work is about to be delivered as more than ~300
words: a wave or epic report, a review, an agent result, a long investigation, a session wrap.

**The failure mode this must avoid: writing the wall and then compressing it.** That delivers
both and costs him more, not less. The order is:

1. **Write the artifact first** — complete, on disk. That is where the reasoning, the
   verification trail and your own errors go.
2. **Deliver only the bites**, ending with the artifact path.

The wall is never a deliverable. It is a file.

> This is not hypothetical. In the session this skill was written, a full `EPIC-REPORT.md`
> was written to disk **and** a 650-word chat message was delivered on top of it. The report
> was right; the message was the wall. Everything in it already existed one path away.

**Do NOT compress proactively when the reasoning IS the deliverable:** a design discussion, a
plan under review, an architecture trade-off, a question that deserves a real explanation, or
anything he asked to see in detail. Compression is for **reports of completed work**, not for
thinking together. When unsure, ask in one line — that costs less than either mistake.
