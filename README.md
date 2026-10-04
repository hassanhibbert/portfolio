# hassanhibbert.com

Source for my portfolio site: **[hassanhibbert.com](https://www.hassanhibbert.com)**.

A static site with no framework, on purpose. It's a single page of content, so plain HTML, CSS and a little JavaScript are all it needs. [Vite](https://vite.dev) builds it, and [vite-plugin-html-inject](https://github.com/donnikitos/vite-plugin-html-inject) splits the page into HTML partials (`src/templates/`) that are inlined at build time.

## Run

```bash
yarn install && yarn dev   # http://localhost:3000 (Node 20+, Yarn 4 via corepack)
```

## Deploy

`yarn deploy` builds the site and syncs `dist/` to the host over SSH (`rsync --delete`). `yarn deploy --dry-run` shows what would change first.

- **No secrets in the repo.** `DEPLOY_USER`, `DEPLOY_HOST` and `DEPLOY_PATH` come from the environment, or from a gitignored `.env.deploy.local` (template: `.env.deploy.local.example`). Values already exported take priority, and the script masks them in its output.
- **Key-only SSH.** The script fails instead of prompting for a password.
- **Other projects are safe.** Paths in `KEEP_ON_SERVER` (`scripts/deploy.sh`) are never deleted, and the script refuses to deploy to `/` or a home directory.
