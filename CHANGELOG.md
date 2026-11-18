# Changelog

## v0.3.0

2026-11-17. Rebound can read a folder and a calendar and speak its replies, and the app's labels now start with a capital.

### New

- **Edit a fact in place**: in a bot's memory, hover a fact and click the pencil. Press Enter to save or Esc to cancel.
- **Edit a routine**: click the pencil on a routine's row. The form opens filled, in its place, with **Save changes**.
- **Rebound connectors**: **Connectors** in a bot's room opens **What <bot> can read**. **Files** is one folder the bot can list and read, read-only, with nothing outside it. Hidden files are skipped, and files over 200,000 bytes or binary files are refused. **Calendar** is one `.ics` file exported from your calendar app, with repeating events. Both are off until you pick them, and they work only with a model that can call tools. A note under a reply shows what the bot read. See [Rebound](docs/rebound.md#connectors).
- **Voice out**: **Voice** in a bot's room opens the bot's voice, with a **Read replies aloud** switch, a voice list, a speed (slow, normal, fast or faster) and **Try it**. Every bot reply has a read aloud button. Ignis uses your Mac's voices, so nothing downloads and nothing leaves your Mac. There is no voice input. See [Rebound](docs/rebound.md#voice).

### Changed

- **Sentence case**: every label in the app and in `bi` now starts with a capital, such as **Memory**, **Routines**, **All bots**, **Plan**, **Manual**, **Accept edits**, **Autopilot**, **Offline-ready** and **API :3333**. The docs match.
- `bi`'s welcome banner shows the ball with its fire, without the app tile.

### Fixed

- Code's changed files panel said "Bouncer Code". It now says "Files that Code changes show up here, ready to review."

Coming next: Intel Macs, Windows and Linux, an updater, and a refreshed design in 0.4.0.

## v0.2.0

The first public release of Bouncer Ignis, the lean edition of Bouncer. macOS on Apple silicon. Builds are not signed or notarized yet.

- **Chat**: talk with a model you have loaded. Chats are saved, and you can search, rename and delete them. See [Chat](docs/chat.md).
- **Code**: an agent that works on a folder you choose. Four modes (Plan, Manual, Accept edits, Autopilot), approval cards with diffs, a changed files panel, checkpoints you can rewind to, a terminal panel, `@` file mentions, and `/compact` plus automatic compaction when a session fills up. See [Code](docs/code.md).
- **Rebound**: bots with a name, a personality, a face, a greeting and a memory. Five starter bots. Routines run a bot on a schedule in the background service and post the reply in their own chat with a notification. See [Rebound](docs/rebound.md).
- **Marketplace**: search GGUF models on Hugging Face, see how each file fits your Mac (**Runs well**, **Tight fit** or **Too large**), and download them. Import a `.gguf` file you already have. See [Models](docs/models.md).
- **Settings**: theme (System, Light, Graphite, Obsidian), accent, high contrast, the `ignis` service, how many models load at once, when idle models unload, and your hardware. See [Settings](docs/settings.md).
- **The `ignis` service**: llama.cpp runs inside it. It keeps models loaded, runs Rebound routines when the window is closed, and serves the local API on port 3333.
- **Local API**: the OpenAI shape (`/v1/chat/completions`, `/v1/completions`, `/v1/embeddings`, JSON schema output), the Anthropic shape (`/v1/messages` and `/v1/messages/count_tokens`, so Claude Code works), and Ollama's API (`/api/chat`, `/api/generate`, `/api/embed`, `/api/pull` and more). A Settings switch makes it answer on Ollama's port, 11434, too. See [Local API](docs/local-api.md) and [Claude Code](docs/claude-code.md).
- **`ignis` commands**: `start`, `stop`, `status`, `logs`, `run`, `serve`, `pull`, `list`, `rm`, `search`, `install`, `update` and `remove`. See [Terminal commands](docs/cli.md).
- **`bi`**: chat in the terminal, full screen or one reply at a time. It reads piped input.
- **Shared with Bouncer**: Ignis uses Bouncer's model library and package format, so a model you download in one shows in the other. See [Ignis with Bouncer](docs/with-bouncer.md).
- **No accounts, no sync, no telemetry.**
- Not in Ignis: the IDE, Studio, Lab, Workflows, MLX, cloud providers, voice input and plugins.

Coming next: Intel Macs, Windows and Linux, an updater, Rebound connectors (a read-only folder and an `.ics` calendar) and voice out.
