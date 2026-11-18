# Claude Code plugins for Bouncer Ignis

This folder holds plugins for [Claude Code](https://code.claude.com/docs/en/plugins), and the repository root
holds the marketplace that lists them (`.claude-plugin/marketplace.json`). The layout follows Anthropic's
`claude-code` repository.

A marketplace is a list of plugins that Claude Code can install from this repository. The marketplace is
named `get-ignis`.

## Install

In Claude Code:

```
/plugin marketplace add shankar-sachin/get-ignis
/plugin install ignis@get-ignis
```

Run `/reload-plugins` or restart Claude Code after the install. To check a copy on disk before you install it:
`claude plugin validate ./plugins/ignis`.

You also need [Bouncer Ignis](https://bouncer-ai.pages.dev/ignis) installed. The commands call its `ignis` and
`bi` programs.

## The `ignis` plugin

Claude Code puts a plugin's name in front of its commands.

| Command | What it does |
| :- | :- |
| `/ignis:status` | Runs `ignis status` and shows whether the service is running. |
| `/ignis:models` | Runs `ignis list` and shows the models you have downloaded. |
| `/ignis:ask <question>` | Sends your question to the local model with `bi "<question>"` and shows the reply. Use it for a private or offline second opinion. |
| `/ignis:serve-claude` | Checks the service and the local API, then shows how to start Claude Code against an Ignis model. |

Each command may run only the commands it needs. For example, `/ignis:ask` may run `bi` and nothing else.
Nothing in the plugin starts, stops or changes the service, and nothing downloads a model.

The plugin also has one skill, `local-model`. It tells Claude when to hand a private, offline or small task to
your local model through the Ignis API on `127.0.0.1:3333`, how to check that the API is up, and what never to
send (secrets, tokens, other people's data).

The local API runs whenever the Ignis service does. Open the app, or run `ignis start`.

## Submit a plugin

Plugins are welcome if they work with Bouncer Ignis.

1. Fork this repository and add your plugin under `plugins/<name>/`, with a `.claude-plugin/plugin.json`.
2. Add an entry for it to `.claude-plugin/marketplace.json` with `"source": "./plugins/<name>"`.
3. Run `claude plugin validate ./plugins/<name>` and `claude plugin validate .`.
4. Open a pull request. Say what the plugin does and how you tested it.

## Rules

- A plugin must be about Bouncer Ignis or work through its `ignis`, `bi` or local API.
- The `name` in `marketplace.json` and in `plugin.json` must match, in kebab-case.
- Use `allowed-tools` to restrict commands to the exact Bash commands they run. No broad `Bash(*)`.
- Nothing runs `sudo`, installs software, or changes the user's settings without the user asking.
- Never send file contents, secrets or tokens to the model unless the user asked for that.
- Only commands, skills, hooks and agents that you describe in the pull request. No network calls to anything but `127.0.0.1` unless the plugin says so plainly in its description.
- State the license of your plugin. Plugins in this repository that carry no license of their own fall under the repository's [LICENSE.md](../LICENSE.md).
- Use plain, short descriptions. Do not claim features Ignis does not have.
