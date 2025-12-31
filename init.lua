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
vim.call('plug#end')

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

  -- See: https://github.com/neovim/nvim-lspconfig/tree/52eb2a070a4f389b1be0f98070f81d23e2b1a715#suggested-configuration
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)
end

vim.lsp.config('solargraph', {
  on_attach = custom_lsp_attach,
  settings = {
  }
})
vim.lsp.enable('solargraph')

vim.lsp.config('ruff', {
  on_attach = custom_lsp_attach,
  settings = {
  }
})
vim.lsp.enable('ruff')

vim.lsp.config('ts_ls', {
  on_attach = custom_lsp_attach,
  settings = {
  }
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

