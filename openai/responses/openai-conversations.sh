#!/bin/bash

[ -f .env ] && set -a && source .env && set +a
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)"

# ==================================
# ====== OpenAI Responses API ======
# ==================================

###
# Generate conversation from OpenAI using new OpenAI Responses API
# @see https://platform.openai.com/docs/api-reference/conversations/create

# MODEL="gpt-5"
INPUT="Hello!"

curl https://api.openai.com/v1/conversations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"metadata\": \"{\"topic\": \"demo\"}\",
    \"items\": [
      {
        \"type\": \"message\",
        \"role\": \"user\",
        \"content\": \"$INPUT\"
      }
    ]
  }" > $SCRIPT_DIR/openai-conversations.response.json
