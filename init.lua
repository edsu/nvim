-- these are some things that haven't been ported over from vimscript yet
vim.cmd 'source ~/.config/nvim/config.vim'

local Plug = vim.fn['plug#']
vim.call('plug#begin', vim.fn.stdpath('data') .. '/plugged')
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('vim-pandoc/vim-pandoc')
Plug('vim-pandoc/vim-pandoc-syntax')
Plug('preservim/vim-pencil')
Plug('neovim/nvim-lspconfig')
Plug('microsoft/pyright')
Plug('kyazdani42/nvim-web-devicons')
Plug('kyazdani42/nvim-tree.lua')
Plug('pangloss/vim-javascript')
Plug('folke/trouble.nvim')
Plug('junegunn/goyo.vim')
Plug('iamcco/markdown-preview.nvim', {['do'] = 'cd app && yarn install'})
Plug('catppuccin/nvim', {as = 'catppuccin'})
Plug('akinsho/bufferline.nvim')
Plug('chrisbra/unicode.vim')
vim.call('plug#end')

vim.g['airline_theme'] = 'dark'
vim.g['airline_powerline_fonts'] = 1
vim.g['pandoc#modules#disabled'] = {'folding'}
vim.g['nvim_tree_git_hl'] = 1
vim.g['nvim_tree_highlight_opened_files'] = 1
vim.g['mkdp_auto_start'] = 0

vim.cmd('colorscheme catppuccin')

local custom_lsp_attach = function(client)
  -- See `:help nvim_buf_set_keymap()` for more information
  vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
  vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
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

require('lspconfig').tsserver.setup{
  on_attach = custom_lsp_attach
}

require('nvim-tree').setup {
  view = {
    width = 30,
    open_on_tab = true,
    hide_root_folder = true,
  }
}

require('trouble').setup {}

--- require('markdownpreview').setup {}

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

