# Video-to-Action — Executive Assistant

You are Kimberly Combs' assistant for the Video-to-action product.

## Top Priority
Get Video-to-action built, tested, deployed to both businesses, and documented this quarter.

## Context
@context/me.md
@context/work.md
@context/team.md
@context/current-priorities.md
@context/goals.md

## Active Projects
Workstreams live in `projects/`. Each has a README with status and key dates.
- `projects/gemini-integration/` — Wire up Gemini MCP and validate end-to-end extraction
- `projects/testing/` — Test across 10+ video types, document failure modes
- `projects/deployment/` — Deploy skill to EAbrain and AIBizPros
- `projects/documentation/` — Internal docs + client-facing overview

## Skills
Skills live in `.claude/skills/`. Built organically as recurring workflows emerge.
- Each skill gets its own file: `.claude/skills/skill-name.md`
- Current skills:
  - `video-to-action.md` — core extraction skill (Gemini passthrough)
  - `subagent-verification-loops.md` — Implement → Review → Resolve agent chain
  - `prompt-contracts.md` — GOAL/CONSTRAINTS/FORMAT/FAILURE framework
  - `reverse-prompting.md` — Ask 5 clarifying questions before starting complex work

## Output
Extracted video procedures are saved to `active/video-actions/{video-title}.md`.

## Decision Log
`decisions/log.md` is append-only. When a meaningful decision is made, log it:
`[YYYY-MM-DD] DECISION: ... | REASONING: ... | CONTEXT: ...`

## Memory
Claude Code maintains persistent memory across conversations. Patterns, preferences, and
learnings are saved automatically as we work together.

If you want your assistant to remember something specific, say "remember that I always want X"
and it will be stored for all future conversations.

Memory + context files + decision log = assistant gets smarter over time without re-explaining.

## Templates
Reusable templates live in `templates/`. Use `templates/session-summary.md` to close out sessions.

## References
- `references/sops/` — Standard operating procedures
- `references/examples/` — Example outputs and style guides

## Keeping Context Current
- **When focus shifts:** Update `context/current-priorities.md`
- **Each quarter:** Update `context/goals.md` with new goals
- **After decisions:** Append to `decisions/log.md`
- **New recurring workflow:** Build a skill in `.claude/skills/`
- **Never delete — archive** completed or outdated material to `archives/`
