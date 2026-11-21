# System requirements

Bouncer Ignis runs on macOS, Windows and Linux. How much it can run depends on your computer's memory and the size of the model you choose. Exact minimum macOS versions are not published yet.

## Supported systems

| System | Processor | Builds |
| --- | --- | --- |
| macOS | Apple silicon (arm64) and Intel (x64) | `.dmg`, `.zip` and the `ignis-cli` `.tar.gz` |
| Windows | Windows 10 and 11, x64 | The setup `.exe` and the `ignis-cli` `.zip` |
| Linux | x64, glibc 2.35 or newer | The `.deb`, the portable `.tar.gz` and the `ignis-cli` `.tar.gz` |

The Linux build is made on Ubuntu 22.04. It needs glibc 2.35 or newer, which means Ubuntu 22.04 or newer, Debian 12 or newer, or Fedora 36 or newer.

There is no Linux arm64 build and no Windows on Arm build. Windows on Arm can run the x64 build under emulation. See [Install](install.md).

## Memory

A model has to fit in memory while it runs, next to your operating system and your other apps. The memory a model needs is roughly the size of its file, plus room for the conversation (the context), plus some overhead. Longer conversations need more memory.

These are approximate file sizes. They give a rough idea of what each model size needs:

| Model size | File size (approx.) | Comfortable memory |
| --- | --- | --- |
| About 4B parameters | 2.5 GB | 8 GB |
| About 8B parameters | 5 GB | 16 GB |
| About 14B parameters | 9 GB | 16 GB |
| About 30B parameters (mixture of experts) | 19 GB | 32 GB |

Ignis checks each model against your computer before you download it, and labels every quantized file **Runs well**, **Tight fit** or **Too large**. On Apple silicon the CPU and GPU share memory, so a model can use most of it. Ignis keeps part of it for the system: the larger of 6 GiB or a quarter of the total. On Windows and Linux the model runs on the CPU and uses system memory.

Trust the label for your computer over this table. Open a model in the Marketplace to see the estimate for each file.

Start with a small model. A 4 to 8 billion parameter model runs on most computers. **Settings, Hardware** shows your processor, memory and graphics.

## Engine

Ignis runs models with llama.cpp, built in, using Metal on Macs. On Windows and Linux it runs on the CPU for now. GPU support there is planned. There is no engine to install or switch.

## Disk space

Plan for the model files on top of the app. Models are stored in the `models` folder inside Bouncer's model library folder. See [Models](models.md#the-library).

| System | Model library | Ignis's data |
| --- | --- | --- |
| macOS | `~/Library/Application Support/Bouncer/models` | `~/Library/Application Support/Bouncer Ignis` |
| Windows | `%APPDATA%\Bouncer\models` | `%APPDATA%\Bouncer Ignis` |
| Linux | `~/.config/Bouncer/models` | `~/.config/Bouncer Ignis` |

On Linux, the folders are under `$XDG_CONFIG_HOME` when it is set.

## Internet

Ignis works offline once a model is on your computer. You need a connection to search Hugging Face, download models and use the package index. See [Privacy](privacy.md).

## Related

- [Install](install.md)
- [Getting started](getting-started.md)
- [Models](models.md)
