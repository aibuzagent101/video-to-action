# Video-to-Action — Product Overview

## What It Is
A cross-business AI skill that uses Gemini as a video analysis passthrough to extract actionable steps from YouTube videos, tutorials, and demos. Claude queries Gemini about video content and converts it into executable instructions.

## The Core Insight
Claude can't watch video natively. Gemini can analyze YouTube videos directly. The solution: send Gemini the video URL, ask structured questions, get back a clean extraction, then Claude executes against that extraction. A 30-minute tutorial becomes an executable procedure.

## What It Does
- Accepts a YouTube URL + user intent
- Queries Gemini in 2–3 structured passes (overview, step-by-step, technical details)
- Compiles a structured procedure document
- Executes the steps OR delivers the summary, depending on intent

## What Gemini Can Extract
- Spoken instructions, on-screen text, code shown on screen
- UI interactions, settings, values mentioned
- Terminal commands, file paths, dependencies

## Intended Use
- Internal: across EAbrain (GHCS) and AIBizPros workflows
- External: deployable to clients as a billable skill/product

## Stack
- Gemini MCP (`gemini-design` server, `execute_task` tool)
- Claude API (orchestration, execution)
- Output: `active/video-actions/{video-title}.md`

## Trigger Phrases
"watch this video", "learn from this video", "extract steps from video", "video to action", "analyze this YouTube", "what does this tutorial show", "turn this video into steps", "learn from this tutorial", `/video-to-action`
