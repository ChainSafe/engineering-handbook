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
You'd be considered insane if you use vim to write java code.
Luckily rust code is shorter to write that it is practical to just use very simple editing tools.

#### Easy
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


#### Advance
- **VIM**
    - Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient.
    - Vim is shipped in most linux distribution and it is a bare minimal configuration.
    - Unlike Clion or VSCode which has a built-in way to install a plugin, but in vim,
      be able to install a plugin in vim, first you need to install a plugin manager first.
      We recommend you to use [vim-plug](https://github.com/junegunn/vim-plug).
      Then the install this plugins using the `vim-plug` plugin manager
        - nerdtree
        - vim-fugitive
        - rust.vim
        - youcompleteme
        - coc-rust-analyzer
    - Similar to vim
        - Neovim, which adds a lot of improvement on the language server backend.
        - kakoune editor, an alternative editor to vim with different order of the modal editing actions

#### Insanity
- **Emacs**
    - emacs is a text editor, which happens to ship an entire Operating system with it.
    - you can install rust-analyzer as a plugin in emacs

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
