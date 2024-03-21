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
#' @param args string including additional arguments passed on to `makeblastdb`.
#' @author Michael Hahsler
#' @seealso [[blast()] for opening and searching BLAST databases.
#' @references BLAST+
#' \url{http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download}
#' @keywords model
#' @examples
#'
#' \dontrun{
#' ## check if makeblastdb is correctly installed
#' Sys.which("makeblastdb")
#'
#' ## see possible arguments
#' blast_help("makeblastdb")
#'
#' ## create a database for some example sequences
#' seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
#'     package="rBLAST"))
#'
#' ## 1. write the FASTA file
#' dir <- tempdir()
#' writeXStringSet(seq, filepath = file.path(dir, "seqs.fasta"))
#'
#' ## 2. make database
#' makeblastdb(file.path(dir, "seqs.fasta"), dbtype = "nucl")
#'
#' ## 3. open database
#' db <- blast(file.path(dir, "seqs.fasta"))
#' db
#'
#' ## 4. perform search (first sequence in the db should be a perfect match)
#' predict(db, seq[1])
#'
#' ## clean up
#' unlink(dir, recursive = TRUE)
#' }
#' @export
makeblastdb <- function(file, dbtype = "nucl", args = "") {
  system(paste(
    .findExecutable("makeblastdb"),
    "-in",
    file,
    "-dbtype",
    dbtype,
    args
  ))
}
