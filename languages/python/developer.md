# Python Developer

Idiomatic Python at ChainSafe — for ops, scripting, internal tooling, and Ansible work.

> **In one line:** Modern Python (3.11+). Type-hinted at module boundaries. `ruff` + `mypy --strict` in CI. `uv` for dependencies.

## Tooling baselines

- **Python version:** 3.11+ for new code. Pin in `pyproject.toml`.
- **Formatter + linter:** [`ruff`](https://docs.astral.sh/ruff/) — replaces `black`, `isort`, `flake8`, most of `pylint`. Fast. `ruff format` + `ruff check`.
- **Type checker:** `mypy --strict` or `pyright` strict mode. CI gate.
- **Dependency manager:** [`uv`](https://docs.astral.sh/uv/) for new projects; `poetry` where entrenched. Lockfile committed.
- **Test runner:** `pytest`.

## `pyproject.toml` baseline

```toml
[project]
name = "mytool"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[tool.ruff]
target-version = "py311"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "C4", "DTZ", "RET", "SIM"]
ignore = []

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra --strict-markers"
```

## Project layout

```
mytool/
├── pyproject.toml
├── uv.lock              # or poetry.lock
├── README.md
├── src/
│   └── mytool/
│       ├── __init__.py
│       ├── cli.py
│       └── core.py
└── tests/
    └── test_core.py
```

`src/` layout is the modern default — prevents accidental local imports during testing.

## Type discipline

```python
from dataclasses import dataclass
from typing import Protocol

@dataclass(frozen=True, slots=True)
class Order:
    id: str
    amount: int
    currency: str

class Fetcher(Protocol):
    def fetch(self, url: str) -> bytes: ...

def process(orders: list[Order], fetcher: Fetcher) -> dict[str, int]:
    ...
```

- `@dataclass(frozen=True, slots=True)` for records — immutable, memory-efficient.
- `Protocol` for structural typing (interfaces).
- Built-in generic syntax (`list[Order]`, `dict[str, int]`) — Python 3.9+.
- No untyped `def` at module boundaries.

## Error handling

```python
class ConfigError(Exception):
    """Raised when configuration is invalid or missing."""

class NetworkError(Exception):
    """Raised on network failure after retries."""

def load_config(path: str) -> Config:
    try:
        raw = pathlib.Path(path).read_text()
    except FileNotFoundError as e:
        raise ConfigError(f"Config not found: {path}") from e

    try:
        return Config.parse(raw)
    except ParseError as e:
        raise ConfigError(f"Config parse failed: {path}") from e
```

- Specific exception classes.
- `raise X from e` preserves the cause chain (Python's equivalent of error wrapping).
- **Raise exceptions rather than returning `None`** on failure (Effective Python Item 32) — a `None` return is ambiguous with a legitimately-empty result and pushes error-checking onto every caller.
- Never bare `except:`.

## CLI with `click`

```python
import click

@click.group()
def cli() -> None:
    """My internal tool."""

@cli.command()
@click.argument("name")
@click.option("--dry-run", is_flag=True, help="Show what would change.")
def deploy(name: str, dry_run: bool) -> None:
    """Deploy NAME to staging."""
    if dry_run:
        click.echo(f"[dry-run] would deploy {name}")
        return
    click.echo(f"deploying {name}")

if __name__ == "__main__":
    cli()
```

- `click` or `typer` for non-trivial CLIs.
- `--dry-run` for any tool that mutates state.
- Subcommands via `@cli.group()` + `@cli.command()`.

## Async

```python
import asyncio
import httpx

async def fetch_all(urls: list[str]) -> list[bytes]:
    async with httpx.AsyncClient() as client:
        return await asyncio.gather(*[client.get(u) for u in urls])
```

- `asyncio` for I/O-bound concurrency when the task warrants it.
- `httpx` over `requests` for the async variant.
- Don't mix sync and async in the same module without clear reason.

## Logging

```python
import logging
logger = logging.getLogger(__name__)

def do_thing() -> None:
    logger.info("doing thing", extra={"context": "value"})
```

- `logging.getLogger(__name__)` per module — gives you the natural namespace tree.
- Configure at the entry point (`cli.py`, `main.py`), not in library code.
- Structured logging via the `extra` dict; don't bake context into the message string.

## Testing

```python
import pytest

@pytest.fixture
def sample_config() -> Config:
    return Config(name="test", timeout=30)

def test_load_valid(sample_config: Config, tmp_path: pathlib.Path) -> None:
    path = tmp_path / "config.toml"
    path.write_text(sample_config.to_toml())
    loaded = load_config(str(path))
    assert loaded == sample_config

def test_load_missing_raises(tmp_path: pathlib.Path) -> None:
    with pytest.raises(ConfigError, match="not found"):
        load_config(str(tmp_path / "nonexistent.toml"))
```

- `pytest` fixtures for setup; built-in `tmp_path` for filesystem tests.
- `pytest.raises` with a `match` argument for negative tests.
- `parametrize` for table-driven tests.

## CI baseline

- `ruff format --check .`
- `ruff check .`
- `mypy --strict src/`
- `pytest`
- `uv lock --check` (verify lockfile is up to date)

## Patterns

- **Dataclasses for records.** Not dicts.
- **`pathlib.Path` for paths.** Not string concatenation.
- **f-strings for formatting.** Not `%` or `.format()`.
- **Context managers (`with`)** for resource handling.
- **List/dict comprehensions** for transformations; loops for side effects.
- **`functools.lru_cache`** for memoization where appropriate.
- **Keyword-only arguments** (`def f(*, timeout: int)`) for options at wide call sites — callers can't transpose positional args, and adding a parameter later doesn't shift the others (Effective Python Item 37).
- **Docstrings on every public function, class, and module** (Effective Python Item 118) — they document the contract (what it does, raises, returns) and surface through `help()` / `pydoc`.

## Anti-patterns

- Bare `except:`.
- Mutable default arguments (`def f(x=[])`).
- Star imports (`from foo import *`).
- `global` keyword.
- Untyped functions at the module boundary.
- Comparing types with `type(x) == Foo` instead of `isinstance(x, Foo)`.
- `requirements.txt` without a lockfile for non-trivial projects.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
