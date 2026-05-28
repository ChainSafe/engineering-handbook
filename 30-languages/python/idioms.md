---
title: Python Idioms
status: draft (v2)
authors:
  - "@kalambet"
language: python
last_updated: 2026-05-27
---

# Python Idioms

Idiomatic Python (3.11+) for ChainSafe internal tooling.

## Modern type hints

```python
def process(orders: list[Order], limit: int | None = None) -> dict[str, int]:
    ...
```

- Built-in generics (`list`, `dict`, `tuple`) since 3.9.
- `T | None` since 3.10 (replaces `Optional[T]`).
- No need to `from typing import List, Dict, Optional`.

## Dataclasses for records

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Money:
    amount: int       # store as integer cents/smallest unit
    currency: str
```

- `frozen=True` for immutability — hashable, safer.
- `slots=True` for memory + speed.
- For unstructured-but-typed bags, `TypedDict` is the alternative.

## Protocols (structural typing)

```python
from typing import Protocol

class Fetcher(Protocol):
    def fetch(self, url: str) -> bytes: ...

def process(f: Fetcher) -> None:
    f.fetch("https://example.com")
```

Caller's class doesn't need to inherit from `Fetcher` — duck-typed at the type level.

## Pattern matching (3.10+)

```python
match event:
    case Order(id=id_, amount=amount) if amount > 0:
        process_order(id_, amount)
    case Refund(id=id_):
        process_refund(id_)
    case _:
        raise ValueError(f"Unknown event: {event}")
```

Exhaustiveness checking when paired with strict mypy.

## `pathlib` over string paths

```python
from pathlib import Path

config = Path("~/.config/mytool/config.toml").expanduser()
if config.exists():
    raw = config.read_text()
```

Don't manipulate paths as strings.

## f-strings

```python
url = f"https://api.example.com/orders/{order_id}"
log.info(f"Processing {len(orders)} orders for {customer.name}")
```

- f-strings for formatting.
- `f"{value=}"` syntax for debug output (Python 3.8+): `f"{x=}"` → `x=42`.

## Context managers

```python
from contextlib import contextmanager

@contextmanager
def open_db_connection():
    conn = connect()
    try:
        yield conn
    finally:
        conn.close()

with open_db_connection() as conn:
    conn.execute(...)
```

- `with` for resource handling.
- `@contextmanager` for custom resources.
- `contextlib.suppress` for the "ignore this specific exception" case.

## Enum

```python
from enum import StrEnum

class OrderState(StrEnum):
    PENDING = "pending"
    ACTIVE = "active"
    CANCELLED = "cancelled"
```

`StrEnum` (3.11+) — enum members are also strings, JSON-serializable, comparable to strings.

## List/dict comprehensions

```python
totals = {customer: sum(o.amount for o in orders if o.customer == customer)
          for customer in customers}

active = [o for o in orders if o.state == OrderState.ACTIVE]
```

For transformations. For side effects, use a loop — comprehensions with side effects are unidiomatic.

## Iterators and generators

```python
def chunks(items: list[T], size: int) -> Iterator[list[T]]:
    for i in range(0, len(items), size):
        yield items[i:i + size]
```

Generators for streaming; iterators for protocol compatibility.

## `functools` toolkit

```python
from functools import cache, lru_cache, reduce, partial

@cache
def expensive(x: int) -> int:
    ...

multiply_by_two = partial(multiply, 2)
```

- `@cache` (3.9+) — unbounded memoization.
- `@lru_cache(maxsize=N)` for bounded.
- `partial` for argument binding.

## Logging

```python
import logging
log = logging.getLogger(__name__)

log.info("processing order", extra={"order_id": order.id, "amount": order.amount})
```

- `logging.getLogger(__name__)` per module.
- Structured logging via `extra` dict.
- Configure at the entrypoint, not in library code.

## Testing with pytest

```python
import pytest

@pytest.fixture
def sample_config(tmp_path: Path) -> Config:
    p = tmp_path / "config.toml"
    p.write_text("name = 'test'")
    return load_config(p)

@pytest.mark.parametrize("input,expected", [
    ("a", "A"),
    ("ab", "AB"),
    ("", ""),
])
def test_upper(input: str, expected: str) -> None:
    assert input.upper() == expected
```

- Fixtures for setup.
- `tmp_path` built-in for filesystem tests.
- `parametrize` for table-driven tests.

## Related

- [`developer.md`](./developer.md), [`gotchas.md`](./gotchas.md).
