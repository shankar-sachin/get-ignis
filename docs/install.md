# Install Bouncer Ignis

Bouncer Ignis installs in one command, or from a file you download yourself. It runs on macOS (Apple silicon and Intel), Windows 10 and 11 (x64) and Linux (x64). See [System requirements](system-requirements.md).

## One-line install

### macOS and Linux

In Terminal:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh
```

The script fetches the newest release and checks it against the release's `SHA256SUMS` file. It never uses `sudo`.

On macOS it:

- puts `Bouncer Ignis.app` in `/Applications`, or in `~/Applications` when `/Applications` is not writable (`--user` always uses `~/Applications`);
- clears the macOS quarantine flag, so the unsigned app opens;
- links `ignis` and `bi` from inside the app into `~/.local/bin`, and tells you how to add that folder to your `PATH` if it is not there.

On Linux it:

- installs the portable app into `~/.local/share/bouncer-ignis/app`;
- adds an app menu entry, `~/.local/share/applications/bouncer-ignis.desktop`;
- links `ignis`, `bi` and `bouncer-ignis` into `~/.local/bin`, and tells you how to add that folder to your `PATH` if it is not there.

With `--cli-only` it installs just the two commands, into `~/.local/share/bouncer-ignis/cli`, linked from `~/.local/bin`.

### Windows

In PowerShell:

```powershell
irm https://bouncer-ai.pages.dev/ignis/install.ps1 | iex
```

The script fetches the newest release, checks it against `SHA256SUMS`, and runs the installer silently. The installer is per-user, so it needs no admin rights. It:

- installs Bouncer Ignis to `%LOCALAPPDATA%\Programs\Bouncer Ignis`;
- adds a Start menu entry;
- adds that folder to your user `PATH`, so `ignis` and `bi` work in a new terminal.

With `-CliOnly` it installs just `ignis.exe` and `bi.exe`, into `%LOCALAPPDATA%\Programs\Bouncer Ignis\cli`, and adds that folder to your user `PATH`.

## Installer options

On macOS and Linux, pass options after `-s --` when you pipe the script to `sh`:

```sh
curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh -s -- --dry-run
```

| Option | What it does |
| --- | --- |
| `--dry-run` | Find the release and print what would happen. Nothing is downloaded or installed. |
| `--version <tag>` | Install a specific release, for example `--version v0.3.0`. The default is the newest release. |
| `--cli-only` | Install only the `ignis` and `bi` commands, not the app. |
| `--user` | macOS only: install the app into `~/Applications`. |

On Windows, run the script as a script block to pass options:

```powershell
& ([scriptblock]::Create((irm https://bouncer-ai.pages.dev/ignis/install.ps1))) -DryRun
```

| Option | What it does |
| --- | --- |
| `-DryRun` | Find the release and print what would happen. Nothing is downloaded or installed. |
| `-Version <tag>` | Install a specific release. The default is the newest release. |
| `-CliOnly` | Install only `ignis.exe` and `bi.exe`, not the app. |

## Download it yourself

Every release is at [Releases](https://github.com/shankar-sachin/get-ignis/releases). Names include the version, shown here as `<version>`, for example `0.3.0`.

### macOS

Use `arm64` for Apple silicon and `x64` for Intel Macs.

| File | What it is |
| --- | --- |
| `Bouncer-Ignis-<version>-arm64.dmg`, `Bouncer-Ignis-<version>-x64.dmg` | The app, as a disk image. Open it and drag Bouncer Ignis to Applications. |
| `Bouncer-Ignis-<version>-arm64-mac.zip`, `Bouncer-Ignis-<version>-x64-mac.zip` | The app, as a zip. Unzip it and move it to Applications. |
| `ignis-cli-<version>-macos-arm64.tar.gz`, `ignis-cli-<version>-macos-x64.tar.gz` | Just the `ignis` and `bi` commands, without the app, in a folder named `ignis-<version>-macos-arm64` or `ignis-<version>-macos-x64`. |

The app also carries both commands, in `Bouncer Ignis.app/Contents/MacOS`.

### Windows

| File | What it is |
| --- | --- |
| `Bouncer-Ignis-Setup-<version>-x64.exe` | The installer. It installs for your user only, with no admin rights, to `%LOCALAPPDATA%\Programs\Bouncer Ignis`. It adds a Start menu entry and puts that folder on your user `PATH`, so `ignis` and `bi` work in a new terminal. |
| `ignis-cli-<version>-windows-x64.zip` | Just `ignis.exe` and `bi.exe`, without the app, in a folder named `ignis-<version>-windows-x64`. |

### Linux

| File | What it is |
| --- | --- |
| `bouncer-ignis_<version>_amd64.deb` | A system-wide install for Debian and Ubuntu. Run `sudo apt install ./bouncer-ignis_<version>_amd64.deb`. It puts the files in `/opt/bouncer-ignis`, links `ignis`, `bi` and `bouncer-ignis` into `/usr/bin`, and adds an app menu entry. |
| `Bouncer-Ignis-<version>-linux-x64.tar.gz` | A portable folder with `ignis-app`, `ignis`, `bi`, an icon and a `.desktop` file. Unpack it anywhere. |
| `ignis-cli-<version>-linux-x64.tar.gz` | Just the `ignis` and `bi` commands, without the app, in a folder named `ignis-<version>-linux-x64`. |

There is no AppImage.

### Checksums

| File | What it is |
| --- | --- |
| `SHA256SUMS` | The checksums of every file in the release. |

To use the commands from an archive instead of the app, unpack it and put `ignis` and `bi` in the same folder, on your `PATH`. `bi` looks for `ignis` next to itself. See [Terminal commands](cli.md).

## Verify the download

Each release includes a `SHA256SUMS` file. Save it in the folder with your download.

On macOS:

```sh
shasum -a 256 -c SHA256SUMS --ignore-missing
```

On Linux:

```sh
sha256sum -c SHA256SUMS --ignore-missing
```

On Windows, print the hash of the file and compare it with the line for that file in `SHA256SUMS`:

```powershell
Get-FileHash -Algorithm SHA256 .\Bouncer-Ignis-Setup-<version>-x64.exe
```

If a file's hash does not match, delete it and download it again.

## Unsigned builds

Ignis builds are not signed or notarized yet. This is expected for now. Only install builds from the releases page linked here.

### macOS

macOS may stop the first launch. If it blocks the app:

1. Right-click Bouncer Ignis in Applications and choose **Open**, then confirm.
2. Or open **System Settings, Privacy & Security**, scroll to **Security** and click **Open Anyway** next to Bouncer Ignis.

You can also remove the quarantine flag in Terminal:

```sh
xattr -dr com.apple.quarantine "/Applications/Bouncer Ignis.app"
```

### Windows

SmartScreen may warn about an installer you downloaded. Click **More info**, then **Run anyway**.

### Linux

Nothing special.

## Uninstall

Uninstalling removes the app, not your models and chats.

### macOS

1. Stop the background service: `ignis stop`.
2. Quit Bouncer Ignis, then move `Bouncer Ignis.app` from Applications to the Trash.
3. If you installed the commands, delete `ignis` and `bi` from where you put them.

If you turned on **Start at login**, turn it off first, or run `ignis disable`. Otherwise `~/Library/LaunchAgents/com.bouncer.ignis.service.plist` stays behind.

### Windows

Open **Settings, Apps, Installed apps**, find Bouncer Ignis and choose **Uninstall**. It stops the service and removes the login item. Models and chats stay.

If you installed with `-CliOnly`, delete `%LOCALAPPDATA%\Programs\Bouncer Ignis\cli` and remove it from your user `PATH`.

### Linux

- Installed with the `.deb`: `sudo apt remove bouncer-ignis`.
- Installed with the install script: run `ignis stop`, then delete `~/.local/share/bouncer-ignis`, `~/.local/share/applications/bouncer-ignis.desktop`, and the `ignis`, `bi` and `bouncer-ignis` links in `~/.local/bin`.

If you turned on **Start at login**, run `ignis disable` first, or delete `~/.config/autostart/bouncer-ignis.desktop`.

### Your data

To delete Ignis's data too, remove its data folder. Your model library is Bouncer's and lives in `models` inside Bouncer's folder. Leave it if you use Bouncer. See [Models](models.md#the-library).

| System | Ignis's data | Bouncer's folder (model library) |
| --- | --- | --- |
| macOS | `~/Library/Application Support/Bouncer Ignis` | `~/Library/Application Support/Bouncer` |
| Windows | `%APPDATA%\Bouncer Ignis` | `%APPDATA%\Bouncer` |
| Linux | `~/.config/Bouncer Ignis` | `~/.config/Bouncer` |

On Linux, the folders are under `$XDG_CONFIG_HOME` when it is set.

## Related

- [Getting started](getting-started.md)
- [System requirements](system-requirements.md)
- [Updates](updates.md)
- [Troubleshooting](troubleshooting.md)
