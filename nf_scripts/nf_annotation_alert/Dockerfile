FROM r-base

# Install java and rJava
RUN apt-get -y update && apt-get install -y \
   default-jdk \
   r-cran-rjava \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/

## install synapser
RUN R -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

##install other packages
RUN R -e 'install.packages(c("dplyr","rlang", "mailR"))'

COPY check_for_missing_core_annotations.R /usr/local/bin/check_for_missing_core_annotations.R

RUN chmod a+x /usr/local/bin/check_for_missing_core_annotations.R

ENV PATH="/usr/local/bin:${PATH}"

## Make Docker container executable
ENTRYPOINT ["Rscript", "/usr/local/bin/check_for_missing_core_annotations.R"]

