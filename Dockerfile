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

RUN R -e "options(repos = \
  list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/${WHEN}')); \
  dotR <- file.path(Sys.getenv('HOME'), '.R'); \
  if (!file.exists(dotR)) dir.create(dotR); \
  M <- file.path(dotR, "Makevars"); \
  if (!file.exists(M)) file.create(M); \
  cat('\nCXX14FLAGS=-O3 -march=native -mtune=native -fPIC', \
  'CXX14=clang++', \
  file = M, sep = '\n', append = TRUE); \
  install.packages('rstan', type = 'source'); \
  install.packages('remotes'); \
  remotes::install_github('asael697/varstan', dependencies = TRUE)"

# install the other packages for brms
RUN install2.r --skipinstalled --error --d TRUE --ncpus -1 \
    brms \
    here \
    tidybayes \
    forecast \
    xfun

CMD [ "R" ]
