FROM lcolling/r-verse-base:latest

# Using clang to compile Stan
# Using the default g++ causes memory issues
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    clang

RUN apt-get install -y --no-install-recommends libudunits2-dev
RUN apt-get install -y --no-install-recommends libgdal-dev

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install_stan.R creates a makevars file and installs rstan from source
# following the instructions at https://github.com/stan-dev/rstan/wiki/Installing-RStan-on-Linux

COPY install_stan.R install_stan.R
RUN ["r", "install_stan.R"]

# install the other packages for brms
RUN install2.r --skipinstalled --error --d TRUE --ncpus -1 \
    brms \
    here \
    tidybayes \
    forecast \
    xfun

CMD [ "R" ]