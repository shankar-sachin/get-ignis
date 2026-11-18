# Terminal commands

Ignis comes with two commands. `ignis` manages the background service and your models. `bi` is a chat in the terminal. They share everything with the desktop app: the same model library, the same service and the same settings.

## Set up the commands

The commands are in the `ignis-cli-<version>-macos-arm64.tar.gz` on the [releases page](https://github.com/shankar-sachin/get-ignis/releases), or from the [install script](install.md) with `--cli-only`. Keep `ignis` and `bi` in the same folder, and put that folder on your `PATH`. `bi` finds `ignis` next to itself, and starts it when it needs it.

Check that they work:

```sh
ignis --version
bi --version
```

## ignis

`ignis` runs the background service, which keeps models loaded, runs Rebound routines and serves the [local API](local-api.md). The desktop app starts it for you. You can also run it yourself.

```sh
ignis start                      # start the service in the background
ignis start --model Qwen3-8B-GGUF   # and keep this model loaded
ignis status                     # is it running, and what is loaded
ignis logs -n 100                # the last 100 lines of its log
ignis stop                       # stop it
```

### Service

| Command | What it does |
| --- | --- |
| `start [--model <model>] [--json]` | Starts the service, detached, and prints its status. If it is already running, it says so and prints the status. |
| `stop` | Stops the service. |
| `status [--json]` | Shows the service: version, process, uptime, the local API address, and the models loaded. Exits with code 1 when it is not running. |
| `logs [-n <lines>] [-f]` | Prints the service log. `-n` or `--lines` sets how many lines (50 by default). `-f` or `--follow` keeps printing what is added until you press Ctrl+C. |
| `run [--model <model>]` | Runs the service in the foreground. This is what `start` launches. |
| `serve [--port <port>] [--model <model>]` | Runs the service in the foreground and serves the local API on a port, whatever the settings say. It refuses to run while the background service is running. |

`--json` prints the status as JSON. The log file is `~/Library/Application Support/Bouncer Ignis/logs/daemon.log`.

### Models

```sh
ignis pull unsloth/Qwen3-8B-GGUF          # the quant that suits this Mac
ignis pull unsloth/Qwen3-8B-GGUF:Q4_K_M   # or name the quant
ignis list                                # or: ignis ls
ignis rm Qwen3-8B-GGUF
```

| Command | What it does |
| --- | --- |
| `pull <owner/Repo-GGUF[:quant]>` | Downloads a model from Hugging Face into the library. Without `:quant`, it picks the one that suits this Mac. Ctrl+C stops it, and running it again resumes. It needs the owner, like `owner/Repo-GGUF`. |
| `list [--json]` | Lists your models with size and when they were last used. Also `ls`. A model whose file is gone shows `(missing)`. |
| `rm <model>` | Deletes a model. It refuses while the model is loaded, in Ignis's service or in Bouncer. |
| `search <words> [--hf] [--json]` | Searches the package index. With `--hf`, it searches Hugging Face for GGUF repos instead. |

A model can be named by its full library id, its repo, or just the repo's name when only one quant of it is downloaded, with or without `:quant`. See [Models](models.md#names). Gated models need `HF_TOKEN` set. See [Models](models.md#gated-models).

### Packages

A package is a model with the settings it runs best with. See [Models](models.md#packages).

| Command | What it does |
| --- | --- |
| `install <package> [--force]` | Installs a package: `owner/name`, `owner/name@version`, an https URL or a `.bcr.json` file. It downloads the package's model too. `--force` installs it again if it is already installed. |
| `update [package] [--check]` | Updates every installed package, or the one you name. `--check` (or `--dry-run`) only lists what is out of date. |
| `remove <package> [--keep-model]` | Removes a package, and its model unless the model was yours before. `--keep-model` keeps the model. |

### Exit codes and output

Tables and JSON go to standard output. Progress and messages go to standard error. Exit codes: `0` done, `1` failed, `2` wrong usage, `130` stopped with Ctrl+C.

## bi

`bi` chats with a model from the terminal.

```sh
bi                              # the full-screen chat
bi "say hi"                     # one reply, then quit
bi -m Qwen3-8B-GGUF "say hi"    # one reply from this model
cat notes.md | bi "sum this up" # piped text goes with your question
```

| Option | What it does |
| --- | --- |
| `-m`, `--model <model>` | The model to use: a library id, repo or name. `ignis list` shows them. |
| `<question>` | A question to answer. `bi` prints one reply and quits. |

With a question or piped text, `bi` starts the service if needed, loads the model, prints the reply as it is written, and exits. Without `-m`, it uses the model the service keeps warm, and tells you to name one if there is none. Ctrl+C stops the reply, and the exit code is `130`. If something reads the output and goes away, such as `head`, the reply stops.

With no question and no piped input, `bi` opens the full-screen chat. It needs a terminal. If you start it with `-m`, that model loads. Otherwise, `/model` picks one.

### Commands in the chat

Type `/` to open the command menu. Press <kbd>Tab</kbd> to fill in the highlighted command.

| Command | What it does |
| --- | --- |
| `/help`, `/?` | Shows the commands. |
| `/model [model]`, `/load` | Switches to another model, or shows a list to pick from. |
| `/clear`, `/new` | Starts a new conversation. |
| `/bye`, `/exit`, `/quit` | Quits. |

Start and end a message with `"""` to write more than one line, or press <kbd>Alt</kbd> <kbd>Enter</kbd> for a new line.

### Keys in the chat

| Key | What it does |
| --- | --- |
| <kbd>Enter</kbd> | Sends the message. |
| <kbd>Esc</kbd> | Stops a reply, or clears what you typed. |
| <kbd>Ctrl</kbd> <kbd>C</kbd> | Stops a reply. With none running, clears the input. On an empty input, quits. |
| <kbd>Ctrl</kbd> <kbd>D</kbd> | Quits, when the input is empty. |
| <kbd>↑</kbd> <kbd>↓</kbd> | Recall earlier messages. In the command menu, move through it. |
| <kbd>PgUp</kbd> <kbd>PgDn</kbd> | Scroll the conversation. <kbd>Shift</kbd> <kbd>↑</kbd> and <kbd>Shift</kbd> <kbd>↓</kbd> scroll by a line. |
| <kbd>Ctrl</kbd> <kbd>A</kbd>, <kbd>Ctrl</kbd> <kbd>E</kbd> | Move to the start or end of the line. |
| <kbd>Ctrl</kbd> <kbd>U</kbd>, <kbd>Ctrl</kbd> <kbd>K</kbd>, <kbd>Ctrl</kbd> <kbd>W</kbd> | Delete to the start of the line, to the end, or the last word. |

## Environment variables

| Variable | What it does |
| --- | --- |
| `IGNIS_USER_DATA_DIR` | Use this folder instead of `~/Library/Application Support/Bouncer Ignis` for Ignis's settings, chats and logs. |
| `BOUNCER_USER_DATA_DIR` | Use this folder instead of `~/Library/Application Support/Bouncer` for the model library. |
| `HF_TOKEN` | A Hugging Face token for gated models, sent only to Hugging Face. |
| `BOUNCER_BCR_INDEX` | Read the package index from another address. |
| `IGNIS_HIDDEN` | Keep the service's desktop notifications off, for test runs. |

The service reads these when it starts. If you set one, stop the service with `ignis stop` first, with the same variables set.

## Related

- [Local API](local-api.md)
- [Models](models.md)
- [Troubleshooting](troubleshooting.md)
