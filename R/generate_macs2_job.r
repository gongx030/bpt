generate_macs2_job <- function(
	prefix, 
	index, 
	ntasks = 4, 
	pmem = 1900, 
	partition = 'msismall', 
	conda_env = 'base', 
	verbose = FALSE, 
	...
){
  params <- list(...)
  command <- sprintf("#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --ntasks=%d
#SBATCH --mem=%dmb
#SBATCH --partition=%s
#SBATCH --output jobs/%s_%d.out
#SBATCH --output jobs/%s_%d.err

source $HOME/.bashrc
conda activate %s

module load macs/2.1.1
module load kent/2.4.7 # bedGraphToBigWig

cd %s
treatment_file=%s
NAME=%s
bdg_file=${NAME}_treat_pileup.bdg
bw_file=${NAME}_treat_pileup.bw
gsize=%s
shift=%d
extsize=%d
temp_file=$(mktemp)
chrom_sizes=%s

macs2 callpeak -t $treatment_file -f BAMPE -g $gsize -n $NAME --qvalue 0.05 --shift $shift --extsize $extsize --keep-dup 1 --call-summits --nomodel --bdg
LC_COLLATE=C sort -k1,1 -k2,2n $bdg_file > $temp_file
bedGraphToBigWig $temp_file $chrom_sizes $bw_file
rm -f $temp_file
", 
		ntasks, ceiling(pmem * ntasks), partition, prefix, index, prefix, index, conda_env, 
		getwd(), 
		params[['bam_files']], 
		params[['name']],
		params[['gsize']], 
		params[['shift']], 
		params[['extsize']],
		params[['chrom_sizes']]
	)
	  if (verbose){
			command %>% message()
		}
	cat(command, file = params[['job_file']])
	sprintf('writing %s', params[['job_file']]) %>% message()
}

