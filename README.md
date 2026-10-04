# hassanhibbert.com

Source for my portfolio site: **[hassanhibbert.com](https://www.hassanhibbert.com)**.

I'm a software developer who builds features end to end, from React and React Native frontends to Java and Spring Boot backends. The site covers my recent projects and background.

## Stack

A static site with no framework, on purpose: it's a few pages of content, so plain HTML, CSS and a little JavaScript are all it needs.

- **[Vite](https://vite.dev)** for the dev server and production build
- **[vite-plugin-html-inject](https://github.com/donnikitos/vite-plugin-html-inject)** to split the page into HTML partials (`<load src="…" />`) that are inlined at build time
- **Vanilla CSS** with custom properties for the theme, and a responsive layout from phone width up
- **Vanilla JavaScript** modules: the copyright year, plus an `IntersectionObserver` that highlights the current section in the sidebar

## Project structure

```
src/
├── index.html              page shell; pulls in the partials below
├── main.js                 entry: styles + scripts
├── css/style.css           theme tokens, layout, components
├── scripts/                small JS modules
├── public/                 copied as-is (favicon)
└── templates/
    ├── layout/             sidebar
    ├── content/            intro, about, contact
    └── projects/           one partial per project card
scripts/deploy.sh           build + rsync to the host
```

## Running locally

Requires Node 20+ and Yarn 4 (via `corepack enable`).

```bash
yarn install
yarn dev        # http://localhost:3000
yarn build      # outputs to dist/
yarn preview    # serve the production build
```

## Deployment

`yarn deploy` builds the site and syncs `dist/` to the web host over SSH with `rsync --delete`.

Connection details come from environment variables only. Nothing about the server is committed:

| Variable | Purpose |
|---|---|
| `DEPLOY_USER` | SSH user |
| `DEPLOY_HOST` | SSH host |
| `DEPLOY_PATH` | the site's web folder on the server |

Export them in your shell, or copy `.env.deploy.local.example` to `.env.deploy.local` (gitignored). Variables already set in the environment take priority over the file. Login uses an SSH key; the script fails instead of prompting for a password.

```bash
yarn deploy --dry-run   # show what would be uploaded or deleted
yarn deploy
```

The script refuses to deploy to `/` or a home directory. Paths listed in `KEEP_ON_SERVER` in `scripts/deploy.sh` are never touched by `--delete`. That list covers `.well-known/`, `.htaccess`, and older projects that still live on the domain.
