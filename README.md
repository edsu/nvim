# nvim

This is my [neovim](https://neovim.io/) setup that I started experimenting with in December 2021 after many years of using vim proper. It also includes information about setting up different language environments.

First install [vim-plug]. Then clone this repo into `~/.config/nvim`. It has some minor language specific configuration (indents, etc) and also sets up some plugins that I like to use like:

* [vim-airline](https://github.com/vim-airline/vim-airline): a visually pleasing & informative status bar
* [vim-pencil](https://github.com/preservim/vim-pencil): some nice defaults for writing prose instead of code
* [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc): edit markdown, especially for pandoc
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig): language server support for python, ruby, javascript, etc
* [nvim-tree](https://github.com/kyazdani42/nvim-tree.lua): a file explorer
* [goyo](https://github.com/junegunn/goyo.vim): distraction free writing
* [glow.nvim](https://github.com/ellisonleao/glow.nvim): viewing markdown in editor
* [nvim-telescope](https://github.com/nvim-telescope/telescope.nvim): use ripgrep to search files quickly

For powerline and nvim-tree to display properly a [NerdTree] font is needed. I use `Hack Nerd Font Mono`. After you download the ZIP, unzip it and use Font Book to install the .ttf files.

## Language servers

Language runtimes and most of the servers are managed with [mise], so install
that first:

    $ curl https://mise.run | sh

Then activate it in your shell (`~/.zshrc`), which is what puts the tools below
on `PATH` — nvim finds its language servers by inheriting `PATH` from whatever
shell it was started in, so if this is missing nothing attaches:

    eval "$(mise activate zsh)"

The runtimes themselves come from mise too, which is the point of using it —
each project can pin its own versions and nvim picks them up:

    $ mise use -g python node ruby

Then the servers, for support from
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md):

    $ mise use -g ruff ty                          # python
    $ mise use -g npm:typescript-language-server   # typescript / javascript
    $ mise use -g gem:ruby-lsp                     # ruby
    $ brew install rust-analyzer                   # rust

The one rule worth remembering: **never install a language server with
`npm install -g` or `gem install`.** Those write into the directory of whichever
runtime version is active — `.../mise/installs/node/26.7.0/lib`, say — so the
server silently vanishes the next time [mise] moves you to a new Node or Ruby.
That is how `typescript-language-server` and `ruby-lsp` both went missing here
without anything appearing to break; nvim just quietly stopped attaching them.

Installing them through mise's `npm:` and `gem:` backends instead puts each one
in its own directory, independent of any runtime, which is the whole fix.
`rust-analyzer` comes from Homebrew for the same reason — it lives outside the
toolchain and survives Rust upgrades.

One server can't be handled this way. `typescript-language-server` has to load
the `typescript` package itself, and mise gives every npm tool a private
`node_modules`, so a globally installed copy is invisible to it. A project with
its own `typescript` devDependency is fine, and is still the best case — the
editor stays pinned to the compiler the project builds with. But a plain-JS
project has no such dependency, and then the server finds nothing at all and
exits with "Could not find a valid TypeScript installation". `init.lua` handles
that by pointing `ts_ls` at a mise-managed 5.x copy via the server's
`tsserver.fallbackPath` option, which is consulted only *after* the workspace
lookup, so a project's own TypeScript still wins.

### Why TypeScript 5, and when to move to 7

`typescript` 7.0 is the native Go rewrite. It dropped the `lib/tsserver.js` that
`typescript-language-server` loads, so it cannot be driven through that server at
all — hence the `@5` pin, both for the global fallback and for the smoke test
fixture.

The replacement is not a new wrapper: the native binary speaks LSP itself. As of
TypeScript 7.0.2 that works, verified by hand — `npm install typescript@7` pulls
a platform package (`@typescript/typescript-darwin-arm64` here) whose binary
answers a real `initialize` request:

    $ ./node_modules/@typescript/typescript-darwin-arm64/lib/tsc --lsp --stdio

So the move to 7 means dropping `typescript-language-server` for that binary,
not waiting on it. What blocks it here is only the bin name: nvim-lspconfig's
`tsgo` config runs `tsgo --lsp --stdio`, and `tsgo` ships in
`@typescript/native-preview`, whose newest build is still a dev snapshot
(`7.0.0-dev.20260707.2`, July 2026). Stable `typescript@7` installs the same
server as `tsc`, so switching means enabling `tsgo` with `cmd` overridden to
`{ 'tsc', '--lsp', '--stdio' }`.

Not yet evaluated: whether the native server's completion, hover, and rename are
good enough for daily use. Worth a `test/smoke.sh` case before switching over.

### Checking it still works

Because a missing server is silent, there is a smoke test:

    $ test/smoke.sh              # all languages
    $ test/smoke.sh python ruby  # just some of them

It builds a throwaway project per language in a temp directory, opens a file in
headless nvim, and checks the expected servers attach (and, where the server
reports them, that diagnostics actually arrive). It exits non-zero on failure,
naming what did not come up. Worth running after any mise upgrade.
 
For Markdown preview with [Glow] to work that needs to be installed:

    brew install glow

## Code completion

Completion is driven entirely by the language servers configured in `init.lua` —
there is no separate completion plugin (nvim-cmp, blink, etc). When an LSP that
supports completion attaches to a buffer, Neovim's built-in `vim.lsp.completion`
is enabled with autotrigger (see `custom_lsp_attach` in `init.lua`), so a popup
menu appears as you type. The keys are:

* `<C-n>` / `<C-p>`: move down / up in the completion menu
* `<C-y>` or `Enter`: accept the highlighted item
* `<C-e>`: dismiss the menu
* `<C-x><C-o>`: trigger completion manually (omni-completion)

Not every server offers completion. Python uses two servers: `ruff` for linting
and formatting, and `ty` for everything else — type-checking diagnostics plus
completion, hover (`K`), go-to-definition (`gd`), references, and rename. The
same pattern holds for the other languages: any configured LSP that advertises
completion will drive the popup automatically.

`basedpyright` used to be configured here for the navigation half, and was
dropped in August 2026 once `ty` proved to cover the same ground. Two things
motivated the switch. basedpyright only reads `[tool.basedpyright]` /
`[tool.pyright]` from a project's `pyproject.toml`, so in a repo configured for
mypy or ty it ignored that config and fell back to its strict "recommended"
defaults — flagging type errors in the editor that `mypy` or `ty check` never
reported. And running two servers that both answer completion and
go-to-definition meant duplicate popup entries and ambiguous `gd`. If ty's
completions ever feel thin, adding basedpyright back with
`typeCheckingMode = 'off'` is the fallback.

## Interacting with LSP

Once a language server has attached to a buffer, these keys (defined in
`custom_lsp_attach` in `init.lua`) let you navigate and act on the code. They
work in normal mode; `<space>` is the leader-style prefix.

Looking things up:

* `K`: **hover** — show docs, type, and signature for the symbol under the
  cursor in a floating window. Press `K` again to jump into that window so you
  can scroll it (and `q` or `<Esc>` to close it). This is the one to reach for
  most — a quick "what is this?" without leaving the file.
* `<C-k>`: **signature help** — show the current function's parameters while
  you're writing a call.

Jumping around the code:

* `gd`: go to **definition** of the symbol under the cursor
* `gD`: go to **declaration**
* `gi`: go to **implementation**
* `gr`: list **references** (everywhere the symbol is used)
* `<space>D`: go to the symbol's **type definition**

Use `<C-o>` to jump back to where you were, and `<C-i>` to jump forward again.

Changing the code:

* `<space>rn`: **rename** the symbol everywhere (safer than a find/replace)
* `<space>ca`: **code action** — apply a fix or refactor the server offers. In
  Python this is how you organize imports and let ruff clean things up.
* `<space>f`: **format** the buffer via the language server

Diagnostics (errors, warnings, hints):

* `<space>e`: show the full diagnostic message under the cursor in a float
* `[d` / `]d`: jump to the **previous** / **next** diagnostic
* `<space>q`: put all diagnostics into the location list

Workspace folders (rarely needed for single-project editing):

* `<space>wa` / `<space>wr`: add / remove a workspace folder
* `<space>wl`: list the current workspace folders

[NerdTree]: https://www.nerdfonts.com/
[Glow]: https://github.com/charmbracelet/glow
[VimPlug]: https://github.com/junegunn/vim-plug
[mise]: https://mise.jdx.dev/
