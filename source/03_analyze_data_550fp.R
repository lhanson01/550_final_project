# create rudimentary brain mask from anatomical data to reduce computation in analysis

brain_mask <- cbind(which(anatomical_data > 0, arr.ind = TRUE),
                    which(anatomical_data > 0))

# select seed voxel o be correlated with the rest of the brain. We select a voxel of
#the precuneus, a known center of the DMN (https://www.jneurosci.org/content/34/3/932.short)


#set.seed(1000)
#brain_mask_row <- sample(1:nrow(brain_mask),1) # >= 100000 for now
select_seed_voxel <- list(x = 50, # <--- Parameterize
                          y = 38, # <---
                          z = 65) # <---
seed_time_series <- functional_image_data[select_seed_voxel$x,
                                          select_seed_voxel$y,
                                          select_seed_voxel$z,]

nt <- length(seed_time_series)

# find pearson correlation with all other voxels in mask

X <- matrix(NA, nrow = nt, ncol = nrow(brain_mask)) # make matrix t x length of mask obtained from ana

for(i in 1:nt){
  X[i,] <- functional_image_data[,,,i][brain_mask[,4]]
  #grab a whole brain at time i then only take the mask voxels from it
}

rm(functional_image_data)
gc()

s_z <-scale(seed_time_series)
corr_vector <- (1/(nt-1))*t(s_z)%*%scale(X)

#corr_vector_old <- apply(X, MARGIN = 2, function(x){
#  corr <- cor(x, seed_time_series)
#})

corr_frame <- as_tibble(t(corr_vector)) %>%
              mutate(which_voxel = brain_mask[,4],
              which_mask_voxel = row_number(),
              value = ifelse(is.nan(V1), NA_real_, V1)) %>%
              arrange(desc(abs(value)))

# find k largest magnitude corr time series
k <- 31

#### sorted voxels
highest_correlation_voxels <- as.data.frame(X[,corr_frame$which_mask_voxel[seq_len(k)]])

rm(X)
gc()



