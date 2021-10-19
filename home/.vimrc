"" .vimrc

set background=dark
set shiftwidth=2
set expandtab
set mouse=a
set belloff=all
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
set updatetime=100

""" Local version if it's there
if filereadable("~/.vimrc_local")
  source ~/.vimrc_local
endif

""" Catch trailing whitespace:
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
