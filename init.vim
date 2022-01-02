syntax on

set mouse=n
set background=dark
set fileencodings=utf-8
set encoding=utf8
set t_kb=
set autoindent
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set smartcase
set showmatch
set showmode
set incsearch
set hlsearch
set ignorecase
set infercase
set tw=80
set matchpairs={:},[:],(:),<:>,`:`
set t_Co=256

filetype on
filetype plugin on
filetype indent on

let g:airline_theme='dark'
let g:airline_powerline_fonts = 1
let g:pandoc#modules#disabled = ["folding"]
let g:nvim_tree_git_hl = 1
let g:nvim_tree_highlight_opened_files = 1
let g:mkdp_auto_start = 1

call plug#begin(stdpath('data') . '/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'preservim/vim-pencil'
Plug 'neovim/nvim-lspconfig'
Plug 'microsoft/pyright'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'pangloss/vim-javascript'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
call plug#end()

augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

lua << EOF

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

  require'lspconfig'.pyright.setup{
    on_attach = custom_lsp_attach
  }

  require'lspconfig'.solargraph.setup {
    on_attach = custom_lsp_attach
  }

  require'lspconfig'.tsserver.setup{
    on_attach = custom_lsp_attach
  }

  require'nvim-tree'.setup {
    view = {
      width = 30,
      open_on_tab = true,
      hide_root_folder = true,
    }
  }

EOF
