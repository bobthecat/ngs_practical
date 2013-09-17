source('library.r')
library(ChIPpeakAnno)
library(biomaRt)
library(org.Mm.eg.db)
library(doMC)
ncore = multicore:::detectCores()
registerDoMC(cores = ncore)

## If help is needed
# vignette('ChIPpeakAnno')

## Folder containing the bed files
loc <- "bed"

## reading all the bed files
# output: a list of data.frame
bedFiles <- readBed(loc)

## transform bed files to IRanges objects
# output: a list of IRanges objects
peaks <- lapply(bedFiles, BED2RangedData)


## Loading the human annotations
# TSS annotation for human sapiens (NCBI36) obtained from biomaRt
# see vignette('ChIPpeakAnno') for info

## The default annotaion from ChIPpeakAnno are mm9 not mm10
# BUILDING THE MM10 PACKAGE
library(biomaRt)
# ensembl=useMart("ensembl")
# listDatasets(ensembl)
ensembl = useMart("ensembl", dataset="mmusculus_gene_ensembl")
# listFilters(ensembl)
# listAttributes(ensembl)
TSS.mouse.GRCm38 <- getAnnotation(ensembl, featureType = "TSS")

## Feature association are made using TSS: means using start of feature when feature is on plus strand 
# and using end of feature when feature is on minus strand. Here the features are genes. 
# parallel version
annotatedPeakList <- mclapply(peaks, function(x){annotatePeakInBatch(x,	AnnotationData=TSS.mouse.GRCm38, output="both")}, mc.cores = ncore)
# not parallel version
# annotatedPeakList <- lapply(peaks, function(x){annotatePeakInBatch(x,AnnotationData=TSS.mouse.GRCm38, output="both")})

## These matrices needs annotation with geneIDs, symbol and long gene name
# There is 2 ways to do that through biomaRt or the BioConductor annotation package.
# BIOMART annotated more transcripts but with non-entrez gene ID. See test below.
## BIOMART
annotatedPeakList_mart <- mclapply(annotatedPeakList, biomaRtAnnot, mc.cores = ncore)

## Transform to data.frame before export to file
annotatedPeakList_martDF <- mclapply(annotatedPeakList_mart, as.data.frame, mc.cores = ncore)

# suppress line without feature name (aka gene symbol)
for(i in 1:length(annotatedPeakList_martDF)){
	theNA <- which(is.na(annotatedPeakList_martDF[[i]]$feature))
	if(length(theNA)>0){
		annotatedPeakList_martDF[[i]] <- annotatedPeakList_martDF[[i]][-theNA,]
	}
}

## adding missing annotation when possible using BioConductor org.Mm.egSYMBOL2EG
## parallel version
# annotatedPeakList_martDF <- mclapply(annotatedPeakList_martDF, addingMissingAnnot, mc.cores = ncore)
## not parallel version
annotatedPeakList_martDF  <- lapply(annotatedPeakList_martDF, addingMissingAnnot)

## CLEAN THE ENTREZGENE ID WITH TWO IDS
annotatedPeakList_martDF <- mclapply(annotatedPeakList_martDF, cleanEG, mc.cores = ncore)

## WRITE FILE FOR IMPORT
write.lists(annotatedPeakList_martDF, file="annotatedPeakList.csv")
