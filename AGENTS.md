# AGENTS.md

## Cursor Cloud specific instructions

As of this writing, this repository (`2030`) is an **empty scaffold**: the only
tracked file is `README.md` (a single-line title). There is:

- No application/source code
- No dependency manifest (no `package.json`, `requirements.txt`, `go.mod`,
  `Cargo.toml`, `pyproject.toml`, etc.)
- No services, database, Docker, Makefile, or CI configuration
- No tests, lint, or build tooling

Consequently there is **nothing to install, lint, test, build, or run** yet, and
the startup update script is intentionally a no-op.

Base tooling available in the Cursor Cloud VM (for whenever real code is added):
Node.js 22, npm 10, Python 3.12, Go 1.22, Rust 1.83. Docker is not preinstalled.

When real application code and a dependency manifest are introduced, revisit this
file and the startup update script so dependencies are installed and services can
be run end to end.
