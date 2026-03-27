library(here)
library(RNifti)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggnewscale)
source("source/visualization_functions.R")

here::i_am("source/02_visualize_data_550fp.R")

#install.packages("ggplot2", repos = "https://cloud.r-project.org")
#install.packages("ggnewscale", repos = "https://cloud.r-project.org")

brain_mask_path <- here("output", "brain_mask.rds")
seed_path <- here("output", "seed.rds")
seed_ts_path <- here("output", "seed_ts.rds")
corr_frame_path <- here("output", "corr_frame.rds")
voxel_rank_path <- here("output", "voxel_ranks.rds")

brain_mask <- readRDS(
  brain_mask_path
)

select_seed_voxel <- readRDS(
  seed_path
)

seed_time_series <- readRDS(
  seed_ts_path
)

corr_frame <- readRDS(
  corr_frame_path
)

highest_correlation_voxels <- readRDS(
  voxel_rank_path
)

k <- 31

# need a long data frame with columns for voxel #, bold value at time t,
# and correlation with seed
long_correlation_frame <- highest_correlation_voxels %>%
  setNames(corr_frame$which_mask_voxel[1:k]) %>%
  pivot_longer(cols = everything(),
               names_to = "Voxel") %>%
  mutate(Voxel = as.numeric(Voxel)) %>%
  arrange(Voxel) %>%
  left_join(corr_frame,
            by = join_by(Voxel == which_mask_voxel)) %>%
  group_by(Voxel) %>%
  mutate(time = row_number()) %>%
  rename("BOLD Intensity" = value.x,
         "Correlation" = value.y) %>%
  select(-which_voxel) %>% mutate(source = "Voxel")



### Plot seed time series along with other ###

nt <- length(seed_time_series)

seed_frame <- as_tibble(seed_time_series) %>% mutate(time = seq_len(nt),
                                                     source = "Seed") %>%
              rename("BOLD Intensity" = value)


bold_lineplot <- ggplot(
                  long_correlation_frame,
                  aes(
                    x = time,
                    y = `BOLD Intensity`,
                    group = Voxel,
                    alpha = Correlation,
                    color = source
                  )
                ) +
                  geom_line() +
                  geom_line(
                    data = seed_frame,
                    aes(x = time, y = `BOLD Intensity`, color = source),
                    linewidth = 1,
                    inherit.aes = FALSE
                  ) +
                  scale_color_manual(
                    values = c("Voxel" = "red", "Seed" = "black"),
                    name = NULL
                  ) +
                  labs(title = paste(k-1, "most correlated voxels with seed voxel"),
                       x = "Scanned brain volumes across time")

lineplot_path <- here("output", "BOLD_lineplot.png")

ggsave(
  lineplot_path,
  bold_lineplot
)

### Plot only anatomical brain ###

# sagittal_anatomical_plot <-slice_plotter(img = anatomical_data,
#                                          plane = "S",
#                                          slice_ind = select_seed_voxel$x)
#
# coronal_anatomical_plot <-slice_plotter(img = anatomical_data,
#                                          plane = "C",
#                                          slice_ind = select_seed_voxel$y)
#
# axial_anatomical_plot <-slice_plotter(img = anatomical_data,
#                                         plane = "A",
#                                         slice_ind = select_seed_voxel$y)

### Plot anatomical brain with correlation based heatmap ###
anatomical_file_path <- here("data", "sub-001_T1w.nii", "sub-001_T1w.nii")
anatomical_data <- readNifti(anatomical_file_path)

sagittal_connectivity_plot <- connectivity_plotter(mask = brain_mask,
                                corr_frame = corr_frame,
                                anat_data = anatomical_data,
                                seed = select_seed_voxel,
                                plane = "S")

coronal_connectivity_plot <- connectivity_plotter(mask = brain_mask,
                                                   corr_frame = corr_frame,
                                                   anat_data = anatomical_data,
                                                   seed = select_seed_voxel,
                                                   plane = "C")

axial_connectivity_plot <- connectivity_plotter(mask = brain_mask,
                                                corr_frame = corr_frame,
                                                anat_data = anatomical_data,
                                                seed = select_seed_voxel,
                                                plane = "A")
# plot paths

sagittal_connectivity_plot_path <- here("output", "sag_con_plot.png")
coronal_connectivity_plot_path <- here("output", "cor_con_plot.png")
axial_connectivity_plot_path <- here("output", "ax_con_plot.png")

ggsave(
  sagittal_connectivity_plot_path,
  sagittal_connectivity_plot
)

ggsave(
  coronal_connectivity_plot_path,
  coronal_connectivity_plot
)

ggsave(
  axial_connectivity_plot_path,
  axial_connectivity_plot
)
