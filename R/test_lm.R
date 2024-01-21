#' Test linear model specified via weights, report calibration parameters, and metrics
#'
#' @param variables vector of variable names
#' @param weights vector of weights of variables
#' @param signs vector of signs of weights
#' @param target target variable name
#' @param data data frame
#' @param concise whether to return concise output
#'
#' @return list
#' @export
#'
#' @examples
#' data <- purrr::map(mtcars, std) |> dplyr::bind_cols()
#' data$mpg <- mtcars$mpg
#'
#' fit <- fit_lm(c("disp", "hp", "wt", "qsec", "am"), "mpg", data)
#' fit
#'
#' test_lm(
#'     c("disp", "hp", "wt", "qsec", "am"), c(0.1, 0.15, 0.4, 0.2, 0.15),
#'     fit$signs, "mpg", data
#' )
#'
#' test_lm(
#'     c("disp", "hp", "wt", "qsec", "am"), c(0, 0.2, 0.4, 0.2, 0.2),
#'     fit$signs, "mpg", data
#' )
test_lm <- function(variables,
                    weights,
                    signs,
                    target,
                    data,
                    concise = TRUE) {
    man_wts <- weights
    names(man_wts) <- variables
    fml <- parameters_to_formula(c(0, man_wts * signs), target)
    x <- eval(parse(text = fml), data)
    y <- data[[target]]
    ce <- stats::lm(y ~ 1 + x)$coefficients
    calibration_a <- ce[2]
    calibration_b <- ce[1]

    preds <- eval(parse(text = fml), data) * calibration_a + calibration_b
    actual <- data[[target]]
    r2 <- make_r2(preds, actual)
    k <- length(variables)
    adjr2 <- make_adjr2(preds, actual, k)
    dxy <- Hmisc::rcorr.cens(preds, actual)["Dxy"]

    if (concise) {
        metrics <- c(r2, adjr2, dxy)
        names(metrics) <- c("r2", "adjr2", "dxy")
        return(list(
            "fml" = fml,
            "calibration" = ce,
            "weights" = round(weights * 100, 2),
            "metrics" = metrics
        ))
    } else {
        return(list(
            "fml" = fml,
            "calibration_a" = calibration_a,
            "calibration_b" = calibration_b,
            "weights" = weights,
            "r2" = r2,
            "adjr2" = adjr2,
            "dxy" = dxy
        ))
    }
}
