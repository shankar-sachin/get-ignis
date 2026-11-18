# Install Bouncer Ignis

Bouncer Ignis installs in one command, or from a file you download yourself. It runs on macOS on Apple silicon only for now.

## One-line install

In Terminal:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh
```

The script fetches the newest release and checks it against the release's `SHA256SUMS` file. Then it:

- puts `Bouncer Ignis.app` in `/Applications`, or in `~/Applications` when `/Applications` is not writable;
- clears the macOS quarantine flag, so the unsigned app opens;
- links `ignis` and `bi` from inside the app into `~/.local/bin`, and tells you how to add that folder to your `PATH` if it is not there.

It never uses `sudo`. With `--cli-only` it installs just the two commands, into `~/.local/share/bouncer-ignis/cli`, linked from `~/.local/bin`.

## Installer options

Pass options after `-s --` when you pipe the script to `sh`:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh -s -- --dry-run
```

| Option | What it does |
| --- | --- |
| `--dry-run` | Find the release and print what would happen. Nothing is downloaded or installed. |
| `--version <tag>` | Install a specific release, for example `--version v0.2.0`. The default is the newest release. |
| `--cli-only` | Install only the `ignis` and `bi` commands, not the app. |

## Download it yourself

Every release is at [Releases](https://github.com/shankar-sachin/get-ignis/releases). Names include the version, shown here as `<version>`, for example `0.2.0`.

| File | What it is |
| --- | --- |
| `Bouncer-Ignis-<version>-arm64.dmg` | The app, as a disk image. Open it and drag Bouncer Ignis to Applications. |
| `Bouncer-Ignis-<version>-arm64-mac.zip` | The app, as a zip. Unzip it and move it to Applications. |
| `ignis-cli-<version>-macos-arm64.tar.gz` | Just the `ignis` and `bi` commands, without the app, in a folder named `ignis-<version>-macos-arm64`. |
| `SHA256SUMS` | The checksums of the files above. |

The app also carries both commands, in `Bouncer Ignis.app/Contents/MacOS`. To use the commands from the `.tar.gz` instead, unpack it and put `ignis` and `bi` in the same folder, on your `PATH`. `bi` looks for `ignis` next to itself. See [Terminal commands](cli.md).

There are no Intel Mac, Windows or Linux builds yet. See [System requirements](system-requirements.md).

## Verify the download

Each release includes a `SHA256SUMS` file. Save it in the folder with your download and run:

```sh
shasum -a 256 -c SHA256SUMS --ignore-missing
```

If a file's hash does not match, delete it and download it again.

## Unsigned builds

Ignis builds are not signed or notarized yet, so macOS may stop the first launch. This is expected for now. Only install builds from the releases page linked here.

If macOS blocks the app:

1. Right-click Bouncer Ignis in Applications and choose **Open**, then confirm.
2. Or open **System Settings, Privacy & Security**, scroll to **Security** and click **Open Anyway** next to Bouncer Ignis.

You can also remove the quarantine flag in Terminal:

```sh
xattr -dr com.apple.quarantine "/Applications/Bouncer Ignis.app"
```

## Uninstall

Uninstalling removes the app, not your models and chats.

1. Stop the background service: `ignis stop`.
2. Quit Bouncer Ignis, then move `Bouncer Ignis.app` from Applications to the Trash.
3. If you installed the commands, delete `ignis` and `bi` from where you put them.

To delete Ignis's data too, remove `~/Library/Application Support/Bouncer Ignis`. Your model library is Bouncer's and lives in `~/Library/Application Support/Bouncer/models`. Leave it if you use Bouncer. See [Models](models.md#the-library).

## Related

- [Getting started](getting-started.md)
- [System requirements](system-requirements.md)
- [Updates](updates.md)
- [Troubleshooting](troubleshooting.md)
