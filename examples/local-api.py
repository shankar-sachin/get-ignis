"""A small client for the Bouncer Ignis local API. Standard library only.

Run the service first (`ignis start`) and download a model (`ignis pull owner/Repo-GGUF`).

    python3 local-api.py                      lists your models
    python3 local-api.py <model> "question"   streams a reply from that model
"""

import json
import sys
import urllib.request

BASE = "http://localhost:3333"


def get(path):
    with urllib.request.urlopen(BASE + path) as response:
        return json.load(response)


def post(path, body):
    request = urllib.request.Request(
        BASE + path,
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    return urllib.request.urlopen(request)


def stream_chat(model, question):
    body = {
        "model": model,
        "messages": [{"role": "user", "content": question}],
        "stream": True,
    }
    with post("/v1/chat/completions", body) as response:
        for raw in response:
            line = raw.decode().strip()
            if not line.startswith("data:"):
                continue
            data = line[len("data:"):].strip()
            if data == "[DONE]":
                break
            choices = json.loads(data).get("choices") or []
            if not choices:
                continue
            text = choices[0].get("delta", {}).get("content")
            if text:
                print(text, end="", flush=True)
    print()


def main():
    if len(sys.argv) < 3:
        for model in get("/v1/models")["data"]:
            print(model["id"])
        print('\nAsk one: python3 local-api.py <model> "your question"')
        return
    stream_chat(sys.argv[1], " ".join(sys.argv[2:]))


if __name__ == "__main__":
    main()
