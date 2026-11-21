# Updates

Ignis can update itself, from **Settings, About** or with `ignis self-update`. Updates come from the [releases page](https://github.com/shankar-sachin/get-ignis/releases), and every download is checked against the release's `SHA256SUMS` before anything is installed.

Self-update works on macOS, on both Apple silicon and Intel. It arrived in 0.4.0, so to get from 0.3.0 or older to 0.4.0, [update by hand](#update-by-hand) once. Intel Macs get their first self-update from the release after the one that adds them.

On Windows and Linux, **About** tells you when a new version is out. To install it, run the install command again, or use the new installer or `.deb`. See [Update by hand](#update-by-hand).

## In the app

On macOS, open **Settings** (<kbd>⌘</kbd> <kbd>,</kbd>) and pick **About**. The first time you open it, Ignis checks for a newer version.

- **Up to date**: you have the newest version. **Check again** checks once more.
- **Update available**: **Release notes** opens the release on GitHub. **Download and install** downloads the app, checks it, and replaces `/Applications/Bouncer Ignis.app` with the new one. `ignis` and `bi` are inside the app, so they update too.
- **Ready to restart**: **Restart now** stops the background service, quits Ignis and opens the new version. A reply in progress stops.

If the update fails, nothing was installed, and **Try again** starts over. If Ignis can't write to the app's folder, it says so; run the install command instead.

## In Terminal

On macOS:

```sh
ignis self-update --check     # show your version and the newest one
ignis self-update             # download, check and install the newest, after asking
ignis self-update -y          # the same, without asking
ignis self-update --version 0.4.0   # install a specific release
```

When `ignis` runs from inside the app, `self-update` updates the whole app. When you installed only the commands (`--cli-only`), it updates `ignis` and `bi` where they are. Run `ignis stop` afterwards, so the next start uses the new service.

## Update by hand

Run the install command again. It fetches the newest release and installs it.

On macOS and Linux:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh
```

On Windows, in PowerShell:

```powershell
irm https://bouncer-ai.pages.dev/ignis/install.ps1 | iex
```

Or download the new files from [Releases](https://github.com/shankar-sachin/get-ignis/releases) and install them as described in [Install](install.md): the new installer on Windows, or the new `.deb` with `sudo apt install ./bouncer-ignis_<version>_amd64.deb` on Linux.

Before you update by hand:

1. Quit Bouncer Ignis.
2. Stop the background service: `ignis stop`. The new version starts it again when you open the app.

Your chats, bots, settings and models are kept. They are in Ignis's data folder and in Bouncer's model library: `~/Library/Application Support/Bouncer Ignis` on macOS, `%APPDATA%\Bouncer Ignis` on Windows and `~/.config/Bouncer Ignis` on Linux. The model library is in the `Bouncer` folder next to it.

## Find out which version you have

- In the app: **Settings, About** shows the version.
- In Terminal: `ignis --version` and `bi --version`.

## What updating sends

Checking asks GitHub's API for the list of Ignis releases. Installing downloads the release's zip and `SHA256SUMS` from GitHub. Nothing about you or your chats is sent. See [Privacy](privacy.md).

## Packages

Packages you installed with `ignis install` update separately. `ignis update --check` lists the ones with a newer version, and `ignis update` installs them. See [Terminal commands](cli.md#packages).

## Related

- [Install](install.md)
- [Settings](settings.md#about)
- [Troubleshooting](troubleshooting.md)
