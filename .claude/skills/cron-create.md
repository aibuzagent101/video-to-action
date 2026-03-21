---
name: cron-create
description: >
  Create reminders, scheduled tasks, and cron jobs for any project. Triggers on "set a reminder", "remind me", "schedule reminder", "add to cron", "cron job", "check reminders", "what do I have scheduled", "done with task", "stop reminders", or /cron-create. Covers social media posting, emails, calendar events, project tasks, lead follow-ups, OMPP updates, and any recurring or one-time task across EAbrain, AIBizPros, and Video-to-action. Works via text and voice (voice-claude).
allowed-tools: Read, Bash, Write, Edit
---

# Cron Create — Reminder & Scheduler Skill

Two types of reminders:
- **Session reminders** — fire while Claude/VSCode is open, stop automatically when session ends or task is done
- **Persistent reminders** — cron jobs for recurring events (social posting, weekly check-ins, etc.)

Always give Kimberly the exact command to run. Always confirm what the reminder is for and when it fires.

---

## Paths
- **Session reminder log:** `/home/kc0312/reminders/session-reminders.log`
- **Persistent reminder log:** `/home/kc0312/reminders/reminders.log`
- **Session PID file:** `/home/kc0312/reminders/session.pid`
- **Scripts dir:** `/home/kc0312/scripts/`

## Scripts
| Script | Purpose |
|---|---|
| `remind.sh "msg" "project"` | Add a persistent reminder to log |
| `session-remind.sh [interval_min]` | Start session loop (background) |
| `stop-reminders.sh` | Stop session loop + clear session reminders |
| `done-task.sh "keyword"` | Mark task done, remove matching reminder |
| `check-reminders.sh` | Show all pending reminders + crontab |

---

## Decision Tree — Which type to use?

**Use SESSION reminders when:**
- "remind me every 15 min while I work on this"
- "remind me in 30 min to check on X"
- "remind me until I finish [task]"
- Any reminder tied to current work session

**Use CRON (persistent) reminders when:**
- "remind me every Monday at 9am"
- "remind me Mon/Wed/Fri to post on LinkedIn"
- "remind me on the 1st of every month"
- Recurring business tasks that should survive reboots

---

## Cron Frequency Reference

| How often | Cron expression |
|---|---|
| Every 15 minutes | `*/15 * * * *` |
| Every 30 minutes | `*/30 * * * *` |
| Every hour | `0 * * * *` |
| Daily at 9am | `0 9 * * *` |
| Mon/Wed/Fri at 9am | `0 9 * * 1,3,5` |
| Every weekday at 8am | `0 8 * * 1-5` |
| Weekly Monday 9am | `0 9 * * 1` |
| 1st of every month | `0 9 1 * *` |

---

## Trigger Phrases
- "set a reminder to..."
- "remind me every 15 minutes to..."
- "remind me until I'm done with..."
- "remind me daily / weekly / Mon-Wed-Fri..."
- "stop reminders" / "I'm done"
- "check my reminders"
- "what do I have scheduled"
- "done with [task]"
- `/cron-create`

---

## What to Remind About (Examples)
- Social media posting (LinkedIn, Facebook — Mon/Wed/Fri)
- Lead follow-up calls and emails
- OMPP / Medicaid status check-ins
- Calendar events and meetings
- Hospital outreach follow-ups
- Client intake tasks
- Content calendar deadlines
- AIBizPros prospect outreach
- Video-to-action script runs

---

## Execution

### For SESSION reminders

**Step 1** — Add the reminder to the session log:
```bash
echo "[REMINDER TEXT] — [PROJECT]" >> /home/kc0312/reminders/session-reminders.log
```

**Step 2** — Start the loop if not already running:
```bash
# Check if already running
cat /home/kc0312/reminders/session.pid 2>/dev/null

# Start it (replace 15 with desired interval in minutes)
bash /home/kc0312/scripts/session-remind.sh 15 &
```

**Step 3** — Output to Kimberly:
```
Run this to start your session reminder (fires every [N] minutes):

echo "[MESSAGE] — [PROJECT]" >> /home/kc0312/reminders/session-reminders.log && bash /home/kc0312/scripts/session-remind.sh [N] &

Your reminder: [plain English — what it says, how often, stops when session ends or you say "done"]
```

**To stop / mark done:**
```
bash /home/kc0312/scripts/stop-reminders.sh
# or remove just one task:
bash /home/kc0312/scripts/done-task.sh "keyword"
```

---

### For CRON (persistent) reminders

**Step 1** — Build the cron entry:
```
[cron expression] /home/kc0312/scripts/remind.sh "[MESSAGE]" "[PROJECT]"
```

**Step 2** — Give Kimberly the exact command:
```
Run this command to add your reminder:

(crontab -l 2>/dev/null; echo "[CRON ENTRY]") | crontab -

Your reminder: [plain English — what it says, when it fires, runs every session]
```

**Step 3** — Confirm it was added:
```bash
crontab -l
```

---

## Stopping / Clearing

| Action | Command |
|---|---|
| Stop session loop | `bash /home/kc0312/scripts/stop-reminders.sh` |
| Mark one task done | `bash /home/kc0312/scripts/done-task.sh "keyword"` |
| Clear all persistent | `rm /home/kc0312/reminders/reminders.log` |
| **Cancel cron reminder early** | `bash /home/kc0312/scripts/crondelete.sh "keyword"` |

### crondelete — Cancel Any Cron Reminder Early

When Kimberly says "crondelete [reminder name]" or "cancel the [task] reminder":
1. Run: `bash /home/kc0312/scripts/crondelete.sh "[keyword]"`
2. It removes any cron job matching that keyword and confirms what was removed
3. Terminal alias: `crondelete "keyword"` (after opening a new terminal)

Example: `bash /home/kc0312/scripts/crondelete.sh "LinkedIn"` removes the LinkedIn posting cron.

---

## Checking Reminders

When asked "check my reminders" or "what do I have scheduled":
1. Run `bash /home/kc0312/scripts/check-reminders.sh`
2. Run `crontab -l`
3. Check if session loop is running: `cat /home/kc0312/reminders/session.pid 2>/dev/null`
4. Present all three clearly

---

## Voice Claude Support

These commands work via voice-claude. When Kimberly speaks a reminder through voice interface:
- Claude receives the transcript and matches trigger phrases above
- Generates the appropriate command and reads it back
- Kimberly confirms and Claude runs it via Bash tool
- Confirmation is spoken back: "Your reminder is set. It will fire every [N] minutes."

Voice trigger examples:
- "Set a reminder every 15 minutes to follow up on leads"
- "Stop reminders"
- "Check my reminders"
- "I'm done with the intake task"

---

## Rules
- Always give the exact command — never make her figure it out
- Always say plainly what the reminder is for and when it fires
- Session reminders: confirm they stop when session ends or task is marked done
- Cron reminders: confirm they persist across reboots
- 15-minute interval: confirm that's what she wants before setting it
- If cron is not running: `sudo service cron start`
- Never leave orphaned reminders running — always tell her how to stop them
