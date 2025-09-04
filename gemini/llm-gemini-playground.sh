#!/usr/bin/env bash
set -euo pipefail

# 1️⃣  pull variables from a .env file sitting in the same folder as this script
#     (if the file exists)
env_file="$(dirname "${BASH_SOURCE[0]}")/.env.llm"
if [[ -f "$env_file" ]]; then
  # export everything the file defines
  set -a          # turn on “export every variable I assign”
  source "$env_file"
  set +a          # turn it off again
fi

# 2️⃣  bail out early if GEMINI_API_KEY is still not set
: "${PLAYGROUND_GEMINI_API_KEY:?PLAYGROUND_GEMINI_API_KEY is not set – either put it in .env or export it before running.}"

# Model=gemini-2.5-flash-lite-preview-06-17
# Model=gemini-2.5-pro
MODEL_ID="gemini-2.5-flash-lite-preview-06-17"
GENERATE_CONTENT_API="generateContent" # or "generateContent", or "streamGenerateContent"

# Conversation variant 1
CONVO_FUNCTION_CALL_SIMPLE='
[
  {
    "role": "user",
    "parts": [ { "text": "Hey, what’s the weather in Berlin?" } ]
  },
  {
    "role": "model",
    "parts": [
      {
        "text": "It looks like you want the weather for Berlin. Let me call the getWeather tool."
      },
      {
        "function_call": {
          "name": "getWeather",
          "args": { "city": "Berlin" }
        }
      }
    ]
  },
  {
    "role": "user",
    "parts": [
      {
        "function_response": {
          "name": "getWeather",
          "response": {
            "output": "27"
          }
        }
      }
    ]
  },
  {
    "role": "model",
    "parts": [
      {
        "text": "The current temperature in Berlin is 27°C."
      }
    ]
  }
]
'
TOOLS_FUNCTION_CALL_SIMPLE='
[
  {
    "functionDeclarations": [
      {
        "name": "getWeather",
        "description": "Gets the weather for a requested city",
        "parameters": {
          "type": "object",
          "properties": {
            "city": {
              "type": "string"
            }
          }
        }
      }
    ]
  }
]
'

# Conversation variant 2 (with confusion about units)
CONVO_MODEL_START='
[
  {
    "role": "model",
    "parts": [
      {
        "text": "Hey Alex, how are you? Did you follow-up our big event yesterday?"
      }
    ]
  },
  {
    "role": "user",
    "parts": [ { "text": "How did you just call me?" } ]
  }
]
'

CONVO_TEST_1='
[
  {
     "role": "model",
     "parts": [
       {
         "text": "Nachmittag Alex! Kante, Charakter und Leadership - das ist dein Vibe! 💎⚡"
       }
     ]
   },
   {
     "role": "user",
     "parts": [
       {
         "text": "hey"
       }
     ]
   },
   {
     "role": "model",
     "parts": [
       {
         "text": "Hallo Alex! Wie kann ich dir heute helfen? Womit möchtest du starten?"
       }
     ]
   },
   {
     "role": "user",
     "parts": [
       {
         "text": "kannst du bitte in den tutor modus gehen?"
       }
     ]
   },
   {
     "role": "model",
     "parts": [
       {
         "functionCall": {
           "name": "switchAgentMode",
           "args": {
             "newMode": "TUTOR",
             "reasoning": "Der Benutzer hat explizit darum gebeten, in den Tutor-Modus zu wechseln."
           },
           "id": "call_c542be96-f979-403c"
         }
       }
     ]
   },
   {
     "role": "user",
     "parts": [
       {
         "functionResponse": {
           "name": "switchAgentMode",
           "response": {
             "success": true,
             "message": "Successfully switched agent mode to TUTOR.",
             "switchedToMode": "TUTOR",
             "reasoning": "Der Benutzer hat explizit darum gebeten, in den Tutor-Modus zu wechseln."
           }
         }
       }
     ]
   },
   {
     "role": "model",
     "parts": [
       {
         "text": "Absolut! Ich bin jetzt im **Tutor-Modus**. 💡\n\nIn diesem Modus geht es darum, dir fundiertes und direkt anwendbares Wissen aus der Führungspsychologie zu vermitteln. Stell es dir wie eine persönliche Masterclass vor, nur eben auf den Punkt und ohne unnötiges Blabla. 😉\n\nWelches Führungsthema interessiert dich heute brennend? Wollen wir vielleicht direkt in mein Lieblingsthema **\"Feedback geben\"** einsteigen oder hast du etwas anderes im Kopf? 🤓"
       }
     ]
   },
   {
     "role": "user",
     "parts": [
       {
         "text": "Danke, und nun?"
       }
     ]
   },
]
'

# 🔁 Pick the conversation you want to test:
CONVERSATION="$CONVO_TEST_1"  # or $CONVO_FUNCTION_CALL_SIMPLE
TOOLS="$TOOLS_FUNCTION_CALL_SIMPLE"

# Call Gemini API with selected conversation
curl -sS -X POST \
  -H "Content-Type: application/json" \
  "https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}:${GENERATE_CONTENT_API}?key=${PLAYGROUND_GEMINI_API_KEY}" \
  -d @- <<EOF
{
  "contents": ${CONVERSATION},
  "generationConfig": {
    "thinkingConfig": {
      "thinkingBudget": -1
    },
    "responseMimeType": "text/plain"
  },
  "tools": ${TOOLS}
}
EOF
