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
#' Call the `makeblastdb` utility to create a BLAST database from a FASTA file.
#'
#' R needs to be able to find the executable (mostly an issue with Windows).
#' Try `Sys.which("makeblastdb")` to see if the program is properly
#' installed.
#'
#' Use `blast_help("makeblastdb")` to see all possible extra arguments.
#' Arguments need to be formated in exactly the way as they would be used for
#' the command line tool.
#'
#' @param file input file/database name. **Note** that the filename and path
#' cannot contain whitespaces.
#' @param dbtype molecule type of target db (`"nucl"` or `"prot"`).
#' @param db_name name of the database (files).
#' @param hash_index logical; create index of sequence hash values.
#' @param args string including additional arguments passed on
#'     to `makeblastdb`.
#' @param verbose logical; show the progress report produced by `makeblastdb`?
#' @author Michael Hahsler
#' @seealso [blast()] for opening and searching BLAST databases.
#' @references BLAST+
#' \url{http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download}
#' @returns Nothing
#' @keywords model
#' @examples
#' ## check if makeblastdb is correctly installed
#' Sys.which("makeblastdb")
#'
#' ## only run if blast is installed
#' if (has_blast()){
#'
#' ## see possible arguments
#' blast_help("makeblastdb")
#'
#' ## read some example sequences
#' seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
#'     package = "rBLAST"
#' ))
#'
#' ## 1. write the FASTA file
#' writeXStringSet(seq, filepath = "seqs.fasta")
#'
#' ## 2. make database
#' makeblastdb(file = "seqs.fasta", db_name = "db/small", dbtype = "nucl")
#'
#' ## 3. open database
#' db <- blast("db/small")
#' db
#'
#' ## 4. perform search (first sequence in the db should be a perfect match)
#' predict(db, seq[1])
#'
#' ## clean up
#' unlink("seqs.fasta")
#' unlink("db", recursive = TRUE)
#' }
#' @export
makeblastdb <- function(file, db_name = NULL, dbtype = "nucl",
                        hash_index = TRUE,
                        args = "", verbose = TRUE) {
    system2(
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
}
