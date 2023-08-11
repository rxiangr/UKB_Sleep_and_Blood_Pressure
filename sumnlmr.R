library(data.table)
library(SUMnlmr)
library(ggplot2)


#---read in data
phedt <- fread('YOUR_full_file_path_to_Phenotype_data') #should at least contain 2 columns per individual: 1 is a column of phenotype value for exposures and 2 is a column of values for outcomes
genodt <- fread('YOUR_full_file_path_to_Genotype_data') #Should contain a 012 genotype matrix with at least 1 SNP data
covdemat <- fread('YOUR_full_file_path_to_Covariates_data')
outpath <- 'YOUR_outpath'
outpref <- 'YOUR_prefix_of_output'
x <- 'name_of_variable_of_exposure'
y <- 'name_of_variable_of_outcome'
nq <- 'YOUR_choice_of_N_of_strata'

#---note: phedt, genodt and covdemat should all be in the same order (sorted the same order for individuals)
#---note: genodt is a single SNP genotype or polygenic risk score (PRS) matrix as nlmr only allows one SNP or a single vector of PRS for this analysis

summ_data <- create_nlmr_summary(y = unlist(phedt[[y]]),x = unlist(phedt[[x]]),g = genodt,
covar = covdemat,family = "gaussian", strata_method = "ranked",q = nq)
#---fit the model
model<- with(summ_data$summary, frac_poly_summ_mr(bx=bx, by=by, bxse=bxse, byse=byse, xmean=xmean,
                  family="gaussian", fig=TRUE))
summary(model)

pngn <- paste0(outpath,'/',outpref,'.nlmr_dbrk.scatt.png')
plot1 <- model$figure+   labs(x=x,y=y)
png(pngn,500,400)
plot1
dev.off()

#---save data
model$p_tests1 <- ifelse(model$p_tests>0.0001,round(model$p_tests,4),signif(model$p_tests, digits=2))
pdt1 <- data.frame(fn=outpref,model$p_tests1)
write.table(pdt1,paste0(outpath,'/',outpref,'.pval.txt'),row.names=F,quote=F,sep='\t')
cat(paste0('Results table saved to ',outpath,'/',outpref,'.pval.txt'),'\n')

#---save plot data
saveRDS(model$figure,paste0(outpath,'/',outpref,'.nlmr_dbrk.rdata'))
cat(paste0('Plot rdata saved to ',outpath,'/',outpref,'.nlmr_dbrk.rdata'),'\n')

#---save lace data
lacedt <- setDT(data.frame(model$lace),keep.rowname='stratum')
write.table(lacedt,paste0(outpath,'/',outpref,'.lace.txt'),row.names=F,quote=F,sep='\t')
cat(paste0('LACE results table saved to ',outpath,'/',outpref,'.lace.txt'),'\n')


