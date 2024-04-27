
<img src="https://bioconductor.org/images/logo/svg/Logo.svg" align="right" />

# R package rBLAST - R Interface for the Basic Local Alignment Search Tool

[![r-universe
status](https://mhahsler.r-universe.dev/badges/rBLAST)](https://mhahsler.r-universe.dev/rBLAST)
[![Package on
Bioc](https://img.shields.io/badge/Bioconductor-blue)](https://bioconductor.org/packages/rBLAST)

Interfaces the Basic Local Alignment Search Tool (BLAST) to search
genetic sequence data bases with the Bioconductor infrastructure. This
includes interfaces to `blastn`, `blastp`, `blastx`, and `makeblastdb`.
The BLAST software needs to be downloaded and installed separately.

Other R interfaces for bioinformatics are also available:

- [rRDP](https://bioconductor.org/packages/rRDP): Interface to the RDP
  Classifier
- [rMSA](https://mhahsler.r-universe.dev/ui#package:rMSA): Interface for
  Popular Multiple Sequence Alignment Tools including ClustalW, MAFFT,
  MUSCLE, and Kalign

## Installation

1.  Install the BLAST software by following the instructions in the
    [INSTALL](https://github.com/mhahsler/rBLAST/blob/devel/INSTALL)
    file.

2.  Install the latest version of the R package

    ``` r
    if (!require("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
    }

    # The following initializes usage of Bioc devel
    BiocManager::install(version = "devel")

    BiocManager::install("rBLAST")
    ```

## Usage

``` r
library(rBLAST)
```

Download the prebuilt 16S Microbial data base from NCBI’s ftp server at:
<https://ftp.ncbi.nlm.nih.gov/blast/db/>

``` r
tgz_file <- blast_db_get("16S_ribosomal_RNA.tar.gz")
untar(tgz_file, exdir = "16S_rRNA_DB")
```

Load the downloaded BLAST database.

``` r
bl <- blast(db = "./16S_rRNA_DB/16S_ribosomal_RNA")
bl
```

    ## BLAST Database
    ## Location: /home/hahsler/baR/rBLAST/16S_rRNA_DB/16S_ribosomal_RNA 
    ## BLAST Type: blastn 
    ## Database: 16S ribosomal RNA (Bacteria and Archaea type strains)
    ##  27,138 sequences; 39,323,968 total bases
    ## 
    ## Date: Apr 9, 2024  5:36 AM   Longest sequence: 3,600 bases
    ## 
    ## BLASTDB Version: 5
    ## 
    ## Volumes:
    ##  /home/hahsler/baR/rBLAST/16S_rRNA_DB/16S_ribosomal_RNA

Load some test sequences shipped with the package.

``` r
seq <- readRNAStringSet(system.file("examples/RNA_example.fasta", package = "rBLAST"))
seq
```

    ## RNAStringSet object of length 5:
    ##     width seq                                               names               
    ## [1]  1481 AGAGUUUGAUCCUGGCUCAGAAC...GGUGAAGUCGUAACAAGGUAACC 1675 AB015560.1 d...
    ## [2]  1404 GCUGGCGGCAGGCCUAACACAUG...CACGGUAAGGUCAGCGACUGGGG 4399 D14432.1 Rho...
    ## [3]  1426 GGAAUGCUNAACACAUGCAAGUC...AACAAGGUAGCCGUAGGGGAACC 4403 X72908.1 Ros...
    ## [4]  1362 GCUGGCGGAAUGCUUAACACAUG...UACCUUAGGUGUCUAGGCUAACC 4404 AF173825.1 A...
    ## [5]  1458 AGAGUUUGAUUAUGGCUCAGAGC...UGAAGUCGUAACAAGGUAACCGU 4411 Y07647.2 Dre...

Query the BLAST database to find matches for the first test sequence
with a 99% percent identity or higher.

``` r
cl <- predict(bl, seq[1, ], BLAST_args = "-perc_identity 99")
cl
```

    ##   qseqid      sseqid pident length mismatch gapopen qstart qend sstart send
    ## 1   1675 NR_151899.1    100     40        0       0     22   61      2   41
    ## 2   1675 NR_041235.1    100     37        0       0     22   58      2   38
    ## 3   1675 NR_173526.1    100     35        0       0     32   66      1   35
    ## 4   1675 NR_117153.1    100     32        0       0     27   58      1   32
    ##    evalue bitscore
    ## 1 1.5e-12       75
    ## 2 7.0e-11       69
    ## 3 9.0e-10       66
    ## 4 4.2e-08       60

## Citation Request

To cite package ‘rBLAST’ in publications use:

> Hahsler M, Nagar A (2024). “rBLAST: R Interface for the Basic Local
> Alignment Search Tool.” Bioconductor version: Release (3.19).
> <doi:10.18129/B9.bioc.rBLAST>
> <https://doi.org/10.18129/B9.bioc.rBLAST>, R package version 0.99.4.

    @Misc{,
      title = {{rBLAST:} {R} Interface for the Basic Local Alignment Search Tool},
      author = {Michael Hahsler and Annurag Nagar},
      year = {2024},
      doi = {10.18129/B9.bioc.rBLAST},
      note = {R package version 0.99.4},
      howpublished = {Bioconductor version: Release (3.19)},
    }

## Acknowledgments

This work was partially supported by grant no. R21HG005912 from the
[National Human Genome Research Institute](https://www.genome.gov/).
