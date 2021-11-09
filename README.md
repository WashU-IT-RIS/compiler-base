# Compiler Base

These images have been developed as working examples to aid in demonstrating how to
build and leverage compilers using Docker.

Image Location: `us.gcr.io/ris-appeng-shared-dev/intel-base`

Versions Available:
- Tags:
  - latest, oneapi2021.1.1_centos7

## Build oneapi2021.1.1_centos7 Image
1. Clone this repo.
   ```bash
   git clone ssh://git@bitbucket.wustl.edu:2222/risdev/compiler-base.git
   ```
2. Change directory.
   ```bash
   cd /compiler-base
   ```
3. Copy oneapi.
   ```bash
   cp -r /scratch1/fs1/ris/application/intel/oneapi/ .
   chmod 755 -R oneapi/
   ```
4. Create Docker image. Replace `<IMAGE_NAME>:<TAG>` with that of your choosing.
   ```bash
   docker build --tag <IMAGE_NAME>:<TAG> -f Dockerfile.oneapi2021.1.1_centos7 .
   ```
5. Push the Docker image.
   ```bash
   docker push <IMAGE_NAME>:<TAG>
   ```

## Compile Using oneapi2021.1.1_centos7 Base Image
1. Connect to the compute client.
   ```bash
   ssh <wustlkey>@compute1-client-1.ris.wustl.edu
2. Run on LSF, mounting the necessary storage allocation(s) for use.
   ```bash
   LSF_DOCKER_VOLUMES="/scratch1/fs1/ris/application/intel/oneapi/:/opt/intel/oneapi" \
   bsub -Is -q general-interactive -a 'docker(us.gcr.io/ris-appeng-shared-dev/intel-base:oneapi2021.1.1_centos7)' \
   /bin/bash
   ```
3. Set up the Intel environment.
   ```bash
   . /opt/intel/oneapi/setvars.sh
   ```
4. Compile code.

## Extend oneapi2021.1.1_centos7 Base Image

### Multi Stage Build: Compile, Keep Only Binaries
Create a new image containing:
* Stage 1:
  * Base OS,
  * Intel compiler,
  * Additional build dependencies,
  * Source code,
  * Resulting binaries.
* Stage 2:
  * Runtime OS,
  * Runtime dependencies,
  * Binaries.

Leveraging this method of build results in only Stage 2 contents and explicitly defined portions of Stage 1
to exist in the final image. In leaving the rest of Stage 1 behind, a far smaller image is created, thereby
reducing computing time/resources/cost, image storage cost and allowing the user to withhold source code from
public consumption.

1. Create a new Dockerfile.
   ```bash
   # Begin Stage 1 with the base compiler image.
   FROM us.gcr.io/ris-appeng-shared-dev/intel-base:oneapi2021.1.1_centos7 as build

   # Add any additional build dependencies here.

   # copy source code to a new location inside the container.
   COPY /path/to/source/code /opt/app_name/src

   # Change directory to location of source code,
   # set up the Intel environment,
   # compile,
   # copy binary to standard location.
   RUN cd /opt/app_name/src/ && \
      . /opt/intel/oneapi/setvars.sh && \
      make && \
      cp -f example.binary /usr/local/bin

   # Begin Stage 2 with a new base image.
   FROM centos:7

   # Copy only the needed parts of Stage 1.
   COPY --from=build /usr/local/bin/example.binary /usr/local/bin
   COPY --from=build /usr/local/lib /usr/local/lib
   COPY --from=build /usr/local/include /usr/local/include

   # Add any additional runtime dependencies here.

   # Set up MLNX_OFED driver.
   ENV MOFED_VERSION 4.9-2.2.4.0
   ENV OS_VERSION rhel7.7
   ENV PLATFORM x86_64
   RUN wget -q http://content.mellanox.com/ofed/MLNX_OFED-${MOFED_VERSION}/MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}.tgz && \
      tar -xvf MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}.tgz && \
      MLNX_OFED_LINUX-${MOFED_VERSION}-${OS_VERSION}-${PLATFORM}/mlnxofedinstall --user-space-only --without-fw-update -q  --distro ${OS_VERSION} && \
      cd .. && \
      rm -rf ${MOFED_DIR} && \
      rm -rf *.tgz
   ```
2. Create Docker image and push to a chosen registry. Refer to
   [ How To Build/Push on the Compute Cluster](https://docs.ris.wustl.edu/doc/compute/recipes/docker-on-compute.html#build-images-using-compute)
   for guidance.

### Single Stage Build: Compile, Keep Source Code and Binaries
Create a new image containing:
* Base OS,
* Intel compiler,
* Additional dependencies,
* Source code,
* Resulting binaries.

This method of build can result in a very large final image (consider the base compiler image alone is 24.7GB).
A large image may result in increased computing time/resources/cost, image storage cost, etc. This method also
caches the source code in build layers resulting in public exposure which may be unwanted.

1. Create a new Dockerfile.
   ```bash
   FROM us.gcr.io/ris-appeng-shared-dev/intel-base:oneapi2021.1.1_centos7

   # Add any additional build dependencies here.

   # copy source code to a new location inside the container
   COPY /path/to/source/code /opt/app_name/src

   # Change directory to location of source code,
   # set up the Intel environment,
   # compile.
   RUN cd /opt/app_name/src/ && \
      . /opt/intel/oneapi/setvars.sh && \
      make
   ```
2. Create Docker image and push to a chosen registry. Refer to
   [ How To Build/Push on the Compute Cluster](https://docs.ris.wustl.edu/doc/compute/recipes/docker-on-compute.html#build-images-using-compute)
   for guidance.

## References
