#' Get job status
#'
#' @export
#'
get_job_status <- function(job_files){

	stopifnot(!missing(job_files))

	status <- rep('N', length(job_files))

	exist <- file.exists(job_files)
	if (any(exist)){
		status[exist] <- 'E'	# the job file exists
	}

	error_files <- gsub('.sh', '.err', job_files)
	h <- file.exists(error_files)
	status[h] <- sprintf('%s|ERR', status[h])

	out_files <- gsub('.sh', '.out', job_files)
	h <- file.exists(out_files)
	status[h] <- sprintf('%s|OUT', status[h])

  command <- 'squeue --me -o "%.28i %.20P %.40j %.8u %.8T %.10M %.9l %.6D %.6C %R"'
	rs <- system(command, intern = TRUE)

	rs <- do.call('rbind', lapply(strsplit(rs, '\n'), function(r) unlist(strsplit(r, '\\s+'))))
	cn <- rs[1, ]
	rs <- rs[-1, , drop = FALSE]
	colnames(rs) <- cn

	job_names <- gsub('jobs/', '', job_files)
	js <- rs[, 'STATE']
	names(js) <- rs[, 'NAME']

	h <- job_names %in% rs[, 'NAME']
	if (any(h)){
		status[h] <- sprintf('%s|%s', status[h], js[job_names[h]])
	}
	status
}

