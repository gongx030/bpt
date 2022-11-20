#' Get bowtie2 alignment rate from error file
#'
get_bowtie2_alignment_rate <- function(job_error_files){
	rs <- sapply(job_error_files, function(f){
		rate <- NA
		if (file.exists(f)){
			x <- scan(f, sep = '\n', what = 'character')
			h <- grepl('^.+\\% overall alignment rate$', x)
			if (any(h)){
				rate <- gsub('(.+)\\% overall alignment rate', '\\1', x[h]) %>% as.numeric()
			}
		}
		rate
	})
	rs
}
