Next Generation Sequencing Pratical
=====================

Instructors:
* David Ruau <davidruau@gmail.com>
* Catherine Wilson <chw39@cam.ac.uk>
* David Phillip Judge <dpj10@cam.ac.uk>

# Aim

The purpose of this practical course is to achieve an overview of Next Generation Sequencing (NGS) data processing and interpretation. In this introduction we will work our way through Chromatin Immuno-precipitation raw sequence (ChIP-seq) up to analysing resulting gene lists.

## Introduction to ChIP-seq

Chromatin immunoprecipitation (ChIP) allows investigating interactions between a protein and the DNA of a cell. Immunoprecipitation use antibodies to recognized specific proteins that bind to DNA. After several steps the DNA bound by the protein is recovered and sequenced (ChIP-seq). The sequenced are then analysed using bioinformatics techniques that we will review today (See [wikipedia figure for ChIP-seq](https://en.wikipedia.org/wiki/ChIP-sequencing)). Also see Kidder, B. L. et al., ChIP-Seq: technical considerations for obtaining high-quality data. Nature immunology (2011).

Today we will use an experiment published by Ang et al., Cell 2011; where key transcription factor proteins for pluripotency were studied in mouse embryonic stem cells. We will further focus on a single ChIP-seq for Oct4 and its associated control. Raw data can be found online on Gene Expression Omnibus (accession number: GSE22934). The Oct4 (Pou5f1) gene is a transcription factor (e.g. it controls other genes) important for early development of the embryo and maintenance of pluripotency.


## Practical

### 1)	Introduction

**1.1) Short Intorduction to UNIX**

[Wiki page](https://github.com/bobthecat/ngs_practical/wiki/UNIX-tutorial)

**1.2) Navigate to the ngs_pratical folder which is on the desktop**

Use what you just learned in the Unix tutorial

**1.3) Now list the files in the directory:**

You will find **two folder (sample and control)** containing each one file call sample.fastq and control.fastq, respectively. Both the raw sequences in fastQ format. The fastQ format encodes at the same time the sequence and their quality.

**1.4) Have a look at the beginning of the file type the following:**

	head sample/sample.fastq

You can notice that there is no header (column title). This mean that fastQ files can be combined together easily just by appending one to the other. Of course this has to make sense biologically.


### 2) Quality control of the raw sequences reads

We will now align both files (sample and control) to the latest mouse reference genome release GRC83/mm10 using a in-house scripts (ngs_align and sam2bigWig). These scripts combine multiple steps:

1. Check the raw sequences for quality and error.
2. Remove any over-represented sequences (adapters)
3. Align to mm10 using Bowtie2
4. Remove sequences that did not align uniquely

But before we run those script let do the quality control by ourselves.

**In the terminal type:**

    fastqc

Load first the sample.fastq file into the program and run it. Save the results and load now the `SCL_ERX002138_MEL.fq` data. Compare both results.

References: The complete documentation for the fastQC report can be found here:

http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/

### 3) Aligning raw sequences to a reference genome

The program we will use to align our sequence reads to the reference genome is [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml "Bowtie 2: fast and sensitive read alignment"). Bowtie uses indexed genome for the alignment in order to keep its memory footprint small. The reference genome can be downloaded from [ENSEMBL](http://www.ensembl.org/index.html "Ensembl Genome Browser"). The indexed genome is generated using the command: `bowtie-build [genome fasta file] [index name]`

Before you run bowtie you need to know the fastq format. fastq file differ in their representation of the quality score. These could be `Sanger / Illumina 1.9`, `Sanger`, `Illumina 1.5`, `Illumina <1.3` or `Illumina 1.3`. You get this information through the fastQC report.

We simplyfied the analysis by combining all the different steps into a global script `ngs_align`. You can have a look at the script by cliking on it at the top of this web page.

**3.1) Type the following in your terminal:**

    # The script takes two arguments
    # -f: the folder containing the fastq file to process
    # -x: the referecne genome to use
    # -h: display a help menu
    ngs_align -f sample -x mm10
    
    # Processing the control experiment
	ngs_align -f control -x mm10

**3.2) When this is finished take a look at the alignment reports:**

	cat sample/report_bowtie_sample.txt
	
	cat control/report_bowtie_control.txt


### 4) Generating genome profiles

The next processing step after the alignment is to generate genome wide alignment profile that can be displayed in a genome browser. This step is also necessary for downstream analysis to call peaks notably.

For this purpose we will use a wrapper script combining several steps:

1. Transform bowtie output to [BED](http://genome.ucsc.edu/FAQ/FAQformat.html#format1 "UCSC Genome Bioinformatics: FAQ") files
2. Extend the read to 200bp minimum
3. Transform to [BedGraph](http://genome.ucsc.edu/goldenPath/help/bedgraph.html "UCSC Genome Browser: BedGraph Track Format") format then to [bigWig](http://genome.ucsc.edu/goldenPath/help/bigWig.html "UCSC Genome Browser: bigWig Track Format")

**4.1) Type the following on your terminal:**

	sam2bigWig -f sample -x mm10

	sam2bigWig -f control -x mm10


### 5) Calling peaks

We are now ready to call the peaks. This mean determining of a binding event is real or just noise. To determe true signal from noise we use a program call MACS2. The algorithm will determined if a peak is a true positive in your sample using the control sample. You have to set a level of stringency (a p-value) to run the program. 

**5.1) The following command generate the peaks for a stringency of 1e-9.**

These are the command you have to run to call peaks. However, in this practical the control data are not the full dataset so the following commands will not produce correct bed files.

	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-9 -f BED -p 1e-9 --nomodel --shiftsize=100
	
