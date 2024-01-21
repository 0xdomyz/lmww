
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lmww

<!-- badges: start -->
<!-- badges: end -->

The goal of lmww is to support thinking of linear models in terms of
factor weights, instead of factor absolute coefficients. This means
better interpretation of the model drivers, which helps in creating
confidence in the model.

## Installation

You can install the development version of lmww like so:

``` r
# install.packages("devtools")
devtools::install_github("0xdomyz/lmww")
```

## Example

Fit a linear model with weights:

``` r
library(lmww)
## basic example code
purrr::map(mtcars, std) |> dplyr::bind_cols()
#> # A tibble: 32 × 11
#>       mpg    cyl    disp     hp   drat       wt   qsec     vs     am   gear
#>     <dbl>  <dbl>   <dbl>  <dbl>  <dbl>    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#>  1  0.151 -0.105 -0.571  -0.535  0.568 -0.610   -0.777 -0.868  1.19   0.424
#>  2  0.151 -0.105 -0.571  -0.535  0.568 -0.350   -0.464 -0.868  1.19   0.424
#>  3  0.450 -1.22  -0.990  -0.783  0.474 -0.917    0.426  1.12   1.19   0.424
#>  4  0.217 -0.105  0.220  -0.535 -0.966 -0.00230  0.890  1.12  -0.814 -0.932
#>  5 -0.231  1.01   1.04    0.413 -0.835  0.228   -0.464 -0.868 -0.814 -0.932
#>  6 -0.330 -0.105 -0.0462 -0.608 -1.56   0.248    1.33   1.12  -0.814 -0.932
#>  7 -0.961  1.01   1.04    1.43  -0.723  0.361   -1.12  -0.868 -0.814 -0.932
#>  8  0.715 -1.22  -0.678  -1.24   0.175 -0.0278   1.20   1.12  -0.814  0.424
#>  9  0.450 -1.22  -0.726  -0.754  0.605 -0.0687   2.83   1.12  -0.814  0.424
#> 10 -0.148 -0.105 -0.509  -0.345  0.605  0.228    0.253  1.12  -0.814  0.424
#> # ℹ 22 more rows
#> # ℹ 1 more variable: carb <dbl>
```
