get_macs2_n_summits <- function(macs2_summit_files){
	rs <- sapply(macs2_summit_files, function(f){
		n <- NA
		if (file.exists(f)){
			r <- sprintf('wc -l %s', f) %>% system(intern = TRUE)
			n <- gsub('(.+) (.+)', '\\1', r) %>% as.numeric()
		}
		n
	})
	rs
}
