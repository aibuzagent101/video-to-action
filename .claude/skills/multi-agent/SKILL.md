# Skill: Multi-Agent System Architecture

## Trigger
"build a multi-agent system", "set up agents", "multi-agent", `/multi-agent`

## Purpose
Design and run deterministic multi-agent pipelines where each agent has one job
and cannot act outside its scope. Router classifies first — no agent runs blind.

---

## Layer 1 — Intent Router (Command Control)

**Job:** Classify the command before any agent runs. Never skip this step.

**Rule #1 — Router must classify before any agent runs.**

Classification logic:

| Trigger keywords | Routes to |
|---|---|
| `run`, `execute` | Shell / VS Code task runner |
| `open` | Editor / file navigation |
| `create code`, `build a`, `implement`, `refactor`, `debug` | Developer agent |
| `generate leads`, `prospect`, `outreach`, `automation`, `website for` | AIBizPros agent |
| `intake`, `patient`, `caregiver`, `referral`, `medicaid`, `home care` | GHCS agent |
| (no match) | Claude planner (fallback) |

**Example:**
> "Hey Claude build a waiver eligibility checker."
> → matches `build a` → routes to Developer agent

---

## Layer 2 — Orchestrator / Planner Agent

**Job:** Break the classified task into an atomic step plan. Never writes code directly.

**Rules:**
- **Rule #2** — Planner must break tasks into atomic steps.
- **Rule #3** — Each step must target a specific file or module.
- **Rule #4** — Planner cannot modify code directly.
- **Rule #5** — Planner must estimate dependencies before execution.

**Example instruction:** "Add oxygen dependency field to intake system."

**Planner output:**
```
TASK PLAN
1. Modify intake schema       → src/schema/intake.ts
2. Update validation logic    → src/validators/intake.ts
3. Update UI intake form      → src/components/IntakeForm.tsx
4. Update database migration  → db/migrations/add_oxygen_dependency.sql
5. Update tests               → tests/intake_schema.test.ts
6. Update documentation       → docs/intake-fields.md
```

---

## Layer 3 — Specialist Worker Agents

Each worker has one job only. Scope is enforced — agents do not cross boundaries.

### Backend Agent
- **Owns:** database schema, APIs, business logic, server architecture
- **Must not:** edit frontend files
- **Must:** follow repo conventions, generate migrations if schema changes

### Frontend Agent
- **Owns:** UI components, form updates, state management
- **Must not:** modify backend logic
- **Must:** ensure UI validation matches backend validation exactly

### Test Agent
- **Owns:** unit tests, integration tests, edge cases
- **Rule #6** — Every code change must generate tests.
- **Rule #7** — Test coverage cannot decrease.

**Example output from Test Agent:**
```
tests/intake_schema.test.ts
- oxygen_dependency defaults to false
- oxygen_dependency accepts boolean only
- validation rejects null oxygen_dependency
- integration: form submits with oxygen_dependency field
```

---

## Execution Flow

```
Voice / text command
        ↓
[Layer 1] Intent Router — classify the command
        ↓
[Layer 2] Planner — break into atomic steps with file targets
        ↓
[Layer 3] Worker agents run in parallel or sequence
        - Backend Agent
        - Frontend Agent
        - Test Agent
        ↓
Output verified — all steps complete
```

---

## Hard Rules Summary

| Rule | Requirement |
|---|---|
| #1 | Router classifies before any agent runs |
| #2 | Planner breaks tasks into atomic steps |
| #3 | Each step targets a specific file or module |
| #4 | Planner cannot modify code directly |
| #5 | Planner estimates dependencies first |
| #6 | Every code change generates tests |
| #7 | Test coverage cannot decrease |

---

## Voice System Integration (EAbrain)

The Layer 1 router is implemented in:
`voice-claude/src/router.js` — `detectIntent()` function

Intent categories logged as:
`Intent : RUN | OPEN | CODE | BIZ | GHCS | FALLBACK`

---

### Security Agent
Critical for healthcare and any system handling sensitive data.
- **Owns:** PHI exposure scanning, authentication enforcement, endpoint security, encryption rules
- **Rule #8** — No PHI may be logged.
- **Rule #9** — All sensitive routes require authentication.
- **Rule #10** — Data must be encrypted in transit.

### Documentation Agent
- **Owns:** README updates, API docs, developer notes
- **Rule #11** — Documentation must reflect the new architecture after every change.

---

## Layer 4 — Verification Layer

