# System requirements

Bouncer Ignis runs on macOS on Apple silicon. How much it can run depends on your Mac's memory and the size of the model you choose. Exact minimum macOS versions are not published yet.

## Supported systems

| System | Processor | Builds |
| --- | --- | --- |
| macOS | Apple silicon (arm64) | `.dmg`, `.zip` and the `ignis-cli` `.tar.gz` |

Intel Macs, Windows and Linux are planned. There are no builds for them yet. If you need one of those today, use [Bouncer](https://bouncer-ai.pages.dev).

## Memory

A model has to fit in memory while it runs, next to macOS and your other apps. The memory a model needs is roughly the size of its file, plus room for the conversation (the context), plus some overhead. Longer conversations need more memory.

These are approximate file sizes. They give a rough idea of what each model size needs:

| Model size | File size (approx.) | Comfortable memory |
| --- | --- | --- |
| About 4B parameters | 2.5 GB | 8 GB |
| About 8B parameters | 5 GB | 16 GB |
| About 14B parameters | 9 GB | 16 GB |
| About 30B parameters (mixture of experts) | 19 GB | 32 GB |

Ignis checks each model against your Mac before you download it, and labels every quantized file **Runs well**, **Tight fit** or **Too large**. On Apple silicon the CPU and GPU share memory, so a model can use most of it. Ignis keeps part of it for the system: the larger of 6 GiB or a quarter of the total.

Trust the label for your Mac over this table. Open a model in the Marketplace to see the estimate for each file.

Start with a small model. A 4 to 8 billion parameter model runs on most Macs. **Settings, Hardware** shows your processor, memory and graphics.

## Engine

Ignis runs models with llama.cpp, built in, using Metal on Apple silicon. There is no engine to install or switch.

## Disk space

Plan for the model files on top of the app. Models are stored in Bouncer's model library, in `~/Library/Application Support/Bouncer/models`. See [Models](models.md#the-library).

## Internet

Ignis works offline once a model is on your Mac. You need a connection to search Hugging Face, download models and use the package index. See [Privacy](privacy.md).

## Related

- [Install](install.md)
- [Getting started](getting-started.md)
- [Models](models.md)
