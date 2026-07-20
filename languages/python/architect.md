# Python Architect

Architectural guidance for Python work at ChainSafe. Python's scope at ChainSafe is **internal-tooling-grade**: ops scripts, Ansible automation, data analysis, ML/research prototyping, internal CLIs. It is *not* the language of choice for production user-facing services or smart contracts. This shapes the architecture decisions below.

> **In one line:** Python is for operator velocity, not production durability. Optimize for clarity and quick iteration; offload performance-critical work elsewhere.

## Scope reminder

Python at ChainSafe is appropriate for:

- Ops scripts and tooling.
- Ansible automation (Ansible is Python under the hood; see [`../../workflows/infrastructure-and-devops.md`](../../workflows/infrastructure-and-devops.md)).
- Data analysis and reporting.
- ML/research prototypes.
- Internal CLIs.

Python at ChainSafe is *not* appropriate for:

- User-facing services where Lodestar/Forest/Gossamer/Sygma already cover the surface.
- Smart contract code.
- Production cryptographic primitives (use audited Rust/Go libraries).

If your task fits the second list, the language choice itself is the architectural question — escalate to the curator before writing Python.

This is [Effective Python](https://effectivepython.com/) Item 94 (*Know When and How to Replace Python with Another Programming Language*) as house policy: when a Python path turns performance-critical, profile it first (Item 92, *Profile Before Optimizing* — measure with `cProfile` / `timeit`, never guess), then push the hot part into a native extension or another language rather than micro-optimizing Python. Python stays the glue and the velocity layer.

## Defer to `.invariants` for

Python projects generally sit downstream of the main product architecture. The `.invariants` framework applies for cross-component invariants, but most Python work doesn't introduce new architectural invariants — it operates within existing ones.

## Python-specific architectural choices

### Project layout

For non-trivial Python projects:

- `src/` layout (`src/<package>/`, not just `<package>/`) — keeps imports honest and prevents accidental local imports during testing.
- `tests/` parallel to `src/`.
- `pyproject.toml` as the canonical config (PEP 621). No `setup.py`, no `setup.cfg`.
- Dependency management with `uv` or `poetry`. Avoid bare `pip` + `requirements.txt` for non-trivial projects (no lockfile = no reproducibility).
- Lockfile committed (`uv.lock`, `poetry.lock`).

For ops scripts:

- Single-file scripts are fine for genuinely small things.
- Once a script grows past ~200 lines or gets imported by another script, promote it to a package.

### Type discipline

- **Type hints required** for any function exported from a module. `def foo(x: int) -> str:` is the floor.
- **`mypy --strict`** or `pyright` strict in CI. Type-check is a separate step from tests.
- **No `# type: ignore`** without a comment explaining why.
- **`typing.Protocol`** for structural typing — Python's interfaces.
- **`dataclasses` (or `attrs`)** for record types; not `dict`-passing across module boundaries.

### Error model

- **Raise specific exception classes**, never `raise Exception("...")`.
- **Custom exception hierarchies** for libraries with non-trivial error surfaces:
  ```python
  class MyToolError(Exception): pass
  class ConfigError(MyToolError): pass
  class NetworkError(MyToolError): pass
  ```
- **`try`/`except`/`else`/`finally`** when the post-try cleanup matters.
- **Never bare `except:`** — always specify the exception class.

### Async

- **`asyncio` is fine for I/O-bound concurrency** when the task warrants it. Don't reach for it reflexively.
- **`anyio`** for libraries that want runtime independence (works with asyncio and trio).
- **`concurrent.futures.ThreadPoolExecutor`** for I/O-bound concurrency without async syntax.
- **`multiprocessing`** for CPU-bound concurrency (the GIL still matters).
- **Pick one model and stick with it** within a project.

### CLI design

For operator-facing CLIs:

- **`click`** or **`typer`** — argparse only for the simplest scripts.
- **Subcommand structure** for multi-action tools.
- **Exit codes**: 0 success, non-zero failure with distinct codes per failure class.
- **`--dry-run`** flag for any tool that mutates state. The operator-first contract applies even to internal tools.

## ADR shape for Python work

For Python work substantial enough to warrant an ADR:

- **Why Python** — what makes this the right choice over Go/Rust/TS?
- **Public surface** — if a library, what's exported and what's `_private`.
- **Dependency choices** — significant deps named (e.g., `pydantic` vs `dataclasses`, `requests` vs `httpx`).
- **Performance commitments** — if any. Python is rarely the right answer when performance matters.
- **Deployment model** — is this a script, a CLI, a long-running service, a notebook?
- **Invariants impacted** — usually none new; reference upstream invariants if relevant.

## Anti-patterns at design time

- **Python for production hot paths.** Wrong tool; use Go/Rust.
- **Untyped Python at the module boundary.** Type hints are mandatory at the export surface.
- **Bare `pip install` without a lockfile.** No reproducibility.
- **`*args, **kwargs` propagated through layers** when concrete types would do.
- **`dict`-passing for structured data.** Use a dataclass.
- **Mixing async and sync in one codebase without clear boundaries.**

## Related

- [`developer.md`](./developer.md), [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/infrastructure-and-devops.md`](../../workflows/infrastructure-and-devops.md) — Ansible and ops tooling context.
- [Effective Python](https://effectivepython.com/) (Slatkin) — the canonical Python practice reference this section builds on; cataloged in [`sources.md`](../../references/sources.md).
