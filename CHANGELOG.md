# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2026-05-23

### Added
- `PYTHON_VERSION` build arg makes the image's Python version configurable
  (default `3.10`). Override with `PYTHON_VERSION=3.11 docker buildx bake` or
  `docker build --build-arg PYTHON_VERSION=3.11 ...`. The requested interpreter
  is installed from the deadsnakes PPA. See `docs/building.md` for details and
  the matching Network Volume venv requirement.

### Changed
- CI now uses `docker/build-push-action@v7.1.0` with a matrix over the CUDA
  targets, replacing the previous `docker buildx bake` plus override-file flow.
  Builds emit SBOM and provenance attestations and use the GitHub Actions cache
  backend (`type=gha`), scoped per CUDA target.

### Fixed
- Job summary now reports the correct torch (`2.10.0`) and xformers (`0.0.34`)
  versions for the CUDA 12.8 image (previously showed the older `2.9.1` /
  `0.0.33`).

[4.1.0]: https://github.com/ashleykleynhans/runpod-worker-comfyui/releases/tag/4.1.0
