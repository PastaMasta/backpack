backpack
======================

My collection of dotfiles, notes and scripts with a setup script.

```
./backpack
├── home
│   ├── dotdirs
│   └── dotfiles
├── LICENSE.md
├── README.md
└── setup.sh
```

Files in dotfiles are symlinked to ~/ directly

Dot directories are symlinked into ~/ if the dir doesn't already exist; if it does then
the files within that dot directory are symlinked inside the existing dir.

License and Authors
-------------------
Authors: PastaMasta  
See [LICENSE](LICENSE.md) for license rights and limitations (GNU GPLv3).

