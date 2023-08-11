#!/bin/bash
#SBATCH --job-name=gctagwas
#SBATCH --mail-type=FAIL                          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ruidong.xiang@baker.edu.au    # Where to send mail
#SBATCH --ntasks=1                                # Run a single task
#SBATCH --cpus-per-task=1                         # Run on a single or multiple CPUs
#SBATCH --nodes=1                                 # Run on a single Node
#SBATCH --mem=60gb                                # Job memory request
#SBATCH --time=100:00:00                          # Time limit hrs:min:sec
#SBATCH --error=%x.%j.err
#SBATCH --output=%x.%j.out

#---create some tmp directories
tmppath=/sysgen/workspace/users/rxiang/tmp
nodeDir=`mktemp -d $tmppath/smrXXXXXX`
#binDir=/usr/local/bin/

echo "SLURM_JOBID="$SLURM_JOBID
echo "SLURM_JOB_NODELIST"=$SLURM_JOB_NODELIST
echo "SLURM_NNODES"=$SLURM_NNODES
echo "SLURMTMPDIR="$nodeDir
echo "working directory = "$SLURM_SUBMIT_DIR

echo "Job of $pref started at"|paste -d ' ' - <(date)

#==========
cd $nodeDir
#==========


#---run gsmr
/home/rxiang/gcta-1.94.1 --bfile $bfn --gsmr-file $expogwasfn $outcomegwasfn --gsmr-direction $gmsrdi  --clump-r2 $ldrsq  --out $outpath/$outpref --thread-num $corNum --effect-plot --gsmr-snp-min 1
if [ $? -gt 0 ]; then
    echo "ERROR; Failed to run gcta gsmr on compute node"
    exit 1
fi

#---remove tmp files
cd ..
rm -r $nodeDir


