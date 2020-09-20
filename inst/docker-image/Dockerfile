FROM rocker/rstudio:4.0.2

# common devel dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -yqq && \
    apt-get install -yqq \
      build-essential \
      cloc \
      curl \
      default-jdk \
      flex \
      jags \
      libavfilter-dev \
      libbz2-dev \
      libcairo2-dev \
      libfftw3-dev \
      libgdal-dev \
      libglpk-dev \
      libglu1-mesa-dev \
      libgmp3-dev \
      libgsl-dev \
      libhiredis-dev \
      libjpeg-dev \
      liblzma-dev \
      libmagick++-dev \
      libmysqlclient-dev \
      libmpfr-dev \
      libpcre2-dev \
      libpcre3-dev \
      libpoppler-cpp-dev \
      libpq-dev \
      libreadline-dev \
      librsvg2-dev \
      libsodium-dev \
      libudunits2-dev \
      libv8-dev \
      libwebp-dev \
      libxml2-dev \
      rsync \
      texlive-latex-extra \
      tk-dev \
      tree \
      unixodbc-dev \
      vim \
      wget \
      x11-utils \
      xorg-dev \
      xvfb \
      zlib1g-dev

WORKDIR /R

# bootstrap scripts
ARG RUNR_VERSION="master"
ARG CRAN_MIRROR="cran.r-project.org"

env R_VERSION=4.0.2 \
    R_PROJECT_BASE_DIR=/R

env R_DIR="$R_PROJECT_BASE_DIR/R-$R_VERSION" \
    RDT_DIR="$R_PROJECT_BASE_DIR/R-dyntrace" \
    R_LIBS="$R_PROJECT_BASE_DIR/library/$R_VERSION" \
    PACKAGES_SRC_DIR="$R_PROJECT_BASE_DIR/CRAN/extracted" \
    PACKAGES_ZIP_DIR="$R_PROJECT_BASE_DIR/CRAN/src/contrib" \
    CRAN_MIRROR_LOCAL_DIR="$R_PROJECT_BASE_DIR/CRAN" \
    R_KEEP_PKG_SOURCE=1 \
    R_ENABLE_JIT=0 \
    R_COMPILE_PKGS=0 \
    R_DISABLE_BYTECODE=1 \
    OMP_NUM_THREADS=1 \
    RUNR_GITHUB_URL="https://raw.githubusercontent.com/PRL-PRG/runr/$RUNR_VERSION"

env CRAN_MIRROR_LOCAL_URL="file://$CRAN_MIRROR_LOCAL_DIR"

# R
RUN curl "$RUNR_GITHUB_URL/inst/install-r.sh" | bash -s -- -d "$R_DIR" -v "$R_VERSION"

env PATH=$R_DIR/bin:$PATH

ADD install-cran-packages.sh .

# install our package dependencies
ADD our-packages-dependencies.txt /tmp
RUN nohup Xvfb :6 -screen 0 1280x1024x24 >/dev/null 2>&1 & \
    export DISPLAY=:6 && \
    ./install-cran-packages.sh -l $R_LIBS -m "https://$CRAN_MIRROR" -d $PACKAGES_ZIP_DIR -f /tmp/our-packages-dependencies.txt

ADD packages.txt /tmp
RUN nohup Xvfb :6 -screen 0 1280x1024x24 >/dev/null 2>&1 & \
    export DISPLAY=:6 && \
    ./install-cran-packages.sh -l $R_LIBS -m "https://$CRAN_MIRROR" -d $PACKAGES_ZIP_DIR -f /tmp/packages.txt

RUN mkdir -p "$PACKAGES_SRC_DIR" && \
    ls -1 "$PACKAGES_ZIP_DIR"/*.tar.gz | xargs -L 1 tar -C "$PACKAGES_SRC_DIR" -xzf

# ## The following are dependencies that are too outdated in the package repository

# GNU parallel
RUN mkdir parallel && \
    cd parallel && \
    curl http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2 | tar -xjf- --strip 1 && \
    ./configure && \
    make install && \
    mkdir /root/.parallel && \
    touch /root/.parallel/will-cite && \
    mkdir /home/rstudio/.parallel && \
    touch /home/rstudio/.parallel/will-cite

# tooling

ARG INJECTR_VERSION=HEAD
RUN git clone https://github.com/PRL-PRG/injectr && \
    cd injectr && \
    git checkout $INJECTR_VERSION && \
    R CMD INSTALL .

ARG INSTRUMENTR_VERSION=HEAD
RUN git clone https://github.com/PRL-PRG/instrumentr && \
    cd instrumentr && \
    git checkout $INSTRUMENTR_VERSION && \
    R CMD INSTALL .

RUN git clone https://github.com/PRL-PRG/runr && \
    cd runr && \
    git checkout $RUNR_VERSION && \
    R CMD INSTALL .

WORKDIR /

ADD Rprofile.site $R_DIR/etc
# # configure entrypoint
# ADD entrypoint.sh /
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
