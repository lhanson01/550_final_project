here::i_am("source/04_render_report.R")

rmarkdown::render(
  here::here("final_report.qmd"),
  knit_root_dir = here::here()
)
