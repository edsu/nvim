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


local custom_lsp_attach = function(client)
  -- See `:help nvim_buf_set_keymap()` for more information
  vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts, {noremap = true})
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts, {noremap = true})
  --vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
  -- ... and other keymappings for LSP

  -- Use LSP as the handler for omnifunc.
  --    See `:help omnifunc` and `:help ins-completion` for more information.
  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Use LSP as the handler for formatexpr.
  --    See `:help formatexpr` for more information.
  vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  -- For plugins with an `on_attach` callback, call them here. For example:
  -- require('completion').on_attach()
end

require('lspconfig').pyright.setup {
  on_attach = custom_lsp_attach
}

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
