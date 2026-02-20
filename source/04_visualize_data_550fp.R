#install.packages("ggplot2", repos = "https://cloud.r-project.org")
#install.packages("ggnewscale", repos = "https://cloud.r-project.org")

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
# call plots
sagittal_connectivity_plot
coronal_connectivity_plot
axial_connectivity_plot

