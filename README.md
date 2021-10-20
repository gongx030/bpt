# An R package for managing NGS data analysis on UMN MSI. 

## Generating Slurm script for running R commands
* In the R console: generate R and Slurm scripts:
The Slurm script will request the resource of one CPU, one task, walltime of 1 hour, and run at the `small` queue.  The script will execute at the working dir, and execute under the conda environment `base`. 
```
library(ngsmsi)
r_command <- "
print('hello world')
"
id <- 'my_script'
slurm_write_r(id, dir = '.', r_command)
slurm_write_script(
  id, 
  dir = '.', 
  nodes = 1, 
  tasks = 1, 
  partition = 'small', 
  conda = 'base', 
  wd = '.', 
  walltime = '1:00:00'
 )
```
The previous commands will generate `my_script.r` and `my_script.sh` under the working directory.
* In the terminal: submit Slurm script. 
```
sbatch my_script.sh
```

## Query local SRA database by keyword, download SRA files from NCBI SRA database and dump into fastq files
```
library(ngsmsi)
d <- sra_query('SRR5354462') %>%
  select(run_alias, run, library_strategy, sample_attribute, experiment_title, experiment_attribute, sample_alias)
sra_download(d$run)
sra_dump(d$run)
```

## Common Slurm commands
### Start a non-GPU interactive session with one node, four cores, a total memory of 32GB, walltime of 24 hours with X11 forward. 
```
srun --nodes=1 --ntasks-per-node=4 --mem=32gb -t 24:00:00 -p interactive --x11 --pty bash
```
### Start a GPU required interactive session with one node, one k40 GPU, walltime of 24 hours with X11 forward.  
Since the k40 nodes on mesabi does not support node sharing, we may not need to explicitly specify the `--ntasks-per-node` and `--mem` (?). 
The [website](https://www.msi.umn.edu/queues) indicates that "Users are limited to a single job in the interactive and interactive-gpu partitions. However, it appears that it is OK to establish multiple interactive GPU sessions.
```
srun --nodes=1 -t 24:00:00 -p interactive-gpu --gres=gpu:k40:1 --x11 --pty bash
```
### Delete a job
```
scancel
```

### Show all job information
```
squeue -al 
```

### Show only your job information
```
squeue --me
```

### Show partition status
```
sinfo
```
