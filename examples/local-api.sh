#!/bin/sh
# Checks the Ignis local API with curl. Run: sh local-api.sh [model]
# Needs the ignis service running (ignis start) and at least one downloaded model (ignis list).

BASE="http://localhost:3333"

echo "Health:"
curl -s "$BASE/health"
echo

echo "Your models:"
curl -s "$BASE/v1/models"
echo

MODEL="${1:-}"
if [ -z "$MODEL" ]; then
  echo "Pass a model name to ask a question: sh local-api.sh Qwen3-8B-GGUF"
  exit 0
fi

echo "Asking $MODEL:"
curl -s "$BASE/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [{ \"role\": \"user\", \"content\": \"Say hi in five words.\" }],
    \"max_tokens\": 60
  }"
echo
