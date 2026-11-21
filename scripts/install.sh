#!/bin/sh
# Bouncer Ignis installer for macOS (Apple silicon and Intel) and Linux (x64). POSIX sh: works with sh, bash,
# zsh and dash. Windows has install.ps1.
#
# Releases are public in github.com/shankar-sachin/get-ignis (the source stays private):
#   curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh
#   curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh -s -- --dry-run
# or run a local copy: sh install.sh [--dry-run] [--cli-only] [--version v0.2.0]
#
# No login needed. GH_TOKEN or GITHUB_TOKEN, when set, is sent to avoid GitHub's API rate limit.
# Version: the latest release, or --version / IGNIS_VERSION. Release tags look like ignis-v0.2.0.
set -eu

REPO="shankar-sachin/get-ignis"
API="https://api.github.com"
RELEASES_URL="https://github.com/$REPO/releases"

DRY_RUN=0
USER_INSTALL=0
CLI_ONLY=0
VERSION="${IGNIS_VERSION:-}"
TOKEN=""
TMP=""
TAG=""
VER=""
OS=""
ARCH=""

usage() {
  cat <<'EOT'
Usage: install.sh [options]

Installs the latest Bouncer Ignis release, or a given version, from the public releases at
shankar-sachin/get-ignis, on macOS (Apple silicon or Intel) or Linux (x64). Windows: install.ps1.

  macOS       Downloads Bouncer-Ignis-<version>-<arch>-mac.zip, checks it against SHA256SUMS and installs
              "Bouncer Ignis.app" into /Applications (or ~/Applications when that is not writable, or
              with --user). Removes the quarantine flag and links the ignis and bi commands into
              ~/.local/bin.
  Linux       Downloads Bouncer-Ignis-<version>-linux-x64.tar.gz, checks it, unpacks it into
              ~/.local/share/bouncer-ignis/app, adds Bouncer Ignis to the app menu and links ignis, bi
              and bouncer-ignis into ~/.local/bin. (The .deb on the releases page installs system-wide.)
  --cli-only  Downloads ignis-cli-<version>-<os>-<arch>.tar.gz instead and installs just ignis and bi
              (into ~/.local/share/bouncer-ignis/cli, linked from ~/.local/bin). No app.

Never uses sudo.

Options:
  --version <tag>  Install a specific version: v0.2.0, ignis-v0.2.0 or 0.2.0 (default: latest).
                   IGNIS_VERSION does the same.
  --cli-only       Install only the ignis and bi commands.
  --user           Install the app into ~/Applications even when /Applications is writable.
  --dry-run        Print every step and change nothing. The release is looked up, nothing is downloaded.
  -h, --help       Show this help.

No login needed. GH_TOKEN or GITHUB_TOKEN, when set, raises the API rate limit.

Piped usage passes options after -s --:
  curl -fsSL https://bouncer-ai.pages.dev/ignis/install.sh | sh -s -- --dry-run
EOT
}

die() {
  echo "install.sh: error: $*" >&2
  exit 1
}

warn() {
  echo "install.sh: warning: $*" >&2
}

info() {
  echo "==> $*"
}

cleanup() {
  if [ -n "$TMP" ] && [ -d "$TMP" ]; then
    rm -rf "$TMP"
  fi
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --user) USER_INSTALL=1 ;;
      --cli-only) CLI_ONLY=1 ;;
      --version)
        [ $# -ge 2 ] || die "--version needs a value, e.g. --version v0.2.0"
        VERSION="$2"
        shift
        ;;
      --version=*) VERSION="${1#--version=}" ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
  done
}

# Builds: macOS arm64 and x64, Linux x64. Anything else gets a clear message and exit code 1.
check_platform() {
  case "$(uname -s)" in
    Darwin)
      OS=macos
      if is_apple_silicon; then ARCH=arm64; else ARCH=x64; fi
      ;;
    Linux)
      OS=linux
      case "$(uname -m)" in
        x86_64 | amd64) ARCH=x64 ;;
        *)
          echo "Bouncer Ignis is not available for Linux on $(uname -m) yet: Linux builds are x64 only." >&2
          echo "Watch $RELEASES_URL for new builds." >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Bouncer Ignis is not available for $(uname -s). It runs on macOS, Windows (install.ps1) and Linux." >&2
      echo "See $RELEASES_URL" >&2
      exit 1
      ;;
  esac
}

