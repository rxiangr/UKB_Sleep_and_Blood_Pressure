library(data.table)
library(PolyMR)
library(ggplot2)


#---read in data
phedt <- fread('YOUR_full_file_path_to_Phenotype_data') #should at least contain 2 columns per individual: 1 is a column of phenotype value for exposures and 2 is a column of values for outcomes
genodt <- fread('YOUR_full_file_path_to_Genotype_data') #Should contain a 012 genotype matrix with at least 1 SNP data
outpath <- 'YOUR_outpath'
x <- 'name_of_variable_of_exposure'
y <- 'name_of_variable_of_outcome'

#---note that phedt and genodt need to be matched (sorted in the same order of individuals)
#---also note that before analysis, phenotypic values in phedt are corrected for fixed effects and scaled to have mean of 0 and SD of 1.

#---do lables (assuming blppd pressure and sleep hours)
ylab <- paste0('Outcome: ',gsub('_adjusted','',y),' (covar-atjusted, mmHg)')
xlab <- paste0('Exposure: ',x,' (Hours)')

#---assume the 1st column in phedt is the exporue and 2nd column in phedt is outcome, no ID column in genodt
polymr_res <- polymr(phedt[,1], phedt[,2], as.matrix(genodt))
summary(polymr_res$polymr)
pngn <- paste0(outpath,'/',x,'_VS_',y,'.scatt.png')
png(pngn,500,400)
print(plot_polymr(polymr_res,show_binned_observations = F,scale_values=F,xlab=xlab,ylab=ylab))
dev.off()
cat(paste0('plot saved to ',pngn,' at ',Sys.time()),'\n')
#---save r data
saveRDS(polymr_res,paste0(outpath,'/',x,'_VS_',y,'.rdata'))

