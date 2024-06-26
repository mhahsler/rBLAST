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
#' Open a BLAST database and execute blastn (blastp or blastx)
#' from blast+ to find sequences matches.
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
#' @param db the database file to be searched (without file extension).
#' @param type BLAST program to use (e.g., `blastn`, `blastp`, `blastx`).
#' @param object,x An open BLAST database as a BLAST object created
#' with [blast()].
#' @param newdata the query as an object of class [Biostrings::XStringSet].
#' @param remote logical execute the query remotely on the NCBI server. `db`
#'  needs to be the name of a database available in the server.
#' @param BLAST_args additional arguments in command-line style.
#' @param custom_format custom format specified by space delimited format
#' specifiers.
#' @param info print information about the database (needs the executable
#'  `blastdbcmd` in the
#' path).
#' @param verbose logical; print progress and debugging information.
#' @param keep_tmp logical; keep temporary files for debugging.
#' @param info show additional data base information.
#' @param ...  additional arguments are ignored.
#' @return
#' * `blast()` returns a BLAST database object which can be used for
#' queries (via `predict`).
#' * `predict` returns a data.frame containing
#' the BLAST results.
#' * `has_blast()` returns `TRUE` if the blast software installation can be
#' found and `FALSE` otherwise.
#' @author Michael Hahsler
#' @references BLAST Help - BLAST+ Executable:
#' https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html
#'
#' BLAST Command Line Applications User Manual,
#' https://www.ncbi.nlm.nih.gov/books/NBK279690/
#' @keywords model
#' @examples
#' ## check if blastn is correctly installed. Should return the path to the
#' ##   executable
#' Sys.which("blastn")
#'
#' ## only run if blast is installed
#' if (has_blast()) {
#'     ## check version you should have version 1.8.1+
#'     system2("blastn", "-version")
#'
#'     ## download the latest version of the 16S Microbial
#'     ##  rRNA data base from NCBI using the local chache
#'     tgz_file <- blast_db_get("16S_ribosomal_RNA.tar.gz")
#'
#'     ## extract the database files
#'     untar(tgz_file, exdir = "./16S_rRNA_DB")
#'
#'     ## Note the database file can also downloaded without using a
#'     ##    cache using download.file
#'     # download.file(paste("https://ftp.ncbi.nlm.nih.gov/blast/db",
#'     #    "16S_ribosomal_RNA.tar.gz", sep = "/"),
#'     #    "16S_ribosomal_RNA.tar.gz", mode = "wb")
#'     # untar("16S_ribosomal_RNA.tar.gz", exdir = "./16S_rRNA_DB")
#'
#'     ## A BLAST database is just a set of files. It is a good idea to
#'     ## organize the files in a directory.
#'     list.files("./16S_rRNA_DB")
#'
#'     ## load a BLAST database (replace db with the location + name of
#'     ##   the BLAST DB without the extension)
#'     bl <- blast(db = "./16S_rRNA_DB/16S_ribosomal_RNA")
#'     bl
#'
#'     ## read a single example sequence to BLAST
#'     seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
#'         package = "rBLAST"
#'     ))[1]
#'     seq
#'
#'     ## query a sequence using BLAST
#'     cl <- predict(bl, seq)
#'     cl[1:5, ]
#'
#'     ## Pass on BLAST arguments (99% identity) and use a custom format
#'     ## (see BLAST documentation)
#'     fmt <- paste(
#'         "qaccver saccver pident length mismatch gapopen qstart qend",
#'         "sstart send evalue bitscore qseq sseq"
#'     )
#'     cl <- predict(bl, seq,
#'         BLAST_args = "-perc_identity 99",
#'         custom_format = fmt
#'     )
#'     cl
#'
#'     ## cleanup the example: delete the database files
#'     unlink("./16S_rRNA_DB", recursive = TRUE)
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
                         class = "BLAST"))
    }

    db <- file.path(normalizePath(dirname(db)), basename(db))
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
        writeXStringSet(x, infile, append = FALSE, format = "fasta")

        cmd <- .findExecutable(exe)
        args <- c(
            "-db",
            db,
            ifelse(remote, "-remote", ""),
            "-query",
            infile,
            "-out",
            outfile,
            '-outfmt "10',
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

        system2(
            command = cmd,
            args = args
        )

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
        if (verbose) {
            cat(" * reading results from ", outfile, "\n")
        }

        if (is(
            try(
                cl_tab <-
                    read.table(outfile,
                        sep = ",",
                        quote = "",
                        col.names = c_names
                    ),
                silent = FALSE
            ),
            "try-error"
        )) {
            warning("BLAST did not return any matches!")
            cl_tab <- data.frame(matrix(ncol = length(c_names), nrow = 0))
        }

        if (verbose) {
            cat(" * found", nrow(cl_tab), "matches.\n")
        }

        cl_tab
    }

#' @rdname blast
#' @export
has_blast <- function() {
    length(.findExecutable("blastn",
        interactive = FALSE
    )) != 0
}
