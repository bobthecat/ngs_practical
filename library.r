## readBed will read bed files into the specified directory or the local folder (default).
# The output is a list of data.frames containing the bed files
readBed <- function(loc='./'){
	beds <- list()
	listOfFiles <- list.files(path=loc, pattern="*.bed", full.names=TRUE)
	bedNames <- sub("^.*/(.*).bed", '\\1', listOfFiles)
	for(i in 1:length(listOfFiles)){
		print(bedNames[i])
		beds[[bedNames[i]]] <- read.table(listOfFiles[i], col.names=c('chr', 'start', 'stop'))
	}
	return(beds)
}

write.lists <- function(List, file="toto.txt"){
	for(i in 1:length(List)){
		if(i==1){
			write.table(List[[i]], file=file, row.names=FALSE, sep=",", na='')
		}else{
			write.table(List[[i]], file=file, append=TRUE, sep=",", row.names=FALSE, col.names=FALSE, na='')
		}
	}
}

cleanEG <- function(DF){
	eg <- DF$entrezgene	
	eg <- strsplit(as.character(eg), ";")
	# keep only the first one.
	eg <- as.vector(unlist(lapply(eg, function(x) sub(" +", "", x[1]))))
	DF$entrezgene <- eg
	DF
}

addingMissingAnnot <- function(DF){
	idxMissing <- which(is.na(DF$entrezgene))
	print(length(idxMissing))
	if(length(idxMissing)>0){
		# give gene symbol get back gene ID
		x <- mget(DF$external_gene_id[idxMissing], envir=org.Mm.egSYMBOL2EG, ifnotfound=NA)
		if(length(as.vector(unlist(x))) != length(DF$entrezgene[idxMissing])){
			x <- lapply(x, function(y){ifelse(length(y)>1, y[1], y)})	
		}
		DF$entrezgene[idxMissing] <- as.vector(unlist(x))
	}
	return(DF)
}

biomaRtAnnot <- function(annotatedPeak){
	 addGeneIDs(annotatedPeak, mart=ensembl, 
		IDs2Add=c("external_gene_id","entrezgene"))
}
