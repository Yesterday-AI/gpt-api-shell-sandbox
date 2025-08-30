#!/bin/bash

[ -f .env ] && set -a && source .env && set +a
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)"

# =========================================
# ====== OpenAI Chat Completions API ======
# =========================================

###
# Generate response from OpenAI using Chat Completions API
# @see https://platform.openai.com/docs/api-reference/chat/create

MODEL="gpt-5"
SYSTEM_PROMPT="You are a helpful assistant."
INPUT="Hello!"

curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [
      {
        \"role\": \"developer\",
        \"content\": \"$SYSTEM_PROMPT\"
      },
      {
        \"role\": \"user\",
        \"content\": \"$INPUT\"
      }
    ]
  }" > $SCRIPT_DIR/openai-chat-completions.response.json
