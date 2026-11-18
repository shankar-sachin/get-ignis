---
description: Show whether the Bouncer Ignis service is running, and which model it has loaded
allowed-tools: Bash(ignis status:*)
---

Run `ignis status` with the Bash tool and show the output as it is.

- Exit code 1 and "not running" means the service is stopped. Tell the user to start it with `ignis start`. Do not start it yourself.
- If the output lists a local API address, say that Claude Code and other apps can use it.
- If the `ignis` command is not found, say Bouncer Ignis is not installed and point to https://bouncer-ai.pages.dev/ignis.
