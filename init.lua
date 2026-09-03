-- General settings (migrated from config.vim)
vim.opt.mouse = 'n'
vim.opt.background = 'dark'
vim.opt.fileencodings = 'utf-8'
vim.opt.autoindent = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.showmode = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.infercase = true
vim.opt.textwidth = 80
vim.opt.matchpairs = { '{:}', '[:]', '(:)', '<:>', '`:`' }

-- add a border to floating windows (LSP hover, signature help, diagnostics, etc.)
vim.o.winborder = 'rounded'

-- copy to clipboard with ctrl-c in visual mode
vim.keymap.set('v', '<C-c>', '"*y')
-- toggle file tree view
vim.keymap.set('n', '<C-Space>', '<cmd>NvimTreeToggle<CR>')

-- vimwiki: only enable in my Journal since it gets in the way when editing
-- other Markdown (must be set before the plugins load below)
vim.g.vimwiki_list = { { path = '~/Dropbox/Journal/', syntax = 'markdown', ext = '.md' } }
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_url_maxsave = 0

-- May need to install https://github.com/junegunn/vim-plug for this to work
-- probably should switch to using https://github.com/wbthomason/packer.nvim
local Plug = vim.fn['plug#']
vim.call('plug#begin', vim.fn.stdpath('data') .. '/plugged')
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('vim-pandoc/vim-pandoc')
Plug('vim-pandoc/vim-pandoc-syntax')
Plug('preservim/vim-pencil')
Plug('neovim/nvim-lspconfig')
Plug('nvim-tree/nvim-web-devicons')
Plug('nvim-tree/nvim-tree.lua')
Plug('pangloss/vim-javascript')
Plug('junegunn/goyo.vim')
Plug('catppuccin/nvim', {as = 'catppuccin'})
Plug('akinsho/bufferline.nvim')
Plug('chrisbra/unicode.vim')
Plug('rinx/nvim-ripgrep')
Plug('f-person/git-blame.nvim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('ellisonleao/glow.nvim')
Plug('vimwiki/vimwiki')
Plug('L3MON4D3/LuaSnip')
Plug('hashivim/vim-terraform')
Plug('lewis6991/gitsigns.nvim')
vim.call('plug#end')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_lsp_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Native auto-popup completion (Neovim 0.11+) for servers that support it
  if client:supports_method('textDocument/completion') then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  end

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- See: https://github.com/neovim/nvim-lspconfig/tree/52eb2a070a4f389b1be0f98070f81d23e2b1a715#suggested-configuration
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)
end

-- ruby-lsp (Shopify) provides completion / hover / go-to-def / diagnostics
vim.lsp.config('ruby_lsp', {
  on_attach = custom_lsp_attach,
})
vim.lsp.enable('ruby_lsp')

vim.lsp.config('ruff', {
  on_attach = custom_lsp_attach,
  settings = {
  }
})
vim.lsp.enable('ruff')

-- ty (Astral) covers everything else for Python: type-checking diagnostics plus
-- completion, hover, go-to-def, references, rename, and signature help.
--
-- basedpyright used to sit here for the navigation half, but ty provides all of
-- it, and running both meant duplicate completion entries and ambiguous `gd`.
-- basedpyright was also the source of type errors that `ty check` never
-- reported: it only reads [tool.basedpyright] / [tool.pyright] from
-- pyproject.toml, so in a repo configured for mypy or ty it ignored that config
-- and fell back to its strict "recommended" defaults.
vim.lsp.config('ty', {
  on_attach = custom_lsp_attach,
})
vim.lsp.enable('ty')

-- typescript-language-server ships no TypeScript of its own: it needs a
-- `typescript` package to run tsserver.js, and looks for one in the workspace.
-- Plain-JS projects have none, and because mise installs every npm package in
-- its own isolated tree the server has no bundled copy to fall back on either,
-- so it exits with "Could not find a valid TypeScript installation".
--
-- `fallbackPath` is consulted *after* the workspace, so a project that does
-- depend on typescript still gets its own pinned version. (`tsserver.path`
-- would take priority over the workspace and is the wrong knob here.)
--
-- Pinned to the 5.x line on purpose: TypeScript 7 is the native Go rewrite and
-- dropped tsserver.js entirely, so this server cannot drive it at any version.
-- TS 7 speaks LSP itself instead; see README.md for that migration path.
local ts_init_options = {}
local global_tsserver = vim.fn.expand(
  '~/.local/share/mise/installs/npm-typescript/5/node_modules/typescript/lib/tsserver.js'
)
if vim.uv.fs_stat(global_tsserver) then
  ts_init_options.tsserver = { fallbackPath = global_tsserver }
end

vim.lsp.config('ts_ls', {
  on_attach = custom_lsp_attach,
  init_options = ts_init_options,
})
vim.lsp.enable('ts_ls')

vim.lsp.config('rust_analyzer', {
  on_attach = custom_lsp_attach,
  settings = {
    ["rust-analyzer"] = {
        check = {
            command = "clippy"
        },
        cargo = {
            buildScripts = {
                enable = true
            }
        }
    }
  }
})
vim.lsp.enable('rust_analyzer')

require('nvim-tree').setup {
  open_on_tab = true,
  renderer = {
    highlight_git = true,
    highlight_opened_files = "all",
    root_folder_label = false
  },
  view = {
    width = 30
  }
}
 
require('bufferline').setup {
  options = {
    numbers = "buffer_id",
    offsets = {{
      filetype = "NvimTree",
      text = "files",
      highlight = "Directory",
      text_align = "left"
    }}
  }
}

require('nvim-ripgrep').setup {}

require('telescope').setup {}

require('gitsigns').setup {}

vim.g['airline_theme'] = 'dark'
vim.g['airline_powerline_fonts'] = 1
vim.g['pandoc#modules#disabled'] = {'folding'}
vim.g['mkdp_auto_start'] = 0
vim.g['gitblame_enabled'] = 0

vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<CR>", {noremap = true})

-- \1 to go to tab 1, etc
vim.api.nvim_set_keymap('n', '<leader>1', "<cmd>b1<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>2', "<cmd>b2<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>3', "<cmd>b3<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>4', "<cmd>b4<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>5', "<cmd>b5<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>6', "<cmd>b6<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>7', "<cmd>b7<CR>", {noremap = true})


vim.cmd('colorscheme catppuccin')

require('glow').setup {}
vim.g.glow_border = "double"

vim.filetype.add({
  extension = {
    md = 'markdown.pandoc'
  }
})

vim.diagnostic.config(
  {
    underline = true,
    virtual_text = true,
    update_in_insert = true,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ", 
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = " ",
        [vim.diagnostic.severity.INFO] = " ",
      },
    },
  }
)

-- put yanked text on the clipboard for pasting
vim.opt.clipboard = 'unnamedplus'

