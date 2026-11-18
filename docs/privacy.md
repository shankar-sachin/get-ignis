# Privacy

Bouncer Ignis runs models on your own Mac. Your chats, models and files stay on your machine. Ignis connects to the internet only for the specific tasks listed below, and only when you use the feature that needs them. It has no analytics, no telemetry, no crash reporting and no accounts.

## What stays on your machine

These are stored locally and are never uploaded by Ignis:

- **Models**: the model files you download or import, and your library.
- **Chats**: your conversations in Chat, and the bots, memories, routines and chats in Rebound.
- **Files**: the folders and files you open in Code.
- **Connectors and voice**: the one folder and the one `.ics` file you give a bot stay where they are, and a bot reads them only on this Mac. Read aloud uses the voices macOS already has.
- **Code sessions and checkpoints**: Code's sessions, and the snapshots it takes before each turn so you can rewind. They are stored in Ignis's data folder, not in your project.
- **Settings**.

A chat with a local model is processed by the model on your computer. Ignis does not send your messages to a server to get a reply.

## What connects to the internet, and when

| Activity | What is sent | When it happens |
| --- | --- | --- |
| Searching the Marketplace and opening model pages | Requests to Hugging Face for model listings, files and model cards. | When you search or open a model. `ignis search --hf` does the same. |
| Downloading a model | A request for the model file from Hugging Face. | Only when you click **Download**, run `ignis pull`, or send an Ollama `pull` request to the local API. |
| Gated models | Your Hugging Face token, only if you set `HF_TOKEN` before starting Ignis. Sent only to Hugging Face. | Only when you download a gated model. |
| Packages | Requests to bouncer-ai.pages.dev for the package index and package files, then Hugging Face for the package's model. | When you run `ignis search`, `install` or `update`. |

Hugging Face and bouncer-ai.pages.dev receive these requests the same way they receive any request from a browser or downloader, so their own privacy policies apply to what they log.

Ignis has no update check, so it does not contact GitHub on its own. It has no web search and no cloud model providers.

## The local API

The local API listens on this computer only. A web page in your browser can reach it only if you allow the page's origin. See [Local API](local-api.md#who-can-connect). The API does not send what it receives anywhere. It answers from the model on your Mac.

## What Code can run

Code works only inside the folder you choose for a project, and it runs commands there when the mode allows it:

- **Plan** reads files and proposes changes. It makes no edits and runs no commands.
- **Manual** asks before every edit and command.
- **Accept edits** applies edits, but asks before it runs commands.
- **Autopilot** runs everything in the project folder without asking.

Commands that use the network, install packages, publish, delete in bulk or read secret files always ask first, even in autopilot. A command you approve can still contact the internet. Choose **Manual** or **Plan** for folders with sensitive files. The terminal panel is a normal shell, and what you type there is not checked.

## Your Hugging Face token

Ignis does not store a token. If `HF_TOKEN` is set when the service starts, Ignis sends it to Hugging Face with download requests for gated models, and nowhere else.

## Deleting your data

Uninstalling Ignis and deleting `~/Library/Application Support/Bouncer Ignis` removes what Ignis stored. The model library is Bouncer's, in `~/Library/Application Support/Bouncer/models`. See [Install](install.md#uninstall).

## Related

- [Models](models.md)
- [Local API](local-api.md)
- [Settings](settings.md)
- The [privacy policy](../PRIVACY.md)
