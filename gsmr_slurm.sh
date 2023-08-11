#----one need to replace input files to make this run
#--to submit a slurm job using gsmr
bfn=YOUR_Plink_File
expogwasfn=YOUR_Exposure_trait_file
outcomegwasfn=YOUR_Outcome_trait_file
outpath=YOUR_output_path
outpref=YOUR_output_prefix
pref=YOUR_slurm_job_name
ldrsq=0.05
gmsrdir=0
eout=YOUR_error_path
memg=100
corNum=8
sbatch --export=bfn=$bfn,expogwasfn=$expogwasfn,outcomegwasfn=$outcomegwasfn,nrow=$nrow,gmsrdir=$gmsrdir,ldrsq=$ldrsq,outpath=$outpath,outpref=$outpref,corNum=$corNum,memg=$memg --job-name=$pref -o ${eout}/${pref}.%j.o -e ${eout}/${pref}.%j.e  --mem=${memg}gb  --time=0-24:00:00 --nodes=1 --cpus-per-task=$corNum gsmr_perexpo.sh

