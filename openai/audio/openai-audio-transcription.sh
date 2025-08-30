#!/bin/bash

[ -f .env ] && set -a && source .env && set +a
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)"

# Transcribe audio file
# @see https://platform.openai.com/docs/guides/speech-to-text?lang=curl

curl -X POST https://api.openai.com/v1/audio/transcriptions \
  --header "Authorization: Bearer $OPENAI_API_KEY" \
  --header 'Content-Type: multipart/form-data' \
  --form 'model=gpt-4o-transcribe' \
  --form 'file=@./assets/audio/test-speech.mp3' > $SCRIPT_DIR/openai-audio-transcription.response.json