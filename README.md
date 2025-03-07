# Compiler Base

These images have been developed as working examples to aid in demonstrating how to
build and leverage compilers using Docker.

Image Location: `ghcr.io/washu-it-ris/compiler-base`

Versions Available:
- Tags:
  - ubuntu22-mofed5.8-oneapi2025, latest
  - ubuntu22-mofed5.8-oneapi2021

## Build ubuntu22-mofed5.8-oneapi2025 Image
1. Clone this repo.
   ```bash
   git clone ssh://git@github.com/WashU-IT-RIS/compiler-base.git
   ```
2. Change directory.
   ```bash
   cd /compiler-base
   ```
3. Create Docker image. Replace `<IMAGE_NAME>:<TAG>` with that of your choosing.
   ```bash
   docker build --tag <IMAGE_NAME>:<TAG> -f Dockerfile .
   ```
4. Push the Docker image.
   ```bash
   docker push <IMAGE_NAME>:<TAG>
   ```

## Compile Using ubuntu22-mofed5.8-oneapi2025 Base Image
1. Connect to the compute client.
   ```bash
   ssh <wustlkey>@compute1-client-1.ris.wustl.edu
2. Run on LSF, mounting the necessary storage allocation(s) for use.
   ```bash
   LSF_DOCKER_NETWORK=host \
   LSF_DOCKER_IPC=host \
   bsub -n 20 -Is -q general-interactive \
   -R "affinity[core(1):distribute=pack] span[ptile=4]" \
   bsub -Is -q general-interactive -a 'docker(ghcr.io/washu-it-ris/compiler-base:ubuntu22-mofed5.8-oneapi2025)' \
   /bin/bash
   ```
3. Set up the environment.
   ```bash
   source /etc/bashrc
   ```
4. Compile code.

## References
