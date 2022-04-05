# Rust

## IDE and code editors
There are multiple options to work with rust projects, ranging from simple text editors to language aware IDE.
Nowadays, there is a blurred line on what's considered an IDE or a code editor, as installing multiple plugins in a code editor would have the feature in par with that of a fully featured IDE.
As a rule of thumb always use the right tools for the right job.
Choice of IDE is very dependent on the skill level, and how much time you are willing to put into customizing your own code editing workflow.
You'd be considered insane if you use vim to write java code.
Luckily rust code is shorter to write that it is practical to just use very simple editing tools.

## Easy
- **Clion**
    - Clion is a fully featured and powerful IDE from jetbrains, the creator of IntelliJ IDE
    - You can then install the rust plugin for clion from their [marketplace](https://plugins.jetbrains.com/plugin/8182-rust)
    - It comes with a cost at 200 USD / year.
    - Very polished IDE and streamlined workflow for code editing.

- **Visual studio code**
    - VSCode is an opensource code editor from Microsoft
    - You can install the rust and rust-analyzer plugin in the Preferences.
    - With rust and rust-analyzer plugin the code editor intellisense and macro expansion is added into your code editor.
    - With the over growing marketplace you can install a lot of plugins into visual studio code alongside with rust and rust-analyzer


## Advance
- **VIM**
    - Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient.
    - Vim is shipped in most linux distribution and it is a bare minimal configuration.
    - Unlike Clion or VSCode which has a built-in way to install a plugin, but in vim,
        to be able to install a plugin in vim, first you need to install a plugin manager first.

            - We recommend you to use [vim-plug](https://github.com/junegunn/vim-plug)
                - nerdtree
                - vim-fugitive
                - rust.vim
                - youcompleteme
                - coc-rust-analyzer
    - Similar to vim
        - Neovim, which adds a lot of improvement on the language server backend.
        - kakoune editor, an alternative editor to vim with different order of the modal editing actions

## Insanity
- **Emacs**
    - emacs is a text editor, which happens to ship an entire Operating system with it.
    - you can install rust-analyzer as a plugin in emacs
