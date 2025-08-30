#!/bin/bash

[ -f .env ] && set -a && source .env && set +a
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)"

# ==================================
# ====== OpenAI Responses API ======
# ==================================

###
# Generate response from OpenAI using new OpenAI Responses API
# @see https://platform.openai.com/docs/guides/text
# @see https://platform.openai.com/docs/api-reference/responses

MODEL="gpt-5"
INPUT="Write a one-sentence bedtime story about a unicorn."

curl "https://api.openai.com/v1/responses" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $OPENAI_API_KEY" \
    --data "{
        \"model\": \"$MODEL\",
        \"input\": \"$INPUT\"
    }" > $SCRIPT_DIR/openai-responses.response.json