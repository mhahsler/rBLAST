test_that(".findExecutable finds the first available executable", {
    path <- rBLAST:::.findExecutable(c("rblast-command-that-does-not-exist", "sh"))

    expect_length(path, 1L)
    expect_true(nzchar(path))
})

test_that(".findExecutable handles missing executables", {
    exe <- "rblast-command-that-does-not-exist"

    expect_equal(rBLAST:::.findExecutable(exe, interactive = FALSE), "",
        check.attributes = FALSE
    )
    expect_error(
        rBLAST:::.findExecutable(exe),
        "Executable for rblast-command-that-does-not-exist not found"
    )
})
