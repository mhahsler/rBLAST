local_test_dir <- function(pattern = "rBLAST-test-") {
    path <- tempfile(pattern = pattern)
    dir.create(path)
    withr::defer(
        unlink(path, recursive = TRUE, force = TRUE),
        envir = parent.frame()
    )
    path
}
