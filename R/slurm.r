#' slurm_write_r 
#'
#' Write the accompany R script fot the Slurm sript
#'
#' @param id job id
#' @param dir directory for saving the output R script
#' @param r_command R command in string
#'
#' @export
#'
slurm_write_r <- function(id, dir = '.', r_command){

	if (missing(id))
		stop('id must be specified')

	if (!file.exists(dir))
		dir.create(dir)

	r_command <- sprintf("
#
rm(list=ls())

%s

sessionInfo()
warnings()
", r_command)

	r_file <- sprintf('%s/%s.r', dir, id)

	sprintf('writing %s', r_file) %>% message()

	cat(gsub('__file', sprintf('"%s"', id), r_command), file = r_file)

} # slurm_write_r


#' slurm_write_script
#'
#' Write Slurm script
#' 
#' @param id job id
#' @param dir directory for saving the output R script
#' @param partition Slurm partition
#' @param conda Conda environment
#' @param nodes Number of required nodes
#' @param tasks Number of required tasks
#' @param wd the working directory
#' @param walltime Walltime for the job
#' @param type Script type
#' @param gpu Number of required GPUs
#' @param command Command (only for bash jobs)
#
#' @export
#'
slurm_write_script <- function(
	id = NA, 
	dir = '.', 
	partition = 'small',
	conda = 'r',
	nodes = 1, 
	tasks = 1, 
	wd = '.', 
	walltime = '24:00:00',
	type = 'r',
	gpu = 2,
	command = NULL
){

	if (missing(id))
		stop('id must be specified')

	script_file <- sprintf('%s/%s.sh', dir, id)

	sprintf('writing %s', script_file) %>% message()

	if (!file.exists(dir)){
		message(sprintf('create dir: %s', dir))
		dir.create(dir, recursive = TRUE)
	}

	pmem <- c(
		'small' = 2500,
		'ram256g' = 10000
	) # in Mb

	if (partition %in% c('small', 'ram256g')){

		mem <- sprintf('%.0f', pmem[partition] * tasks / 1000)

		cat(sprintf("#!/bin/bash -l
#SBATCH --nodes=%d
#SBATCH --time=%s
#SBATCH --ntasks=%d
#SBATCH --mem=%sgb
#SBATCH --partition=%s
#SBATCH --output %s.out
#SBATCH --output %s.err

source $HOME/.bashrc
conda activate %s 
cd %s
", nodes, walltime, tasks, mem, partition, id, id, conda, wd), file = script_file)

	}else if(partition %in% c('k40')){

		pmem <- 5000
		mem <- sprintf('%.0f', pmem * tasks / 1000)

		cat(sprintf("#!/bin/bash -l
#SBATCH --nodes=%d
#SBATCH --time=%s
#SBATCH --ntasks=%d
#SBATCH --mem=%sgb
#SBATCH --partition=%s
#SBATCH --gres=gpu:k40:%d
#SBATCH --output %s.out
#SBATCH --output %s.err

source $HOME/.bashrc
conda activate %s 
cd %s
", nodes, walltime, tasks, mem, partition, gpu, id, id, conda, wd), file = script_file)

	}else if(partition %in% c('v100')){

		pmem <- 15000
		mem <- sprintf('%.0f', pmem * tasks / 1000)

		cat(sprintf("#!/bin/bash -l
#SBATCH --nodes=%d
#SBATCH --time=%s
#SBATCH --ntasks=%d
#SBATCH --mem=%sgb
#SBATCH --partition=%s
#SBATCH --gres=gpu:v100:%d
#SBATCH --output %s.out
#SBATCH --output %s.err

source $HOME/.bashrc
conda activate %s 
cd %s
", nodes, walltime, tasks, mem, partition, gpu, id, id, conda, wd), file = script_file)

	}else
		stop(sprintf('unknown partition: %s', partition))

	if (type == 'r'){
		r_file <- sprintf('%s/%s.r', dir, id)
		stopifnot(file.exists(r_file))

		cat(sprintf("
$HOME/.conda/envs/%s/bin/Rscript %s
", conda, r_file), file = script_file, append = TRUE)

	}else if (type == 'bash'){

		cat(sprintf("
%s
", command), file = script_file, append = TRUE)

	}else
		stop(sprintf('unknown type:%s', type))

} # slurm_write_script
