Next Generation Sequencing Pratical
=====================

Instructors:
* David Ruau <djr62@cam.ac.uk>
* Catherine Wilson <chw39@cam.ac.uk>
* David Phillip Judge <dpj10@cam.ac.uk>

# Aim

The purpose of this practical course is to achieve an overview of Next Generation Sequencing (NGS) data processing and interpretation. In this introduction we will work our way through Chromatin Immuno-precipitation raw sequence (ChIP-seq) up to analysing resulting gene lists.

## Introduction to ChIP-seq

Chromatin immunoprecipitation (ChIP) allows investigating interactions between a protein and the DNA of a cell. Immunoprecipitation use antibodies to recognized specific proteins that bind to DNA. After several steps the DNA bound by the protein is recovered and sequenced (ChIP-seq). The sequenced are then analysed using bioinformatics techniques that we will review today (See [wikipedia figure for ChIP-seq](https://en.wikipedia.org/wiki/ChIP-sequencing)). Also see Kidder, B. L. et al., ChIP-Seq: technical considerations for obtaining high-quality data. Nature immunology (2011).

Today we will use an experiment published by Ang et al., Cell 2011; where key transcription factor proteins for pluripotency were studied in mouse embryonic stem cells. We will further focus on a single ChIP-seq for Oct4 and its associated control. Raw data can be found online on Gene Expression Omnibus (accession number: GSE22934). The Oct4 (Pou5f1) gene is a transcription factor (e.g. it controls other genes) important for early development of the embryo and maintenance of pluripotency.

**[Q] What kind of questions can you answer using this technique?**

* Gene regulation information. Discover gene regulatory networks.
* DNA motif recognised by Otc4 in mouse embryonic stem cells
* If compared to other Oct4 experiments one can learn about differential DNA binding profile.

**[Q] What are you sequencing?**

* DNA regions bound by the protein of interest
* Those are small fragments. The usual experimental protocol aim at fragments ~150-300bp long.

**[Q] How do you control for unspecific binding event?**

There are three types of control commonly used.

* IgG (nonspecific immunoglobulin G)
* Input chromatin (sheared DNA)
* Knockdown of the factor (KO or siRNA)

## Practical

### 1)	Aligning raw sequences to reference genome

**Open a terminal**

**Navigate to the NGS_pratical folder by typing the following:**

	cd Desktop/ngs_pratical

**Now list the files in the directory by typing:**

	ls

You will find **two folder (sample and control)** containing each one file call sample.fastq and control.fastq, respectively. Both the raw sequences in fastQ format. The fastQ format encodes at the same time the sequence and their quality.

**If you would like to have a look at the beginning of the file type the following:**

	head sample/sample.fq

You can notice that there is no header (column title). This mean that fastQ files can be combined together easily just by appending one to the other. Of course this has to make sense biologically.

We will now align both files to the latest mouse reference genome release GRC83/mm10 using a in-house scripts (ngs_align and sam2bigWig). These scripts combine multiple steps:

1. Check the raw sequences for quality and error.
2. Remove any over-represented sequences (adapters)
3. Align to mm10 using Bowtie2
4. Remove sequences that did not align uniquely

**Type the following on your terminal:**

	ngs_align –f sample –x mm10
	sam2bigWig –f sample –x mm10
	
	ngs_align –f control –x mm10
	sam2bigWig –f control –x mm10

**When this is finished take a look at the alignment reports:**

	cat sample/report_bowtie_GSM288346_Oct4_short.txt
	cat control/report_bowtie_GSM288358_GFP_short.txt

### 2)	Quality check

We will assess the quality control report for the sample and the control.

Browse your way to the `ngs_practical` folder using your file system. Localize in the control and sample folder the fastQC folder and open the HTML file by clicking on it. The fastQC report present you on the left a summary of all the tests.

The complete documentation for the fastQC report can be found here:

http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/

### 3)	Calling peaks

We are now ready to call the peaks. This mean determining of a binding event is real or just noise. To determe true signal from noise we use a program call MACS2. The algorithm will determined if a peak is a true positive in your sample using the control sample. You have to set a level of stringency (a p-value) to run the program. The following command generate the peaks for a stringency of 1e-9.

	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-9 -f BED -p 1e-9 --nomodel --shiftsize=100
	
You can repeat the previous command to generate different peak at other stringency. For example 1e-7, 1e-5 and 1e-3

	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-7 -f BED -p 1e-7 --nomodel --shiftsize=100
	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-5 -f BED -p 1e-5 --nomodel --shiftsize=100
	macs2 callpeak -t sample/sample.BED -c control/control.BED -g mm -n results_p1e-3 -f BED -p 1e-3 --nomodel --shiftsize=100
	# we move the results to to the result folder
	mv results_p1e* results/
	# we clean the peak files (.bed) from the unecessary columns for our analysis
	parallel 'cat {} | cut -f 1-3 > {.}.3bed ; mv {.}.3bed {}' ::: results/*_peaks.bed

You can find the different files already computed for you in the **results** folder.

### 4)	Visualization on UCSC

We will now visualize the sample and control profile as well as the peaks that have been called on the UCSC Genome Browser. Here for simplifying the practical we prepared a session containing the different experiemnts.

(**click on the following link**).

http://genome-euro.ucsc.edu/cgi-bin/hgTracks?db=mm10&hgct_customText=http://lila.results.cscr.cam.ac.uk/david/ngs_practical/tracks

What we are visualizing are the profiles of both the Oct4 sample and the control as well as the peaks called at two different levels of stringency (1e-3, 1e-5, 1e-7 and 1e-9).

**[Q] Which level of stringency is the most accurate?**


### 5)	Extracting peak associated genes using R

We will now attempt to extract the genes associated to the peaks found by MACS2. For this purpose we use a R package called [ChIPpeakAnno](http://www.bioconductor.org/packages/2.12/bioc/html/ChIPpeakAnno.html "Bioconductor - ChIPpeakAnno"). 

> A peak is associated to a gene by looking at his position compared to the Transcription Start Site (TSS) of the neighbouring genes. A peak can be associated to more than one gene.

The instruction how to use the R package are describe in the help of the `ChIPpeakAnno` package and the commands used to generate the gene list of today are in the `bed2gene.r` and `library.r` files in the gitHub repository. 

Briefly, the bed files are loaded in R and genomic regions compared to the TSS list for the mouse genome and associated to one or more gene. The rest of the work consist in annotating the gene with NCBI Entrez gene symbol.

We extracted the list of gene symbol from the comma separated file using a little unix magic formula:

	cat results/annotatedPeakList.csv | cut -d, -f15 | perl -pe 's/"(.*)"/\1/g' | perl -pe 's/^\n//g' | tail -n +2 | sort | uniq > results/gene_list.txt
	
To extract the list of geneID

	cat results/annotatedPeakList.csv | cut -d, -f16 | perl -pe 's/"(\d+)"/\1/g' | perl -pe 's/^\n//g' | tail -n +2 | sort | uniq > results/gene_id.txt
	
### 6)	Meta-analysis of the gene list

We are now at the interpretation level. The bioinformatic ground work is mostly done and, the question of what did we discover? remain.

Interpreting a gene list "by hand" is a daunting task. 

**Do the following: open the gene_list.txt file in the results folder.**

One cannot know everything about all the genes. Genes have multiple annotations and information type associated to them. From pathways where they play a role to molecular function, cellular compartment or biological processes such as diseases. For all those reason we use software that will try to organize the knowledge associated with these genes.

In this practical we will use a new fancy tool call **[Enrichr](http://amp.pharm.mssm.edu/Enrichr/ "Enrichr")** ([Chen et al. BMC Bioinformatics, 2013](http://www.ncbi.nlm.nih.gov/pubmed/23586463 "Enrichr: interactive and collaborative HT... [BMC Bioinformatics. 2013] - PubMed - NCBI")). The Enrichr tool allow to assess your gene list against different knowledge database such [The Gene Ontology](http://www.geneontology.org "The Gene Ontology") or [KEGG](http://www.genome.jp/kegg/ "KEGG: Kyoto Encyclopedia of Genes and Genomes") and many more...

**Find the file call gene_list.txt inside the *results* folder. Either copy and paste the content in the text box of the Enrichr website or submit the file.**

**Then click on the UP arrow in the bottom corner right.**


