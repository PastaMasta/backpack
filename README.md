backpack
======================

My collection of dotfiles and other bits with a setup script and ansible playbook for package installs.

Files in ```./home/``` are symlinked into ```~/```, directories are created if missing so files outside of this repo won't be added unless desired.

Catagorised bashrc files are placed in ```~/.bashbag```, everything inside it is sourced.

Files in ```./versioned/``` are for files dependant on package versions - i.e tmux

backpack-local
-------------------

If there are configuration / settings that are sensitive and can't be added to this repo need to be kept seperate then create a new git repo using [backpack-local](backpack-local-template/README.md)

License and Authors
-------------------

Authors: PastaMasta
See [LICENSE](LICENSE.md) for license rights and limitations (GNU GPLv3).
