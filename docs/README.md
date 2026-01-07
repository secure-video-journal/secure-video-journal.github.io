# Secure Video Journal Blog

Marketing blog for [Secure Video Journal](https://securevideojournal.com), built with Jekyll and the Minima theme.

**Live site:** https://blog.securevideojournal.com

---

## Prerequisites

- [mise](https://mise.jdx.dev/) (recommended) or Ruby 3.x
- Bundler (`gem install bundler`)

### Using mise

```bash
# Install Ruby version from .mise.toml (if present) or latest
mise install ruby

# Activate the environment
mise activate
```

## Running Locally

```bash
# Install dependencies
bundle install

# Start the development server
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

### Live reload (optional)

```bash
bundle exec jekyll serve --livereload
```

### Including draft posts

Posts with `published: false` won't appear by default. To preview them:

```bash
bundle exec jekyll serve --unpublished
```

---

## Deployment

This site deploys automatically via **GitHub Pages** when you push to the `main` branch.

The build output goes to the `docs/` folder (configured via `destination: docs` in `_config.yml`), which GitHub Pages serves.

### Manual build

```bash
bundle exec jekyll build
```

This outputs the static site to `docs/`.

---

## Project Structure

```
├── _config.yml          # Site configuration (title, URL, theme, plugins)
├── _posts/              # Blog posts (Markdown)
├── _includes/           # Reusable HTML partials (header, footer, etc.)
├── _sass/minima/        # Custom SCSS overrides for Minima theme
├── assets/              # Images, logos, and other static files
├── index.markdown       # Homepage
├── docs/                # Built site output (served by GitHub Pages)
├── Gemfile              # Ruby dependencies
└── README.md            # This file
```

---

## Writing Blog Posts

### Creating a new post

Create a file in `_posts/` with the naming convention:

```
YYYY-MM-DD-your-post-slug.markdown
```

Example: `2025-07-15-benefits-of-video-journaling.markdown`

### Front matter template

```markdown
---
layout: post
title: "Your Post Title"
date: 2025-07-15 10:00:00 +0100
categories: journaling self-growth
published: true
---

Your content here...
```

### Front matter options

| Field        | Required | Description                                      |
|--------------|----------|--------------------------------------------------|
| `layout`     | Yes      | Use `post` for blog posts                        |
| `title`      | Yes      | Post title (appears in browser tab and listings) |
| `date`       | Yes      | Publication date with timezone                   |
| `categories` | No       | Space-separated categories for organization      |
| `published`  | No       | Set to `false` to hide from production           |

### Markdown tips

- Use `**bold**` and `*italic*` for emphasis
- Add images: `![Alt text](/assets/img/your-image.png)`
- Superscript citations: `<sup>[1](https://example.com)</sup>`
- HTML tables work directly in Markdown files

---

## Customizing Styles

### Theme customization

The site uses the [Minima](https://github.com/jekyll/minima) theme with custom overrides:

- **`_sass/minima/custom-variables.scss`** - Override theme variables (fonts, colors, spacing)
- **`_sass/minima/custom-styles.scss`** - Add custom CSS rules

### Layout overrides

Custom layouts in `_includes/` override Minima defaults:

- `header.html` - Site header with logo linking to main product site
- `footer.html` - Site footer
- `head.html` - `<head>` content (meta tags, fonts)
- `custom-head.html` - Additional head content (analytics, etc.)

---

## Configuration

Key settings in `_config.yml`:

```yaml
title: Secure Video Journal Blog
url: "https://blog.securevideojournal.com"
destination: docs                    # Build output folder
theme: minima

minima:
  google_analytics: G-RZ0RTXS1PK     # GA4 tracking
  hide_site_feed_link: true          # Hide RSS link in footer
```

**Note:** Changes to `_config.yml` require a server restart.

---

## Current Posts

| File | Title | Status |
|------|-------|--------|
| `2025-06-01-why-keep-a-journal.markdown` | Why Keep a Journal? | Draft |
| `2025-06-14-video-vs-text.markdown` | Video vs Text | - |
| `2025-06-30-mental-health-benefits-of-journaling.markdown` | Mental Health Benefits | - |
| `2025-07-01-cloud-secure copy.markdown` | Cloud Security | - |
| `2025-07-02-encrypted-memories.markdown` | Encrypted Memories | - |

---

## Troubleshooting

### Bundle install fails

```bash
# Update bundler
gem install bundler

# Clear cache and retry
rm -rf vendor/bundle
bundle install
```

### Changes not appearing

1. Check `published: true` in front matter
2. Restart the Jekyll server (required for `_config.yml` changes)
3. Clear browser cache or hard refresh (Cmd+Shift+R)

### Build errors

```bash
# Verbose build output
bundle exec jekyll build --verbose
```