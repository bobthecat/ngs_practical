Next Generation Sequencing Pratical
=====================

Instructors:
* David Ruau <djr62@cam.ac.uk>
* Catherine Wilson <chw39@cam.ac.uk>
* David Phillip Judge <dpj10@cam.ac.uk>


Script used for the NGS ChIP-seq practical for part II student at Cambridge University, UK.

# Aim

The purpose of this practical course is to achieve an overview of Next Generation Sequencing (NGS) data processing and interpretation. In this introduction we will work our way through Chromatin Immuno-precipitation raw sequence (ChIP-seq) up to analysing resulting gene lists.

## Introduction to ChIP-seq

Chromatin immunoprecipitation (ChIP) allows investigating interactions between a protein and the DNA of a cell. Immunoprecipitation use antibodies to recognized specific proteins that bind to DNA. After several steps the DNA bound by the protein is recovered and sequenced (ChIP-seq). The sequenced are then analysed using bioinformatics techniques that we will review today (See [wikipedia figure for ChIP-seq](https://en.wikipedia.org/wiki/ChIP-sequencing)). Also see Kidder, B. L. et al., ChIP-Seq: technical considerations for obtaining high-quality data. Nature immunology (2011).

Today we will use an experiment published by Chen et al., Cell 2008; where key transcription factor proteins for pluripotency were studied in mouse embryonic stem cells. We will further focus on a single ChIP-seq for Oct4 and its associated control. Raw data can be found online on Gene Expression Omnibus (accession number: GSE11431).

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

**1)	Aligning raw sequences to reference genome**

Open the terminal application and navigate to the NGS_pratical folder by typing the following:

<code>cd NGS_pratical</code>

Now list the file in the directory by typing:

<code>ls</code>

You will find two folder (Oct4 and control) containing each one file call GSM288346_Oct4_short.fq and GSM288358_GFP_short.fq, respectively. Both of them contain 30,000 lines of raw sequences in fastQ format. The fastQ format encodes at the same time the sequence and their quality. If you would like to have a look at the beginning of the file type the following:

<code>head GSM288346_Oct4_short.fq</code>

We will align both files to the latest mouse reference genome release GRC83/mm10 using a in-house script. Type the following on your terminal:

<code>
	ngs_align –f sample –x mm10
	
	sam2bigWig –f sample –x mm10
	
	ngs_align –f control –x mm10
	
	sam2bigWig –f control –x mm10
</code>

When this is finished, we take a look at the aligner report:

<code>
cat sample/report_bowtie_GSM288346_Oct4_short.txt

cat control/ report_bowtie_GSM288358_GFP_short.txt
</code>

**2)	Calling peaks**

We are now ready to call the peaks. To call peaks we use a program call MACS2. You have to use both the sample BED file and the control BED file. The MACS2 algorithm will determined if a peak is a true positive in your sample using the control sample. You have to set a p-value in advance. The following command generate the peaks however, this will not work on the sample dataset given

<code>macs2 callpeak -t sample/GSM288346_Oct4_short.BED -c control/GSM288358_GFP_short.BED -g mm -n results_p1e-9 -f BED -p 1e-9 --nomodel --shiftsize=100</code>

We generated in advance the peak file on the full version of the experiments.
You can find the different files in the results folder.

**3)	Quality check**

We will assess the quality control report for the sample and the control.

Go into the NGS_practical folder using your file system. Localize in the control and sample folder the fastQC folder. The complete documentation for the fastQC report can be found here:

http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/


**4)	Visualization on UCSC**

We will now visualize the sample and control profile as well as the peaks that have been called on the UCSC Genome Browser.

http://genome-euro.ucsc.edu/cgi-bin/hgTracks?db=mm10&hgct_customText=http://lila.results.cscr.cam.ac.uk/david/ngs_practical/tracks


**5)	Extracting peak associated genes using R.**

For this purpose we use a R package called ChIPpeakAnno. This will extract the gene associated to the peak found by MACS2. A peak is associated to a gene by looking at his position compared to the transcription Start Site (TSS) of the neighbouring genes. A peak can be associated to more than one gene.
The instruction how to use the R package are describe in the help of the package and the commands ran to generate the gene list of today are on the gitHub repository.

