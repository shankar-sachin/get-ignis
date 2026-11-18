/* Bouncer Ignis landing page: release lookup, copy buttons, theme toggle. Vanilla JS, no build. */
(function () {
  'use strict';

  var REPO = 'shankar-sachin/get-ignis';
  var RELEASES_URL = 'https://github.com/' + REPO + '/releases';
  var API_URL = 'https://api.github.com/repos/' + REPO + '/releases?per_page=10';
  // Same key as the Bouncer site, so a theme choice carries over between the two.
  var THEME_KEY = 'bouncer-theme';

  function $(sel, root) {
    return (root || document).querySelector(sel);
  }

  function $all(sel, root) {
    return Array.prototype.slice.call((root || document).querySelectorAll(sel));
  }

  function isMac() {
    var uad = navigator.userAgentData;
    var platform = (uad && uad.platform) || navigator.platform || '';
    var ua = navigator.userAgent || '';
    if (/iPhone|iPad|iPod|Android/i.test(ua)) return false;
    return /mac/i.test(platform) || /Macintosh|Mac OS X/.test(ua);
  }

  /* ---------- release lookup ---------- */

  function fetchLatestRelease() {
    return fetch(API_URL, { headers: { Accept: 'application/vnd.github+json' } })
      .then(function (res) {
        if (!res.ok) throw new Error('GitHub responded ' + res.status);
        return res.json();
      })
      .then(function (releases) {
        if (!Array.isArray(releases)) return null;
        for (var i = 0; i < releases.length; i++) {
          var r = releases[i];
          if (!r.draft && /^ignis-v/.test(r.tag_name || '') && Array.isArray(r.assets) && r.assets.length) return r;
        }
        return null;
      });
  }

  /* Bouncer-Ignis-<v>-arm64.dmg, Bouncer-Ignis-<v>-arm64-mac.zip, ignis-cli-<v>-macos-arm64.tar.gz */
  function pickAssets(assets) {
    function find(re) {
      for (var i = 0; i < assets.length; i++) {
        if (re.test(assets[i].name || '')) return assets[i];
      }
      return null;
    }
    return {
      dmg: find(/^Bouncer-Ignis-.*-arm64\.dmg$/),
      zip: find(/^Bouncer-Ignis-.*-arm64-mac\.zip$/),
      cli: find(/^ignis-cli-.*-macos-arm64\.tar\.gz$/),
      sums: find(/^SHA256SUMS$/)
    };
  }

  function versionOf(release) {
    return (release.tag_name || '').replace(/^ignis-v/, '');
  }

  /* ---------- rendering ---------- */

  function setBadge(text, live) {
    var badge = $('#release-badge');
    if (!badge) return;
    var label = $('[data-release-label]', badge);
    if (label) label.textContent = text;
    badge.classList.toggle('is-live', !!live);
  }

  function renderList(assets) {
    $all('[data-state]').forEach(function (cell) {
      var key = cell.getAttribute('data-state');
      var asset = assets && assets[key];
      var fileEl = $('[data-file="' + key + '"]', cell.parentNode);
      if (asset) {
        cell.textContent = '';
        var link = document.createElement('a');
        link.href = asset.browser_download_url;
        link.textContent = 'download';
        link.setAttribute('aria-label', 'download ' + asset.name);
        cell.appendChild(link);
        if (fileEl) fileEl.textContent = asset.name;
      }
    });
  }

  function render(release) {
    var status = $('#download-status');
    var btn = $('#hero-download');
    var assets = release ? pickAssets(release.assets) : null;
    if (!assets) {
      if (status) status.textContent = 'Could not read the latest release. See all releases on GitHub.';
      return;
    }
    var version = versionOf(release);
    setBadge('v' + version + ' · macOS, Apple silicon', true);
    if (btn && assets.dmg && isMac()) {
      btn.setAttribute('href', assets.dmg.browser_download_url);
    }
    if (status) status.textContent = 'Latest release: v' + version + '. Builds are unsigned, see the FAQ.';
    renderList(assets);
  }

  /* ---------- copy buttons ---------- */

  function setupCopy() {
    $all('[data-copy]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var text = btn.getAttribute('data-copy');
        var done = function () {
          btn.textContent = 'copied';
          setTimeout(function () {
            btn.textContent = 'copy';
          }, 1600);
        };
        try {
          if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(done, function () {
              btn.textContent = 'select the text';
            });
          } else {
            btn.textContent = 'select the text';
          }
        } catch (e) {
          btn.textContent = 'select the text';
        }
      });
    });
  }

  /* ---------- theme toggle ---------- */

  function currentTheme() {
    var attr = document.documentElement.getAttribute('data-theme');
    if (attr === 'light' || attr === 'dark') return attr;
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
  }

  function labelToggle(btn, theme) {
    var next = theme === 'light' ? 'dark' : 'light';
    btn.setAttribute('aria-label', 'switch to ' + next + ' theme');
    btn.setAttribute('title', 'switch to ' + next + ' theme');
  }

  /* Screenshots come in a light and an obsidian version. Without a stored choice the browser picks by the
     system preference (<picture> media queries). A manual choice enables the matching source and switches the
     other one off, so the image follows the toggle. */
  function applyScreens(theme) {
    var pictures = document.querySelectorAll('picture');
    for (var i = 0; i < pictures.length; i++) {
      var dark = pictures[i].querySelector('source[data-scheme="dark"]');
      var light = pictures[i].querySelector('source[data-scheme="light"]');
      if (!dark || !light) continue;
      dark.setAttribute('media', theme === 'dark' ? 'all' : 'not all');
      light.setAttribute('media', theme === 'light' ? 'all' : 'not all');
    }
  }

  function setupTheme() {
    var btn = $('#theme-toggle');
    if (!btn) return;
    labelToggle(btn, currentTheme());
    if (document.documentElement.getAttribute('data-theme')) applyScreens(currentTheme());
    btn.addEventListener('click', function () {
      var next = currentTheme() === 'light' ? 'dark' : 'light';
      document.documentElement.setAttribute('data-theme', next);
      labelToggle(btn, next);
      applyScreens(next);
      try {
        localStorage.setItem(THEME_KEY, next);
      } catch (e) {
        /* blocked storage: the choice still applies for this visit */
      }
    });
  }

  /* ---------- boot ---------- */

  function init() {
    setupTheme();
    setupCopy();
    fetchLatestRelease()
      .then(render)
      .catch(function () {
        var status = $('#download-status');
        if (status) status.textContent = 'Could not reach GitHub. See all releases on GitHub.';
      });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
