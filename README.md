
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lmww

<!-- badges: start -->
<!-- badges: end -->

The goal of lmww is to support thinking of linear models in terms of
factor weights, instead of factor absolute coefficients. This means
better interpretation of the model drivers, which helps to build
confidence in the model.

## Installation

You can install the development version of lmww like so:

``` r
# install.packages("devtools")
devtools::install_github("0xdomyz/lmww")
```

## Example

Standardize and fit a linear model showing the resulting weights:

``` r
library(lmww)

data <- purrr::map(mtcars, std) |> dplyr::bind_cols()
data$mpg <- mtcars$mpg

fit <- fit_lm(c("disp", "hp", "wt", "qsec", "am"), "mpg", data)
fit
#> $fml
#> mpg ~ 1 + disp + hp + wt + qsec + am
#> <environment: 0x000001c6046492e0>
#> 
#> $fit
#> (Intercept)        disp          hp          wt        qsec          am 
#>   20.090625    1.392780   -1.451513   -3.996345    1.799267    1.731725 
#> 
#> $weights
#>  disp    hp    wt  qsec    am 
#> 13.43 14.00 38.53 17.35 16.70 
#> 
#> $signs
#> disp   hp   wt qsec   am 
#>    1   -1   -1    1    1 
#> 
#> $metrics
#>        r2     adjr2       dxy 
#> 0.8637377 0.8375334 0.8241309
```

Round off the weights to more understandable numbers and examine the
model fit:

``` r
test_lm(
  c("disp", "hp", "wt", "qsec", "am"), c(0.1, 0.15, 0.4, 0.2, 0.15),
  fit$signs, "mpg", data
)
#> $fml
#> mpg ~ 0 + 0.1 * disp + -0.15 * hp + -0.4 * wt + 0.2 * qsec + 
#>     0.15 * am
#> <environment: 0x000001c606080ec8>
#> 
#> $calibration
#> (Intercept)           x 
#>   20.090625    9.381737 
#> 
#> $weights
#> [1] 10 15 40 20 15
#> 
#> $metrics
#>        r2     adjr2       dxy 
#> 0.8599541 0.8330222 0.8323108
```

WIP, constraining some of the weights with upper and lower bounds:

``` r
FALSE
#> [1] FALSE
```
