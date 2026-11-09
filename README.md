# daniel.serbanescu.dk

Personal page of Daniel Șerbănescu: https://daniel.serbanescu.dk/

A static site with no build step: plain HTML, CSS, a little JavaScript, SVG images and MP3 pronunciation recordings.

## Structure

| Path | Purpose |
|---|---|
| `index.html` | The page, including JSON-LD and social preview tags |
| `style.css` | Styles |
| `script/audio.js` | Plays pronunciations in place; without JavaScript the links open the MP3s |
| `img/` | Images; `og-image.png` is rendered from `og-image.svg` |
| `sound/` | Pronunciation recordings |
| `favicons/`, `favicon.ico`, `site.webmanifest` | Icons and web app manifest |
| `robots.txt`, `sitemap.xml`, `humans.txt` | Crawler and author metadata |

## Development

Open `index.html` in a browser, or serve the folder locally:

```sh
python3 -m http.server
```

### Git hooks

The repository keeps its git hooks in `.githooks/`. Git does not enable hooks from a clone automatically, so turn them on once per clone:

```sh
git config core.hooksPath .githooks
```

Check that they are enabled (prints `.githooks`):

```sh
git config --get core.hooksPath
```

To turn them off again:

```sh
git config --unset core.hooksPath
```

#### `pre-commit`: last modified dates

When a commit includes site files, the hook sets the current date in three places and adds those files to the same commit:

| File | Field | Format |
|---|---|---|
| `index.html` | JSON-LD `dateModified` | `2026-11-08T13:07:23+01:00` |
| `sitemap.xml` | `<lastmod>` | `2026-11-08` |
| `humans.txt` | `Last update:` | `2026/11/08` |

- Commits that only touch repo files (`.githooks/`, `.github/`, `.vscode/`, `.gitignore`, `.htmlvalidate.json`, `lighthouserc.json`, `README*`, `LICENSE*`) leave the dates alone.
- If `index.html`, `sitemap.xml` or `humans.txt` has changes that are not staged, the commit is stopped, because the hook stages those files in full. Stage or stash the changes and commit again.
- To commit without running the hook, use `git commit --no-verify`.
- The hook is a POSIX `sh` script and works on Linux and macOS.

### Social preview image

After editing `img/og-image.svg`, re-render the PNG (needs the DejaVu Sans Mono font):

```sh
inkscape img/og-image.svg --export-type=png --export-filename=img/og-image.png
```

## Checks

GitHub Actions runs on every push, on pull requests and weekly:

- HTML validation with html-validate
- link checking with lychee
- Lighthouse scores (accessibility, best practices and SEO must pass)

## Deployment

The site is served by Caddy as static files.

## License

- **Code** (HTML markup, CSS, JavaScript, configuration and scripts) is licensed under the GNU General Public License v3.0 or later. See [LICENSE](LICENSE).
- **Content** (text, pronunciation recordings in `sound/` and the site's own images) is licensed under Creative Commons Attribution-NoDerivatives 4.0 International. See [LICENSE-CONTENT](LICENSE-CONTENT).

The GitHub, LinkedIn, Sifa and Wiktionary logos and the flags are not covered by these licenses. They belong to their respective owners.
