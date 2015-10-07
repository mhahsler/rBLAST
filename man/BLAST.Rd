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
blast(db=NULL)
blast_help()
\method{predict}{BLAST}(object, newdata,
        BLAST_args="",  ...)
\method{print}{BLAST}(x, info=TRUE, ...)
}
\arguments{
  \item{db}{ the database file to be searched (without file extension).}
  \item{object, x}{ A BLAST object. }
  \item{newdata}{ the query as an object of class XStringSet.}
  \item{BLAST_args}{ additional arguments in command-line style.}
  \item{info}{ print information about the database (needs blastdbcmd
  in the path).}
  \item{...}{ additional arguments are ignored.}
}
\details{
    The blast+ software has to be installed and
    be executable by the system. Try \code{Sys.which("blastn")} to
    see if the program is properly installed.

    For Linux (Debian/Ubuntu) install package: ncbi-blast+
    For Windows or OS X you can find the software at
    \url{ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/}.

    Also a database is needed. NCBI BLAST databases are updated daily
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
}
}
\keyword{model}
