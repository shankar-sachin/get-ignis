# Updates

Ignis has no updater yet. It does not check for new versions, and it does not download them. You update by hand. An updater is planned.

## Update by hand

Run the install command again. It fetches the newest release and installs it:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh
```

Or download the new files from [Releases](https://github.com/shankar-sachin/get-ignis/releases) and install them as described in [Install](install.md).

Before you update:

1. Quit Bouncer Ignis.
2. Stop the background service: `ignis stop`. The new version starts it again when you open the app.

Your chats, bots, settings and models are kept. They are in `~/Library/Application Support/Bouncer Ignis` and in Bouncer's model library.

## Find out which version you have

- In the app: **Settings, About** shows the version.
- In Terminal: `ignis --version` and `bi --version`.

## Find out when there is a new one

Watch the [releases page](https://github.com/shankar-sachin/get-ignis/releases), or read the [changelog](../CHANGELOG.md). Releases are tagged `ignis-v<version>`, for example `ignis-v0.3.0`.

## Packages

Packages you installed with `ignis install` update separately. `ignis update --check` lists the ones with a newer version, and `ignis update` installs them. See [Terminal commands](cli.md#packages).

## Related

- [Install](install.md)
- [Troubleshooting](troubleshooting.md)