**5.2) You can repeat the previous command to generate different peak at other stringency. For example 1e-7, 1e-5 and 1e-3**

	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-7 -f BED -p 1e-7 --nomodel --shiftsize=100
	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-5 -f BED -p 1e-5 --nomodel --shiftsize=100
	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-3 -f BED -p 1e-3 --nomodel --shiftsize=100
	# we move the results to to the result folder
	mv results_p1e* results/
	# we clean the peak files (.bed) from the unecessary columns for our analysis
    cat results/results_p1e-9_peaks.bed | cut -f1-3 > temp ; mv temp results/results_p1e-9_peaks.bed
    cat results/results_p1e-7_peaks.bed | cut -f1-3 > temp ; mv temp results/results_p1e-7_peaks.bed
    cat results/results_p1e-5_peaks.bed | cut -f1-3 > temp ; mv temp results/results_p1e-5_peaks.bed
    cat results/results_p1e-3_peaks.bed | cut -f1-3 > temp ; mv temp results/results_p1e-3_peaks.bed

You can find the different files already computed for you in the **results** folder.


### 6)	Visualization on UCSC

We will now visualize the sample and control profile as well as the peaks that have been called on the UCSC Genome Browser. Here for simplifying the practical we prepared a session containing the different experiments.

(**click on the following link**).

http://genome-euro.ucsc.edu/cgi-bin/hgTracks?db=mm10&hgct_customText=http://lila.results.cscr.cam.ac.uk/david/ngs_practical/tracks

What we are visualizing are the profiles of both the Oct4 sample and the control as well as the peaks called at two different levels of stringency (1e-3, 1e-5, 1e-7 and 1e-9).

**Visit the following genes by typing their symbol in UCSC:**

* Pou5f1 (positive control)

* Dppa3 (positive control)

* Psgg1 (positive control)

* Sox2 (positive control)

* Myc (negative control)

**Also visit the following region:**
* `chr1:164,204,459-164,597,842`


### 7)	Extracting peak associated genes using R

**7.1) Short intorduciton to R**

R is a software to analyse data. This is also a statistical programming language. Here is a small primer.

**Intro to R:** [wiki page](https://github.com/bobthecat/ngs_practical/wiki/R-Introduction)

**7.2) Using R to extract a gene list**

**In this practical we already extract the gene list from the peak lists.**

To do so we use a R package called [ChIPpeakAnno](http://www.bioconductor.org/packages/2.12/bioc/html/ChIPpeakAnno.html "Bioconductor - ChIPpeakAnno"). Briefly, a peak is associated to a gene by looking at his position compared to the Transcription Start Site (TSS) of the neighbouring genes. A peak can be associated to more than one gene.

The instruction how to use the R package are describe in the help of the `ChIPpeakAnno` package and the commands used to generate the gene list of today are in the `bed2gene.r` and `library.r` files in this gitHub repository. 

We extracted the list of gene symbol as well as the list of gene ID from the comma separated file and made them available in the results folder.

**7.3) Cleaning the gene list**

Open the file `gene_list.txt` inside the results folder.

### 8)	Meta-analysis of the gene list

We are now at the interpretation level. The bioinformatic ground work is mostly done and, the question of what did we discover? remain.

**8.1) Converting gene ID to gene symbols**

**Convert the Entrez gene IDs in the file gene_id.txt to gene symbols using [MatchMiner](http://discover.nci.nih.gov/matchminer/MatchMinerLookup.jsp "MatchMiner Lookup")**

**Save the gene symbols into a new text file in your results folder**

**8.2) Using annotation to interpret your gene list**

One cannot know everything about all the genes. Genes have multiple annotations and information type associated to them. From pathways where they play a role to molecular function, cellular compartment or biological processes such as diseases. For all those reason we use software that will try to organize the knowledge associated with these genes.

In this practical we will use a new fancy tool call **[Enrichr](http://amp.pharm.mssm.edu/Enrichr/ "Enrichr")** ([Chen et al. BMC Bioinformatics, 2013](http://www.ncbi.nlm.nih.gov/pubmed/23586463 "Enrichr: interactive and collaborative HT... [BMC Bioinformatics. 2013] - PubMed - NCBI")). The Enrichr tool allow to assess your gene list against different knowledge database such [The Gene Ontology](http://www.geneontology.org "The Gene Ontology") or [KEGG](http://www.genome.jp/kegg/ "KEGG: Kyoto Encyclopedia of Genes and Genomes") and many more...

**Find the file call gene_list.txt inside the *results* folder. Either copy and paste the content in the text box of the Enrichr website or submit the file.**

**Then click on the UP arrow in the bottom corner right.**


**8.3) Focusing on a gene**

Several tools exist that can help you understand a gene.

One of my favorite is [HEFalMp](http://hefalmp.princeton.edu "HEFalMp: Providing Functional Maps of the Human Genome"). HEFalMp is based on gene expression analysis of all the dataset available in Gene Expression Omnibus. Typing a gene symbol return you a gene list that tells you what other gene are likely co-regulated partner of your gene.


Another tool to discover interation partner of you gene of interest is [iHOP](http://www.ihop-net.org/UniPub/iHOP/ "iHOP - Information Hyperlinked over Proteins").

**[Exercices]** Generate an interaction graph for Pou5f1 using iHOP.


### 9) Using pre-processed ChIP-seq datasets

Direct your browser to the following website:
[http://haemcode.stemcells.cam.ac.uk](http://haemcode.stemcells.cam.ac.uk "HAEMCODE")


### 10) Questions and exercises

([See the wiki.](https://github.com/bobthecat/ngs_practical/wiki/NGS-practical-questions-and-exercises))

