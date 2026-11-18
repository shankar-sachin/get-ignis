# Claude Code

[Claude Code](https://www.anthropic.com/claude-code) is Anthropic's coding agent for the terminal. Ignis answers in Anthropic's Messages shape, so you can point Claude Code at a model on your Mac. The model runs locally. Nothing is sent to Anthropic.

This is separate from [Code](code.md), the agent inside the Ignis app. Use whichever you prefer.

## Point Claude Code at Ignis

1. Make sure the service is running and you have a model: `ignis status` and `ignis list`. See [Terminal commands](cli.md).
2. Start Claude Code with these environment variables:

```sh
ANTHROPIC_BASE_URL=http://localhost:3333 \
ANTHROPIC_AUTH_TOKEN=ignis \
claude --model Qwen3-8B-GGUF
```

Replace `Qwen3-8B-GGUF` with a model name from `ignis list`. Ignis does not check the token, but Claude Code wants one, so any text works.

To make it stick, export the variables in your shell profile, or put them in Claude Code's settings under `env`.

## Things to know

- **Pick a capable model.** Claude Code asks a lot of a model: long prompts and many tool calls. Models of 14 billion parameters and up cope better, and a small model may struggle.
- **The first request loads the model**, so it takes longer. Keep the model loaded with `ignis start --model <model>`, and set **Unload when idle** to never in [Settings](settings.md#engine).
- **Context.** Ignis loads a model with the largest context that fits your memory, up to 32,768 tokens. Claude Code's prompt is large, so a long session may reach the limit. `/compact` in Claude Code helps.
- **Token counts.** `POST /v1/messages/count_tokens` returns an estimate, so `/context` in Claude Code works.
- **Web search** in Claude Code is not available with local models.
- **Images and PDFs.** Images are not supported in Ignis yet.

If a request fails, `ignis logs` shows what the service saw. See [Troubleshooting](troubleshooting.md#the-local-api).

## The Claude Code plugin

The get-ignis repository is a Claude Code plugin marketplace. Its `ignis` plugin checks the service (`/ignis:status`), lists your models (`/ignis:models`), asks your local model for a second opinion (`/ignis:ask`) and walks you through this page (`/ignis:serve-claude`).

```
/plugin marketplace add shankar-sachin/get-ignis
/plugin install ignis@get-ignis
```

See [`plugins/`](https://github.com/shankar-sachin/get-ignis/tree/main/plugins).

## Related

- [Local API](local-api.md)
- [Code](code.md)
- [Terminal commands](cli.md)
