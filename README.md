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
| `favicons/`, `favicon.ico`, `site.webmanifest` | Icons and web app manifest; the PNG icons and `favicon.ico` are rendered from `favicon.svg` and `maskable.svg` |
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

#### `pre-commit`: last modified dates and copyright year

When a commit includes site files, the hook sets the current date in three places and adds those files to the same commit:

| File | Field | Format |
|---|---|---|
| `index.html` | JSON-LD `dateModified` | `2026-11-08T13:07:23+01:00` |
| `sitemap.xml` | `<lastmod>` | `2026-11-08` |
| `humans.txt` | `Last update:` | `2026/11/08` |
| `index.html` | Footer copyright year | `2026` in 2026, then a range such as `2026–2027` |

- Commits that only touch repo files (any top-level dotfile or dot-directory such as `.github/` or `.gitattributes`, plus `lighthouserc.json`, `README*` and `LICENSE*`) leave the dates alone.
- If `index.html`, `sitemap.xml` or `humans.txt` has changes that are not staged, the commit is stopped, because the hook stages those files in full. Stage or stash the changes and commit again.
- To commit without running the hook, use `git commit --no-verify`.
- The hook is a POSIX `sh` script and works on Linux.

### Social preview image

After editing `img/og-image.svg`, re-render the PNG (needs the DejaVu Sans Mono font) and shrink it with pngquant and oxipng:

```sh
inkscape img/og-image.svg --export-type=png --export-filename=img/og-image.png
pngquant --quality=90-100 --speed 1 --strip --force --output img/og-image.png img/og-image.png
oxipng -o max --strip safe --alpha img/og-image.png
```

pngquant reduces the image to a 256-color palette, which is visually identical here and cuts the file to about a third.

CI fails if `og-image.svg` has a newer commit than `og-image.png`.

### Icons

`favicons/favicon.svg` is the source of every icon. After changing it, re-render the PNG icons and `favicon.ico` (needs Inkscape and ImageMagick):

```sh
for size in 16 32; do
    inkscape favicons/favicon.svg --export-type=png --export-width=$size --export-filename=favicons/favicon-${size}x${size}.png
done
inkscape favicons/favicon.svg --export-type=png --export-width=180 --export-filename=favicons/apple-touch-icon.png
for size in 192 512; do
    inkscape favicons/favicon.svg --export-type=png --export-width=$size --export-filename=favicons/android-chrome-${size}x${size}.png
done
inkscape favicons/favicon.svg --export-type=png --export-width=48 --export-filename=favicon-48.png
magick favicons/favicon-16x16.png favicons/favicon-32x32.png favicon-48.png favicon.ico
rm favicon-48.png
```

`favicons/maskable.svg` places `favicon.svg` inside the safe zone of a full-bleed background. After changing either, re-render the maskable icons:

```sh
for size in 192 512; do
    inkscape favicons/maskable.svg --export-type=png --export-width=$size --export-filename=favicons/maskable-${size}x${size}.png
done
```

CI fails if a source SVG has a newer commit than any icon rendered from it.

## Checks

GitHub Actions runs on every push, on pull requests and weekly:

- HTML validation with html-validate
- shell script linting of the git hooks and `.github/scripts/` with ShellCheck
- CSS linting with stylelint (`stylelint-config-standard`, see `.stylelintrc.json`)
- JSON checks: the web app manifest and the JSON-LD in `index.html` must parse
- rendered images (the social preview image and all icons) must not be older than their SVG sources
- link checking with lychee
- Lighthouse scores: the median performance score over three runs must be at least 0.9, accessibility at least 0.95, best practices and SEO at least 0.9 (see `lighthouserc.json`)
- on the weekly run and manual runs only: the action and npm versions pinned in the workflows must not be a major version behind (`.github/scripts/check-updates.sh`, which can also be run locally with `gh` and `npm`)

## Deployment

The site is served by Caddy as static files.

Pushing a `v*` tag creates a GitHub release. Its "Source code" archives (and `git archive`) contain only the files the web server needs, plus `LICENSE` and `LICENSE-CONTENT`. Dotfiles, documentation, tooling config and source SVGs are excluded via `export-ignore` in [.gitattributes](.gitattributes). Add any new non-served file there.

## License

- **Code** (HTML markup, CSS, JavaScript, configuration and scripts) is licensed under the GNU General Public License v3.0 or later. See [LICENSE](LICENSE).
- **Content** (text, pronunciation recordings in `sound/` and the site's own images) is licensed under Creative Commons Attribution-NoDerivatives 4.0 International. See [LICENSE-CONTENT](LICENSE-CONTENT).

The GitHub, LinkedIn, Sifa and Wiktionary logos and the flags are not covered by these licenses. They belong to their respective owners.
