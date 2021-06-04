FROM lcolling/r-verse-base:latest

# Install `curl` and `jags` c libraries
RUN apt-get update && apt-get install -y curl 
RUN apt-get update && apt-get install -y jags

RUN apt-get update \
    && apt-get install -y \
       curl \
       jags
       
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

# Create a makevars file and then install rstan from source
# following the instructions at https://github.com/stan-dev/rstan/wiki/Installing-RStan-on-Linux
# Install remaining R packages using specific versions (latest as of Feb 2021, or by indexing specific commits on Github)
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
  install.packages('rjags'); \
  install.packages('reshape'); \
  install.packages('MCMCpack'); \
  install.packages('runjags'); \
  install.packages('here'); \
  install.packages('MCMCglmm'); \
  install.packages('xfun'); \
  install.packages('mgcv'); \
  install.packages('pbapply'); \
  install.packages('ggplot2'); \
  install.packages('ProbReco'); \
  install.packages('remotes'); \
  install.packages('viridis'); \
  remotes::install_github('robjhyndman/forecast@f0965d594a23fa90b3b56152f52f3a5fbc5240e9', dependencies = TRUE); \
  remotes::install_github('tsmodels/tsmethods@16601e3bd21d7293490d820137324e4f16462dbf', dependencies = TRUE); \
  remotes::install_github('tsmodels/tsaux@da46a751c619ba10184f0749ccd7d9fb9a7be31f', dependencies = TRUE); \
  remotes::install_github('tsmodels/tsets@51a26d80fdfafc41d564d08a38fe4c9776ba333f', dependencies = TRUE); \
  remotes::install_github('tsmodels/tsvets@7bea965911ddee0c585199cb380b1299e341273b', dependencies = TRUE); \
  remotes::install_github('nicholasjclark/mvforecast', dependencies = TRUE)"

CMD [ "R" ]
