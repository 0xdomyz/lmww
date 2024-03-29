% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/util_std.R
\name{std}
\alias{std}
\title{Standardize a numeric vector}
\usage{
std(v)
}
\arguments{
\item{v, }{a numeric vector, NA is allowed.}
}
\value{
a numeric vector.
}
\description{
Standardize a numeric vector
}
\examples{
std(c(1, 2, 3, 4, 5, NA, 7))

# apply std on data
purrr::map(mtcars, std) |> dplyr::bind_cols()
}
