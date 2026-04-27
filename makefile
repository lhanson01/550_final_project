# R_LIBS_USER := C:/Users/whhanso/AppData/Local/R/win-library/4.5

# export R_LIBS_USER



# rule to build image
# $@ evaluates to the target name in make 
# $(<variable>) references a variable in make
########### REPORT GENERATION ##############
X ?= 59
Y ?= 78
Z ?= 59
############ DOCKERHUB CODE ################
# files that if changed, we would want to rebuild image 
#PROJECTFILES = report.Rmd source/* Makefile
#RENVFILES = renv.lock renv/active.R renv/settings.dcf

final_report/final_report.html:  
	docker run -v "/$$(pwd)/final_report":/home/rstudio/final_project/final_report \
	lhanson010/lh_final_project



ANALYSIS_OBJECTS =  output/corr_frame.rds output/voxel_ranks

$(ANALYSIS_OBJECTS): source/01_prep_analyze_data_550fp.R
	Rscript source/01_prep_analyze_data_550fp.R $(X) $(Y) $(Z)
	
FIGURES = output/BOLD_lineplot.png output/sag_con_plot.png \
          output/cor_con_plot.png \
          output/ax_con_plot.png 

$(FIGURES): source/02_visualize_data_550fp.R source/visualization_functions.R
	Rscript source/02_visualize_data_550fp.R
          
output/voxel_table.rds: source/03_make_table.R
	Rscript source/03_make_table.R

.PHONY: all_output
all_output: $(ANALYSIS_OBJECTS) $(FIGURES) output/voxel_table.rds

.PHONY: clean
clean: 
	rm -f output/* final_report/final_report.html
	
.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"
