# Rust
Our most notable Rust stack:
* https://github.com/ChainSafe/forest/ (Filecoin Rust)
* https://github.com/ChainSafe/mina-rs (Mina Rust)
* https://github.com/ChainSafe/chainbridge-substrate (ChainBridge Substrate)
* https://github.com/ChainSafe/PINT (Polkadot Index Network Token)
* [and others](https://github.com/chainsafe?q=&type=all&language=rust&sort=)

## Repository Structure

:::note

TBD

:::

## IDE Configurations

There are multiple options to work with rust projects, ranging from simple text editors to language-aware IDE.
Nowadays, there is a blurred line between what's considered an IDE or a code editor, as installing multiple plugins in a code editor would have the feature on par with that of a fully-featured IDE.
As a rule of thumb always use the right tools for the right job.
Choice of IDE is very dependent on the skill level, and how much time you are willing to put into customizing your code editing workflow.
You'd be considered insane if you use Vim to write java code.
Luckily rust code is shorter to write so it is practical to just use very simple editing tools.

### Easy
- **Clion**
    - Clion is a fully-featured and powerful IDE from Jetbrains, the creator of IntelliJ IDE
    - You can then install the rust plugin for Clion from their [marketplace](https://plugins.jetbrains.com/plugin/8182-rust)
    - Well-polished IDE and streamlined workflow for code editing.
    - ChainSafe will get a license for you - [Read more](../../5_the-formal-stuff/process_and_policy.md#requesting-license)

- **Visual Studio code**
    - [VSCode](https://github.com/microsoft/vscode) for short, is an open source code editor from Microsoft
    - Built on top of electron
    - You can install the rust and rust-analyzer plugin in the Preferences settings
    - With rust and [rust-analyzer plugin](https://marketplace.visualstudio.com/items?itemName=matklad.rust-analyzer), IntelliSense and macro expansion will be usable in the code editor
    - With the ever-growing [marketplace](https://marketplace.visualstudio.com/vscode) you can install a wide variety of plugins into the editor

### Intermediate
- **Sublime text**
    - [Sublime text](https://www.sublimetext.com/) a snappy text editor with syntax highlighting for a wide range of language syntax, including rust
- **Lapce**
    - [Lapce](https://github.com/lapce/lapce) is an opensource text editor written in rust for rust programmers who are also fun of Vim
    - Works out of the box for rust development without having to install any plugins
    - Experimental and in alpha stage
- **Helix**
    - It is the same vein as Lapce but for use inside the terminal


### Advance
- **VIM**
    - Vim is a highly configurable and powerful text editor which gives its user the most efficient way to edit text regardless of the size, language and format
    - Vim is shipped in most Linux distributions and it is a bare minimal configuration
    - Unlike Clion or VSCode which has a built-in way to install a plugin, in Vim, to be able to install a plugin you need to install a plugin manager first.
      [Vimawesome](https://vimawesome.com/) is an excellent resource for finding Vim plugins and instructions on how to install plugins for each different plugin manager.
      We recommend you to use [vim-plug](https://github.com/junegunn/vim-plug) for the plugin manager.
      Then the install these plugins using the `vim-plug` plugin manager:
        - [nerdtree](https://vimawesome.com/plugin/nerdtree-red)
        - [vim-fugitive](https://vimawesome.com/plugin/fugitive-vim)
        - [rust.vim](https://vimawesome.com/plugin/rust-vim-superman)
        - [youcompleteme](https://vimawesome.com/plugin/youcompleteme)
        - [coc-rust-analyzer](https://github.com/fannheyward/coc-rust-analyzer)
        - [fzf](https://vimawesome.com/plugin/fzf)
        - [gruvbox](https://vimawesome.com/plugin/gruvbox)
    - Similar to Vim
        - [Neovim](https://neovim.io/), which adds a lot of improvement on the language server backend
        - [Kakoune](https://kakoune.org/) editor, an alternative editor to Vim with different order of the modal editing actions

### Insanity
- **Emacs**
    - Emacs is a text editor, which happens to ship an entire Operating system with it
    - you can install rust-analyzer as a plugin in Emacs

### Summary
In summary, the choice of editor is really up to the users and it is affected by the following:
 - skill level,
 - types of projects they are usually working with
 - available device

There are trade-offs for all of the editors. Making the developer experience more streamlined requires a great deal of the processing of the code such as code indexing/re-indexing upon code changes.
Clion IDE and VSCode require a decent workstation since it needs to use a huge chunk of memory, and it could get really slow for big projects.
Using Clion and VSCode to open multiple projects at the same time would bring your workstation to its knees no matter how beefy your machine is.
If you using a less powerful device such as a laptop, then a terminal base code editor such as Vim, Kakoune, or Helix would be ideal.
This terminal-based text editor is also viable for editing code and configurations remotely to a server, where a graphical editor wouldn't be possible.

Our overall recommendation would be Clion to easily get started and Vim for advanced users.
Vim is frustrating and unintuitive to start at first, but it is delightful once you get the hang of it, then you can just keep discovering new editing tricks.
Opening multiple projects with Vim is instantaneous and only uses very few system resources.
Vim also offers a great deal of flexibility and reproducibility. Let's say, you travel a lot and you need to use a new device as your new workstation.
You can easily recreate the same editor configuration with your new device.
This can be done by checking in your editor configurations `.vimrc` into your repository, alongside a shell script.
The shell script could contain the list of terminal commands to install `vim` and a plugin manager, then a command to copy the configuration files into your home directory.


## Linter Configuration
Clippy and RustFMT are doing a pretty good job nowadays.
* `cargo fmt --all --check` should always pass without warnings/errors
* `cargo clippy --all-targets -- -D warnings` should always pass without errors

## Security
Cargo's audit feature should not disclose any unpatched vulnerabilities.
* `cargo audit` should always pass without errors

### Testing, Mocking

:::note

TBD

:::

## Continuous Integration
Check out Forest's collection of Rust workflows: [ChainSafe/forest/.github/workflows/rust.yml](https://github.com/ChainSafe/forest/blob/main/.github/workflows/rust.yml)

* Rust is slow on CI and therefore, we should always use _Github Actions_ with third-party hosted runners
  * e.g., `runs-on: buildjet-16vcpu-ubuntu-2004`
  * see https://buildjet.com
  * consult Elizabeth or Afri for details
* Rust is not only slow but also expensive on CI and therefore, we should always cancel stale jobs
  * e.g., `uses: styfle/cancel-workflow-action@0.9.1`
  * see https://github.com/marketplace/actions/cancel-workflow-action
* Tell the compiler that we are on CI and want to squeeze out most performance
    ```yaml
    env:
      CI: 1
      CARGO_INCREMENTAL: 1
    ```
* Don't use Github Actions cache, use _Rust Cache_
  * e.g., `uses: Swatinem/rust-cache@v1.3.0`
  * https://github.com/marketplace/actions/rust-cache
* Use always nightly/beta/stable build matrices
    ```yaml
    strategy:
    matrix:
      os: [ubuntu-latest, macos-latest]
      rv: [stable, beta, nightly]
    ```
* If you only want to compile on CI, disable debug symbols for faster builds
  * e.g., `cargo build --profile dev`, with:
    ```toml
    [profile.dev]
    debug = 0
    ```
