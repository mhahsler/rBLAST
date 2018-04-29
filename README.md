# rBLAST - Interface for BLAST search (R-Package)

[![Travis-CI Build Status](https://travis-ci.org/mhahsler/rBLAST.svg?branch=master)](https://travis-ci.org/mhahsler/rBLAST)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mhahsler/rBLAST?branch=master&svg=true)](https://ci.appveyor.com/project/mhahsler/rBLAST)

Interfaces the Basic Local Alignment Search Tool (BLAST) to search genetic sequence data bases with the Bioconductor infrastructure. This includes
interfaces to `blastn`, `blastp`, `blastx`, and `makeblastdb`.
The BLAST software needs to be downloaded and installed separately.

## Installation

* Install [Bioconductor](http://www.bioconductor.org/install/) and the Bioconductor package
`Biostrings`.
* Download and install the package from [AppVeyor](https://ci.appveyor.com/project/mhahsler/rBLAST/build/artifacts) or install via `install_github("mhahsler/rBLAST")` (requires the R package `devtools`) 
* Install the BLAST software by following the instructions found in `? blast`

## Usage
```R
## download the 16S Microbial data base from NCBI
download.file("ftp://ftp.ncbi.nlm.nih.gov/blast/db/16SMicrobial.tar.gz",
    "16SMicrobial.tar.gz", mode='wb')
```
```
trying URL 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/16SMicrobial.tar.gz'
ftp data connection made, file length 4192539 bytes
==================================================
downloaded 4.0 MB
```

```R
untar("16SMicrobial.tar.gz", exdir="16SMicrobialDB")

## load some test data 
seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
                        package="rBLAST"))
seq
```

```
  A RNAStringSet instance of length 5
    width seq                                                                    names               
[1]  1481 AGAGUUUGAUCCUGGCUCAGAACGAACGCUGGCG...UGGUGAUCGGGGUGAAGUCGUAACAAGGUAACC 1675
[2]  1404 GCUGGCGGCAGGCCUAACACAUGCAAGUCGAACG...GGCAGCCGACCACGGUAAGGUCAGCGACUGGGG 4399
[3]  1426 GGAAUGCUNAACACAUGCAAGUCGCACGGGCAGC...GUGUAGUCGNAACAAGGUAGCCGUAGGGGAACC 4403
[4]  1362 GCUGGCGGAAUGCUUAACACAUGCAAGUCGCACG...GAGUUGGUUUUACCUUAGGUGUCUAGGCUAACC 4404
[5]  1458 AGAGUUUGAUUAUGGCUCAGAGCGAACGCUGGCG...GCGACUGGGGUGAAGUCGUAACAAGGUAACCGU 4411
```

```R
## load a BLAST database (replace db with the location + name of the BLAST DB)
bl <- blast(db="./16SMicrobialDB/16SMicrobial")
bl
```

```
BLAST Database
Location: /home/hahsler/baR/rMSA/16SMicrobialDB/16SMicrobial 
Database: 16S Microbial Sequences
	17,624 sequences; 25,680,771 total bases

Date: Jun 2, 2015  12:00 AM	Longest sequence: 2,211 bases

Volumes:
	/home/hahsler/baR/rMSA/16SMicrobialDB/16SMicrobial
```

```R
## query a sequence using BLAST
cl <- predict(bl, seq[1,])
cl[1:5,]
```

```
  QueryID                     SubjectID Perc.Ident Alignment.Length Mismatches Gap.Openings Q.start
1    1675 gi|559795231|ref|NR_104821.1|      90.82             1459        124            8      16
2    1675 gi|444304125|ref|NR_074549.1|      85.99             1249        158           15     235
3    1675 gi|444304125|ref|NR_074549.1|      94.20               69          4            0       1
4    1675 gi|645320383|ref|NR_117601.1|      85.99             1249        158           15     235
5    1675 gi|645320383|ref|NR_117601.1|      93.85               65          4            0       5
  Q.end S.start S.end     E Bits
1  1468       5  1459 0e+00 1943
2  1478     247  1483 0e+00 1321
3    69       1    69 3e-22  106
4  1478     243  1479 0e+00 1321
5    69       1    65 6e-20   99
```
