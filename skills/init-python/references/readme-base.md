# <project-name>

## Prerequisites

- [UV](https://docs.astral.sh/uv/) (Python package manager)

## Setup

```bash
uv sync
```

## Development

### Running

```bash
uv run python -m <package>.main
```

### Linting

```bash
./lint.sh
```

### Testing

```bash
uv run pytest
```

### Pre-commit hooks

Pre-commit hooks are installed automatically. To run manually:

```bash
uv run pre-commit run --all-files
```
