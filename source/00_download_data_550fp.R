#install.packages("here")
#install.packages("RNifti", repos = "https://cloud.r-project.org")
#install.packages("tidyverse", repos = "https://cloud.r-project.org")
library(tidyverse)
library(here)
library(RNifti)

# download anatomical brain MRI for creating mask/plotting
anatomical_file_path <- here("data", "sub-001_T1w.nii", "sub-001_T1w.nii")
anatomical_data <- readNifti(anatomical_file_path)

# download functional MRI
functional_file_path <- here("data", "shortened_fMRI_data.nii")
functional_image_data <- readNifti(functional_file_path, internal = T)
