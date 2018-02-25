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
  if(is.null(db)) stop("No BLAST database specified!")
  db <- file.path(normalizePath(dirname(db)), basename(db))
  if(length(Sys.glob(paste(db, "*", sep="")))<1) stop("BLAST database does not exit!")

  ### check if executable is available
  .findExecutable(type)

  ### check database
  status <- try(system(paste(.findExecutable("blastdbcmd"), "-db", db,
      "-info"), ignore.stdout = TRUE, ignore.stderr = FALSE))
  if(status != 0) stop("Problem loading the database.")

  structure(list(db = db, type = type), class="BLAST")
}

print.BLAST <- function(x, info=TRUE, ...) {
  cat("BLAST Database\nLocation:", x$db, "\n")
  cat("BLAST Type:", x$type, "\n")

  if(info) {
    out <- system(paste(.findExecutable("blastdbcmd"), "-db", x$db,
      "-info"), intern=TRUE)
    cat(paste(out, collapse="\n"))
    cat("\n")
  }
}

blast_help <- function(type = "blastn") {
  system(paste(.findExecutable(c(type)), "-help"))
}


predict.BLAST <- function(object, newdata, BLAST_args="", custom_format ="",
  ...) {

  db <- object$db
  exe <- object$type
  x <- newdata

  ## get temp files and change working directory
  wd <- tempdir()
  dir <- getwd()
  temp_file <- basename(tempfile(tmpdir = wd))
  on.exit({
    #cat(temp_file, "\n")
    file.remove(Sys.glob(paste(temp_file, "*", sep="")))
    setwd(dir)
  })
  setwd(wd)

  infile <- paste(temp_file, ".fasta", sep="")
  outfile <- paste(temp_file, "_BLAST_out.txt", sep="")

  writeXStringSet(x, infile, append=FALSE, format="fasta")

  system(paste(.findExecutable(exe), "-db", db,
    "-query", infile, "-out", outfile, '-outfmt "10', custom_format,
    '"', BLAST_args))

  ## rdp output column names
  if(custom_format == "") {
    c_names <- c("QueryID",  "SubjectID", "Perc.Ident",
      "Alignment.Length", "Mismatches", "Gap.Openings", "Q.start", "Q.end",
      "S.start", "S.end", "E", "Bits" )
  }else{
    c_names <- unlist(strsplit(custom_format, split = " +"))
  }

  ## read and parse rdp output
  if(is(try(cl_tab <- read.table(outfile, sep=",", quote = ""), silent=TRUE), "try-error")) {
    warning("BLAST did not return a match!")
    cl_tab <- data.frame(matrix(ncol=length(c_names), nrow=0))
  }

  if(ncol(cl_tab) != length(c_names)) stop("Problem with format (e.g., custom_format)!")
  colnames(cl_tab) <- c_names

  cl_tab
}




