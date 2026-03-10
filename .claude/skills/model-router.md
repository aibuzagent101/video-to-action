---
name: model-router
description: >
  Routes tasks to the right model based on complexity and type. Use before starting any significant task to pick the right model. Triggers on "which model", "route this", "what model should I use", or /model-router. Also triggers automatically when a task type is identified.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Model Router

Pick the cheapest model that can do the job. Don't use Opus for a yes/no question. Don't use Haiku for architecture design.

## Routing Table

### Tier 1 — Haiku (60% of tasks)
**Model:** `claude-haiku-4-5-20251001`
**Use for:**
- Classification — "is this a lead?", "does this qualify?", "what category is this?"
- Triage — routing decisions, priority sorting, tagging
- Yes/No decisions — eligibility checks, pass/fail evaluations
- Simple extraction — pull a field from a document, parse structured data
- Short summaries — 1-3 sentence recaps of known content
- Status checks — "is this done?", "what's the current state?"
- Repetitive batch tasks — same operation across many items

**Trigger words:** classify, triage, qualify, check, is this, does this, yes or no, sort, tag, extract, parse, quick

---

### Tier 2 — Sonnet or GPT-4.1 (35% of tasks)
**Model:** `claude-sonnet-4-6` or `gpt-4.1`
**Use for:**
- Code generation — writing functions, scripts, automation modules
- Research — gathering and synthesizing information from multiple sources
- Analysis — interpreting data, comparing options, drawing conclusions
- Writing — emails, proposals, outreach, content drafts
- Multi-step reasoning — tasks requiring more than 2-3 logical steps
- Discovery call prep, proposal building, outreach writing
- Make.com scenario design, automation blueprints

**When to use GPT-4.1 vs Sonnet:**
- Code with lots of tool use or function calling → GPT-4.1
- Writing, reasoning, Claude-native tasks → Sonnet

**Trigger words:** write, build, code, research, analyze, compare, explain, draft, design, generate

---

### Tier 3 — Opus (5% of tasks)
**Model:** `claude-opus-4-6`
**Use for:**
- Architecture decisions — system design, major structural choices
- Complex planning — multi-week project plans, dependency mapping
- Deep review — auditing critical code, compliance review, security analysis
- Hard reasoning — problems where Sonnet has failed or given weak answers
- High-stakes output — anything going to a client, regulator, or investor

**Only use Opus when:**
- The task is one you'd ask your most senior expert
- Sonnet gave an answer you don't trust
- The output has real consequences if wrong

**Trigger words:** architect, plan, review, audit, design the system, strategy, high-stakes

---

## Decision Process

1. Read the task
2. Match to a tier using the table above
3. If unsure between tiers, go one tier up (err toward quality, not cost)
4. State the model choice before starting:
   > "Routing to Haiku — this is a classification task."
   > "Routing to Sonnet — this requires code generation."
   > "Routing to Opus — this is architecture-level planning."

## Cost Reference

| Model | Relative Cost | Use |
|-------|--------------|-----|
| Haiku | 1x | Fast, cheap, high-volume |
| Sonnet | ~6x | Balanced quality/cost |
| GPT-4.1 | ~5x | Strong at code + tool use |
| Opus | ~18x | Reserve for hardest problems |

## Standing Rules

- Default model for all sessions: Haiku
- Do NOT use Opus unless the task clearly qualifies
- If a Haiku answer looks wrong, escalate to Sonnet — don't retry Haiku
- Batch tasks (same operation × many items) always go to Haiku
- Client-facing final output: at minimum Sonnet
