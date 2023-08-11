library(data.table)
library(MendelianRandomization)

smrresfn <- 'YOUR_SNP_effect_file'
outpath <- 'YOUR_output_path'
outpref <- 'YOUR_outout_prefix'

effdt <- fread('YOUR_file_path_to_SNP_effect_file')
#---note: effdt at least has the following columns: 1. SNP beta on x (exposure); 2. standard error of SNP beta on x; 3. SNP beta on y (outcome); 4. standard error of SNP beta on y.
#for function mr_input, bx is 1, bxse is 2, by is 3 and byse is 4; in my case, these values correspond to b.x, se.xm b.y and se.y, respectively.

MRInputObject <- mr_input(bx =effdt$b.x,bxse =effdt$se.x, by =effdt$b.y, byse =effdt$se.y)
EggerObject <- mr_egger(MRInputObject,distribution = "normal")
WeightedMedianObject <- mr_median(MRInputObject,weighting = "weighted",distribution = "normal",alpha = 0.05,iterations = 10000,seed = 314159265)
eggerres <- data.frame(fn=outpref,method='egger',b=EggerObject$Estimate,se=EggerObject$StdError.Est,p=EggerObject$Pvalue.Est,nSNP=EggerObject$SNPs)
wmerres <- data.frame(fn=outpref,method='wm',b=WeightedMedianObject$Estimate,se=WeightedMedianObject$StdError,p=WeightedMedianObject$Pvalue,nSNP=WeightedMedianObject$SNPs)
cbres <- setDT(rbind(eggerres,wmerres))
cbres[,b:=round(b,3)]
cbres[,se:=round(se,3)]
cbres[,p:=ifelse(p>1e-4,round(p,4),p)]
write.table(cbres,paste0(outpath,'/',outpref,'.table.txt'),row.names=F,quote=F,sep='\t')

