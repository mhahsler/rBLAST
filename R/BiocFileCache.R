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

#' Manage BLAST Database Downloads using BioCFileCache
#'
#' Use [BiocFileCache::BiocFileCache] to manage local copies of BLAST database downloads.
#' NCBI BLAST databases are updated daily and
#' may be downloaded via FTP from \url{https://ftp.ncbi.nlm.nih.gov/blast/db/}.
#'
#' The package maintains its own local cache which can be accessed using
#' `blast_db_cache()`.
#'
#' @family blast
#' @param file the filename of the database.
#' @param baseURL URL to download blast databases from. The default is NCBI's
#'  ftp server.
#' @param check_update logical; update the local cache if there is a newer
#'    version of the file available on the server. This may take some time.
#' @param verbose logical; display download information.
#' @returns
#' * `blast_db_cache()` returns the path to the local [BiocFileCache::BiocFileCache] cache.
#' * `blast_db_get()` returns the file path to a downloaded BLAST database
#'     file.

#' @author Michael Hahsler
#' @examples
#' ## get a database file (will be downloaded if the
#' ##     local copy is not up-to-date)
#' db_16S <- blast_db_get("16S_ribosomal_RNA.tar.gz")
#' db_16S
#'
#' ## directly interacting with the local cache
#' library(BiocFileCache)
#'
#' ## show the package's cache directory
#' local_cache <- blast_db_cache()
#' local_cache
#'
#' ## bfc functions can be used to manage the local cache
#' bfcinfo(local_cache)
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
            paste0("https://ftp.ncbi.nlm.nih.gov/blast/db/", file)

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
