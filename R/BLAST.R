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


#' Basic Local Alignment Search Tool (BLAST)
#'
#' Open a local or remote BLAST database and search it with a BLAST+
#' command-line program such as `blastn`, `blastp`, or `blastx`.
#'
#' # Installing BLAST+
#' The BLAST+ software needs to be installed on your system. Installation
#' instructions are available in this package's
#' [INSTALL](https://github.com/mhahsler/rBLAST/blob/devel/INSTALL) file and
#' at \url{https://www.ncbi.nlm.nih.gov/books/NBK569861/}.
#'
#' R needs to be able to find the executable. After installing the software,
#' try in R
#' ```
#' Sys.which("blastn")
#' ```
#'
#' If the command returns "" instead of the path to the executable,
#' then you need to set the environment variable called PATH. In R
#' ```
#' Sys.setenv(PATH = paste(Sys.getenv("PATH"),
#'    "path_to_your_BLAST_installation", sep=.Platform$path.sep))
#' ```
#' # BLAST Databases
#' You will also need a database. NCBI BLAST databases are updated daily and
#' may be downloaded via FTP from \url{https://ftp.ncbi.nlm.nih.gov/blast/db/}.
#' See [blast_db_cache()] on how to manage a local cache of database files.
#'
#' BLAST databases are a set of database files with different extensions.
#' All files start with the same database name. For example,
#' `16S_ribosomal_RNA.tar.gz` contains
#' files starting with `16S_ribosomal_RNA` which is the database name used
#' for calling `blast()`.
#'
#' Large databases are separated into several archives numbered `00`, `01`, etc.
#' Download all archives and extract the files in the same directory.
#' All files will have a common name which is the database name used for calling
#' `blast()`.
#' @name blast
#' @aliases blast BLAST
#' @family blast
#' @param db Character scalar naming the database to search. For a local
#'   database, supply the path and database prefix without an index-file
#'   extension. For a remote search, supply an NCBI database name such as
#'   `"nt"` or `"nr"`.
#' @param type Character scalar naming the BLAST+ search program, for example
#'   `"blastn"`, `"blastp"`, or `"blastx"`. The program must be compatible
#'   with the query sequences and database type.
#' @param object,x An open BLAST database as a BLAST object created
#' with [blast()].
#' @param newdata Query sequences as a [Biostrings::XStringSet] object. Use a
#'   DNA or RNA string set with nucleotide searches and an amino-acid string
#'   set with protein searches.
#' @param remote Logical scalar. If `TRUE`, execute the query on an NCBI server.
#'   Remote searches use a shared service and can be substantially slower than
#'   local searches.
#' @param BLAST_args Character scalar containing additional BLAST+ command-line
#'   options, for example `"-perc_identity 99 -num_threads 4"`. The database,
#'   query, output file, and output format are managed by `predict.BLAST()` and
#'   should not be supplied here.
#' @param custom_format Character scalar containing space-separated BLAST
#'   output field specifiers, such as `"qseqid sseqid pident length"`. An empty
#'   string uses the standard 12-column tabular format. See the BLAST+
#'   documentation for available specifiers.
#' @param info Logical scalar. For `print.BLAST()`, query and display database
#'   metadata using `blastdbcmd`. Set to `FALSE` to print only the database path
#'   and BLAST program.
#' @param verbose Logical scalar; report the generated files, command, and
#'   number of matches.
#' @param keep_tmp Logical scalar; retain the query FASTA and BLAST output files
#'   in [tempdir()] for debugging. Retained files can be large, especially for
#'   repeated or parallel searches, and must be managed by the caller.
#' @param ... Additional arguments; currently ignored.
#' @return
#' * `blast()` returns an object of class `BLAST` containing the database,
#'   search program, and remote-search setting.
#' * `predict.BLAST()` returns a data frame with one row per hit. Column names
#'   follow `custom_format`, or the standard 12 BLAST fields when it is empty.
#'   A search without hits returns a zero-row data frame.
#' * `print.BLAST()` returns `NULL` invisibly and is called for its side effect.
#' * `blast_help()` returns the exit status from the BLAST+ help command.
#' * `has_blast()` returns a logical scalar indicating whether at least
#'   `blastn`, `makeblastdb`, and `blastdbcmd` can be
#'   found on `PATH`.
#'
#' @details
#' `blast()` validates a local database with `blastdbcmd -info`. It does not
#' download or create a database; use [blast_db_get()] for NCBI archives or
#' [makeblastdb()] to build a database from a FASTA file.
#'
#' `predict.BLAST()` writes `newdata` to a temporary FASTA file, invokes the
#' selected BLAST+ program, and parses delimiter-separated tabular output. A
#' FASTA write failure, a nonzero BLAST exit status, or a missing output file
#' produces an error before result parsing. Use `verbose = TRUE` together with
#' `keep_tmp = TRUE` when diagnosing a failed command.
#'
#' BLAST's own multithreading is controlled with the `-num_threads` option in
#' `BLAST_args`. This is distinct from running several `predict()` calls in
#' parallel.
#' @author Michael Hahsler
#' @references BLAST Help - BLAST+ Executable:
#' https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html
#'
#' BLAST Command Line Applications User Manual,
#' https://www.ncbi.nlm.nih.gov/books/NBK279690/
#' @keywords model
#' @examples
#' ## Check if BLAST is installed
#' Sys.which(c("blastn", "makeblastdb", "blastdbcmd"))
#'
#' ## Build and query a small local database (only if BLAST is installed).
#' if (has_blast()) {
#'     ## Create a BLAST DB
#'     seq <- readRNAStringSet(system.file(
#'         "examples/RNA_example.fasta",
#'         package = "rBLAST"
#'     ))
#'     work_dir <- tempfile("rBLAST-example-")
#'     dir.create(work_dir)
#'     fasta <- file.path(work_dir, "sequences.fasta")
#'     db_path <- file.path(work_dir, "database")
#'
#'     writeXStringSet(seq, fasta)
#'     makeblastdb(fasta, db_name = db_path, dbtype = "nucl", verbose = FALSE)
#'
#'     ## DB files
#'     list.files(work_dir)
#'
#'     ## Open and query the DB
#'     db <- blast(db_path)
#'     db
#'
#'     hits <- predict(
#'         db, seq[1],
#'         BLAST_args = "-perc_identity 99 -num_threads 2",
#'         custom_format = "qseqid sseqid pident length evalue bitscore"
#'     )
#'     hits
#'
#'     ## Cleanup
#'     unlink(work_dir, recursive = TRUE)
#' }
#' @importFrom utils read.table
#' @importFrom methods is
#' @import Biostrings
#' @export
blast <- function(db = NULL, remote = FALSE, type = "blastn") {
    if (is.null(db)) {
        stop("No BLAST database specified!")
    }

    if (remote) {
        return(structure(list(db = db, type = type, remote = TRUE),
            class = "BLAST"
        ))
    }

    db <- normalizePath(db, mustWork = FALSE)
    dbfiles <- Sys.glob(paste0(db, "*"))
    if (length(dbfiles) < 1) {
        stop("BLAST database does not exist! (tried to open: ", db, ")")
    }

    ### check for spaces
    if (length(grep(" ", db)) > 0) {
        stop(
            "Database name or path contains spaced.",
            " Rename or move database to remove spaces (current path: ",
            db,
            ")"
        )
    }

    ### check if executable is available
    .findExecutable(type)

    ### check database
    status <-
        try(system2(
            .findExecutable("blastdbcmd"),
            args = c("-db", db, "-info"),
            stdout = FALSE
        ))
    if (status != 0) {
        stop("Problem loading the database! (trying to execute: blastdbcmd)")
    }

    structure(list(db = db, remote = FALSE, type = type), class = "BLAST")
}

