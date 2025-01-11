" scientific network for WSL2
" export hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
" export http_proxy="http://${hostip}:{proxy_port}"
" export https_proxy="http://${hostip}:{proxy_port}"

" Avoid au executed more than once.
if has('autocmd')
  " au is a feature that trigger actions when certain events happen.
  au!
endif

" 'Q' in normal mode enters Ex mode, almost never want this.
" As for me, sometimes will touch the Q(shift+q) by mistake.
nmap Q <Nop>

" Try to prevent bad habits like using the arrow keys for movement. This is not the only possible bad habit. For example, holding down the h/j/k/l keys for movement, rather than using more efficient movement commands, is also a bad habit. The former is enforceable through a .vimrc, while we don't know how to prevent the latter. Do this in normal mode... But it still can't stop to hold down the h/j/k/l, whoop~
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>

if has('gui_running')
  set guifont=FiraCode\ Nerd\ Font\ 16
  set guifontwide=Noto\ Sans\ Mono\ CJK\ SC\ 17

  let do_syntax_sel_menu = 1
  let do_no_lazyload_menu = 1
endif

set number
set relativenumber

set enc=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

" Attention here, we do some work by default and the sequence is stil  important
source $VIMRUNTIME/ftplugin/man.vim
source $VIMRUNTIME/vimrc_example.vim

" Universal ctags need be installed by linux.
" C++ project generating tags file cmd: `ctags --fields=+iaS --extra=+q -R .`
" C project generating tags file cmd: `ctags --language=c --langmap=c:.c.h --fields=+S -R .`
set tags=./tags;,tags,/usr/local/etc/systags

" export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu norelativenumber noma' -\""
set spelllang+=cjk
set keywordprg=:Man
set formatoptions+=mM

" reserve offset not to scroll
set scrolloff=3
set linebreak

