# rBLAST - R Interface for the Basic Local Alignment Search Tool (BLAST)

[![rBLAST r-universe
status](https://mhahsler.r-universe.dev/badges/rBLAST)](https://mhahsler.r-universe.dev/ui#package:rBLAST)

Interfaces the Basic Local Alignment Search Tool (BLAST) to search genetic sequence data bases with the Bioconductor infrastructure. This includes
interfaces to `blastn`, `blastp`, `blastx`, and `makeblastdb`.
The BLAST software needs to be downloaded and installed separately.

Other R interfaces for bioinformatics are also available:

* [rRDP](https://mhahsler.r-universe.dev/ui#package:rRDP): Interface to the RDP Classifier 
* [rMSA](https://mhahsler.r-universe.dev/ui#package:rMSA): Interface for Popular Multiple 
    Sequence Alignment Tools including ClustalW, MAFFT, MUSCLE, and Kalign


## Installation

1. Install the Bioconductor package `Biostrings` following the instructions [here](https://bioconductor.org/packages/release/bioc/html/Biostrings.html).
2. Install the `rBlast` from r-universe using 
   ```R 
   install.packages('rBLAST', repos = 'https://mhahsler.r-universe.dev')
   ```
3. Install the BLAST software by following the instructions found in 
   ```R
   library('rBLAST')
   ? blast
   ```

## Usage

Download the 16S Microbial data base from NCBI

```R
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
```

Load some test sequences

```R
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

Load a BLAST database (replace db with the location + name of the BLAST DB)

```R
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


Query a sequence using BLAST

```R
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

## Citation Request

Cite the use of this package as:

> Hahsler M, Nagar A (2019). rBLAST: R Interface for the Basic Local Alignment Search Tool. 
> R package version 0.99.2, URL: https://github.com/mhahsler/rBLAST.

BibTeX
```  
@Manual{,
    title = {rBLAST: R Interface for the Basic Local Alignment Search Tool},
    author = {Michael Hahsler and Anurag Nagar},
    year = {2019},
    note = {R package version 0.99.2},
  }
```
