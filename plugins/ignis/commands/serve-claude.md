---
description: Explain how to point Claude Code at a model running in Bouncer Ignis
allowed-tools: Bash(ignis status:*), Bash(ignis list:*), Bash(curl -s http://127.0.0.1:3333/health)
---

Explain how to run Claude Code against a local Ignis model. Check the state first, then give the steps that are still missing.

1. Run `ignis list` and note the model ids.
2. Run `ignis status`. If the service is not running, say so.
3. Run `curl -s http://127.0.0.1:3333/health`. A reply of `{"status":"ok"}` means the local API is up on port 3333. No reply means the Ignis service is not running. Tell the user to open the Bouncer Ignis app or run `ignis start`. Do not start anything yourself.
4. Show the user this to run in their own terminal, filled in with a real model id from step 1:

```
ANTHROPIC_BASE_URL=http://localhost:3333 ANTHROPIC_AUTH_TOKEN=ignis ANTHROPIC_MODEL=<model id> claude
```

Notes to include:

- The API answers Anthropic-shaped requests on `http://localhost:3333`. It needs no key on this computer, so a placeholder like `ignis` works.
- A local model is slower and less capable than a hosted one. Keep tasks small.
- This restarts Claude Code against the local model. It does not change the session that is running now.
- Details: https://bouncer-ai.pages.dev/ignis/docs.html#/claude-code
