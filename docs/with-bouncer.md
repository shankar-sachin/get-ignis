# Ignis with Bouncer

[Bouncer](https://bouncer-ai.pages.dev) and Bouncer Ignis can live on the same Mac. Ignis is the lean edition: it has less, and uses far less memory. They share your models and packages, and keep everything else apart.

## What they share

- **The model library.** Ignis uses Bouncer's library, in `~/Library/Application Support/Bouncer/models`. A model you download in Ignis shows in Bouncer, and the other way round. Each app changes the library under the same lock file, so they do not overwrite each other.
- **Model load options.** If you tuned a model in Bouncer, such as its context size, Ignis reads those options. Ignis never writes to Bouncer's copy. Options Ignis sets itself, for example from a package, go to its own folder and win over Bouncer's for that model.
- **Packages.** Ignis uses Bouncer's package format and package index. `ignis install owner/name` installs the same package you would find in Bouncer.
- **The look.** The same themes, with Ignis red as the default accent.

## What they keep apart

| | Ignis | Bouncer |
| --- | --- | --- |
| Data folder | `~/Library/Application Support/Bouncer Ignis` | `~/Library/Application Support/Bouncer` |
| Settings | Its own `settings.json` | Its own |
| Chats, Rebound bots, Code sessions | Its own | Its own |
| Local API port | 3333 | 3133 |

Chats, bots and Code sessions do not move between them. Ignis has no account and no sync.

## Running both

- **Memory.** A model loaded in one app takes memory. A model loaded in both takes it twice. Unload it in one app first if memory is tight.
- **Deleting a model.** `ignis rm` refuses while the model is loaded in Ignis's service or in Bouncer.
- **Ollama's port.** Only one app can answer on port 11434 at a time. If you turn on **Answer on Ollama's port** in Ignis while Bouncer has it, Ignis says which one is there. Turn it off in Bouncer first, or leave it off in Ignis.
- **Different ports.** Ignis's API is on 3333 and Bouncer's is on 3133, so you can run both at once and point different tools at each.

## What Ignis does not have

Ignis has Chat, Code, Rebound, the Marketplace and Settings. It does not have the IDE, Studio, Lab, Workflows, MLX models, cloud providers, voice input, plugins, accounts or sync. If you need those, use Bouncer.

## Related

- [Models](models.md)
- [Local API](local-api.md)
- [Settings](settings.md)
