#!/bin/sh
# Builds the website into dist/, laid out the way it is served at https://bouncer-ai.pages.dev/ignis/:
# the site's files at the root of dist/, the user docs the docs page reads in dist/docs/, and the two
# installers in dist/ (so /ignis/install.sh and /ignis/install.ps1 work).
#
# get-bouncer's Cloudflare Pages build copies this dist/ into its own dist/ignis/. Nothing here needs a
# server: every link in the site is relative.
set -eu
cd "$(dirname "$0")/.."
rm -rf dist
mkdir dist

cp -R site/. dist/
if [ -d docs ]; then
  cp -R docs dist/docs
else
  echo "build-site.sh: no docs/ folder, the docs page will be empty" >&2
fi
cp scripts/install.sh scripts/install.ps1 dist/
echo "site built in dist/ (serve it at /ignis/)"
