# nvim

This is my [neovim](https://neovim.io/) setup that I started experimenting with in December 2021 after many years of using vim proper.

First install [vim-plug]. The clone this repo into `~/.config/nvim`. It has some minor language specific configuration (indents, etc) and also sets up some plugins that I like to use like:

* [vim-airline](https://github.com/vim-airline/vim-airline): a visually pleasing & informative status bar
* [vim-pencil](https://github.com/preservim/vim-pencil): some nice defaults for writing prose instead of code
* [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc): edit markdown, especially for pandoc
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig): language server support for python, ruby, javascript, etc
* [nvim-tree](https://github.com/kyazdani42/nvim-tree.lua): a file explorer
* [goyo](https://github.com/junegunn/goyo.vim): distraction free writing
* [glow.nvim](https://github.com/ellisonleao/glow.nvim): viewing markdown in editor
* [nvim-telescope](https://github.com/nvim-telescope/telescope.nvim): use ripgrep to search files quickly

For powerline and nvim-tree to display properly a [NerdTree] font is needed. I use `Hack Nerd Font Mono`. After you download the ZIP, unzip it and use Font Book to install the .ttf files.

For language support from [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md):

    $ curl -LsSf https://astral.sh/uv/install.sh | sh
    $ uv tool install ruff ty
    $ pipx install basedpyright
    $ npm install -g typescript-language-server typescript
    $ brew install rust-analyzer
    $ gem install ruby-lsp
 
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

Not every server offers completion. For Python, `ruff` only does linting and
formatting, so `basedpyright` is enabled alongside it to provide completion,
hover (`K`), go-to-definition (`gd`), and type-checking. The same pattern holds
for the other languages: any configured LSP that advertises completion will
drive the popup automatically.

Coding shortcuts:

To organize imports in Python `<space> ca` will call ruff and format things.
   
[NerdTree]: https://www.nerdfonts.com/
[Glow]: https://github.com/charmbracelet/glow
[VimPlug]: https://github.com/junegunn/vim-plug
