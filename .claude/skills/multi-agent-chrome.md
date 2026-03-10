---
name: multi-agent-chrome
description: Orchestrate parallel browser automation using multiple Chrome DevTools MCP instances. Use when a task requires doing the same browser action across many targets simultaneously (e.g., submitting contact forms, filling applications, scraping pages that need JS rendering). Spin up 1-5 parallel Chrome agents.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Multi-Agent Chrome Orchestrator

Spin up 1-5 parallel Claude Code agents, each with its own Chrome browser, to do browser tasks concurrently.

## When to Use

- Submitting contact forms across a list of websites
- Filling out applications on multiple platforms
- Scraping JS-rendered pages that need real browser interaction
- Any repetitive browser task where doing it sequentially is too slow

## Architecture

```
{PROJECT_ROOT}/active/multi-chrome-agent/
├── chat.md                    # Shared coordination file
├── launch_chrome.sh           # Spawns Chrome instances on ports 9223-9227
├── kill_chrome.sh             # Tears down all Chrome instances
├── agent-CLAUDE.md            # Template — copy into each chrome-agent-N/ as CLAUDE.md
├── chrome-agent-1/            # Workspace for Agent 1
│   ├── .mcp.json              # Chrome DevTools on port 9223
│   └── CLAUDE.md              # Agent behavior instructions (copy from agent-CLAUDE.md)
├── chrome-agent-2/            # Port 9224
├── chrome-agent-3/            # Port 9225
├── chrome-agent-4/            # Port 9226
└── chrome-agent-5/            # Port 9227
```

## Step-by-Step Orchestration

### 1. Determine how many agents are needed

Look at the task. If there are 10 contact forms to fill, 3-5 agents is good. If there are 3, use 2-3. Don't over-provision.

### 2. Set up agent directories

For N agents, create their folders and copy the CLAUDE.md template:

```bash
BASE=active/multi-chrome-agent
for i in $(seq 1 N); do
    mkdir -p "$BASE/chrome-agent-$i"
    cp "$BASE/agent-CLAUDE.md" "$BASE/chrome-agent-$i/CLAUDE.md"
done
```

Then create the `.mcp.json` for each agent (port 9223 for agent 1, 9224 for agent 2, etc.):

```json
{
  "mcpServers": {
    "chrome": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "env": { "PUPPETEER_LAUNCH_OPTIONS": "{\"args\":[\"--remote-debugging-port=9223\"]}" }
    }
  }
}
```

Change the port number per agent.

### 3. Launch Chrome instances

```bash
bash active/multi-chrome-agent/launch_chrome.sh [COUNT]
```

This spawns `COUNT` Chrome instances on ports 9223+. Wait for the "READY" confirmation for each.

### 4. Reset the chat file

Clear the chat file and write task assignments:

```markdown
# Multi-Chrome Agent Chat

## Orchestrator
[2026-03-10 09:00] Launching 3 agents for contact form submission.

### Agent 1 Tasks
1. Go to https://example1.com/contact -> fill name, email, message
2. Go to https://example2.com/contact -> same form fill

### Agent 2 Tasks
1. Go to https://example3.com/contact -> fill form
2. Go to https://example4.com/contact -> fill form

### Agent 3 Tasks
1. Go to https://example5.com/contact -> fill form
2. Go to https://example6.com/contact -> fill form

## Agent 1

## Agent 2

## Agent 3
```

### 5. Spawn Claude Code agents

Open N terminal tabs manually (Linux/ChromeOS — no osascript):

```
Tab 1: cd active/multi-chrome-agent/chrome-agent-1 && claude
Tab 2: cd active/multi-chrome-agent/chrome-agent-2 && claude
Tab 3: cd active/multi-chrome-agent/chrome-agent-3 && claude
```

Each agent will:
- Pick up its CLAUDE.md (browser worker instructions)
- Connect to its Chrome instance via its local .mcp.json
- Read chat.md for its task assignments
- Execute tasks and report status back to chat.md

### 6. Monitor progress

Read the chat file periodically to check agent status:

```bash
cat active/multi-chrome-agent/chat.md
```

Look for `[DONE]`, `[ERROR]`, or `[WORKING]` tags from each agent.

### 7. Tear down

When all agents report `[DONE]`:

```bash
bash active/multi-chrome-agent/kill_chrome.sh
```

## Chat Protocol

Agents communicate via the shared chat.md file:

| Tag | Meaning |
|-----|---------|
| `[WORKING]` | Agent is actively processing a task |
| `[DONE]` | Agent completed all assigned tasks |
| `[ERROR]` | Agent hit a blocker (CAPTCHA, timeout, etc.) |
| `[WAITING]` | Agent is idle, waiting for new tasks |

## Port Map

| Agent | Chrome Port | Workspace |
|-------|------------|-----------|
| 1 | 9223 | chrome-agent-1/ |
| 2 | 9224 | chrome-agent-2/ |
| 3 | 9225 | chrome-agent-3/ |
| 4 | 9226 | chrome-agent-4/ |
| 5 | 9227 | chrome-agent-5/ |

Port 9222 is reserved for the main (non-parallel) Chrome DevTools MCP.

## Edge Cases

- **CAPTCHA:** Agent reports `[ERROR] CAPTCHA on https://...` in chat. Orchestrator can reassign or skip.
- **Rate limiting:** Spread URLs across more agents so each hits the site fewer times.
- **Login required:** Pre-authenticate in each Chrome instance before assigning tasks, or include login steps in the task list.
- **Long-running tasks:** If the orchestrator needs to abort, write `[ABORT]` in the Orchestrator section of chat.md.
