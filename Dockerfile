FROM lcolling/r-verse-base:latest

# Use clang to compile Stan
# Using the default g++ causes memory issues
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    clang

RUN apt-get install -y --no-install-recommends libudunits2-dev
RUN apt-get install -y --no-install-recommends libgdal-dev
RUN apt-get update && apt-get install -y --no-install-recommends libv8-dev

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a makevars file and install rstan from source
# following the instructions at https://github.com/stan-dev/rstan/wiki/Installing-RStan-on-Linux
# Install remaining R packages using specific versions (latest as of February 2021 or using specific commits on Github)
RUN R -e "options(repos = \
  list(CRAN = 'https://mran.revolutionanalytics.com/snapshot/2021-02-01/')); \
  dotR <- file.path(Sys.getenv('HOME'), '.R'); \
  if (!file.exists(dotR)) dir.create(dotR); \
  M <- file.path(dotR, 'Makevars'); \
  if (!file.exists(M)) file.create(M); \
  cat('\nCXX14FLAGS=-O3 -march=native -mtune=native -fPIC', \
  'CXX14=clang++', \
  file = M, sep = '\n', append = TRUE); \
  install.packages('rstan', type = 'source'); \
  install.packages('remotes'); \
  install.packages('brms'); \
  install.packages('here'); \
  install.packages('tidybayes'); \
  install.packages('xfun'); \
  install.packages('mgcv'); \
  install.packages('prophet'); \
  install.packages('pbapply'); \
  install.packages('ggplot2'); \
  install.packages('viridis'); \
  install.packages('reshape'); \
  remotes::install_github('nicholasjclark/mvforecast', dependencies = TRUE); \
  remotes::install_github('asael697/varstan@5378f428cad9560dae7f6daf8f431113f19a2019', dependencies = TRUE)"

CMD [ "R" ]