is_apple_silicon() {
  [ "$(uname -m)" = "arm64" ] && return 0
  # Under Rosetta, uname reports x86_64. The hardware flag still shows Apple silicon.
  [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = "1" ]
}

setup_auth() {
  command -v curl >/dev/null 2>&1 || die "curl is needed to download Bouncer Ignis"
  TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
}

# curl against the GitHub API, with the token when there is one. $1 Accept header, then curl args.
gh_curl() {
  accept=$1
  shift
  if [ -n "$TOKEN" ]; then
    curl -fsSL -H "Authorization: Bearer $TOKEN" -H "Accept: $accept" "$@" </dev/null
  else
    curl -fsSL -H "Accept: $accept" "$@" </dev/null
  fi
}

# GET repos/$REPO/<path>, printing the JSON on stdout.
api_get() {
  gh_curl application/vnd.github+json "$API/repos/$REPO/$1" \
    || die "GitHub API request failed: $1 (no such release, or the API rate limit; set GH_TOKEN to raise it)"
}

resolve_release() {
  if [ -n "$VERSION" ]; then
    case "$VERSION" in
      ignis-v*) TAG="$VERSION" ;;
      v*) TAG="ignis-$VERSION" ;;
      *) TAG="ignis-v$VERSION" ;;
    esac
  else
    api_get "releases?per_page=30" >"$TMP/list.json"
    TAG=$(grep -o '"tag_name": *"ignis-v[^"]*"' "$TMP/list.json" | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/' || true)
    [ -n "$TAG" ] || die "Bouncer Ignis has no published release yet. Watch $RELEASES_URL for the first one."
  fi
  VER="${TAG#ignis-v}"
  api_get "releases/tags/$TAG" >"$TMP/release.json"

  # "id name" for each asset: the id from the asset's API url, the name from its download url.
  awk '
    /"url": *"[^"]*\/releases\/assets\/[0-9]+"/ { s = $0; sub(/.*\/releases\/assets\//, "", s); sub(/".*/, "", s); id = s }
    /"browser_download_url"/ { s = $0; sub(/.*\//, "", s); sub(/".*/, "", s); if (id != "") print id, s; id = "" }
  ' "$TMP/release.json" >"$TMP/assets.txt"
}

asset_exists() {
  awk -v n="$1" '$2 == n { found = 1 } END { exit !found }' "$TMP/assets.txt"
}

asset_id() {
  awk -v n="$1" '$2 == n { print $1; exit }' "$TMP/assets.txt"
}

asset_list() {
  awk '{ printf "%s ", $2 }' "$TMP/assets.txt"
}

download_asset() {
  # $1 asset name, $2 destination path
  id=$(asset_id "$1")
  gh_curl application/octet-stream -o "$2" "$API/repos/$REPO/releases/assets/$id" || die "download failed: $1"
  info "downloaded $1"
}

sha256_of() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  else
    sha256sum "$1" | awk '{ print $1 }'
  fi
}

# Download an asset and check it against SHA256SUMS. A release without SHA256SUMS is refused.
fetch_verified() {
  asset_exists SHA256SUMS || die "$TAG has no SHA256SUMS asset, so $1 can't be verified. Nothing was installed."
  download_asset "$1" "$TMP/$1"
  download_asset SHA256SUMS "$TMP/SHA256SUMS"
  expected=$(awk -v n="$1" '$2 == n || $2 == ("*" n) { print $1; exit }' "$TMP/SHA256SUMS")
  [ -n "$expected" ] || die "SHA256SUMS has no entry for $1"
  actual=$(sha256_of "$TMP/$1")
  [ "$expected" = "$actual" ] || die "checksum mismatch for $1 (expected $expected, got $actual)"
  info "sha256 verified for $1"
}

