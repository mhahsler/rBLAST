#' @keywords internal
#'
#' @section Package overview:
#'
#' rBLAST provides an R interface to locally installed NCBI BLAST+ programs.
#' Use [makeblastdb()] to build a local database, [blast()] to open it, and
#' `predict()` to search it with sequences stored in Biostrings containers.
#' [blast_db_get()] can download and cache prebuilt NCBI database archives.
#'
#' BLAST+ is external software and must be installed separately. Use
#' [has_blast()] and `Sys.which()` to diagnose executable discovery.
#'
#' @section Citation:
#'
#' Run `citation("rBLAST")` to obtain the citation for the installed package
#' version.
#'
#' @seealso [blast()], [makeblastdb()], [blast_db_get()]
#'
"_PACKAGE"
