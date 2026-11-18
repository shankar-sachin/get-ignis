---
description: Ask the local Ignis model a question, for a private or offline second opinion
argument-hint: <question>
allowed-tools: Bash(bi:*)
---

Send the user's question to the local model and show its answer. The question is: $ARGUMENTS

1. If the question is empty, ask the user what to ask and stop.
2. Run `bi "<question>"` once with the Bash tool. Wrap the question in double quotes, and escape any double quote, backtick, dollar sign or backslash inside it. `bi` prints one reply to stdout and quits.
3. Show the model's reply under a short heading such as "Local model (Ignis)". Add nothing to it. Say plainly when you disagree with it.

Rules:

- Send only the question text the user gave you. Do not add file contents, secrets, tokens, environment variables or other project data to it.
- Do not pass `-m` unless the user names a model.
- If `bi` prints "No model to answer with", tell the user to name one with `/ignis:models` and then ask again with their choice, or to load one in the Ignis app.
- If `bi` is not found, say Bouncer Ignis is not installed.
- Run it once. Do not retry in a loop.
