---
name: token-efficiency
description: >
  Standing rules for keeping Claude Code sessions lean. Apply always. Covers scope limits, output caps, delta context, command macros, and context gate. Triggers on "token efficiency", "keep it lean", "compress context", or /token-efficiency.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Token Efficiency Rules

Apply these rules in every session. They are not optional.

## 1. Reason Internally — Output Minimal

Reason internally. Return only the final answer or action. Do not show chain-of-thought unless explicitly asked. No "here's what I'm thinking..." preambles.

## 2. Specify Scope Before Reading Files

Never read the entire repo. Always specify which directories to analyze. Example:

> Analyze only: `ghcs/intake/` and `ghcs/forms/`. Ignore all other directories.

If scope is not given, ask before reading broadly.

## 3. Delta Context

Do not resend full context when updating. Say:

> Previous context still applies. New change: [single update only].

Only the delta gets processed.

## 4. Cap Output Size

Default response limit: 200 tokens for answers, 500 tokens for documents, unlimited for code.
If a shorter answer is possible, use it.
User can override: "give me full detail" or "expand this."

## 5. Context Gate

If the conversation exceeds ~2000 tokens of back-and-forth context, compress:
- Summarize prior conversation to bullet facts only
- Discard redundant dialogue
- Continue from compressed state

## 6. Pre-Index Knowledge

Do not re-read full reference docs on every run. Use the indexed knowledge files:

**EAbrain:**
- `context/work.md` — business facts
- `references/sops/` — operating procedures
- `.claude/rules/home-care-compliance.md` — compliance rules

**AIBizPros:**
- `references/AI_AUTOMATION_LIBRARY.md` — automation blueprints
- `references/AI_SALES_PLAYBOOK.md` — sales process
- `references/TARGET_CLIENT_PROFILES.md` — client profiles

Reference by filename, not by re-reading the full content.

## 7. GHCS Command Macros

Short commands that expand to full workflows. Use these instead of long prompts:

| Command | What It Does |
|---------|-------------|
| `ghcs intake` | Run lead intake qualifier on a new referral |
| `ghcs leads` | Show pipeline status — who needs follow-up today |
| `ghcs referral` | Generate outreach script for a new referral source |
| `ghcs content` | What to post today on social media |
| `ghcs verify [name]` | Verify NPI + payer eligibility for a lead |
| `ghcs recruit` | Generate caregiver job posting or screening questions |

## 8. AIBizPros Command Macros

| Command | What It Does |
|---------|-------------|
| `biz qualify [prospect]` | Run prospect-qualifier on a new lead |
| `biz outreach [name/company]` | Write LinkedIn + cold email for a prospect |
| `biz prep [prospect]` | Build discovery call brief |
| `biz proposal [notes]` | Generate proposal from discovery notes |
| `biz pipeline` | Show prospect tracker status |
