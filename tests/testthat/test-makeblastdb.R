test_that("makeblastdb constructs command-line arguments", {
    call <- NULL
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/makeblastdb",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = function(command, args, stdout, ...) {
            call <<- list(command = command, args = args, stdout = stdout)
            0L
        },
        .package = "base"
    )

    status <- makeblastdb(
        "input.fasta",
        db_name = "db/example", dbtype = "prot",
        hash_index = FALSE, args = "-parse_seqids", verbose = FALSE
    )
    expect_identical(status, 0L)
    expect_identical(call$command, "/mock/makeblastdb")
    expect_match(call$args, "-in input.fasta", fixed = TRUE)
    expect_match(call$args, "-dbtype prot", fixed = TRUE)
    expect_match(call$args, "-out db/example", fixed = TRUE)
    expect_match(call$args, "-parse_seqids", fixed = TRUE)
    expect_false(grepl("-hash_index", call$args, fixed = TRUE))
    expect_false(call$stdout)
})

test_that("makeblastdb enables the hash index and verbose output by default", {
    call <- NULL
    local_mocked_bindings(
        .findExecutable = function(...) "/mock/makeblastdb",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = function(command, args, stdout, ...) {
            call <<- list(args = args, stdout = stdout)
            0L
        },
        .package = "base"
    )

    makeblastdb("input.fasta")
    expect_match(call$args, "-hash_index", fixed = TRUE)
    expect_identical(call$stdout, "")
})
