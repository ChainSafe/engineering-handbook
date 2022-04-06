# Rust
Our most notable Rust stack:
* https://github.com/ChainSafe/forest/ (Filecoin Rust)
* https://github.com/ChainSafe/mina-rs (Mina Rust)
* https://github.com/ChainSafe/chainbridge-substrate (ChainBridge Substrate)
* https://github.com/ChainSafe/PINT (Polkadot Index Network Token)

### Repository Structure

### IDE Configurations

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
