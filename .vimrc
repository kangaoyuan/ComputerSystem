" scientific network
" export hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
" export http_proxy="http://${hostip}:{proxy_port}"
" export https_proxy="http://${hostip}:{proxy_port}"

" Avoid au executed more than once.
if has('autocmd')
  au!
endif

" Try to prevent bad habits like using the arrow keys for movement. This is not the only possible bad habit. For example, holding down the h/j/k/l keys for movement, rather than using more efficient movement commands, is also a bad habit. The former is enforceable through a .vimrc, while we don't know how to prevent the latter. Do this in normal mode...
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>

set number
set relativenumber

set enc=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

source $VIMRUNTIME/ftplugin/man.vim
source $VIMRUNTIME/vimrc_example.vim

" C++ project generating tags file cmd: `ctags --fields=+iaS --extra=+q
" -R .`
" C project generating tags file cmd: `ctags --language=c --langmap=c:.c.h --fields=+S -R .`
set tags=./tags;,tags,/usr/local/etc/systags
set formatoptions+=mM
" export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu norelativenumber noma' -\""
set keywordprg=:Man
set spelllang+=cjk
"set scrolloff=1
set linebreak
set nobackup

if has('persistent_undo')
  set undofile
  " Here for vim syntax, _ is forbiden for all identifier and cotnent
  set undodir=~/.vim/undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
  endif
endif

"if has('mouse')
  "if has('gui_running') || (&term =~ 'xterm' && !has('mac'))
    "set mouse=a
  "else
    "set mouse=nvi
  "endif
"endif

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
" is that terminal window must have focus before you can scroll to
" enter normal mode
tnoremap <silent> <ScrollWheelUp> <c-w>:call EnterTerminalNormalMode()<CR>
nnoremap <silent> <ScrollWheelDown> <ScrollWheelDown>:call ExitTerminalNormalModeIfBottom()<CR>



nnoremap <esc>^[ <esc>^[
nnoremap <esc> :noh<CR>


" vim-plug
call plug#begin('~/.vim/plugged')
Plug 'yegappan/mru'
Plug 'mbbill/undotree'
Plug 'morhetz/gruvbox'
Plug 'mbbill/echofunc'
Plug 'tpope/vim-eunuch'
" leaning some useful :G git commands, such as :Gwrite, :Gread and :0Gclog, :Gblame
Plug 'tpope/vim-fugitive'
" need install fzf package with bat and ripgrep packages to perfect.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" need install ctags package
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'frazrepo/vim-rainbow'
Plug 'vim-scripts/LargeFile'
Plug 'mg979/vim-visual-multi'
Plug 'vim-airline/vim-airline'
Plug 'skywind3000/asyncrun.vim'
" can configure it options to use ctags generating tags file.
Plug 'ludovicchabant/vim-gutentags'
Plug 'uguu-org/vim-matrix-screensaver'
Plug 'nelstrom/vim-visual-star-search'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clangd-completer' }
" This plug needs .md file type to :MarkdownPreview open
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()
" manual installing undowarnnings.vim under ~/.vim/plugin folder

let g:LargeFile = 200
let g:EchoFuncAutoStarBalloonDeclaration = 0

set bg=dark
autocmd vimenter * ++nested colorscheme gruvbox


nnoremap <F1> :Matrix<CR>
inoremap <F1> <C-O>:Matrix<CR>
vnoremap <F1> :w !clip.exe<CR><CR>
nnoremap <F2> :RainbowToggle<CR>
inoremap <F2> <C-O>:RainbowToggle<CR>
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
nnoremap <F12> :MarkdownPreviewToggle<CR>
inoremap <F12> <C-O>:MarkdownPreviewToggle<CR>
" <C-i> and <Tab> are strictly equivalent.
" need install llvm or clang-format package and .clang-fromat config file
noremap <silent> <S-Tab> :pyxf /usr/share/clang/clang-format-14/clang-format.py<CR>

" Define :make acutally executing command
set makeprg=make\ -j4
" Define Make custom command to execute AsyncRun command to run make
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
nnoremap <F5>  :if g:asyncrun_status != 'running'<bar>
                 " check if the current buffer is modified
                 \if &modifiable<bar>
                   \update<bar>
                 \endif<bar>
                 \exec 'Make'<bar>
               \else<bar>
                 \AsyncStop<bar>
               \endif<CR>

if !has('gui_running')
  " nerdcommenter don't add to menu
  let g:NERDMenuMode = 0

  " terminal truecolor, for tmux wo need add below two cmds to .tmux.conf
  " set -g default-terminal \"tmux-256color"
  " set -ga terminal-overrides \",*256col*:Tc"
  " if exists('+termguicolors')
  " if has ('termguicolors') && ($COLORTERM == 'truecolor' || $COLORTERM == '24bit')
  "   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  "   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  "   set termguicolors
  " endif

  " mru need gui resolution.
  if has('wildmenu')
    set wildmenu
    set cpoptions-=<
    set wildcharm=<C-Z>
    nnoremap <F10>      :emenu <C-Z>
    inoremap <F10> <C-O>:emenu <C-Z>
  endif
endif

if has('autocmd')
  function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
  endfunction

  " choose such as 'source code pro', 'fira code', 'dejavu sans mono for
  " powerline' and so on powerline in system
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_tab_nr = 0
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#overflow_marker = '鈥?

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

  au BufRead /usr/include/*  call GnuIndent()

  au FileType c,cpp,objc  setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4 cinoptions=:0,g0,(0,w1
  au FileType json        setlocal expandtab shiftwidth=2 softtabstop=2
  au FileType vim         setlocal expandtab shiftwidth=2 softtabstop=2
  au FileType help        nnoremap <buffer> q <C-W>c

  let g:asyncrun_open = 10
endif

" automatically close the last quickfix window
aug QFClose
  au!
  au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
aug END

function! IsGitRepo()
  " This function requires pip3 install GitPython
  if has('python')
  " :PymodeLint check py code, :PymodeLintAuto fix py code
pythonx << EOF
try:
  import git
except ImportError:
  pass
import vim

def is_git_repo():
  try:
    _ = git.Repo('.', search_parent_directories=True).git_dir
    return 1
  except:
    return 0
EOF
    return pyxeval('is_git_repo()')
  else
    return 0
  endif
endfunction

"let g:pymode_rope = IsGitRepo()
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
" let g:c_gnu = 1
" let g:c_no_cformat = 1
" let g:c_space_errors = 1
" let g:c_no_curly_error = 1
" if exists('g:c_comment_strings')
"   unlet g:c_comment_strings
" endif

