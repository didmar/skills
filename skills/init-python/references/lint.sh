#!/usr/bin/env bash
set -euo pipefail
stepdown check . && ruff check . --fix && ruff format .
