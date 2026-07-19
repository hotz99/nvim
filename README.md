# Neovim config

Personal Neovim configuration built on [LazyVim](https://github.com/LazyVim/LazyVim).

> Tailored for macOS. Some pieces assume macOS-specific tools (Skim, Ghostty,
> the `open` command, and system fonts) — see the inline notes in
> `lua/plugins/latex.lua` and `lua/config/markdown_pdf_preview.lua`.

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim   # LazyVim bootstraps lazy.nvim and installs plugins on first launch
```

## What's customized

- **Colorscheme** — `github_dark_default` (`lua/plugins/colorscheme.lua`)
- **TypeScript** — TypeScript v7 `tsc --lsp` instead of `vtsls`; `oxlint` for
  linting and `oxfmt` for formatting, resolved from the workspace's
  `node_modules/.bin` (`lsp-tsc.lua`, `lint.lua`, `formatting.lua`)
- **Completion** — autocomplete popup off by default; toggle cmp with
  `<leader>uA` (`lua/plugins/cmp.lua`)
- **LaTeX** — VimTeX with `latexmk` + Skim (`lua/plugins/latex.lua`)
- **Markdown → PDF preview** — live pandoc/xelatex render shown inline via
  Snacks image (`lua/config/markdown_pdf_preview.lua`, keys under `<leader>m`)
- **Keymaps** — `jj` to escape insert mode; `<leader>at` / `<leader>af` yank the
  current file path (with/without line:col) for pasting into AI tools
  (`lua/config/keymaps.lua`)
