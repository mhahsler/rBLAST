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

blast  <- function(db = NULL, type = "blastn") {
  if (is.null(db))
    stop("No BLAST database specified!")
  db <- file.path(normalizePath(dirname(db)), basename(db))
  if (length(Sys.glob(paste(db, "*", sep = ""))) < 1)
    stop("BLAST database does not exist! (tried to open: ", db, ")")

  ### check for spaces
  if (length(grep(" ", db)) > 0)
    stop(
      "Database name or path contains spaced. rename or move database to remove spaces (current path: ",
      db,
      ")"
    )

  ### check if executable is available
  .findExecutable(type)

  ### check database
  status <-
    try(system2(
      .findExecutable("blastdbcmd"),
      args = c("-db", db, "-info"),
      stdout = FALSE
    ))
  if (status != 0)
    stop("Problem loading the database! (trying to execute: blastdbcmd)")

  structure(list(db = db, type = type), class = "BLAST")
}

print.BLAST <- function(x, info = TRUE, ...) {
  cat("BLAST Database\nLocation:", x$db, "\n")
  cat("BLAST Type:", x$type, "\n")

  if (info) {
    out <- system2(
      .findExecutable("blastdbcmd"),
      args = c("-db", x$db,
               "-info"),
      stdout = TRUE
    )
    cat(paste(out, collapse = "\n"))
    cat("\n")
  }
}


blast_help <- function(type = "blastn") {
  system2(.findExecutable(c(type)), args = c("-help"))
}


predict.BLAST <-
  function(object,
           newdata,
           BLAST_args = "",
           custom_format = "",
           verbose = FALSE,
           keep_tmp = FALSE,
           ...) {
    db <- object$db
    exe <- object$type
    x <- newdata

    ## get temp files and change working directory
    wd <- tempdir()
    dir <- getwd()
    temp_file <- basename(tempfile(tmpdir = wd))
    on.exit({
      if (!keep_tmp)
        file.remove(Sys.glob(paste(temp_file, "*", sep = "")))
      else
        cat("Temporary BLAST files kept in", wd, "\n")
      setwd(dir)
    })

    if (verbose)
      cat("Starting BLAST\n * all files are written to:", wd , "\n")
    setwd(wd)

    infile <- paste(temp_file, ".fasta", sep = "")
    outfile <- paste(temp_file, "_BLAST_out.txt", sep = "")

    if (verbose)
      cat(" * writing FASTA query sequences to", infile , "\n")
    writeXStringSet(x, infile, append = FALSE, format = "fasta")

    cmd <- .findExecutable(exe)
    args <- c(
      "-db",
      db,
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

    if (verbose)
      cat(" * running", .findExecutable(exe) ,
          args, "\n")

    system2(command = cmd,
            args = args)

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
    } else{
      c_names <- unlist(strsplit(custom_format, split = " +"))
    }

    ## read and parse BLAST output
    if (verbose)
      cat(" * reading results from ", outfile , "\n")

    if (is(try(cl_tab <-
               read.table(outfile,
                          sep = ",",
                          quote = "",
                          col.names = c_names),
               silent = FALSE)
           , "try-error")) {
      warning("BLAST did not return any matches!")
      cl_tab <- data.frame(matrix(ncol = length(c_names), nrow = 0))
    }

    # stitle returns two columns???
    #if(ncol(cl_tab) != length(c_names)) stop("Problem with format (e.g., custom_format)!")
    #colnames(cl_tab) <- c_names

    if (verbose)
      cat(" * found", nrow(cl_tab) , "matches.\n")

    cl_tab
  }
