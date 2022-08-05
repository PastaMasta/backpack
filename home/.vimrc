"" .vimrc

""" Local version if it's there
if filereadable(expand("~/.vimrc_local"))
  source ~/.vimrc_local
endif

"------------------------------------------------------------------------------+
" Basic config
"------------------------------------------------------------------------------+

""" Visual changes
syntax on
set background=dark
set belloff=all
set encoding=UTF-8
set cursorcolumn

" Highlight all search hits
set hlsearch

" Number highlighting
set number
highlight LineNr ctermfg=0 ctermbg=blue

""" Inputs
set shiftwidth=2
set expandtab
set mouse=a
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»

" Gotta go fast
set updatetime=100

""" Folding
set foldmethod=syntax
set foldlevel=1

""" Catch trailing whitespace:
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

"------------------------------------------------------------------------------+
" Plugins
"------------------------------------------------------------------------------+

""" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"--------------------------------------+
" vim-plug plugins:
"--------------------------------------+
call plug#begin('~/.vim/plugged')

""" airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'airblade/vim-gitgutter'
Plug 'dense-analysis/ale'

""" NERDTree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'ryanoasis/vim-devicons' " load last TODO: install fonts?

""" Other syntaxies
Plug 'jvirtanen/vim-hcl'

call plug#end()

"------------------------------------------------------------------------------+
" Plugin-specific config
"------------------------------------------------------------------------------+

"--------------------------------------+
" NERDTree config
"--------------------------------------+
""" Start NERDTree. If a file is specified, move the cursor to its window.
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

""" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"--------------------------------------+
" Airline config
"--------------------------------------+
let g:airline_theme='molokai'

"------------------------------------------------------------------------------+
" Functions etc
"------------------------------------------------------------------------------+

"--------------------------------------+
" Tab completion
" TODO: Update this: so tab cycle choices
"--------------------------------------+
function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
                                                  " line to one character right
                                                  " of the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash = match(substr, '\/') != -1       " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction
inoremap <tab> <c-r>=Smart_TabComplete()<CR>

"--------------------------------------+
" Create new scripts with template files if a skeleton with the same extension exists
" Also chmod +x the file if not already +x'ed
"--------------------------------------+
if has("autocmd")
  augroup templates
    au!
    autocmd BufNewFile *.* silent! execute '0r ~/.vim/templates/skeleton.'.expand("<afile>:e")
    autocmd BufWritePost *.sh,*.py,*.rb
    \  if getfperm(expand('%')) !~# 'x'
    \|   silent execute "! chmod +x %" | w
    \| endif
  augroup END
endif

"--------------------------------------+
" Search for selected text
" https://vim.fandom.com/wiki/Search_for_visually_selected_text
"--------------------------------------+
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
