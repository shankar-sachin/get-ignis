# Frequently asked questions

Short answers to the questions people ask most. For setup steps, see [Getting started](getting-started.md).

## What is Bouncer Ignis?

The lean edition of Bouncer. It has Chat, Code, Rebound, the Marketplace and Settings, and runs models with llama.cpp inside a small Rust app. It uses a fraction of the memory of the Electron app, and it shares Bouncer's model library. See [Ignis with Bouncer](with-bouncer.md).

## Is it free?

Yes, it is free to download and use. See the [license](../LICENSE.md).

## Is it open source?

No. Ignis is closed source. The public repository [get-ignis](https://github.com/shankar-sachin/get-ignis) holds the releases, the install script and these docs. It does not contain the app's source.

## Which systems does it run on?

macOS on Apple silicon. Intel Macs, Windows and Linux are planned. See [System requirements](system-requirements.md).

## Does anything leave my machine?

Your prompts, chats, files and the model's replies stay on your computer. Ignis contacts the internet only to search and download from Hugging Face, and to read Bouncer's package index when you use packages. There is no analytics or telemetry, no update check and no account. See [Privacy](privacy.md).

## Does it work offline?

Yes, once a model is on your Mac. Searching and downloading models need a connection.

## Which models can I run?

Any GGUF model that llama.cpp can run. The Marketplace lists GGUF builds from Hugging Face and labels each file **Runs well**, **Tight fit** or **Too large** for your Mac. MLX models are not supported. See [Models](models.md).

## Where is my data stored?

| What | Where |
| --- | --- |
| Ignis's data: settings, chats, bots, Code sessions, logs | `~/Library/Application Support/Bouncer Ignis` |
| The model library, shared with Bouncer | `~/Library/Application Support/Bouncer/models` |

## How do I update?

By hand, for now. See [Updates](updates.md).

## Does the service keep running when I close the window?

Yes. The `ignis` service runs on its own, so Rebound routines run and other apps can use the [local API](local-api.md). Stop it with `ignis stop`, or the **Stop service** button in **Settings, Engine**.

## Can I use it with Claude Code, Ollama apps or the OpenAI libraries?

Yes. The local API on port 3333 answers in all three shapes. See [Local API](local-api.md) and [Claude Code](claude-code.md).

## Can I use it with Bouncer on the same Mac?

Yes. See [Ignis with Bouncer](with-bouncer.md).

## Why doesn't it have the IDE, Studio, Lab or Workflows?

Ignis is lean on purpose. It does not have the IDE, Studio, Lab, Workflows, MLX, cloud providers, voice input, plugins, accounts or sync. Use Bouncer for those.

## What is coming next?

Intel Macs, Windows and Linux, an updater, and a refreshed design in 0.4.0. Rebound connectors (a read-only folder and an `.ics` calendar) and voice out are in Ignis now. Voice input is not.

## Where do I report a problem?

Start with [Troubleshooting](troubleshooting.md). Then [open an issue](https://github.com/shankar-sachin/get-ignis/issues/new/choose) with your Ignis version, your Mac and the output of `ignis logs`, with any private text removed.