" stop the highlight to search 
nnoremap <esc>^[ <esc>^[
nnoremap <esc> :noh<CR>

set nobackup
if has('persistent_undo')
  set undofile
  " Here for vim syntax, _ is forbiden for all identifier and cotnent
  set undodir=~/.vim/undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
  endif
endif

" Not like arrow key, the mouse maybe useful in many scenario.
set mouse=a

let s:term_pos = {} " { bufnr: [winheight, n visible lines] }
function! EnterTerminalNormalMode()
    if &buftype != 'terminal' || mode('') != 't'
        return 0
    endif
    setlocal nonumber norelativenumber
    call feedkeys("\<LeftMouse>\<c-w>N", "x")
    let s:term_pos[bufnr()] = [winheight(winnr()), line('$') - line('w0')]
    call feedkeys("\<ScrollWheelUp>")
endfunction

function! ExitTerminalNormalModeIfBottom()
    if &buftype != 'terminal' || !(mode('') == 'n' || mode('') == 'v')
        return 0
    endif
    let term_pos = s:term_pos[bufnr()]
    let vis_lines = line('$') - line('w0')
    let vis_empty = winheight(winnr()) - vis_lines
    " if size has only expanded, match visible lines on entry
    if term_pos[1] <= winheight(winnr())
        let req_vis = min([winheight(winnr()), term_pos[1]])
        if vis_lines <= req_vis | call feedkeys("i", "x") | endif
    " if size has shrunk, match visible empty lines on entry
    else
        let req_vis_empty = term_pos[0] - term_pos[1]
        let req_vis_empty = min([winheight(winnr()), req_vis_empty])
        if vis_empty >= req_vis_empty | call feedkeys("i", "x") | endif
    endif
endfunction

" scrolling up enters normal mode in terminal window, scrolling back to
" the cursor's location upon entry resumes terminal mode. only limitation
" is that terminal window must be focused before you can scroll to
" enter normal mode
tnoremap <silent> <ScrollWheelUp> <c-w>:call EnterTerminalNormalMode()<CR>
nnoremap <silent> <ScrollWheelDown> <ScrollWheelDown>:call ExitTerminalNormalModeIfBottom()<CR>


" vim-plug
call plug#begin('~/.vim/plugged')
" Cool
Plug 'uguu-org/vim-matrix-screensaver' " F1
" Recent files
Plug 'yegappan/mru' " F2
" Using vim-eunuch commands can keep the undo records.
Plug 'mbbill/undotree' " F6
" NERDTree to show the working directory
Plug 'preservim/nerdtree' " F7
" need install fzf package with bat and ripgrep packages to perfect.
" combining with bat and ripgrep tools, we can set FZF_DEFAULT_COMMAND='rg
" --files --sortr modified'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim' " F8
" need install ctags package to show the identifiers through current buffer.
Plug 'majutsushi/tagbar' " F9

Plug 'morhetz/gruvbox'
Plug 'mbbill/echofunc'
" Implement shell feature mapping to vim, such as :Delete, :Move.
Plug 'tpope/vim-eunuch'
" leaning some useful :G git commands, such as :Gwrite, :Gread, :Gvdiff and :0Gclog, :Gblame.
Plug 'tpope/vim-fugitive'
" <Leader>hu undo stage, <Leader>hs stage, <Leader>hp play difference
Plug 'airblade/vim-gitgutter'
" <Leader>cc to comment, <Leader>cu to undo, <Leader>cs to comment multi
" lines.
Plug 'preservim/nerdcommenter'
Plug 'frazrepo/vim-rainbow'
Plug 'vim-scripts/LargeFile'
" <C-N> to search words to select or not using n or q
Plug 'mg979/vim-visual-multi'
Plug 'vim-airline/vim-airline'
Plug 'skywind3000/asyncrun.vim'
" can configure its options to use ctags generating tags file.
Plug 'ludovicchabant/vim-gutentags'
Plug 'nelstrom/vim-visual-star-search'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" I strongly recommend we configure the compile_commands.json to project
" working directory
" From Make, we can utilize the bear or compiledb tools.
" From CMake, we can utilize the option -DCMAKE_EXPORT_COMPILE_COMMANDS=1.
" A tiny thing we should notice is the possible bug from the mutil-threads, a
" digression.
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clangd-completer' }
" This plug needs .md file type to :MarkdownPreview open
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()
" manual installing undowarnnings.vim under ~/.vim/plugin folder

let g:LargeFile = 200
let g:EchoFuncAutoStarBalloonDeclaration = 0

" configure gruvbox theme
set bg=dark
autocmd vimenter * ++nested colorscheme gruvbox


nnoremap <F1> :Matrix<CR>
inoremap <F1> <C-O>:Matrix<CR>
" For WSL 
" vnoremap <F1> :w !clip.exe<CR><CR>
" For Linux 
vnoremap <F1> :w !xclip -selection clipboard<CR><CR>
nnoremap <F2> :MRUToggle<CR>
inoremap <F2> <C-O>:MRUToggle<CR>
nnoremap <F3> :YcmDiags<CR>
inoremap <F3> <C-O>:YcmDiags<CR>
nnoremap <F4> :cclose<CR>
nnoremap <F6> :UndotreeToggle<CR>
inoremap <F6> <C-O>:UndotreeToggle<CR>
" In NERDTree window, typing I to toggele hideen files.
nnoremap <F7> :NERDTreeToggle<CR>
inoremap <F7> <C-O>:NERDTreeToggle<CR>
nnoremap <F8> :Files<CR>
inoremap <F8> <C-O>:Files<CR>
nnoremap <F9> :TagbarToggle<CR>
inoremap <F9> <C-O>:TagbarToggle<CR>
nnoremap <F10> :RainbowToggle<CR>
inoremap <F10> <C-O>:RainbowToggle<CR>
nnoremap <F12> :MarkdownPreviewToggle<CR>
inoremap <F12> <C-O>:MarkdownPreviewToggle<CR>
" <C-i> and <Tab> are strictly equivalent.
" need install llvm or clang-format package and .clang-fromat config file
noremap <silent> <S-Tab> :pyxf /usr/share/clang/clang-format.py<CR>


if !has('gui_running')
  " nerdcommenter don't add to menu
  let g:NERDMenuMode = 0

  " terminal truecolor, for tmux we need add below two cmds to .tmux.conf
  " set -g default-terminal \"tmux-256color"
  " set -ga terminal-overrides \",*256col*:Tc"
  " if exists('+termguicolors')
  " if has ('termguicolors') && ($COLORTERM == 'truecolor' || $COLORTERM == '24bit')
  "   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  "   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  "   set termguicolors
  " endif

endif

if has('autocmd')
  function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
  endfunction

  let g:asyncrun_open = 10

  " choose such as 'source code pro', 'fira code', 'dejavu sans mono for
  " powerline' and so on powerline in system
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_tab_nr = 0
  let g:airline#extensions#tabline#buffer_nr_show = 1
  " Here we use ellipsis, a single character that represent three dots.
  " For linux, enter insert mode and then press `<C-V> + u2026`, or 
  " `<C-K> + ,.`
  " For windows, enter win+r to search charmap and then select a font to
  " search, click and copy
  " We can use ga to see the ellipsis inner code
  let g:airline#extensions#tabline#overflow_marker = '…'

  " ycm setting
  let g:ycm_use_clangd = 1
  let g:ycm_auto_hover = ''
  let g:ycm_complete_in_comments = 1
  let g:ycm_autoclose_preview_window_after_insertion = 1
  let g:ycm_filetype_whitelist = {
        \ 'c': 1,
        \ 'cpp': 1,
        \ 'java': 1,
        \ 'python': 1,
        \ 'vim': 1,
        \ 'sh': 1,
        \ 'zsh': 1,
        \ }
  let g:ycm_key_invoke_completion = '<C-Z>'
  let g:ycm_goto_buffer_command = 'edit'
  nnoremap <Leader>gt :YcmCompleter GoTo<CR>
  nnoremap <Leader>fi :YcmCompleter FixIt<CR>
  nnoremap <Leader>gd :YcmCompleter GoToDefinition<CR>
  nnoremap <Leader>gr :YcmCompleter GoToReferences<CR>
  nnoremap <Leader>gh :YcmCompleter GoToDeclaration<CR>


  au FileType c,cpp,objc  setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4 cinoptions=:0,g0,(0,w1
  au FileType json        setlocal expandtab shiftwidth=2 softtabstop=2
  au FileType vim         setlocal expandtab shiftwidth=2 softtabstop=2
  au FileType help,man    nnoremap <buffer> q <C-W>c

  au BufRead /usr/include/*  call GnuIndent()

endif

" automatically close the last quickfix window
aug QFClose
  au!
  au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
aug END


let g:pymode_rope_completion = 1
let g:pymode_reope_complete_on_dot = 0
let g:pymode_syntax_string_format = 0
let g:pymode_syntax_string_templates = 0
let g:pymode_syntax_print_as_function = 1
" some case can boost the startup time contrast to IsGitRepo function.
let g:pymode_rope = !empty(finddir('.git', '.;'))

" Adding below commands to filetype detect config file ~/.vim/filetype.vim
" if exists("did_load_filetypes")
"   finish
" endif
"
" function! s:CheckCPP()
"   if expand('%:t') !~ '\.'
"     setfiletype cpp
"   endif
" endfunction
"
" augroup filetypedetect
"   au! BufRead, BufNewFile *.asm setfiletype masm
"   au! BufRead proxy.pac setfiletype javascript
"   au! BufRead */c++/* call s:CheckCPP()
"   au! BufRead */icnlude/* call s:CheckCPP()
" augroup END

" setting below options to c syntax highlight config file ~/.vim/syntax/c.vim
" and  ~/.vim/syntax/cpp.vim to do syntax highlight fine tuning, which will be
" loaded before the system syntax/c.vim amd syntax/cpp.vim
" let g:c_gnu = 1
" let g:c_no_cformat = 1
" let g:c_space_errors = 1
" let g:c_no_curly_error = 1
" if exists('g:c_comment_strings')
"   unlet g:c_comment_strings
" endif

