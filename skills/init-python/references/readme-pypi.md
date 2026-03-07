## Publishing to PyPI

This project uses [trusted publishing](https://docs.pypi.org/trusted-publishers/) via GitHub Actions.

To publish a new version:

1. Update the version in `pyproject.toml`
2. Create a GitHub release with a tag matching the version (e.g., `v0.1.0`)
3. The publish workflow will automatically build and upload to PyPI

> **First-time setup:** Configure a trusted publisher on PyPI under your project's settings (Publishing tab). Use `publish.yml` as the workflow name and `publish` as the environment name.
