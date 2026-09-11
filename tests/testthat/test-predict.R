blast_test_object <- function(remote = FALSE) {
    structure(
        list(db = "/mock/database", type = "blastn", remote = remote),
        class = "BLAST"
    )
}

blast_output_writer <- function(lines, calls = NULL, status = 0L) {
    force(lines)
    force(status)
    function(command, args, ...) {
        if (!is.null(calls)) {
            calls$command <- command
            calls$args <- args
        }
        outfile <- args[match("-out", args) + 1L]
        if (!is.null(lines)) {
            writeLines(lines, outfile)
        }
        status
    }
}

test_that("predict.BLAST parses default and custom output formats", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGTACGTACGT"))
    default_line <- paste(
        c("q1", "s1", 100, 12, 0, 0, 1, 12, 5, 16, "1e-10", 42),
        collapse = "@"
    )
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(default_line),
        .package = "base"
    )

    output <- capture.output(
        result <- predict(blast_test_object(), query, verbose = TRUE)
    )
    expect_s3_class(result, "data.frame")
    expect_identical(
        names(result),
        c(
            "qseqid", "sseqid", "pident", "length", "mismatch", "gapopen",
            "qstart", "qend", "sstart", "send", "evalue", "bitscore"
        )
    )
    expect_identical(result$qseqid, "q1")
    expect_identical(result$sseqid, "s1")
    expect_true(any(grepl("found 1 matches", output, fixed = TRUE)))

    local_mocked_bindings(
        system2 = blast_output_writer("q1@s1@100"),
        .package = "base"
    )
    custom <- predict(
        blast_test_object(), query,
        custom_format = "qseqid sseqid pident"
    )
    expect_identical(names(custom), c("qseqid", "sseqid", "pident"))
    expect_equal(custom$pident, 100)
})

test_that("data.table and base parsers return the same results", {
    skip_if_not_installed("data.table")

    query <- Biostrings::DNAStringSet(c(q1 = "ACGTACGTACGT"))
    lines <- c(
        paste(
            c("q1", "s1", 100, 12, 0, 0, 1, 12, 5, 16, "1e-10", 42),
            collapse = "@"
        ),
        paste(
            c("q1", "s2", 91.7, 12, 1, 0, 1, 12, 20, 9, "2e-04", 31.5),
            collapse = "@"
        )
    )
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(lines),
        .package = "base"
    )

    data_table_result <- predict(blast_test_object(), query)
    base_result <- with_mocked_bindings(
        predict(blast_test_object(), query),
        requireNamespace = function(package, quietly = FALSE) FALSE,
        .package = "base"
    )

    expect_identical(data_table_result, base_result)
})

test_that("predict.BLAST handles searches without hits", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGTACGTACGT"))
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(character()),
        .package = "base"
    )

    result <- predict(blast_test_object(), query)
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0L)
    expect_equal(ncol(result), 12L)
})

test_that("predict.BLAST builds remote commands and reports progress", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGTACGTACGT"))
    calls <- new.env(parent = emptyenv())
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(character(), calls = calls),
        .package = "base"
    )

    output <- capture.output(
        result <- predict(blast_test_object(remote = TRUE), query, verbose = TRUE)
    )
    expect_true("-remote" %in% calls$args)
    expect_true(any(grepl("Starting BLAST", output, fixed = TRUE)))
    expect_true(any(grepl(
        "number of lines in results file: 0", output,
        fixed = TRUE
    )))
    expect_equal(nrow(result), 0L)

    object_without_remote <- blast_test_object()
    object_without_remote$remote <- NULL
    predict(object_without_remote, query)
    expect_false("-remote" %in% calls$args)
})

test_that("predict.BLAST cleans or retains its temporary files", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGTACGTACGT"))
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(character()),
        .package = "base"
    )

    before <- list.files(tempdir(), full.names = TRUE)
    predict(blast_test_object(), query)
    expect_setequal(list.files(tempdir(), full.names = TRUE), before)

    output <- capture.output(
        predict(blast_test_object(), query, keep_tmp = TRUE)
    )
    retained <- setdiff(list.files(tempdir(), full.names = TRUE), before)
    expect_length(retained, 2L)
    expect_true(any(grepl("[.]fasta$", retained)))
    expect_true(any(grepl("_BLAST_out[.]txt$", retained)))
    expect_true(any(grepl("Temporary BLAST files kept", output, fixed = TRUE)))
    unlink(retained)
})

test_that("predict.BLAST reports FASTA write failures", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGT"))
    original_wd <- getwd()
    local_mocked_bindings(
        writeXStringSet = function(...) stop("simulated write failure"),
        .package = "rBLAST"
    )

    expect_error(
        predict(blast_test_object(), query),
        "Failed to write BLAST query FASTA file:.*simulated write failure"
    )
    expect_identical(getwd(), original_wd)
})

test_that("predict.BLAST verifies the written FASTA file", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGT"))
    with_mocked_bindings(
        expect_error(
            predict(blast_test_object(), query),
            "BLAST query FASTA file was not created"
        ),
        writeXStringSet = function(...) NULL,
        .package = "rBLAST"
    )

    expect_error(
        predict(blast_test_object(), query[FALSE]),
        "BLAST query FASTA file is empty"
    )

    with_mocked_bindings(
        expect_error(
            predict(blast_test_object(), query),
            "BLAST query FASTA file is not readable"
        ),
        file.access = function(...) -1L,
        .package = "base"
    )
})

test_that("predict.BLAST checks BLAST status and output creation", {
    query <- Biostrings::DNAStringSet(c(q1 = "ACGT"))
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastn",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = blast_output_writer(NULL, status = 2L),
        .package = "base"
    )
    expect_error(
        predict(blast_test_object(), query),
        "blastn failed with exit status 2.*No BLAST results were read"
    )

    local_mocked_bindings(
        system2 = blast_output_writer(NULL),
        .package = "base"
    )
    expect_error(
        predict(blast_test_object(), query),
        "completed without creating its output file"
    )
})
