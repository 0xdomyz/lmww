% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test_lm.R
\name{test_lm}
\alias{test_lm}
\title{Test linear model specified via weights, report calibration parameters, and metrics}
\usage{
test_lm(variables, weights, signs, target, data, concise = TRUE)
}
\arguments{
\item{variables}{vector of variable names}

\item{weights}{vector of weights of variables}

\item{signs}{vector of signs of weights}

\item{target}{target variable name}

\item{data}{data frame}

\item{concise}{whether to return concise output}
}
\value{
list
}
\description{
Test linear model specified via weights, report calibration parameters, and metrics
}
\examples{
data <- purrr::map(mtcars, std) |> dplyr::bind_cols()
data$mpg <- mtcars$mpg

fit <- fit_lm(c("disp", "hp", "wt", "qsec", "am"), "mpg", data)
fit

test_lm(
    c("disp", "hp", "wt", "qsec", "am"), c(0.1, 0.15, 0.4, 0.2, 0.15),
    fit$signs, "mpg", data
)

test_lm(
    c("disp", "hp", "wt", "qsec", "am"), c(0, 0.2, 0.4, 0.2, 0.2),
    fit$signs, "mpg", data
)
}
