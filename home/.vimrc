"" .vimrc

set background=dark
set shiftwidth=2
set expandtab
set mouse=a
set belloff=all
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
set updatetime=100
set hlsearch

""" Folding
" set foldmethod=syntax
" set foldlevel=1

""" Number highlighting
highlight LineNr ctermfg=0 ctermbg=green

""" Local version if it's there
if filereadable("~/.vimrc_local")
  source ~/.vimrc_local
endif

""" Catch trailing whitespace:
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

""" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

""" vim-plug plugins:
call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'dense-analysis/ale'
call plug#end()

""" Airline config
let g:airline_theme='deus'

""" Tab completion
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

""" Create new scripts with template files if a skeleton with the same extension exists
""" Also chmod +x the file if not already +x'ed
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
