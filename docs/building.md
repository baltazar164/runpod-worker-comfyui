## Building the Docker image

You can either build this Docker image yourself, or alternatively,
you can use one of my pre-built images:

### Pre-built Images

| CUDA Version  | Torch  | xformers     | Image                                                            |
|---------------|--------|--------------|------------------------------------------------------------------|
| 12.4          | 2.6.0  | 0.0.29.post3 | `ghcr.io/ashleykleynhans/runpod-worker-comfyui:4.1.0-cuda12.4.1` |
| 12.8          | 2.10.0 | 0.0.34       | `ghcr.io/ashleykleynhans/runpod-worker-comfyui:4.1.0-cuda12.8.1` |

### Building Yourself

The image is built with `docker buildx bake` against the targets in
[`docker-bake.hcl`](../docker-bake.hcl), which set the correct
CUDA / torch / xformers / Python versions for each variant. Plain
`docker build` will not produce the same image because it won't pick
up these build args.

```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/runpod-worker-comfyui.git
cd runpod-worker-comfyui

# Build both CUDA targets
docker buildx bake

# Or build a single target
docker buildx bake cuda124
docker buildx bake cuda128
```

The default tags are
`docker.io/ashleykza/runpod-worker-comfyui:<release>-cuda<cuda_version>`.
To push to your own registry, override `REGISTRY` and `REGISTRY_USER`
(see [`docker-bake.hcl`](../docker-bake.hcl) for all overridable
variables) and add `--push`:

```bash
docker login
REGISTRY=docker.io REGISTRY_USER=your-username \
  docker buildx bake --push
```

If you're building on an M1 or M2 Mac, there will be an architecture
mismatch because they are `arm64`, but Runpod runs on `amd64`
architecture. Force the target platform with `--set`:

```bash
docker buildx bake --set "*.platform=linux/amd64" --push
```

### Customizing the Python version

The image defaults to Python `3.10`, which matches the version installed
on a fresh Runpod Pytorch template. To build with a different Python
version, override the `PYTHON_VERSION` variable when running
`docker buildx bake`:

```bash
# Build both CUDA targets with Python 3.11
PYTHON_VERSION=3.11 docker buildx bake

# Build only the CUDA 12.8 target with Python 3.12
PYTHON_VERSION=3.12 docker buildx bake cuda128
```

If you are building the image directly with `docker build` rather than
`bake`, pass the same value as a build arg:

```bash
docker build --build-arg PYTHON_VERSION=3.11 -t dockerhub-username/runpod-worker-comfyui:1.0.0 .
```

Supported versions are whatever the
[deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)
ships for Ubuntu 22.04 (currently `3.10` through `3.13`).

**Important:** the Python version baked into the image must match the
Python version of the ComfyUI venv on your Network Volume. If you change
`PYTHON_VERSION` here, recreate `/workspace/venv` on the Network Volume
with the same interpreter (see
[Install ComfyUI on your Network Volume](installing.md)).
