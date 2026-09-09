test_that("makeblastdb, blast, and predict work together", {
    skip_if_not(has_blast(), message = "BLAST+ is not installed.")
    skip_if(Sys.which("makeblastdb") == "", "makeblastdb is not installed.")
    skip_if(Sys.which("blastdbcmd") == "", "blastdbcmd is not installed.")

    sequences <- Biostrings::readRNAStringSet(system.file(
        "examples/RNA_example.fasta",
        package = "rBLAST"
    ))
    work_dir <- local_test_dir()
    fasta <- file.path(work_dir, "sequences.fasta")
    db_path <- file.path(work_dir, "database")
    Biostrings::writeXStringSet(sequences, fasta)

    expect_identical(
        makeblastdb(
            fasta,
            db_name = db_path, dbtype = "nucl", verbose = FALSE
        ),
        0L
    )
    expect_true(length(Sys.glob(paste0(db_path, ".*"))) > 0L)

    db <- blast(db_path)
    result <- predict(db, sequences[1L], BLAST_args = "-perc_identity 99")
    expect_equal(nrow(result), 1L)
    expect_equal(result$sseqid, 1675L)
})
