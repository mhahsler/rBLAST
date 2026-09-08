#######################################################################
# rBLAST - Interface to BLAST
# Copyright (C) 2015 Michael Hahsler and Anurag Nagar
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#' Cache BLAST Database Archives
#'
#' Download BLAST database archives and manage local copies with
#' [BiocFileCache::BiocFileCache].
#'
#' `blast_db_cache()` opens rBLAST's user-level cache. Its location is selected
#' by [tools::R_user_dir()] and therefore depends on the operating system and
#' environment.
#'
#' `blast_db_get()` returns a cached archive when available and downloads it
#' otherwise. With `check_update = TRUE`, the remote resource is checked and an
#' outdated cached copy is refreshed. Downloaded archives still need to be
#' extracted before their database prefix can be passed to [blast()]. Large
#' NCBI databases can consist of multiple numbered archives; download and
#' extract every part into the same directory.
#'
#' @family blast
#' @param file Character scalar giving the archive filename, for example
#'   `"16S_ribosomal_RNA.tar.gz"`.
#' @param baseURL Character scalar giving the directory URL from which `file`
#'   is downloaded. It must end in `/`.
#' @param check_update Logical scalar; check whether the remote file is newer
#'   than the cached copy and download it when necessary.
#' @param verbose Logical scalar; report whether a file is downloaded or a
#'   cached copy is returned.
#' @return
#' * `blast_db_cache()` returns a [BiocFileCache::BiocFileCache] object.
#' * `blast_db_get()` returns a character vector containing the local path to
#'   the cached archive.

#' @author Michael Hahsler
#' @examples
#' \dontrun{
#' ## Download or retrieve an existing cached copy (this will take a little).
#' blast_db_get("16S_ribosomal_RNA.tar.gz")
#'
#' ## Extract the chached archive, then open the database using its prefix.
#' db_dir <- tempfile("16S-rRNA-")
#' dir.create(db_dir)
#' untar(blast_db_get("16S_ribosomal_RNA.tar.gz"), exdir = db_dir)
#' db <- blast(file.path(db_dir, "16S_ribosomal_RNA"))
#' db
#'
#' ## Inspect the underlying cache with BiocFileCache functions.
#' cache <- blast_db_cache()
#' BiocFileCache::bfcinfo(cache)
#' }
#' @export
blast_db_cache <-
    function() {
        cache <- tools::R_user_dir("rBLAST", which = "cache")
        BiocFileCache::BiocFileCache(cache)
    }

#' @rdname blast_db_cache
#' @export
blast_db_get <-
    function(file = "16S_ribosomal_RNA.tar.gz",
             baseURL = "https://ftp.ncbi.nlm.nih.gov/blast/db/",
             check_update = TRUE,
             verbose = TRUE) {
        fileURL <-
            paste0(baseURL, file)

        bfc <- blast_db_cache()
        rid <-
            BiocFileCache::bfcquery(bfc, file, "rname")$rid
        if (!length(rid)) {
            rid <-
                names(BiocFileCache::bfcadd(bfc, file, fileURL))
        }

        if (check_update && !isFALSE(BiocFileCache::bfcneedsupdate(bfc, rid))) {
            if (verbose)
                message("Downloading latest version of ", file, " from ",
                        baseURL)
            BiocFileCache::bfcdownload(bfc, rid)
        } else
            if (verbose)
                message("Returning local copy of ", file)

        BiocFileCache::bfcrpath(bfc, rids = rid)
    }
