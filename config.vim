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

augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

let g:vimwiki_list = [{ 'path': '~/Dropbox/Journal/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_url_maxsave=0

set clipboard+=unnamedplus
