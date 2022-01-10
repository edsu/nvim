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

" \1 to go to tab 1, etc
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt

" Tab navigation like Firefox.
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Toggle File Tree View
nnoremap <C-space> :NvimTreeToggle<CR>

augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

autocmd FileType ruby setlocal omnifunc=LanguageClient#complete
