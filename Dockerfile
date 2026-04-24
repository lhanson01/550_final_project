FROM rocker/tidyverse:4.5.1 as base

RUN mkdir /home/rstudio/final_project
WORKDIR /home/rstudio/final_project

RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

RUN Rscript -e "renv::restore(prompt = FALSE)"

###### DO NOT EDIT STAGE 1 BUILD LINES ABOVE ######

FROM rocker/tidyverse:4.5.1

RUN mkdir /home/rstudio/final_project

WORKDIR /home/rstudio/final_project
COPY --from=base /home/rstudio/final_project .

COPY final_report.qmd .
COPY makefile . 
RUN mkdir data
RUN mkdir source
RUN mkdir output
COPY data/ data/
COPY source/ source/
COPY references.bib .
RUN mkdir final_report

CMD make && mv final_report.html final_report

