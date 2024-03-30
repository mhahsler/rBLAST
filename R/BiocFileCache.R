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
#' Use [BiocFileCache] to manage local copies of BLAST database downloads.
#' NCBI BLAST databases are updated daily and
#' may be downloaded via FTP from https://ftp.ncbi.nlm.nih.gov/blast/db/.
#'
#' @family blast
#' @param file the filename of the database.
#' @param baseURL URL to download blast databases from. The default is NCBI's
#' ftp server.
#' @param verbose logical; display download information.
#' @returns
#' * `blast_db_cache()` returns the path to the local [BiocFileCache] cache.
#' * `blast_db_get()` returns the file path to a downloaded BLAST database
#'     file.

#' @author Michael Hahsler
#' @examples
#' library(BiocFileCache)
#'
#' ## show the package's cache directory
#' cache <- blast_db_cache()
#' cache
#'
#' ## get a database file (will be downloaded the first time)
#' db_16S <- blast_db_get("16S_ribosomal_RNA.tar.gz")
#' db_16S
#'
#' ## bfc functions can be used to manage the local cache
#' bfcinfo(cache)
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
             verbose = TRUE) {
        fileURL <-
            paste0("https://ftp.ncbi.nlm.nih.gov/blast/db/", file)

        bfc <- blast_db_cache()
        rid <-
            BiocFileCache::bfcquery(bfc, file, "rname")$rid
        if (!length(rid)) {
            if (verbose) {
                message("Downloading ", file)
            }
            rid <-
                names(BiocFileCache::bfcadd(bfc, file, fileURL))
        }

        if (!isFALSE(BiocFileCache::bfcneedsupdate(bfc, rid))) {
            BiocFileCache::bfcdownload(bfc, rid)
        }

        BiocFileCache::bfcrpath(bfc, rids = rid)
    }
