## Test

skip_if_not(has_blast(), message = "BLAST+ is not installed.")

## check if blast is correctly installed
expect_false(all(Sys.which("makeblastdb") == ""))
expect_false(all(Sys.which("blastn") == ""))

## create a database for some example sequences
seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
    package = "rBLAST"
))

## 1. write the FASTA file
dir <- tempdir()
writeXStringSet(seq, filepath = file.path(dir, "seqs.fasta"))

## 2. make database
makeblastdb(file.path(dir, "seqs.fasta"), dbtype = "nucl", verbose = FALSE)

expect_true(dir.exists(dir))

## 3. open database
db <- blast(file.path(dir, "seqs.fasta"))
#db


## 4. perform search (first sequence in the db should be a perfect match)
res <- predict(db, seq[1], BLAST_args = "-perc_identity 99")

expect_equal(nrow(res), 1L)
expect_equal(res$sseqid, 1675L)

## clean up
unlink(dir, recursive = TRUE)