BIN_DIR="$HOME/.local/bin"

# Links ~/.local/bin/<name> to $2. A link that already points into a Bouncer Ignis install is replaced;
# anything else at that path is left alone with a warning.
link_one() {
  name=$1
  target=$2
  link="$BIN_DIR/$name"
  if [ -L "$link" ]; then
    case "$(readlink "$link")" in
      *"/Bouncer Ignis.app/Contents/MacOS/$name" | */bouncer-ignis/cli/"$name" | */bouncer-ignis/app/*) ;;
      *)
        warn "$link already exists and isn't Ignis's, so the $name command was not set up"
        return 0
        ;;
    esac
  elif [ -e "$link" ]; then
    warn "$link already exists and isn't Ignis's, so the $name command was not set up"
    return 0
  fi
  rm -f "$link"
  ln -s "$target" "$link"
  info "linked $link -> $target"
}

link_cli() {
  # $1 directory holding the ignis and bi binaries
  mkdir -p "$BIN_DIR"
  link_one ignis "$1/ignis"
  link_one bi "$1/bi"
  profile="~/.zprofile"
  [ "$OS" = linux ] && profile="~/.profile"
  case ":$PATH:" in
    *":$BIN_DIR:"*) echo "terminal: run ignis --help, or bi \"hello\"" ;;
    *)
      echo "note: $BIN_DIR is not on your PATH. Add this line to $profile, then open a new terminal:"
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      ;;
  esac
}

install_app() {
  if [ "$OS" = linux ]; then
    install_linux_app
    return
  fi
  zip="Bouncer-Ignis-$VER-$ARCH-mac.zip"
  asset_exists "$zip" || die "$TAG has no macOS build named $zip. Available: $(asset_list)"

  dest_dir="/Applications"
  if [ "$USER_INSTALL" -eq 1 ] || [ ! -w /Applications ]; then
    dest_dir="$HOME/Applications"
  fi
  target="$dest_dir/Bouncer Ignis.app"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would download: $zip and SHA256SUMS"
    echo "would verify: shasum -a 256 against SHA256SUMS (stops on a mismatch)"
    echo "would unzip and install: $target (replacing any existing copy)"
    echo "would remove quarantine: xattr -dr com.apple.quarantine \"$target\""
    echo "would link: $BIN_DIR/ignis and $BIN_DIR/bi -> $target/Contents/MacOS/"
    echo "would not use sudo"
    return 0
  fi

  fetch_verified "$zip"
  mkdir -p "$TMP/mac"
  ditto -x -k "$TMP/$zip" "$TMP/mac" || die "could not unzip $zip"
  [ -d "$TMP/mac/Bouncer Ignis.app" ] || die "Bouncer Ignis.app not found inside $zip"

  mkdir -p "$dest_dir"
  if [ -e "$target" ]; then
    if pgrep -f "Bouncer Ignis.app/Contents/MacOS" >/dev/null 2>&1; then
      warn "Bouncer Ignis is running. Quit it first, or the old copy keeps running until you relaunch."
    fi
    info "replacing $target"
    rm -rf "$target"
  fi
  mv "$TMP/mac/Bouncer Ignis.app" "$target"
  xattr -dr com.apple.quarantine "$target" 2>/dev/null || true

  info "installed $target"
  echo "launch with: open \"$target\""
  link_cli "$target/Contents/MacOS"
  echo "If macOS still blocks the first launch (unsigned build): right-click Bouncer Ignis, choose Open."
}

# Linux: the portable app folder in ~/.local/share/bouncer-ignis/app, a menu entry and the commands.
install_linux_app() {
  tarball="Bouncer-Ignis-$VER-linux-$ARCH.tar.gz"
  asset_exists "$tarball" || die "$TAG has no Linux build named $tarball. Available: $(asset_list)"
  app_dir="$HOME/.local/share/bouncer-ignis/app"
  apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would download: $tarball and SHA256SUMS"
    echo "would verify: sha256 against SHA256SUMS (stops on a mismatch)"
    echo "would install: $app_dir (replacing any existing copy)"
    echo "would add to the app menu: $apps_dir/bouncer-ignis.desktop"
    echo "would link: $BIN_DIR/ignis, $BIN_DIR/bi and $BIN_DIR/bouncer-ignis -> $app_dir/"
    echo "would not use sudo"
    return 0
  fi

  fetch_verified "$tarball"
  mkdir -p "$TMP/linux"
  tar -xzf "$TMP/$tarball" -C "$TMP/linux" || die "could not unpack $tarball"
  src=$(find "$TMP/linux" -type f -name ignis-app | head -n 1)
  [ -n "$src" ] || die "ignis-app was not found inside $tarball"
  src=$(dirname "$src")

  if [ -x "$app_dir/ignis" ]; then
    "$app_dir/ignis" stop >/dev/null 2>&1 || true
  fi
  rm -rf "$app_dir"
  mkdir -p "$(dirname "$app_dir")"
  mv "$src" "$app_dir"
  info "installed $app_dir"

  mkdir -p "$apps_dir"
  cat >"$apps_dir/bouncer-ignis.desktop" <<EOT
[Desktop Entry]
Type=Application
Name=Bouncer Ignis
Comment=Run local models: chat, code and bots
Exec="$app_dir/ignis-app" %U
Icon=$app_dir/bouncer-ignis.png
Terminal=false
Categories=Development;Utility;
StartupWMClass=ignis-app
EOT
  info "added Bouncer Ignis to the app menu"
  link_cli "$app_dir"
  link_one bouncer-ignis "$app_dir/ignis-app"
  echo "launch with: bouncer-ignis, or Bouncer Ignis in the app menu"
}

install_cli() {
  tarball="ignis-cli-$VER-$OS-$ARCH.tar.gz"
  asset_exists "$tarball" || die "$TAG has no terminal build named $tarball. Available: $(asset_list)"
  cli_dir="$HOME/.local/share/bouncer-ignis/cli"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would download: $tarball and SHA256SUMS"
    echo "would verify: sha256 against SHA256SUMS (stops on a mismatch)"
    echo "would install: $cli_dir/ignis and $cli_dir/bi"
    [ "$OS" = macos ] && echo "would remove quarantine: xattr -dr com.apple.quarantine \"$cli_dir\""
    echo "would link: $BIN_DIR/ignis and $BIN_DIR/bi -> $cli_dir/"
    echo "would not use sudo"
    return 0
  fi

  fetch_verified "$tarball"
  mkdir -p "$TMP/cli"
  tar -xzf "$TMP/$tarball" -C "$TMP/cli" || die "could not unpack $tarball"
  ignis_bin=$(find "$TMP/cli" -type f -name ignis | head -n 1)
  bi_bin=$(find "$TMP/cli" -type f -name bi | head -n 1)
  [ -n "$ignis_bin" ] && [ -n "$bi_bin" ] || die "ignis and bi were not found inside $tarball"

  mkdir -p "$cli_dir"
  rm -f "$cli_dir/ignis" "$cli_dir/bi"
  cp "$ignis_bin" "$cli_dir/ignis"
  cp "$bi_bin" "$cli_dir/bi"
  chmod 755 "$cli_dir/ignis" "$cli_dir/bi"
  if [ "$OS" = macos ]; then
    xattr -dr com.apple.quarantine "$cli_dir" 2>/dev/null || true
  fi
  info "installed ignis and bi in $cli_dir"
  link_cli "$cli_dir"
}

main() {
  parse_args "$@"
  check_platform

  TMP=$(mktemp -d "${TMPDIR:-/tmp}/ignis-install.XXXXXX")
  trap cleanup EXIT INT TERM

  setup_auth
  if [ "$DRY_RUN" -eq 1 ]; then
    info "dry run: the release is looked up, nothing is downloaded or changed"
  fi
  info "repository: $REPO"
  resolve_release
  info "release: $TAG ($OS $ARCH)"

  if [ "$CLI_ONLY" -eq 1 ]; then
    install_cli
  else
    install_app
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "dry run: nothing was downloaded or installed"
  fi
}

main "$@"
