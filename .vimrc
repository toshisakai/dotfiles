"         □                   
"         □  □       □        
"   □  □     □□□ □   □□    □□□
"   □  □  □  □□□□ □  □□□  □   
"    □□□  □  □ □□ □  □    □   
"    □□   □  □  □ □  □    □   
"    □□   □  □  □ □  □    □□□□



" 基本設定
" ------- ------- ------- ------- ------- ------- -------
set nocompatible
set autoread
set ambiwidth=double
set backspace=indent,eol,start
set backspace=2
set nostartofline
set hidden
set nobackup
set noswapfile
set incsearch
set ignorecase
set smartcase
set wrapscan
set expandtab
set clipboard=unnamed,autoselect
set smarttab
set autoindent
set nosmartindent

set title
set ruler
set number
set showmatch
set matchtime=1
set display=lastline
set pumheight=10
set cursorline
set list listchars=tab:»-,trail:-,eol:¬,extends:»,precedes:«,nbsp:%
set hlsearch

" 基本のインデント等設定
set tabstop=2 softtabstop=0 shiftwidth=2

" dain Scripts
" ------- ------- ------- ------- ------- ------- -------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/tsakai/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/tsakai/.cache/dein')
    call dein#begin('/Users/tsakai/.cache/dein')

    " Let dein manage dein
    " Required:
    call dein#add('/Users/tsakai/.cache/dein/repos/github.com/Shougo/dein.vim')

    " Add or remove your plugins here like this:
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('davidhalter/jedi-vim')
    call dein#add('tpope/vim-fugitive')
    call dein#add('ctrlpvim/ctrlp.vim')
    call dein#add('scrooloose/nerdtree')
    call dein#add('scrooloose/syntastic')
    call dein#add('jistr/vim-nerdtree-tabs')
    call dein#add('pasela/edark.vim')
    call dein#add('itchyny/lightline.vim')
    call dein#add('aereal/vim-colors-japanesque')

    " Required:
    call dein#end()
    call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" Colorscheme
" ------- ------- ------- ------- ------- ------- -------
colorscheme japanesque

" lightline
" ------- ------- ------- ------- ------- ------- -------
set laststatus=2
let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'LightLineModified',
        \   'readonly': 'LightLineReadonly',
        \   'fugitive': 'LightLineFugitive',
        \   'filename': 'LightLineFilename',
        \   'fileformat': 'LightLineFileformat',
        \   'filetype': 'LightLineFiletype',
        \   'fileencoding': 'LightLineFileencoding',
        \   'mode': 'LightLineMode'
        \ }
        \ }

" function
function! LightLineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      return fugitive#head()
    endif
  catch
  endtry
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

" Keybind
" ------- ------- ------- ------- ------- ------- -------
nnoremap Y y$
nmap <silent> <Esc><Esc> :nohlsearch<CR>
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Indent and tabstop
" ------- ------- ------- ------- ------- ------- -------
syntax on
autocmd FileType php setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType php setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120
autocmd FileType coffee,javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=120
autocmd FileType html,htmldjango,xhtml,haml setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=0
autocmd FileType sass,scss,css setlocal tabstop=2 shiftwidth=2 softtabstop=2 textwidth=120

" python
" ------- ------- ------- ------- ------- ------- -------
if isdirectory("~/.pyenv/shims:")
    let $PATH = "~/.pyenv/shims:".$PATH
    let g:syntastic_python_checkers = ["flake8"]
    autocmd BufWritePost *.py call Flake8()
endif