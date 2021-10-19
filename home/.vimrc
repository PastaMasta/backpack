"" .vimrc

set background=dark
set shiftwidth=2
set expandtab
set mouse=a
set belloff=all
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
set updatetime=100
source ~/.vimrc_local

""" Catch trailing whitespace:
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
