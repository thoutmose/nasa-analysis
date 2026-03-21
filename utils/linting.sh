#!/bin/bash

echo "Linting Python files using ruff..."
uv run --with ruff ruff check --fix dags/
uv run --with ruff ruff format dags/

if [ $? -eq 0 ]; then
    echo "Linting complete!"
else
    echo "Linting failed!"
    exit 1
fi
