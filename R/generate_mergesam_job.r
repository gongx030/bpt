generate_mergesam_job <- function(
	prefix, 
	index, 
	ntasks = 1, 
	pmem = 1900, 
	partition = 'msismall', 
	conda_env = 'base', 
	verbose = FALSE, 
	...
){
	params <- list(...)

	index <- as.integer(index)

	input_files <- as.character(params[['input_files']])
	input_files <- strsplit(input_files, ',') %>% unlist()
	stopifnot(all(file.exists(input_files)))
	input_files <- paste(sprintf('I=%s', input_files), collapse = ' ')

	output_file <- params[['output_file']]
	bam_index_file <- gsub('.bam', '.bai', output_file)
	bam_index_file2 <- gsub('.bam', '.bam.bai', output_file)

	stopifnot(!is.null(params[['job_file']]))

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

cd %s
input_files=\"%s\"
output_file=%s
bam_index_file=%s
bam_index2_file=%s

java -Djava.io.tmpdir=$TMPDIR -Xmx2g -jar /panfs/roc/msisoft/picard/2.25.6/picard.jar MergeSamFiles $input_files O=$output_file SORT_ORDER=coordinate TMP_DIR=$TMPDIR CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT CREATE_MD5_FILE=true
ln -s $bam_dedup_index_file $bam_dedup_index2_file # tools like bedtools need index file in bam.bai format

", ntasks, ceiling(pmem * ntasks), partition, prefix, index, prefix, index, conda_env, 
	getwd(), 
	input_files,
	output_file,
	bam_index_file,
	bam_index_file2
)
	if (verbose){
		command %>% message()
	}

	cat(command, file = params[['job_file']])
	sprintf('writing %s', params[['job_file']]) %>% message()
}
