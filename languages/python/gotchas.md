# Python Gotchas

Common bug classes and surprising behavior in Python.

## Mutable default arguments

```python
def append_to(item, target=[]):     # BUG: shared across calls
    target.append(item)
    return target

append_to(1)  # [1]
append_to(2)  # [1, 2]  — same list!
```

Default arguments are evaluated once, at function-definition time. Use `None` as the sentinel:

```python
def append_to(item, target=None):
    if target is None:
        target = []
    target.append(item)
    return target
```

## Late binding in closures

```python
funcs = [lambda: i for i in range(3)]
[f() for f in funcs]   # [2, 2, 2], not [0, 1, 2]
```

Closures capture variables by name, not by value. Bind explicitly:

```python
funcs = [(lambda i=i: i) for i in range(3)]   # [0, 1, 2]
```

## Bare `except`

```python
try:
    do_thing()
except:
    pass    # also catches KeyboardInterrupt, SystemExit
```

Catches everything including signals and exits. Use `except Exception:` at minimum; usually specific exception classes.

## `is` vs `==`

```python
if x is "":      # may be True for cached strings, False otherwise — implementation-defined
if x == "":      # correct
```

`is` checks identity; `==` checks equality. Use `is` only for `None`, `True`, `False`.

## Floating-point comparison

```python
0.1 + 0.2 == 0.3   # False
```

Use `math.isclose` or work in integer units (cents instead of dollars).

## `dict.keys()` while mutating

```python
for k in d:           # RuntimeError if you modify d during iteration
    if cond(k):
        del d[k]
```

Iterate over a copy: `for k in list(d):`. Or build a new dict.

## `range` is not a list

```python
r = range(10)
len(r)        # 10
r[5]          # 5
sum(r)        # 45
r.append(11)  # AttributeError — range is not a list
```

Convert with `list(r)` if you need mutation.

## `requests.get` without timeout

```python
requests.get("https://slow.example.com")   # may hang forever
```

Always pass `timeout=`. Same for `httpx`. Same for `urllib.request`.

## `subprocess.run` without `check=True`

```python
subprocess.run(["maybe-fail"])   # returns silently on non-zero exit
subprocess.run(["maybe-fail"], check=True)   # raises CalledProcessError
```

Default behavior is to ignore non-zero exits. Almost always wrong.

## `shell=True` injection

```python
subprocess.run(f"rm -rf {user_input}", shell=True)   # command injection
```

Use the list form: `subprocess.run(["rm", "-rf", user_input])`. No shell, no injection.

## `json.loads` with floats and money

```python
json.loads('{"amount": 0.1}')["amount"] + json.loads('{"amount": 0.2}')["amount"]
# 0.30000000000000004
```

Don't store money as floats. Use `Decimal` or integer smallest-units.

## `pickle` is not safe

```python
import pickle
data = pickle.loads(untrusted_bytes)   # arbitrary code execution
```

`pickle` is not a deserialization format for untrusted data. Use JSON, MessagePack, or a schema-validated format.

## `eval` / `exec` on user input

Almost always wrong. If you think you need it, you don't.

## `os.path` vs `pathlib`

```python
os.path.join("foo", "bar")   # works, but stringly typed
Path("foo") / "bar"           # better
```

`pathlib` is the modern way. `os.path` still has the API; `pathlib.Path` is typed.

## `time.time()` for measuring durations

```python
start = time.time()
do_thing()
duration = time.time() - start   # affected by system clock changes
```

Use `time.perf_counter()` or `time.monotonic()` for durations.

## Mixing `print` and logging

`print` writes to stdout; logging defaults to stderr. CLI output mixed with log lines is confusing. Use logging consistently for diagnostic output; `print` (or `click.echo`) for user-facing output.

## Global state in modules

```python
# config.py
CONFIG = None

def load(path):
    global CONFIG
    CONFIG = read(path)
```

Mutating global state at import time or via side-effects makes testing painful. Use a config object passed explicitly.

## Circular imports

```python
# a.py imports b
# b.py imports a
```

Python handles some circular imports OK; others break with `ImportError` or partially-initialized modules. Refactor to break the cycle (extract shared types into a third module).

## `__init__.py` side effects

Heavy work in `__init__.py` runs at import. Slow startup, surprising state. Keep `__init__.py` minimal — just re-exports.

## `# type: ignore` everywhere

Each `# type: ignore` is technical debt. Make them specific (`# type: ignore[arg-type]`) and comment why.

## `from foo import *`

Pollutes the namespace, hides what was imported, breaks linters that check for unused imports. Don't.

## Floats in `dict` keys

```python
d = {0.1: "a"}
d[0.1 + 0.0]   # KeyError sometimes, depending on float representation
```

Floats as dict keys are fragile. Use Decimal or an integer representation.

## `assert` removed by `-O`

```python
def transfer(amount):
    assert amount > 0
    do_transfer(amount)
```

`python -O` strips assertions. Don't use `assert` for validation that must happen at runtime — raise explicitly.

## Mutable class attributes shared across instances

```python
class Box:
    contents = []     # CLASS attribute, shared

a = Box()
b = Box()
a.contents.append(1)
b.contents   # [1]  — shared!
```

Initialize mutable attributes in `__init__`:

```python
class Box:
    def __init__(self):
        self.contents = []
```

## `dict` insertion order

Since Python 3.7, dicts preserve insertion order. But don't rely on that for sets — `set` does not preserve order.

## Related

- [`idioms.md`](./idioms.md), [`reviewer.md`](./reviewer.md).