#' @rdname blast
#' @export
blast_help <- function(type = "blastn") {
    system2(.findExecutable(c(type)), args = c("-help"))
}

#' @rdname blast
#' @export
print.BLAST <- function(x, info = TRUE, ...) {
    cat("BLAST Database\nLocation:", x$db, "\n")
    cat("BLAST Type:", x$type, "\n")

    if (info) {
        out <- system2(
            .findExecutable("blastdbcmd"),
            args = c(
                "-db", x$db,
                "-info"
            ),
            stdout = TRUE
        )
        cat(paste(out, collapse = "\n"))
        cat("\n")
    }
}

#' @rdname blast
#' @export
predict.BLAST <-
    function(object,
             newdata,
             BLAST_args = "",
             custom_format = "",
             verbose = FALSE,
             keep_tmp = FALSE,
             ...) {
        db <- object$db
        remote <- object$remote
        if (is.null(remote)) {
            remote <- FALSE
        }
        exe <- object$type
        x <- newdata

        ## get temp files and change working directory
        wd <- tempdir()
        dir <- getwd()
        temp_file <- basename(tempfile(tmpdir = wd))
        on.exit({
            if (!keep_tmp) {
                file.remove(Sys.glob(paste(temp_file, "*", sep = "")))
            } else {
                cat("Temporary BLAST files kept in", wd, "\n")
            }
            setwd(dir)
        })

        if (verbose) {
            cat("Starting BLAST\n * all files are written to:", wd, "\n")
        }
        setwd(wd)

        infile <- paste(temp_file, ".fasta", sep = "")
        outfile <- paste(temp_file, "_BLAST_out.txt", sep = "")

        if (verbose) {
            cat(" * writing FASTA query sequences to", infile, "\n")
        }
        tryCatch(
            writeXStringSet(x, infile, append = FALSE, format = "fasta"),
            error = function(e) {
                stop(
                    "Failed to write BLAST query FASTA file: ",
                    file.path(wd, infile), "\n",
                    "Reason: ", conditionMessage(e),
                    call. = FALSE
                )
            }
        )

        if (!file.exists(infile)) {
            stop(
                "BLAST query FASTA file was not created: ",
                file.path(wd, infile),
                call. = FALSE
            )
        }

        if (is.na(file.info(infile)$size) || file.info(infile)$size == 0L) {
            stop(
                "BLAST query FASTA file is empty: ",
                file.path(wd, infile),
                call. = FALSE
            )
        }

        if (file.access(infile, mode = 4L) != 0L) {
            stop(
                "BLAST query FASTA file is not readable: ",
                file.path(wd, infile),
                call. = FALSE
            )
        }

        cmd <- .findExecutable(exe)
        args <- c(
            "-db",
            db,
            ifelse(remote, "-remote", ""),
            "-query",
            infile,
            "-out",
            outfile,
            '-outfmt "10 delim=@ ',
            ### 10 is CSV
            custom_format,
            '"',
            BLAST_args
        )

        if (verbose) {
            cat(
                " * running", .findExecutable(exe),
                args, "\n"
            )
        }

        status <- system2(
            command = cmd,
            args = args
        )

        if (!identical(status, 0L)) {
            stop(
                exe, " failed with exit status ", status,
                ". No BLAST results were read.\n",
                "Query file: ", file.path(wd, infile), "\n",
                "Output file: ", file.path(wd, outfile), "\n",
                "Run with `verbose = TRUE, keep_tmp = TRUE` to inspect ",
                "the command and temporary files.",
                call. = FALSE
            )
        }

        if (!file.exists(outfile)) {
            stop(
                exe, " completed without creating its output file: ",
                file.path(wd, outfile),
                call. = FALSE
            )
        }

        ## rdp output column names
        if (custom_format == "") {
            c_names <- c(
                "qseqid",
                "sseqid",
                "pident",
                "length",
                "mismatch",
                "gapopen",
                "qstart",
                "qend",
                "sstart",
                "send",
                "evalue",
                "bitscore"
            )
        } else {
            c_names <- unlist(strsplit(custom_format, split = " +"))
        }

        ## read and parse BLAST output
        output <- readLines(outfile)
        hits <- length(output)
        if (verbose) {
            cat(" * reading results from", outfile, "\n")
            cat(" * number of lines in results file:", hits, "\n")
        }

        if (hits == 0L) {
            return(data.frame(matrix(ncol = length(c_names), nrow = 0)))
        }

        cl_tab <-
            read.table(outfile,
                sep = "@",
                quote = "",
                col.names = c_names
            )


        if (verbose) {
            cat(" * found", nrow(cl_tab), "matches.\n")
        }

        cl_tab
    }

#' @rdname blast
#' @export
has_blast <- function() {
    exes <- c("blastn", "makeblastdb", "blastdbcmd")
    paths <- vapply(exes,
        FUN = .findExecutable, FUN.VALUE = character(1L),
        interactive = FALSE
    )
    all(nzchar(paths))
}
