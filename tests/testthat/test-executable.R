test_that(".findExecutable finds the first available executable", {
    path <- rBLAST:::.findExecutable(c("rblast-command-that-does-not-exist", "sh"))

    expect_length(path, 1L)
    expect_true(nzchar(path))
})

test_that(".findExecutable handles missing executables", {
    exe <- "rblast-command-that-does-not-exist"

    expect_length(rBLAST:::.findExecutable(exe, interactive = FALSE), 0L)
    expect_error(
        rBLAST:::.findExecutable(exe),
        "Executable for rblast-command-that-does-not-exist not found"
    )
})

test_that("has_blast reports executable availability", {
    local_mocked_bindings(
        .findExecutable = function(...) character(0),
        .package = "rBLAST"
    )
    expect_false(has_blast())

    local_mocked_bindings(
        .findExecutable = function(...) "/usr/bin/blastn",
        .package = "rBLAST"
    )
    expect_true(has_blast())
})
