-- these are some things that haven't been ported over from vimscript yet
vim.cmd 'source ~/.config/nvim/config.vim'

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
Plug('microsoft/pyright')
Plug('nvim-tree/nvim-web-devicons')
Plug('nvim-tree/nvim-tree.lua')
Plug('pangloss/vim-javascript')
Plug('folke/trouble.nvim')
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
vim.call('plug#end')

-- See: https://github.com/neovim/nvim-lspconfig/tree/52eb2a070a4f389b1be0f98070f81d23e2b1a715#suggested-configuration
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local custom_lsp_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
end

require('lspconfig').solargraph.setup {
  on_attach = custom_lsp_attach
}

require('lspconfig').tsserver.setup {
  on_attach = custom_lsp_attach
}

require('lspconfig').rust_analyzer.setup {
  on_attach = custom_lsp_attach
}

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
 
require('trouble').setup {}

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

vim.g['airline_theme'] = 'dark'
vim.g['airline_powerline_fonts'] = 1
vim.g['pandoc#modules#disabled'] = {'folding'}
vim.g['mkdp_auto_start'] = 0
vim.g['gitblame_enabled'] = 0

vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<CR>", {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<CR>", {noremap = true})

vim.cmd('colorscheme catppuccin')

vim.g.glow_border = "double"

-- Configure `ruff-lsp`.
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
-- For the default config, along with instructions on how to customize the settings
require('lspconfig').ruff_lsp.setup {
  on_attach = custom_lsp_attach,
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}


