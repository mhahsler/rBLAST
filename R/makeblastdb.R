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

#' Create BLAST Databases
#'
#' Run the BLAST+ `makeblastdb` utility to create a local nucleotide or protein
#' database from a FASTA file.
#'
#' R needs to be able to find the executable (mostly an issue with Windows).
#' Try `Sys.which("makeblastdb")` to see if the program is properly
#' installed.
#'
#' Use `blast_help("makeblastdb")` to see all available options. Additional
#' options supplied through `args` are passed to the command-line program.
#'
#' When `db_name` is `NULL`, BLAST uses `file` as the output database prefix.
#' Otherwise, database index files are created using the `db_name` prefix. The
#' destination directory must already exist. Paths containing whitespace are
#' not supported by this interface.
#'
#' @family blast
#' @param file Character scalar giving the input FASTA path.
#' @param dbtype Character scalar specifying the database molecule type:
#'   `"nucl"` or `"prot"`.
#' @param db_name Optional character scalar giving the output database prefix,
#'   including its directory if needed.
#' @param hash_index Logical scalar; add `-hash_index` to create an index of
#'   sequence hash values.
#' @param args Character scalar containing additional `makeblastdb`
#'   command-line options.
#' @param verbose Logical scalar; show output produced by `makeblastdb`.
#' @author Michael Hahsler
#' @return The integer exit status returned by `makeblastdb`; zero indicates
#'   success. The function is primarily called for its side effect of creating
#'   the database files.
#' @keywords model
#' @examples
#' ## Only run if BLAST is installed
#' if (has_blast()) {
#'     ## Create an example BLAST DB
#'     seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
#'         package = "rBLAST"
#'     ))
#'     work_dir <- tempfile("rBLAST-db-")
#'     dir.create(work_dir)
#'     fasta <- file.path(work_dir, "sequences.fasta")
#'     db_path <- file.path(work_dir, "database")
#'     writeXStringSet(seq, fasta)
#'
#'     status <- makeblastdb(
#'         fasta, db_name = db_path, dbtype = "nucl", verbose = FALSE
#'     )
#'     status
#'
#'     ## Created DB files
#'     Sys.glob(paste0(db_path, ".*"))
#'
#'     ## Cleanip
#'     unlink(work_dir, recursive = TRUE)
#' }
#' @export
makeblastdb <- function(file, db_name = NULL, dbtype = "nucl",
                        hash_index = TRUE,
                        args = "", verbose = TRUE) {
    status <- system2(
        .findExecutable("makeblastdb"),
        paste(
            "-in",
            file,
            "-dbtype",
            dbtype,
            ifelse(!is.null(db_name), paste("-out", db_name), ""),
            ifelse(hash_index, "-hash_index", ""),
            args
        ),
        stdout = ifelse(verbose, "", FALSE)
    )

    if(status)
      stop("makeblastdb failed with a non-zero status: ", status)

    return(invisible(status))
}
