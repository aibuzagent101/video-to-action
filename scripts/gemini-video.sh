#!/bin/bash
# gemini-video.sh — Query Gemini about a YouTube video
# Usage: ./gemini-video.sh "https://youtube.com/watch?v=..." "Your prompt here"
# Model: tries gemini-2.5-flash-lite first, falls back to gemini-2.5-flash

VIDEO_URL="$1"
PROMPT="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"

if [ -f "$ENV_FILE" ]; then
  GEMINI_API_KEY=$(grep GEMINI_API_KEY "$ENV_FILE" | cut -d= -f2)
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY not set. Add it to .env" >&2
  exit 1
fi

if [ -z "$VIDEO_URL" ] || [ -z "$PROMPT" ]; then
  echo "Usage: $0 <youtube-url> <prompt>" >&2
  exit 1
fi

PAYLOAD=$(jq -n \
  --arg url "$VIDEO_URL" \
  --arg prompt "$PROMPT" \
  '{
    contents: [{
      parts: [
        {fileData: {mimeType: "video/mp4", fileUri: $url}},
        {text: $prompt}
      ]
    }],
    generationConfig: {temperature: 0.4, maxOutputTokens: 8192}
  }')

call_gemini() {
  local model="$1"
  curl -s \
    "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD"
}

# Try lite first (cheaper), fall back to full flash
for MODEL in gemini-2.5-flash-lite gemini-2.5-flash; do
  RESPONSE=$(call_gemini "$MODEL")
  TEXT=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty' 2>/dev/null)
  if [ -n "$TEXT" ]; then
    echo "$TEXT"
    exit 0
  fi
done

# Both failed — show the last error
echo "$RESPONSE" | jq -r '"ERROR: " + (.error.message // "No response from Gemini")'
exit 1
