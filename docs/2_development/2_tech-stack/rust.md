# Rust
Our most notable Rust stack:
* https://github.com/ChainSafe/forest/ (Filecoin Rust)
* https://github.com/ChainSafe/mina-rs (Mina Rust)
* https://github.com/ChainSafe/chainbridge-substrate (ChainBridge Substrate)
* https://github.com/ChainSafe/PINT (Polkadot Index Network Token)

### Repository Structure

### IDE Configurations

There are multiple options to work with rust projects, ranging from simple text editors to language aware IDE.
Nowadays, there is a blurred line on what's considered an IDE or a code editor, as installing multiple plugins in a code editor would have the feature in par with that of a fully featured IDE.
As a rule of thumb always use the right tools for the right job.
Choice of IDE is very dependent on the skill level, and how much time you are willing to put into customizing your own code editing workflow.
You'd be considered insane if you use Vim to write java code.
Luckily rust code is shorter to write that it is practical to just use very simple editing tools.

#### Easy
- **Clion**
    - Clion is a fully featured and powerful IDE from Jetbrains, the creator of IntelliJ IDE
    - You can then install the rust plugin for Clion from their [marketplace](https://plugins.jetbrains.com/plugin/8182-rust)
    - Very polished IDE and streamlined workflow for code editing.
    - It comes with a cost at 200 USD / year, however there is [free license program](https://www.jetbrains.com/community/opensource/#support) you can apply for non-commercial opensource projects

- **Visual Studio code**
    - [VSCode](https://github.com/microsoft/vscode) for short, is an opensource code editor from Microsoft
    - Built on top of electron
    - You can install the rust and rust-analyzer plugin in the Preferences
    - With rust and rust-analyzer plugin the code editor intellisense and macro expansion is added into your code editor
    - With the over growing marketplace you can install a lot of plugins into visual studio code alongside with rust and rust-analyzer

#### Intermediate
- **Sublime text**
    - [Sublime text](https://www.sublimetext.com/) a snappy text editor with syntax highlighting for a wide range of language syntax, including rust
- **Lapce**
    - [Lapce](https://github.com/lapce/lapce) is an opensource text editor written in rust for rust programmers who are are also fun of Vim
    - Works out of the box for rust development without having to install any plugins
    - Experimental and in alpha stage
- **Helix**
    - It the same vein as Lapce but for use inside the terminal


#### Advance
- **VIM**
    - Vim is a highly configurable and powerful text editor which gives its user the most efficient way to edit text regardless of the size, language and format
    - Vim is shipped in most linux distribution and it is a bare minimal configuration
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

#### Insanity
- **Emacs**
    - Emacs is a text editor, which happens to ship an entire Operating system with it
    - you can install rust-analyzer as a plugin in Emacs

#### Summary
In summary, the choice of editor is really up to the users and it is affected by the skill level, the types of projects they are usually working with and the situation that they are in.
There are trade-offs to all of the editors. Making the developer experience more streamline requires great deal of processing of the code such as code indexing/re-indexing upon code changes.
Clion IDE and VSCode requires a decent workstation since it needs to use a huge chunk of memory, and it could get real slow for big projects.
Using Clion and VSCode to open multiple projects at the same time would really bring your workstation to its knees no matter how beefy your machine is.
If you using less powerful device such as a laptop, then terminal base code editor such as Vim, Kakoune, or Helix would be ideal.
These terminal base text editor is also viable for editing code and configurations remotely to a server, where graphical editor wouldn't be possible.

Our overall recommendation is Vim.
Vim is frustrating and unintuitive to start at first, but it is really delightful once you get the hang of it, then you can just keep discovering new editing tricks.
Opening multiple projects with Vim is instantaneous and only uses very little system resources.
Vim also offers a great deal of flexibility and reproducibility. Let's say, you travel a lot and you need to use a new device as your new workstation.
You can easily recreate the same editor configuration with your new device.
This can be done by checking in your editor configurations `.vimrc` into your private repo, alongside with a shell script.
The shell script could contain the list of terminal commands to install `vim` and a plugin manger, and moving the `.vimrc` file into your home directory.


### Linter Configuration
Clippy and RustFMT are doing a pretty good job nowadays.
* `cargo fmt --all --check` should always pass without warnings/errors
* `cargo clippy --all-targets -- -D warnings` should always pass without errors

### Security
Cargo's audit feature should not disclose any unpatched vulnerabilities.
* `cargo audit` should always pass without errors

### Vetted Libraries

### Testing, Mocking

### Continuous Integration
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
