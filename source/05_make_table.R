
# Mean correlation for positively correlated voxels, top 5 correlations,
#mean correlation for negatively correlated voxels, top 5 correlations

# Positive  Correlation n: Mean:  Standard Deviation: 
#1          + corr1
#2          + corr2
#3          + corr3
#4          + corr4
#5          + corr5

# Negative Correlation  n: Mean: Standard Deviation: 
#1          - corr1  
#2          - corr2
#3          - corr3
#4          - corr4
#5          - corr5  

voxel_table <-
  corr_frame %>% rename("Correlation" = value) %>%
  mutate(pos_or_neg = ifelse(Correlation > 0, "Positive",
                                            "Negative")) %>%
  filter(!(Correlation %in% c(1,NA))) %>%
    select(pos_or_neg, Correlation) %>%
    tbl_summary(
      by = pos_or_neg,
      statistic = list(Correlation ~ "Mean = {mean} | SD = {sd}"),
      digits = list(Correlation ~ 3)
    ) %>%
  modify_spanning_header(c("stat_1", "stat_2") ~ "**Correlation Sign**") 
  


  