# rBLAST - Interface for BLAST search (R-Package)

[![Travis-CI Build Status](https://travis-ci.org/mhahsler/rBLAST.svg?branch=master)](https://travis-ci.org/mhahsler/rBLAST)

Interfaces the Basic Local Alignment Search Tool (BLAST) to search genetic sequence data bases with the Bioconductor infrastructure. This includes
interfaces to `blastn`, `blastp`, `blastx`, and `makeblastdb`.
The BLAST software needs to be downloaded and installed separately.

## Installation

1. Install the package `devtools`.
2. Install the Bioconductor package `Biostrings` either using
`devtools::install_bioc("Biostrings")` or directly from
[Bioconductor](http://www.bioconductor.org/install/).
3. Install `rBlast` from GitHub using `devtools::install_github("mhahsler/rBLAST")`.
4. Install the BLAST software by following the instructions found in `? blast`

## Usage
```R
## download the 16S Microbial data base from NCBI
download.file("https://ftp.ncbi.nlm.nih.gov/blast/db/16S_ribosomal_RNA.tar.gz",
+   "16S_ribosomal_RNA.tar.gz", mode='wb')
```
```
trying URL 'https://ftp.ncbi.nlm.nih.gov/blast/db/16S_ribosomal_RNA.tar.gz'
Content type 'application/x-gzip' length 37346728 bytes (35.6 MB)
==================================================
downloaded 35.6 MB
```

```R
untar("16S_ribosomal_RNA.tar.gz", exdir="16SMicrobialDB")

## load some test data 
seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
                        package="rBLAST"))
seq
```

```
RNAStringSet object of length 5:
    width seq                                                                 names               
[1]  1481 AGAGUUUGAUCCUGGCUCAGAACGAACGCUGG...GGUGAUCGGGGUGAAGUCGUAACAAGGUAACC 1675
[2]  1404 GCUGGCGGCAGGCCUAACACAUGCAAGUCGAA...GCAGCCGACCACGGUAAGGUCAGCGACUGGGG 4399
[3]  1426 GGAAUGCUNAACACAUGCAAGUCGCACGGGCA...UGUAGUCGNAACAAGGUAGCCGUAGGGGAACC 4403
[4]  1362 GCUGGCGGAAUGCUUAACACAUGCAAGUCGCA...AGUUGGUUUUACCUUAGGUGUCUAGGCUAACC 4404
[5]  1458 AGAGUUUGAUUAUGGCUCAGAGCGAACGCUGG...CGACUGGGGUGAAGUCGUAACAAGGUAACCGU 4411
```

```R
## load a BLAST database (replace db with the location + name of the BLAST DB)
bl <- blast(db="./16S_rRNA_DB/16S_ribosomal_RNA")
bl
```

```
BLAST Database
Location: /home/hahsler/baR/rBLAST/16S_rRNA_DB/16S_ribosomal_RNA 
BLAST Type: blastn 
Database: 16S ribosomal RNA (Bacteria and Archaea type strains)
	21,856 sequences; 31,790,086 total bases

Date: May 1, 2021  5:36 AM	Longest sequence: 3,600 bases

BLASTDB Version: 5

Volumes:
	/home/hahsler/baR/rBLAST/16S_rRNA_DB/16S_ribosomal_RNA
```

```R
## query a sequence using BLAST
cl <- predict(bl, seq[1,])
cl[1:5,]
```

```
  QueryID   SubjectID Perc.Ident Alignment.Length Mismatches Gap.Openings Q.start Q.end S.start
1    1675 NR_104821.1     90.816             1459        124            8      16  1468       5
2    1675 NR_117601.1     85.896             1255        160           15     229  1478     237
3    1675 NR_117601.1     93.846               65          4            0       5    69       1
4    1675 NR_074549.1     85.896             1255        160           15     229  1478     241
5    1675 NR_074549.1     94.203               69          4            0       1    69       1
  S.end        E Bits
1  1459 0.00e+00 1943
2  1479 0.00e+00 1321
3    65 7.21e-20   99
4  1483 0.00e+00 1321
5    69 4.31e-22  106
```
