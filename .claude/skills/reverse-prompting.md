---
name: reverse-prompting
description: >
  Force the agent to ask clarifying questions before starting work. The agent surfaces its own assumptions, the user disambiguates, and only then does it proceed. Triggers on "reverse prompt", "ask me questions first", "what questions do you have", "clarify before starting", "surface assumptions", or /reverse-prompting. Also triggers on phrases like "don't start until you ask me", "what do you need to know", or "ask before building".
allowed-tools: Read, Grep, Glob, Bash, Task, Write, Edit, AskUserQuestion
---

# Reverse Prompting

Before touching anything, ask the user exactly 5 clarifying questions that would most change your approach. Do not proceed until they answer. Surface your own assumptions, let the user disambiguate, then build with high-quality context.

**Why this works:** The most expensive agent failures are silent assumption failures — confidently building the wrong thing because you assumed REST when they meant GraphQL, or assumed a new file when they wanted to extend an existing one. Reverse prompting makes those assumptions visible and fixable before they're expensive. The 5-question constraint forces you to prioritize which unknowns matter most.
