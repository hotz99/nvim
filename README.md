# Neovim config

Personal Neovim configuration built on [LazyVim](https://github.com/LazyVim/LazyVim).

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim   # LazyVim bootstraps lazy.nvim and installs plugins on first launch
```

## What's customized

- **Colorscheme** — `github_dark_default` (`lua/plugins/colorscheme.lua`)
- **TypeScript** — Effect-patched TypeScript 7 LSP instead of `vtsls`; `oxlint` for
  linting and `oxfmt` for formatting, resolved from the workspace's
  `node_modules/.bin` (`lsp-tsc.lua`, `lint.lua`, `formatting.lua`)
- **Completion** — autocomplete popup off by default; toggle cmp with
  `<leader>uA` (`lua/plugins/cmp.lua`)
- **Keymaps** — `jj` to escape insert mode; `<leader>at` / `<leader>af` yank the
  current file path (with/without line:col) for pasting into AI tools
  (`lua/config/keymaps.lua`)
