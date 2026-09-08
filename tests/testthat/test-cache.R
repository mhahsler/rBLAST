test_that("blast_db_cache uses the package user cache", {
    calls <- new.env(parent = emptyenv())
    local_mocked_bindings(
        R_user_dir = function(package, which) {
            calls$package <- package
            calls$which <- which
            "/mock/cache"
        },
        .package = "tools"
    )
    local_mocked_bindings(
        BiocFileCache = function(cache) {
            calls$cache <- cache
            structure(list(cache = cache), class = "MockBiocFileCache")
        },
        .package = "BiocFileCache"
    )

    cache <- blast_db_cache()
    expect_s3_class(cache, "MockBiocFileCache")
    expect_identical(calls$package, "rBLAST")
    expect_identical(calls$which, "cache")
    expect_identical(calls$cache, "/mock/cache")
})

test_that("blast_db_get returns an existing cached file", {
    cache <- structure(list(), class = "MockBiocFileCache")
    local_mocked_bindings(blast_db_cache = function() cache, .package = "rBLAST")
    local_mocked_bindings(
        bfcquery = function(...) data.frame(rid = "RID1"),
        bfcneedsupdate = function(...) FALSE,
        bfcrpath = function(bfc, rids) paste0("/cache/", rids),
        bfcadd = function(...) stop("bfcadd should not be called"),
        bfcdownload = function(...) stop("bfcdownload should not be called"),
        .package = "BiocFileCache"
    )

    expect_message(
        path <- blast_db_get("database.tar.gz"),
        "Returning local copy of database.tar.gz"
    )
    expect_identical(path, "/cache/RID1")
})

test_that("blast_db_get adds missing files using baseURL", {
    calls <- new.env(parent = emptyenv())
    cache <- structure(list(), class = "MockBiocFileCache")
    local_mocked_bindings(blast_db_cache = function() cache, .package = "rBLAST")
    local_mocked_bindings(
        bfcquery = function(...) data.frame(rid = character()),
        bfcadd = function(bfc, rname, fpath) {
            calls$rname <- rname
            calls$fpath <- fpath
            stats::setNames("/cache/file", "RID2")
        },
        bfcneedsupdate = function(...) FALSE,
        bfcrpath = function(bfc, rids) paste0("/cache/", rids),
        .package = "BiocFileCache"
    )

    path <- suppressMessages(blast_db_get(
        "database.tar.gz",
        baseURL = "https://example.test/blast/"
    ))
    expect_identical(calls$rname, "database.tar.gz")
    expect_identical(calls$fpath, "https://example.test/blast/database.tar.gz")
    expect_identical(path, "/cache/RID2")
})

test_that("blast_db_get refreshes outdated cached files", {
    calls <- new.env(parent = emptyenv())
    calls$downloads <- 0L
    cache <- structure(list(), class = "MockBiocFileCache")
    local_mocked_bindings(blast_db_cache = function() cache, .package = "rBLAST")
    local_mocked_bindings(
        bfcquery = function(...) data.frame(rid = "RID3"),
        bfcneedsupdate = function(...) TRUE,
        bfcdownload = function(bfc, rid) {
            calls$downloads <- calls$downloads + 1L
            invisible(NULL)
        },
        bfcrpath = function(bfc, rids) paste0("/cache/", rids),
        .package = "BiocFileCache"
    )

    expect_message(
        path <- blast_db_get(
            "database.tar.gz",
            baseURL = "https://example.test/blast/"
        ),
        "Downloading latest version"
    )
    expect_identical(calls$downloads, 1L)
    expect_identical(path, "/cache/RID3")
})
