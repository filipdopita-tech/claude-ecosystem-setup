# Python Rules (consolidated)
# Read when: writing/reviewing Python code, debugging .py files, Python architecture decisions

## Coding Style

- Follow **PEP 8** conventions
- Use **type annotations** on all function signatures
- Formatters: **black** (formatting), **isort** (imports), **ruff** (linting)
- Prefer immutable data structures:

```python
from dataclasses import dataclass
from typing import NamedTuple

@dataclass(frozen=True)
class User:
    name: str
    email: str

class Point(NamedTuple):
    x: float
    y: float
```

## Patterns

- **Protocol** for duck typing (not ABC unless needed):

```python
from typing import Protocol

class Repository(Protocol):
    def find_by_id(self, id: str) -> dict | None: ...
    def save(self, entity: dict) -> dict: ...
```

- **Dataclasses** as DTOs:

```python
@dataclass
class CreateUserRequest:
    name: str
    email: str
    age: int | None = None
```

- Use **context managers** (`with`) for resource management
- Use **generators** for lazy evaluation and memory-efficient iteration

## Testing

- Framework: **pytest**
- Coverage: `pytest --cov=src --cov-report=term-missing` (target: 80%+)
- Categorize with `pytest.mark`:

```python
@pytest.mark.unit
def test_calculate_total(): ...

@pytest.mark.integration
def test_database_connection(): ...
```

## Security

- Secrets via environment variables only, never hardcoded:

```python
import os
from dotenv import load_dotenv

load_dotenv()
api_key = os.environ["OPENAI_API_KEY"]  # Raises KeyError if missing
```

- Static analysis: `bandit -r src/`

## Hooks (PostToolUse, .py files)

- **black/ruff**: auto-format after edit
- **mypy/pyright**: run type checking after edit
- Warn on `print()` statements — use `logging` module instead

## Skills (for deeper reference)

- `python-patterns` — decorators, concurrency, package organization
- `python-testing` — detailed pytest patterns and fixtures
- `django-security` — Django-specific security (if applicable)
