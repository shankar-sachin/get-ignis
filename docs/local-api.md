# Local API

The `ignis` background service serves an API on your Mac, so other apps and scripts can use your models. It answers in three shapes: OpenAI's, Anthropic's and Ollama's. Requests never leave your computer.

## Address and defaults

| | |
| --- | --- |
| Address | `http://localhost:3333` |
| OpenAI base URL | `http://localhost:3333/v1` |
| Anthropic base URL | `http://localhost:3333` |
| Ollama base URL | `http://localhost:3333`, or `http://localhost:11434` with the [Ollama port switch](#answer-on-ollamas-port) |
| Who can connect | This computer only |
| API key | Not needed |

The service starts the API when it starts, unless a `local-server.json` file turns it off. **Settings, engine** shows the address next to **local API**, and `ignis status` prints it. Ignis uses port 3333 so it never clashes with Bouncer's 3133.

Any request needs a model. Name it in the `model` field, by its library id, repo or name, as described in [Models](models.md#names). `GET /v1/models` lists them. If **load when needed** is on in [Settings](settings.md#engine), which it is by default, a request for a model that is not loaded loads it first. The first reply is slower while it loads.

Check that it is up:

```sh
curl http://localhost:3333/health
# {"status":"ok"}
curl http://localhost:3333/v1/models
```

## OpenAI shape

| Route | What it does |
| --- | --- |
| `GET /v1/models` | Lists your models and whether each is loaded. |
| `POST /v1/chat/completions` | A chat reply, whole or streamed. |
| `POST /v1/completions` | A completion for a raw prompt, with no chat template. One prompt only. |
| `POST /v1/embeddings` | Embeddings for one text or a list of texts. |

```sh
curl http://localhost:3333/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3-8B-GGUF",
    "messages": [{ "role": "user", "content": "Say hi in five words." }]
  }'
```

Set `"stream": true` to get server-sent events. Add `"stream_options": { "include_usage": true }` to get token counts at the end.

Ignis reads these fields: `temperature`, `top_p`, `top_k`, `min_p`, `repeat_penalty`, `presence_penalty`, `frequency_penalty`, `seed`, `max_tokens` (or `max_completion_tokens`), `stop`, `chat_template_kwargs` and `tools`. A reasoning model's thinking comes back as `reasoning_content`.

**JSON output.** Send `response_format` with `{"type": "json_object"}` or `{"type": "json_schema", "json_schema": {"schema": { ... }}}`, and the reply follows it. It can't be combined with `tools`.

```sh
curl http://localhost:3333/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3-8B-GGUF",
    "messages": [{ "role": "user", "content": "Name a city and its country." }],
    "response_format": {
      "type": "json_schema",
      "json_schema": { "schema": {
        "type": "object",
        "properties": { "city": { "type": "string" }, "country": { "type": "string" } },
        "required": ["city", "country"]
      } }
    }
  }'
```

**Tools.** The `tools` you send go to the model's chat template. A model writes its calls as text in the reply, in its own format.

**Embeddings.** `input` is a string or a list of strings. `encoding_format` is `float` (the default) or `base64`. `dimensions` is not supported.

```sh
curl http://localhost:3333/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{ "model": "Qwen3-8B-GGUF", "input": ["first text", "second text"] }'
```

Not supported yet: images and audio in messages, more than one choice (`n` above 1), and raw `grammar`.

With the OpenAI Python library:

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:3333/v1", api_key="ignis")
reply = client.chat.completions.create(
    model="Qwen3-8B-GGUF",
    messages=[{"role": "user", "content": "Say hi in five words."}],
)
print(reply.choices[0].message.content)
```

The library wants a key. Ignis ignores it, so any text works.

## Anthropic shape

| Route | What it does |
| --- | --- |
| `POST /v1/messages` | A reply in Anthropic's Messages shape, whole or streamed. |
| `POST /v1/messages/count_tokens` | An estimated token count. It does not load or call a model. |

```sh
curl http://localhost:3333/v1/messages \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "Qwen3-8B-GGUF",
    "max_tokens": 200,
    "messages": [{ "role": "user", "content": "Say hi in five words." }]
  }'
```

The endpoint takes the system prompt and `system` messages, text blocks, `tool_use` and `tool_result` blocks, tools, `tool_choice` and structured output (`output_config.format` with a JSON schema). Server tools, document blocks and prompt-cache controls are rejected or ignored, and thinking blocks are not replayed. This is what lets [Claude Code](claude-code.md) use your models.

## Ollama's API

Ignis also answers in Ollama's shapes, so apps made for Ollama work with your models.

| Route | What it does |
| --- | --- |
| `GET /api/version` | A version, for clients that check for a minimum. |
| `GET /api/tags` | Lists your models. |
| `GET /api/ps` | Lists the loaded models. |
| `POST /api/show` | Details of a model. |
| `POST /api/chat` | A chat reply, streamed as one JSON object per line unless `"stream": false`. |
| `POST /api/generate` | A completion, in the same way. |
| `POST /api/embed` | Embeddings. |
| `POST /api/embeddings` | Embeddings, in the older shape. |
| `POST /api/pull` | Downloads a model from Hugging Face. |

```sh
curl http://localhost:3333/api/chat -d '{
  "model": "Qwen3-8B-GGUF",
  "messages": [{ "role": "user", "content": "Say hi in five words." }],
  "stream": false
}'
```

Ollama names work when one of your models matches them. For example, `qwen2.5-coder:7b` finds `bartowski/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M` if you have it. A name that matches nothing gets a 404. `hf.co/owner/repo:quant` names work too.

`/api/pull` takes a Hugging Face repo, `owner/Repo-GGUF` with an optional `:quant`, not a name from Ollama's library.

An empty `/api/chat` or `/api/generate` request is how clients load a model. Ignis answers and loads the model with the first real request.

### Answer on Ollama's port

Apps made for Ollama look on port 11434. To have Ignis answer there too, turn on **Answer on Ollama's port** in **Settings, engine**. It is off until you turn it on, and it is for this computer only. **ollama's port** in the same card shows whether it is listening.

If something else is using 11434, the card says what. If Ollama itself is running, quit it, then turn the switch on again.

## Who can connect

- **This computer only.** The API listens on `127.0.0.1` and `::1`. A request whose `Host` header is not `localhost`, `127.0.0.1` or `[::1]` gets a 403.
- **No key.** Requests from this computer need no API key. If a client sends one, Ignis ignores it, so placeholder keys work.
- **Web pages.** A page in a browser can only call the API if its origin is on the allowed list. By default the list is empty. A request with a body from a page whose origin is not allowed is refused with a 403 on Ollama's routes, and a body that is not `application/json` is refused on the others (415). To allow an origin, see below.
- **Body size.** A request body can be up to 4 MB.

Requests that Ignis answers with an error use the shape of the API they came in on: OpenAI's `error` object, Anthropic's `type: "error"`, or Ollama's `{"error": "..."}`.

## local-server.json

The API's settings are in `~/Library/Application Support/Bouncer Ignis/local-server.json`. The service re-reads the file when it changes. Ignis writes it when you flip the Ollama port switch. Edit it by hand only if you need the options below, and keep the JSON valid. A file that can't be read is kept as a `.bak` copy and replaced with defaults.

```json
{
  "version": 1,
  "config": {
    "enabled": true,
    "port": 3333,
    "corsOrigins": ["http://localhost:5173"]
  },
  "keys": []
}
```

| Key | What it does |
| --- | --- |
| `enabled` | Turns the API on or off. A missing file means on. |
| `port` | The port, from 1024 to 65535. |
| `corsOrigins` | Up to 20 origins that web pages may call from, each as `scheme://host[:port]` with no path, like `http://localhost:5173`. `*` is not allowed. |
| `ollamaPort` | The same as the settings switch. |

`ignis serve --port <port>` runs the API on a port for one run, whatever the file says.

## Related

- [Claude Code](claude-code.md)
- [Terminal commands](cli.md)
- [Troubleshooting](troubleshooting.md#the-local-api)
- [Examples](../examples/README.md): a Python client.
