# Troubleshooting

Fixes for the most common problems. If yours is not here, [open an issue](https://github.com/shankar-sachin/get-ignis/issues/new/choose) with your Ignis version, your Mac and the service log lines around the error.

## Install

### macOS says the app can't be opened

Builds are not signed or notarized yet. Right-click Bouncer Ignis in Applications and choose **Open**, or run:

```sh
xattr -dr com.apple.quarantine "/Applications/Bouncer Ignis.app"
```

See [Install](install.md#unsigned-builds).

### `ignis: command not found` or `bi: command not found`

The commands are not on your `PATH`. Put `ignis` and `bi` together in one folder that is on your `PATH`, then open a new terminal. See [Terminal commands](cli.md#set-up-the-commands).

### `bi` says it can't start the service

`bi` looks for `ignis` in the same folder as itself. Keep the two together.

## The service

### The service won't start, or stops right away

Run `ignis status`. If it is not running, `ignis logs` shows the last lines of its log, which is in `~/Library/Application Support/Bouncer Ignis/logs/daemon.log`. You can also run `ignis run` to see its output in the terminal. Settings, engine shows the same state with a **Start service** button.

If `ignis stop` says the service didn't stop in time, quit the app and try again.

### Check what the service is doing

`ignis status` shows the version, uptime, the local API address and the loaded models. `ignis logs -f` follows the log while you try the thing that fails.

## Models

### A model won't load

- Open the model in the Marketplace and check its fit. A file marked **Too large** may not load. Pick a smaller file.
- Unload other models. **Settings, Engine** sets how many may load at once.
- Read the error in `ignis logs`.

### A model is slow

Close other apps to free memory. If a file is marked **Tight fit**, a smaller quantization is faster. Long conversations need more memory and slow down.

### A download fails

Check your connection and run it again. A download that stopped resumes from where it was. A model marked *This model is gated* needs you to accept its terms on huggingface.co and to set `HF_TOKEN` before you start Ignis. See [Models](models.md#gated-models).

### `ignis pull` says to name a repo

`pull` needs the owner, like `owner/Repo-GGUF`. Search with `ignis search <words> --hf`.

### `ignis rm` refuses

The model is loaded, in Ignis's service or in Bouncer. Run `ignis stop`, or unload it in Bouncer, then try again.

### A model shows as missing

The file is gone from the library folder. Delete the entry, or download it again.

## The local API

### Connection refused on port 3333

The service is not running, or the API is off. Run `ignis status`. If the address is missing, check `local-server.json` for `"enabled": false`. See [Local API](local-api.md#local-serverjson). If the card says *Port 3333 is already in use*, something else has the port. Run `ignis serve --port <port>` for another one.

### 403 forbidden_host

The `Host` header was not `localhost`, `127.0.0.1` or `[::1]`. The API answers on this computer only.

### 403 forbidden_origin, or a browser app can't connect

The page's origin is not on the allowed list. Add it to `corsOrigins` in `local-server.json`. See [Local API](local-api.md#local-serverjson).

### 415 unsupported_media_type

Send the body as `application/json`. Ollama's routes accept a body with no content type.

### 404 model_not_found

The `model` does not match one of your models, or matches more than one. `ignis list` shows them. Use the full library id, like `owner/Repo-GGUF:Q4_K_M`.

### 503 model_load_failed

The model could not load. `ignis logs` has the reason, often too little memory.

### 400 context_length_exceeded

The prompt is longer than the model's context. Send less, or start a new conversation.

### Ollama's port won't open

**Settings, Engine** shows why in the **Ollama's port** line. If Ollama is running, quit it. If Bouncer or another Ignis window has the port, turn it off there. See [Local API](local-api.md#answer-on-ollamas-port).

## Code

### Code says *Load a model in the title bar first.*

Click the model pill in the title bar and choose a model.

### Code stops after a while

It stops after 50 steps in a turn, if the same step fails three times in a row, or if the reply hits the length limit. Send a message to go on. For a long session, run `/compact`.

### Code won't run a command

In **Plan** mode, commands are refused. In other modes, risky commands such as installs and network use ask first, and some commands, like `sudo`, never run. See [Code](code.md#modes).

## Rebound

### A routine did not run

Routines run in the `ignis` service. Check that it is running with `ignis status`. The routine's panel shows *last run failed* with the reason. A routine also needs a model: the bot's own, or the one the service keeps warm.

## Reset

To start Ignis from scratch, quit it, run `ignis stop`, and move `~/Library/Application Support/Bouncer Ignis` somewhere else. Your models are not in that folder.

## Related

- [Install](install.md)
- [Local API](local-api.md)
- [FAQ](faq.md)
