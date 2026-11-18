---
name: local-model
description: Hand a private, offline or low-stakes task to the user's local model through the Bouncer Ignis API on 127.0.0.1:3333. Use when the user asks for a local, private or offline answer, a second opinion from their own model, or a cheap bulk job such as summaries or classification.
---

# Delegate to the local model

Bouncer Ignis runs open models on the user's Mac. When its local API is on, you can ask one of those models a question over HTTP. The text never leaves the computer.

Use this when the user asks for it, or when the task suits a small model: a summary, a rewrite, a label, a quick second opinion. Do not use it for hard reasoning, long code changes or anything where being wrong is costly. Say that the answer came from a small local model, and check it before you rely on it.

## Check that it is up

```
curl -s http://127.0.0.1:3333/health
```

`{"status":"ok"}` means the API is running. If there is no reply, the Ignis service is not running. Tell the user to open the Bouncer Ignis app or run `ignis start`. Do not start the service yourself and do not change their settings. `ignis status` shows whether the background service runs at all.

## See which models exist

```
curl -s http://127.0.0.1:3333/v1/models
```

or `ignis list`. Use an `id` from the list. Do not guess one.

## Ask a question

```
curl -s http://127.0.0.1:3333/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"<model id>","messages":[{"role":"user","content":"<question>"}]}'
```

The reply is OpenAI-shaped: the text is in `choices[0].message.content`. Build the JSON body with a tool that escapes strings (for example `jq -n --arg q "$QUESTION" ...`) so quotes in the text cannot break it. For one quick question, the `bi "<question>"` command does the same and prints just the reply. The API also speaks the Anthropic shape (`POST /v1/messages`) and the Ollama shape.

On this computer the API needs no key. If a request answers 401, tell the user. Never invent or search for a key.

## What to never send

The model is local, but the habit matters, and a prompt can end up in logs and history. Send only what the task needs.

- No passwords, API keys, tokens, private keys or `.env` contents.
- No personal data about other people, and no files the user has not said you may share.
- Nothing from the user's project beyond the snippet the task is about.

## Limits

- The first request after the service starts can take a while because the model has to load.
- Local models have short context windows. Keep prompts small.
- Do not send the API anything from a network address other than `127.0.0.1` or `localhost`. The API is meant for this computer.
