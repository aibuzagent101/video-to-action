---
name: video-to-action
description: >
  Use Gemini as a video analysis passthrough to extract actionable steps from YouTube videos, tutorials, and demos. Claude calls the Gemini API via bash to analyze video content and converts it into executable instructions. Triggers on "watch this video", "learn from this video", "extract steps from video", "video to action", "analyze this YouTube", or /video-to-action. Also triggers on phrases like "what does this tutorial show", "turn this video into steps", or "learn from this tutorial".
allowed-tools: Read, Grep, Glob, Bash, Task, Write, Edit
---

# Video-to-Action via Gemini Passthrough

Claude can't watch video natively. But Gemini can analyze YouTube videos. Use Gemini as a passthrough: call the Gemini API with the video URL, ask structured questions, get back actionable steps that Claude can execute.

**Why this works:** A 30-minute tutorial becomes executable instructions. Course content, documentation videos, product demos — all become agent-parseable. You don't need Claude to "see" the video — you need a structured extraction of what the video teaches, then Claude executes against that extraction.

## Setup

**Script:** `scripts/gemini-video.sh` — wraps the Gemini API call
**API key:** stored in `.env` as `GEMINI_API_KEY`
**Model:** `gemini-2.5-flash`

To call Gemini from anywhere in this project:
```bash
bash /home/kc0312/projects/Video-to-action/scripts/gemini-video.sh "YOUTUBE_URL" "YOUR PROMPT"
```

## Execution

### 1. Parse the request

Extract from the user's message:
- **Video URL** — YouTube link
- **Intent** — what the user wants
  - "Follow this tutorial" → extract and execute steps
  - "What does this video show?" → extract and summarize
  - "Learn this technique" → extract as a reusable procedure
- **Scope** — full video or specific section ("the part about X", "starting at 5:00")

If no URL is provided, ask for one. If intent is unclear, ask.

### 2. Query Gemini — Phase 1: Overview

```bash
bash /home/kc0312/projects/Video-to-action/scripts/gemini-video.sh \
  "VIDEO_URL" \
  "Analyze this YouTube video and provide a structured breakdown.

Provide:
1. VIDEO TITLE and approximate length
2. SUMMARY — what the video teaches in 2-3 sentences
3. PREREQUISITES — what tools, software, or knowledge is needed
4. MAIN SECTIONS — major sections with approximate timestamps
5. KEY OUTCOMES — what the viewer can do after watching

Be specific and concrete. Don't say 'the presenter shows techniques' — say what the techniques are."
```

Read the response. If the video can't be analyzed (private, unavailable), tell the user.

### 3. Query Gemini — Phase 2: Step-by-step extraction

```bash
bash /home/kc0312/projects/Video-to-action/scripts/gemini-video.sh \
  "VIDEO_URL" \
  "Extract detailed step-by-step instructions from this video.

For each major step:
1. STEP NUMBER and TITLE
2. TIMESTAMP — approximately when this step occurs
3. ACTION — what to do, in imperative form ('Click File > New', 'Set the value to 0.5')
4. DETAILS — specific values, settings, parameters shown
5. VISUAL REFERENCE — what the screen/result should look like after this step
6. COMMON MISTAKES — if the presenter mentions pitfalls, note them

Format as a numbered list. Be extremely specific about values, menu paths, and settings.
If the presenter says 'adjust to taste', note the value they actually used in the demo.

SCOPE: [insert scope constraint if user specified a section]"
```

### 4. Query Gemini — Phase 3: Technical details (coding/software content only)

```bash
bash /home/kc0312/projects/Video-to-action/scripts/gemini-video.sh \
  "VIDEO_URL" \
  "Extract all code, commands, configurations, and technical details from this video.

Extract:
1. All CODE SNIPPETS shown (reconstruct from what's visible)
2. All TERMINAL COMMANDS run
3. All CONFIGURATION values or settings changed
4. All FILE PATHS referenced
5. All DEPENDENCIES or PACKAGES installed
6. Any API keys, environment variables, or config needed (note if placeholder values)

For code: provide complete snippets, not fragments. If partially visible, note what's inferred.
For commands: provide exact command including flags and arguments."
```

### 5. Compile the procedure document

Combine all Gemini responses. Write to `active/video-actions/{sanitized-video-title}.md`:

```markdown
# {Video Title} — Extracted Procedure

**Source**: {video URL}
**Extracted**: {date}
**Intent**: {what the user wants to do with this}

## Prerequisites
- {tool/software 1}
- {knowledge requirement}

## Steps

### Step 1: {title} ({timestamp})
**Action**: {what to do}
**Details**: {specific values, settings}
**Expected result**: {what it should look like after}
{Common mistake warning if applicable}

## Code & Commands
{All extracted code snippets and commands, in order}

## Configuration
{All settings, env vars, config values mentioned}

## Notes
- {Caveats, version-specific details, or limitations}
```

### 6. Execute or deliver

**"Follow this tutorial" → Execute the steps**
- Work through the procedure step by step
- Use extracted code/commands directly
- If a step requires visual verification: "Step 5 requires visual confirmation — check that {expected result} before I continue"

**"What does this video show?" → Deliver the summary**
- Present overview and step list
- Don't execute anything
- Offer to execute if the user wants

**"Learn this technique" → Save as reusable procedure**
- Write to a permanent location (not `active/`)
- Strip video-specific details, generalize where appropriate

### 7. Handle limitations

- **Can extract**: Spoken instructions, on-screen text, code shown, UI interactions, settings and values
- **Partially reliable**: Code that's partially visible, fast-scrolling content
- **Cannot extract**: Subtle visual techniques, audio-only cues with no verbal description

Flag low-confidence steps:
```
Step 7: {title}
WARNING: LOW CONFIDENCE — visual technique may not be fully captured.
The video shows: {best description available}
Recommend: Watch {timestamp} directly for this step.
```

## Multi-video learning

1. Extract procedures from each video separately
2. Merge into a single procedure, resolving conflicts (later videos override earlier ones)
3. De-duplicate steps that appear in multiple videos
4. Note where videos disagree on approach

## Edge cases

- **Video unavailable/private**: Tell the user. Suggest they provide a transcript instead.
- **Not a tutorial**: Still extract key claims, demonstrated results, referenced tools. Note it's not step-by-step content.
- **Very long video (1hr+)**: Ask which section matters. Analyze in segments if they want the full thing.
- **Non-English video**: Gemini handles many languages. Note potential translation artifacts.
- **Extracted code doesn't work**: Common — video code is often partial or has typos. Flag inferred parts for user to verify.
- **Outdated content**: Note version discrepancies if tools/APIs have newer versions.

## Output files

| File | Description |
|------|-------------|
| `active/video-actions/{video-title}.md` | Extracted procedure document |

One file per video. Not overwritten across different videos.
