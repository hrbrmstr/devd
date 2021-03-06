% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/devd.r
\name{devd_stop}
\alias{devd_stop}
\title{Stop a running devd process}
\usage{
devd_stop(p)
}
\arguments{
\item{p}{a [processx::process()] object (the return value from [devd_start])}
}
\description{
Stop a running devd process
}
\examples{
\dontrun{
dd <- devd_start()
devd_log(dd)
devd_stop(dd)
}
}
