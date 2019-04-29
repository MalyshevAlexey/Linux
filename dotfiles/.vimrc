call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/syntastic'
Plug 'benmills/vimux'
Plug 'tpope/vim-obsession'
"Plug 'valloric/youcompleteme'
call plug#end()

set nocompatible
syntax enable
filetype plugin on

set path+=**
set wildmenu
set encoding=utf-8
set number
set winfixwidth
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartcase
set ignorecase
set laststatus=2
set stl=%f\ Line:%l/%L\ (%p%%)\ Col:%v\ Buf:#%n\ 0x%B

colorscheme elflord
"set cursorline
""hi CursorLine term=bold cterm=bold guibg=Grey40
"set wrap
""set textwidth=79
"set colorcolumn=+1
""set formatoptions=qrn1

nnoremap <C-f> :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeQuitOnOpen = 1

function! TmuxMove(direction)
        let wnr = winnr()
        silent! execute 'wincmd ' . a:direction
        " If the winnr is still the same after we moved, it is the last pane
        if wnr == winnr()
                call system('tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR'))
        end
endfunction

nnoremap <silent> <c-h> :call TmuxMove('h')<cr>
nnoremap <silent> <c-j> :call TmuxMove('j')<cr>
nnoremap <silent> <c-k> :call TmuxMove('k')<cr>
nnoremap <silent> <c-l> :call TmuxMove('l')<cr>

