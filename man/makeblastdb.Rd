\name{makeblastdb}
\alias{makeblastdb}
\title{
Create BLAST Databases
}
\description{
Call the makeblastdb utility to create a BLAST database from a FASTA file.
}
\usage{
makeblastdb(file, dbtype = "nucl", args="")
}
\arguments{
  \item{file}{ input file/database name. \bold{Note} that the filename and path cannot contain whitespaces. }
  \item{dbtype}{ molecule type of target db (\code{"nucl"} or \code{"prot"}).}
  \item{args}{ string including all further arguments passed on to makeblastdb. }
}
\details{
R needs to be able to find the executable (mostly an issue with Windows).
Try \code{Sys.which("makeblastdb")} to see if the program is properly installed.

Use \code{blast_help("makeblastdb")} to see all possible extra arguments.
Arguments need to be formated in exactly the way as they would be used for
the command line tool.
}
\references{
BLAST+ \url{http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download}
}
\author{
    Michael Hahsler
}
\examples{
\dontrun{
## check if makeblastdb is correctly installed
Sys.which("makeblastdb")

## see possible arguments
blast_help("makeblastdb")

## create a database for some example sequences
seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
    package="rBLAST"))

## 1. write the FASTA file
dir <- tempdir()
writeXStringSet(seq, filepath = file.path(dir, "seqs.fasta"))

## 2. make database
makeblastdb(file.path(dir, "seqs.fasta"), dbtype = "nucl")

## 3. open database
db <- blast(file.path(dir, "seqs.fasta"))
db

## 4. perform search (first sequence in the db should be a perfect match)
predict(db, seq[1])

## clean up
unlink(dir, recursive = TRUE)
}
}
\keyword{model}
