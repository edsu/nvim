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

" Copy to clipboard with ctrl-c when in visual mode
vnoremap <C-c> "*y

" Toggle File Tree View
nnoremap <C-space> :NvimTreeToggle<CR>

autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

" Only enable vimwiki in my Journal since it gets in the way when editing other Markdown
let g:vimwiki_list = [{ 'path': '~/Dropbox/Journal/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 0
let g:vimwiki_url_maxsave=0

" put yanked text on the clipboard for pasting
set clipboard+=unnamedplus
