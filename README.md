# Code used for data processing, linear regression and Mendelian Randomisation (MR) for analysis of sleep disruptions and blood pressure in the UK Biobank

These codes are for the paper "Poor sleep and shift work associate with increased blood pressure and inflammation in UK Biobank participants" in Press in Nature Communications. These codes are contributed by Drs. Artika Nath and Ruidong Xiang.

DataPreprocessing_ForLinearRegression_NatureComms.R is used for data processing from the UK Biobank.

LinearRegression_NatureComms.R illustrates the analysis of linear regression between sleep phenotypes and blood pressure.

gsmr_perexpo.sh is a shell script for conducting GSMR on HPC.

gsmr_slurm.sh is a shell script to submit slurm jobs conducting GSMR.

mr_wm_egger.R is a Rscript do conduct Mendelian randomisation (MR) using methods of weighted median and MR-egger.

polymr.R is a Rscript to conduct non-linear MR using software called PolyMR.

sumnlmr.R is a Rscript to conduct non-linear MR using software called SUMnlmr.

In addition:
Linear MR: GSMR (https://yanglab.westlake.edu.cn/software/gsmr/), weighted median and egger (https://cran.r-project.org/web/packages/MendelianRandomization/vignettes/Vignette_MR.pdf).

Non-linear MR: PolyMR (https://github.com/JonSulc/PolyMR) and SUMnlmr (https://github.com/amymariemason/SUMnlmr). 
