test_that("blast validates database input", {
    expect_error(blast(), "No BLAST database specified")

    missing_db <- file.path(tempdir(), "rblast-database-that-does-not-exist")
    expect_error(blast(missing_db), "BLAST database does not exist")

    spaced_dir <- local_test_dir(pattern = "rBLAST test ")
    spaced_db <- file.path(spaced_dir, "database")
    file.create(paste0(spaced_db, ".nhr"))
    expect_error(blast(spaced_db), "contains spaced")
})

test_that("blast creates remote database objects without local checks", {
    db <- blast("nt", remote = TRUE, type = "blastx")

    expect_s3_class(db, "BLAST")
    expect_identical(db$db, "nt")
    expect_identical(db$type, "blastx")
    expect_true(db$remote)
})

test_that("blast checks a local database with blastdbcmd", {
    db_dir <- local_test_dir()
    db_path <- file.path(db_dir, "database")
    file.create(paste0(db_path, ".nhr"))
    calls <- list()

    local_mocked_bindings(
        .findExecutable = function(exe, ...) paste0("/mock/", exe),
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = function(command, args, ...) {
            calls[[length(calls) + 1L]] <<- list(command = command, args = args)
            0L
        },
        .package = "base"
    )

    db <- blast(db_path)
    expect_s3_class(db, "BLAST")
    expect_false(db$remote)
    expect_identical(db$db, normalizePath(db_path, mustWork = FALSE))
    expect_identical(calls[[1L]]$command, "/mock/blastdbcmd")
    expect_identical(calls[[1L]]$args, c("-db", db$db, "-info"))
})

test_that("blast reports an invalid local database", {
    db_dir <- local_test_dir()
    db_path <- file.path(db_dir, "database")
    file.create(paste0(db_path, ".nhr"))

    local_mocked_bindings(
        .findExecutable = function(exe, ...) paste0("/mock/", exe),
        .package = "rBLAST"
    )
    local_mocked_bindings(system2 = function(...) 2L, .package = "base")

    expect_error(blast(db_path), "Problem loading the database")
})

test_that("blast_help invokes the requested executable", {
    call <- NULL
    local_mocked_bindings(
        .findExecutable = function(exe, ...) paste0("/mock/", exe),
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = function(command, args, ...) {
            call <<- list(command = command, args = args)
            0L
        },
        .package = "base"
    )

    expect_identical(blast_help("blastp"), 0L)
    expect_identical(call$command, "/mock/blastp")
    expect_identical(call$args, "-help")
})

test_that("print.BLAST prints basic and optional database information", {
    db <- structure(
        list(db = "/data/example", type = "blastn", remote = FALSE),
        class = "BLAST"
    )

    basic <- capture.output(print(db, info = FALSE))
    expect_true(any(grepl("BLAST Database", basic, fixed = TRUE)))
    expect_true(any(grepl("Location: /data/example", basic, fixed = TRUE)))
    expect_true(any(grepl("BLAST Type: blastn", basic, fixed = TRUE)))

    local_mocked_bindings(
        .findExecutable = function(...) "/mock/blastdbcmd",
        .package = "rBLAST"
    )
    local_mocked_bindings(
        system2 = function(...) c("Database: example", "1 sequence"),
        .package = "base"
    )
    detailed <- capture.output(print(db))
    expect_true(any(grepl("Database: example", detailed, fixed = TRUE)))
    expect_true(any(grepl("1 sequence", detailed, fixed = TRUE)))
})
