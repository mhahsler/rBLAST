\name{BLAST}
\alias{blast}
\alias{blast_help}
\alias{predict.BLAST}
\alias{print.BLAST}
\title{
Basic Local Alignment Search Tool (BLAST)
}
\description{
Execute blastn from blast+.
}
\usage{
blast(db=NULL, type = "blastn")
blast_help(type = "blastn")
\method{predict}{BLAST}(object, newdata,
        BLAST_args="", custom_format="", ...)
\method{print}{BLAST}(x, info=TRUE, ...)
}
\arguments{
  \item{db}{ the database file to be searched (without file extension).}
  \item{type}{ BLAST program to use (e.g., blastn, blastp, blastx).}
  \item{object, x}{ A BLAST object. }
  \item{newdata}{ the query as an object of class XStringSet.}
  \item{BLAST_args}{ additional arguments in command-line style.}
  \item{custom_format}{ custom format specified by space delimited format specifiers. }
  \item{info}{ print information about the database (needs blastdbcmd
  in the path).}
  \item{...}{ additional arguments are ignored.}
}
\details{
The blast+ software has to be installed:
\itemize{
    \item{For Linux (Debian/Ubuntu)}{install package: ncbi-blast+}
    \item{For Windows or OS X} install the software from
    \url{ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/}.
}

R needs to be able to find the executable (mostly an issue with Windows).
Try \code{Sys.which("blastn")} to see if the program is properly installed.
If not, then you probably need to set the environment variable called PATH
using something like
\code{Sys.setenv(PATH = paste(Sys.getenv("PATH"), "path_to_BLAST", sep= .Platform$path.sep))}.
You can use Sys.getenv("PATH") first to see what is currently in the
search path.

You will also need a database. NCBI BLAST databases are updated daily
and may be downloaded via FTP
from \url{ftp://ftp.ncbi.nlm.nih.gov/blast/db/}.
}
\value{
\code{blast()} returns a blast database object which can be used for queries
(via \code{predict}). \code{predict}
returns a data.frame containing the
blast results.
}
\references{
BLAST+ \url{http://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download}
}
\author{
    Michael Hahsler
}
\examples{
\dontrun{
## check if blastn is correctly installed
Sys.which("blastn")

## download the 16S Microbial data base from NCBI
download.file("ftp://ftp.ncbi.nlm.nih.gov/blast/db/16SMicrobial.tar.gz",
  "16SMicrobial.tar.gz", mode='wb')
untar("16SMicrobial.tar.gz", exdir="16SMicrobialDB")

seq <- readRNAStringSet(system.file("examples/RNA_example.fasta",
	package="rBLAST"))

## shorten names
names(seq) <-  sapply(strsplit(names(seq), " "), "[", 1)
seq

## load a BLAST database (replace db with the location + name of the BLAST DB)
bl <- blast(db="./16SMicrobialDB/16SMicrobial")
bl

print(bl, info=TRUE)

## query a sequence using BLAST
cl <- predict(bl, seq[1,])
cl[1:5,]

## custom format (see BLAST documentation)
cl <- predict(bl, seq[1,], custom_format = "qseqid bitscore length")
cl[1:5,]
}
}
\keyword{model}