Quality control firewall. Nothing gets committed until all checks pass.

**Verification pipeline:**
```
code written → tests generated → tests executed → security scan → linting → approval → commit
```

**Rules:**
- **Rule #12** — If tests fail → rollback.
- **Rule #13** — If security scan fails → reject changes.
- **Rule #14** — If compile fails → retry with fix agent.

---

## Final Layer — Execution

Once verification passes:
- Git commit created
- Changes summarized
- Report sent to user

**Example output:**
```
Task Complete
Files modified : 5
Tests added    : 3
Security scan  : passed
Coverage       : 91%
```

---

## Full Execution Flow

```
Voice / text command
        ↓
[Layer 1] Intent Router — classify the command
        ↓
[Layer 2] Planner — atomic steps with file targets + dependency estimate
        ↓
[Layer 3] Worker agents (parallel where possible)
        - Backend Agent
        - Frontend Agent
        - Test Agent
        - Security Agent
        - Documentation Agent
        ↓
[Layer 4] Verification — tests, security scan, lint, compile
        ↓
[Execution] Commit + summary report
```

---

## AIBizPros Application — Business Automation Agent Teams

This architecture is the core product AIBizPros sells to clients.
Deploy agent teams for any business workflow, not just code.

### Example: "AI Sales Team" (client deliverable)

```
Lead Research Agent → Lead Qualification Agent → Email Generation Agent → CRM Update Agent → Follow-Up Agent
```

**Lead Research Agent**
- Tools: Apollo, Apify, LinkedIn scraping
- Rule #15 — Only collect verified business contacts.
- Rule #16 — No duplicate leads.

**Lead Qualification Agent**
- Job: determine if prospect fits ICP
- Rule #17 — Company must match industry criteria.
- Rule #18 — Employee count within target range.

**Email Generation Agent**
- Job: write personalized outreach
- Rule #19 — Must reference company-specific details.
- Rule #20 — Email length < 120 words.

**CRM Update Agent**
- Job: log all lead activity
- Rule #21 — Every interaction logged.
- Rule #22 — Lead status must update automatically.

**Follow-Up Agent**
- Job: send follow-up sequence
- Rule #23 — Maximum 4 follow-ups per prospect.
- Rule #24 — Stop immediately if prospect replies.

---

## Complete Rules Reference

| Rule | Requirement |
|---|---|
| #1 | Router classifies before any agent runs |
| #2 | Planner breaks tasks into atomic steps |
| #3 | Each step targets a specific file or module |
| #4 | Planner cannot modify code directly |
| #5 | Planner estimates dependencies first |
| #6 | Every code change generates tests |
| #7 | Test coverage cannot decrease |
| #8 | No PHI may be logged |
| #9 | All sensitive routes require authentication |
| #10 | Data must be encrypted in transit |
| #11 | Documentation must reflect new architecture |
| #12 | If tests fail → rollback |
| #13 | If security fails → reject changes |
| #14 | If compile fails → retry with fix agent |
| #15 | Only collect verified business contacts |
| #16 | No duplicate leads |
| #17 | Company must match industry criteria |
| #18 | Employee count within target range |
| #19 | Outreach must reference company-specific details |
| #20 | Email length < 120 words |
| #21 | Every interaction logged |
| #22 | Lead status must update automatically |
| #23 | Maximum 4 follow-ups per prospect |
| #24 | Stop if prospect replies |

---

## Example Client System — HVAC Company

**Agent pipeline:**
```
Market Scanner Agent
        ↓
Local Business Lead Agent
        ↓
Outreach Agent
        ↓
Appointment Booking Agent
```

**Outcome:**
- Leads sourced automatically
- Emails sent
- Appointments booked

This is a complete AI sales department sold as a packaged service.

---

## Why Multi-Agent Systems Work

Single AI tries to do everything → doesn't scale.
Specialization increases efficiency — nature proved this. AI is applying the same principle.

Each agent is scoped, testable, replaceable, and parallelizable.
The system as a whole is more reliable than any single model doing everything.

---

## The Frontier — Persistent Memory Agents

The most advanced systems add memory agents that persist across runs.

**What they remember:**
- Project history
- Past bugs and how they were resolved
- Architecture decisions and why they were made

Over time the system becomes a self-improving engineering organization —
it gets smarter about your specific codebase and business with every task.

**For AIBizPros:** This is the premium tier offering. A client system that learns
their business over time is worth significantly more than a one-time automation build.
