connectivity_plotter <- function(mask, corr_frame, anat_data, seed, plane){
  #SAGITTAL
  if (plane == "S"){
    plane_name <- "Sagittal"
    seed_slice <- anat_data[seed$x,,]
    slice_longer <- expand.grid(Y = seq_len(nrow(seed_slice)),
                                Z = seq_len(ncol(seed_slice))) %>%
      mutate(intensity = as.vector(seed_slice))

    #anat_data %>%
    #reshape2::melt()

    mask_new <- as.data.frame(mask) %>% mutate(which_voxel = V4) %>% select(-V4)
    corr_intensity_frame <- inner_join(mask_new, corr_frame) %>% rename(X = dim1,
                                                                        Y = dim2,
                                                                        Z = dim3,
                                                                        correlation = value,
                                                                        ) %>%
      mutate(abs_corr = ifelse(is.na(correlation),0, abs(correlation)))

    slice_corr_intensity <- corr_intensity_frame %>% filter(X == seed$x) %>%
      #mutate(correlation = ifelse(abs(correlation) < 0.5, NA_real_, correlation)) %>%
      inner_join(.,slice_longer, by=join_by(Y,Z))


    plot <- ggplot() +
      geom_tile(data = slice_corr_intensity, aes(x = Y, y = Z, fill = intensity)) +
      scale_fill_gradient(low = "black", high = "white") + guides(fill = "none") +
      new_scale_fill() +
      geom_tile(data=slice_corr_intensity, aes(x=Y, y=Z, fill = correlation,
                                               alpha = abs_corr)) +
      scale_fill_viridis_c(option = "plasma") + guides(alpha = "none") +
      annotate("point", x = seed$y, y = seed$z,
               color = "red", size = 3) +
      coord_equal() + labs(title = paste0("Whole-brain seed connectivity",
                                          " (", plane_name, ")"))
  }
  #CORONAL
  if (plane == "C"){
    plane_name <- "Coronal"
    seed_slice <- anat_data[,seed$y,]
    slice_longer <- expand.grid(X = seq_len(nrow(seed_slice)),
                                Z = seq_len(ncol(seed_slice))) %>%
      mutate(intensity = as.vector(seed_slice))

    mask_new <- as.data.frame(mask) %>% mutate(which_voxel = V4) %>% select(-V4)
    corr_intensity_frame <- inner_join(mask_new, corr_frame) %>% rename(X = dim1,
                                                                        Y = dim2,
                                                                        Z = dim3,
                                                                        correlation = value) %>%
      mutate(abs_corr = ifelse(is.na(correlation),0, abs(correlation)))
    
    slice_corr_intensity <- corr_intensity_frame %>% filter(Y == seed$y) %>%
      inner_join(.,slice_longer, by=join_by(X,Z))


    plot <- ggplot() +
      geom_tile(data = slice_corr_intensity, aes(x = X, y = Z, fill = intensity)) +
      scale_fill_gradient(low = "black", high = "white") + guides(fill = "none") +
      new_scale_fill() +
      geom_tile(data=slice_corr_intensity, aes(x=X, y=Z, fill = correlation,
                alpha = abs_corr)) +
      scale_fill_viridis_c(option = "plasma") + guides(alpha = "none") +
      annotate("point", x = seed$x, y = seed$z,
               color = "red", size = 3) +
      coord_equal() + labs(title = paste0("Whole-brain seed connectivity",
                                          " (", plane_name, ")"))
  }
  #AXIAL
  if (plane == "A"){
    plane_name <- "Axial"
    seed_slice <- anat_data[,,seed$z]
    slice_longer <- expand.grid(X = seq_len(nrow(seed_slice)),
                                Y = seq_len(ncol(seed_slice))) %>%
      mutate(intensity = as.vector(seed_slice))

    mask_new <- as.data.frame(mask) %>% mutate(which_voxel = V4) %>% select(-V4)
    corr_intensity_frame <- inner_join(mask_new, corr_frame) %>% rename(X = dim1,
                                                                        Y = dim2,
                                                                        Z = dim3,
                                                                        correlation = value) %>%
      mutate(abs_corr = ifelse(is.na(correlation),0, abs(correlation)))
    
    slice_corr_intensity <- corr_intensity_frame %>% filter(Z == seed$z) %>%
      inner_join(.,slice_longer, by=join_by(X,Y))


    plot <- ggplot() +
      geom_tile(data = slice_corr_intensity, aes(x = X, y = Y, fill = intensity)) +
      scale_fill_gradient(low = "black", high = "white") + guides(fill = "none") +
      new_scale_fill() +
      geom_tile(data=slice_corr_intensity, aes(x=X, y=Y, fill = correlation,
                alpha = abs_corr)) +
      scale_fill_viridis_c(option = "plasma") + guides(alpha = "none") +
      annotate("point", x = seed$x, y = seed$y,
               color = "red", size = 3) +
      coord_equal() + labs(title = paste0("Whole-brain seed connectivity",
                                          " (", plane_name, ")"))
  }
  return(plot)
}
  slice_plotter <- function(img, plane, slice_ind){
  dim_img <- dim(img)
  if(plane == "S"){
    if (slice_ind > dim_img[1]){
      stop("Slice index must not exceed maximum slice index for sagittal plane")
    } else {
      single_slice <- img[slice_ind,,]
      single_slice_longer <- expand.grid(X = seq_len(nrow(single_slice)),
                                         Y = seq_len(ncol(single_slice))
      )
      plottable_slice <- single_slice_longer %>% mutate(value = as.vector(single_slice))

      slice_plot <- ggplot(plottable_slice, aes(X, Y, fill = value)) +
        geom_tile() + theme_void() + scale_fill_gradient(
          low = "black",
          high = "white"
        )
      slice_plot
    }
  }else if (plane == "C"){
    if (slice_ind > dim_img[2]){
      stop("Slice index must not exceed maximum slice index for coronal plane")
    } else {
      single_slice <- img[,slice_ind,]
      single_slice_longer <- expand.grid(X = seq_len(nrow(single_slice)),
                                         Y = seq_len(ncol(single_slice))
      )
      plottable_slice <- single_slice_longer %>% mutate(value = as.vector(single_slice))

      slice_plot <- ggplot(plottable_slice, aes(X, Y, fill = value)) +
        geom_tile() + theme_void() + scale_fill_gradient(
          low = "black",
          high = "white"
        )
      slice_plot
    }
  } else if (plane == "A"){
    if (slice_ind > dim_img[3]){
      stop("Slice index must not exceed maximum slice index for axial plane")
    } else {
      single_slice <- img[,,slice_ind]
      single_slice_longer <- expand.grid(X = seq_len(nrow(single_slice)),
                                         Y = seq_len(ncol(single_slice))
      )
      plottable_slice <- single_slice_longer %>% mutate(value = as.vector(single_slice))

      slice_plot <- ggplot(plottable_slice, aes(X, Y, fill = value)) +
        geom_tile() + theme_void() + scale_fill_gradient(
          low = "black",
          high = "white"
        )
      slice_plot
    }
  } else {
    stop("Plane must be S for Sagittal images, C for coronal images, or A for Axial images")
  }
}

