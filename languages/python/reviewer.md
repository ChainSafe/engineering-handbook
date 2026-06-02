# Python Reviewer

Language-specific review for Python PRs at ChainSafe. Python's scope is internal-tooling-grade; review is **SOFT WARNING** tier (agent flags, operator decides).

> **In one line:** Type hints at boundaries, no bare excepts, no mutable defaults, lockfile up-to-date, no `# type: ignore` without reason.

## Severity tier

**SOFT WARNING.** Per [reviewer-severity tier table](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail), Python is not in the security-critical-language list. If Python ever ends up in a security-critical path at ChainSafe, the language choice itself is the issue — escalate to the curator.

## Checklist

### Type discipline

- **Type hints at module boundaries.** Public functions need full annotations.
- **`# type: ignore`** requires a comment.
- **`Any` reaches into typed code** — flag and ask whether a `Protocol` or `Union` would work.
- **No untyped `**kwargs`** propagated through layers when concrete types would do.
- **`isinstance(x, Foo)`** for type checks, not `type(x) == Foo`.
- **Keyword-only arguments** (`*`) at wide call sites so options can't be transposed (Effective Python Item 37).
- **Public functions, classes, and modules have docstrings** (Effective Python Item 118).

### Errors

- **No bare `except:`** — always specify exception class.
- **No `except Exception:`** without a reason — usually too broad.
- **`raise X from e`** to preserve the cause chain when wrapping.
- **No string-message `raise Exception(...)`** for non-trivial errors — use a typed exception class.
- **Failures raise; they don't return `None`** (Effective Python Item 32) — a `None` return is ambiguous with an empty result.
- **No silently-swallowed errors.** `pass` in an `except` block deserves a comment.

### Resource handling

- **`with` (context manager)** for files, network connections, locks. Not raw `open`/`close`.
- **`pathlib.Path`** for paths, not string concatenation.
- **No global mutable state** without `threading.Lock` or equivalent.

### Async (when present)

- **No mixing sync and async** in the same module without clear boundary.
- **No `time.sleep()`** in async code (use `asyncio.sleep`).
- **No blocking I/O calls** in async functions (use the async variant or `run_in_executor`).
- **`asyncio.gather` over an unbounded input** — use a semaphore.

### CLI tools

- **`--dry-run` flag** for any tool that mutates state. The operator-first contract applies.
- **Exit codes:** 0 success, distinct non-zero codes per failure class.
- **`click` or `typer`** for non-trivial CLIs; not raw argparse.
- **Output goes to stderr or stdout deliberately** — log to stderr, data to stdout.

### Dependencies

- **Lockfile committed and up-to-date.** `uv.lock` or `poetry.lock`.
- **No `pip install` in committed scripts.** Tools should declare deps in `pyproject.toml`.
- **Audit-style dep additions:** each new package is a supply-chain choice.

### Tests

- **`pytest` with fixtures** for setup, not module-level globals.
- **`pytest.raises(X, match=...)`** for negative tests.
- **Parametrize over copy-paste** for similar test cases.
- **No tests with implicit network access** — mock or fixture.

### Lint and format

- **`ruff check`** clean.
- **`ruff format --check`** clean.
- **`mypy --strict`** clean.
- **No `# noqa`** without a comment.

### Project structure

- **`src/` layout** for non-trivial projects.
- **`pyproject.toml`** as canonical config; no `setup.py` / `setup.cfg`.

## What to flag vs fix in place

- **Flag:** type-hint gaps, error-handling choices, async design, dep additions, lint suppressions.
- **Suggest with code suggestion:** trivial ruff fixes, type-hint additions on private functions, doc string formatting.
- **Don't fix and push** unless authorized.

## When the reviewer skill refuses to review

- Non-Python code in diff.
- Empty PR description.
- Out-of-session-scope code.
- **Python code in a production-product hot path** — refuse and escalate. The language choice is the architectural finding.

## Phrasing

- Lead with concern: "This function returns `dict[str, Any]` and several callers `kwargs` it forward. A `dataclass` or `TypedDict` at the boundary would catch the bugs lurking in those `Any`s."
- Cite the rule when relevant.
- `nit:` for taste-level.

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md).
- [Effective Python](https://effectivepython.com/) (Slatkin) — canonical practice reference (see [`sources.md`](../../references/sources.md)).
