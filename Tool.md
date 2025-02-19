# Tool

[toc]

## Shortcut

### Windows

#### Win 功能键

1. **alt + [shift] + tab** 切换已经打开的应用窗口
2. **ctrl + shift + esc** 打开任务管理器
3. **ctrl + alt + delete** 打开安全选项（含任务管理器）
4. **ctrl + n** 新开当前应用窗口
5. **ctrl + shift + n** 新建目录夹
6. **ctrl + h** 打开文本替换对话框

#### Win 快捷键

1. **window+ r** 运行功能
2. **window + s** 搜索功能
3. **window + i** 打开设置
4. **window + p** 打开投影
5. **window + shift + s** 截屏
6. **window + l** 快速锁定电脑
7. **window + e** 打开资源管理器
8. **window + d** 最小化所有应用窗口
9. **win + tab** 列出所有打开的应用窗口
10. **window + x + u + u/r** 快速关机、重启

### Linux

#### Terminal 功能键 

- shift + ctrl + c 

  复制  

- shift + ctrl + v 

  粘贴  

- ctrl + shift + t 

  新建一个 Tab Terminal

- ctrl + shift + w 

  关闭一个 Tab Terminal

- ctrl + p 

  history 历史命令向上查找

- ctrl + n 

  history 历史命令向下查找

- ctrl + c 

  发出 2 号 SIGINT 信号给前台进程组，中断进程  

- ctrl + \

  发出 3 号 SIGQUIT 信号给前台进程组，进程退出

- ctrl + z 

  发出 20 号 SIGTSTP 信号给前台进程组，暂停进程  

- ctrl + r

  输入关键字搜索 history 历史命令，键入 ctrl + r 继续搜索，键入 arrow->right 获得该命令

#### Terminal 快捷键 

- ctrl + l

  向下翻页清屏  

- ctrl + h

  输出 Backspace 到命令行中。

- ctrl + i

  输出 Tab 到命令行中。

- ctrl + j

  输出 Line Feed 到命令行中 == Enter or Return。

- Tab

  补全已经敲了一部分的文件名和目录名，还可以补全命令的某些参数、Makefile 目标等。

  > **自动补全**同时兼具了**检查拼写错误**的功能，如果前几个字母拼写错了，键入 TAB 就会补全失败，提醒用户拼写错误。

- ctrl + d 

  \$ 空时退出当前 Shell

- ctrl + d

  delete cursor 后一个字符  

  > 输入流或者空命令行下，Ctrl + d == EOF，当 shell 接收到这个 marker，会终止整个 terminal session 终端会话。

- ctrl + h

  backspace cursor 前一个字符  

- alt + d

  delete cursor 后一个单词  

- ctrl + w 

  backspace cursor 前一个单词

- ctrl + k 

  delete cursor 后所有字符 

- ctrl + u 

  backspace cursor 前所有字符 

- ctrl + b

  cursor 向左移动一个字符

- ctrl + f 

  cursor 向右移动一个字符  

- alt + b

  cursor 向左移动一个单词，至首字符

- alt + f

  cursor 向右移动一个单词，至尾字符

- ctrl + a 

  cursor 向左移动到首字符

- ctrl + e 
  cursor 向右移动到末尾字符  

> bash 的快捷键和 emacs 保持一致：尽量使用主键盘快捷键而不使用移动光标键和编辑键。因为手不必离开主键盘是效率最高的。
>
> | 快捷键 |   功能    |       助记       |
> | :----: | :-------: | :--------------: |
> | ctrl-p |    UP     |     previous     |
> | ctrl-n |   Down    |       next       |
> | ctrl-b |   Left    |     backward     |
> | ctrl-f |   Right   |     forward      |
> | ctrl-d |  Delete   |      delete      |
> | ctrl-h | Backspace |                  |
> | ctrl-i |    Tab    |                  |
> | ctrl-j |   Enter   |       jump       |
> | ctrl-a |   Home    | the first letter |
> | ctrl-e |    End    |       end        |

## WSL

### ZSH

1. 使用包管理器，如：apt，pacman，brew，安装 zsh

2. 设置 zsh 为默认 shell，`sudo chsh -s $(which zsh)`，重启 terminal 观察变化。

3. 由于安装 zsh 后，我们需要使用 oh-my-zsh 工具管理插件和主题，所以首次重启 terminal 进入 zsh 后，无需设置 .zshrc 内容。

4. 安装 oh-my-zsh，及其插件

   ```bash
   $sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

   ```bash
   $ git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
   
   $ git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   
   $git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   
   $git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
   
   $git clone --depth=1 https://github.com/junegunn/fzf.vim.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf
   ```

5. 在 .zshrc 中，设置 plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-syntax-substring-search fzf) 插件后，`source ~/.zshrc`。

   > 为了 powerlevel10k 主题效果，需要更换 Terminal 终端设置中 powerline font，例如：fira code, source code pro, JetBrains Nerd Font. `$ p10k configure` 可以体验和更换字体和主题。

   在 [Font 下载](https://github.com/ryanoasis/nerd-fonts/releases) 界面下，选择具体 font 字体的 zip 压缩包，解压缩到 C 盘 Windows/Fonts/ 后，到 Terminal 中设置字体。进入zshrc 中，设置 ZSH_THEME="powerlevel10k/powerlevel10k" 主题后，`source ~/.zshrc`。

### vim

#### plug manager

[vim-plug](https://github.com/junegunn/vim-plug) Github repo 中，记录了该插件管理器的下载和使用方法。下面是简介：

```bash
# install vim-pulg
$ curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

vim-plug 的使用，除了在 .vimrc 配置文件中添加 `call plug#begin()` 和 `call plug#end()` 两条语句和其中的插件，不需要任何其他语句。

保存退出 .vimrc 配置文件后，再启动 vim 便可重新加载各 Plug，也可以直接在 vim 中键入 `:source .vimrc` 实现不退出 Vim 加载配置文件的效果。

打开 .vimrc 配置文件后，删除需要移除 Plug 所对应的那一行内容，保存退出 .vimrc 配置文件，再启动，或者在 vim 中键入 `:source .vimrc` 命令。再键入 `:PlugClean` 命令完成清理。

> `PlugInstall`、`:PlugUpdate`、`:PlugUpgrade` 命令分别对 .vimrc 配置文件中指定的 plug 插件和 vim-plug 本身进行安装和更新。 

#### own configuration  

  ```bash
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
  ```

> YouCompleteMe maybe need some dev lib to support, such as `sudo apt install python3-dev`，when you encounter some errors.

`~/.vim/plugged/YouCompleteMe` 下 `git submodule update --init --recursive`，`python3 install.py --clangd-completer` 