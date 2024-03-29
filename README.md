
# R package rBLAST - R Interface for the Basic Local Alignment Search Tool

[![CRAN
version](http://www.r-pkg.org/badges/version/rBLAST)](https://CRAN.R-project.org/package=rBLAST)
[![stream r-universe
status](https://mhahsler.r-universe.dev/badges/rBLAST)](https://mhahsler.r-universe.dev/rBLAST)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/rBLAST)](https://CRAN.R-project.org/package=rBLAST)

Interfaces the Basic Local Alignment Search Tool (BLAST) to search
genetic sequence data bases with the Bioconductor infrastructure. This
includes interfaces to `blastn`, `blastp`, `blastx`, and `makeblastdb`.
The BLAST software needs to be downloaded and installed separately.

Other R interfaces for bioinformatics are also available:

- [rRDP](https://mhahsler.r-universe.dev/ui#package:rRDP): Interface to
  the RDP Classifier
- [rMSA](https://mhahsler.r-universe.dev/ui#package:rMSA): Interface for
  Popular Multiple Sequence Alignment Tools including ClustalW, MAFFT,
  MUSCLE, and Kalign

## Installation

1.  Install the Bioconductor package `Biostrings` following the
    instructions
    [here](https://bioconductor.org/packages/release/bioc/html/Biostrings.html).

2.  Install `rBlast` from r-universe using

    ``` r
    install.packages("rBLAST", repos = "https://mhahsler.r-universe.dev")
    ```

3.  Install the BLAST software by following the instructions in the
    [INSTALL](https://github.com/mhahsler/rBLAST/blob/devel/INSTALL)
    file.

## Usage

``` r
library(rBLAST)
```

Download the 16S Microbial data base from NCBI.

``` r
download.file("https://ftp.ncbi.nlm.nih.gov/blast/db/16S_ribosomal_RNA.tar.gz", "16S_ribosomal_RNA.tar.gz",
    mode = "wb")

untar("16S_ribosomal_RNA.tar.gz", exdir = "16S_rRNA_DB")
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
    ##  22,239 sequences; 32,329,036 total bases
    ## 
    ## Date: Mar 12, 2024  5:36 AM  Longest sequence: 3,600 bases
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
    ## 1 1.2e-12       75
    ## 2 5.8e-11       69
    ## 3 7.4e-10       66
    ## 4 3.5e-08       60

## Citation Request

Cite the use of this package as:

> Hahsler M, Nagar A (2019). rBLAST: R Interface for the Basic Local
> Alignment Search Tool. R package version 0.99.2, URL:
> <https://github.com/mhahsler/rBLAST>.

BibTeX

    @Manual{,
        title = {{rBLAST: R Interface for the Basic Local Alignment Search Tool}},
        author = {Michael Hahsler and Anurag Nagar},
        year = {2019},
        note = {R package version 0.99.2},
        url = {https://github.com/mhahsler/rBLAST}
      }
