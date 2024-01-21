#' Fit linear model, additionally report weights, additional metrics
#'
#' @param variables vector of variable names
#' @param target target variable name
#' @param data data frame
#' @param model_has_intercept whether model has intercept
#' @param concise whether to return concise output
#'
#' @return list
#' @export
#'
#' @examples
#' data <- purrr::map(mtcars, std) |> dplyr::bind_cols()
#' data$mpg <- mtcars$mpg
#'
#' fit_lm(c("cyl", "disp"), "mpg", data)
#'
#' fit_lm(c("cyl", "disp"), "mpg", data, concise = FALSE)
#'
#' vars <- setdiff(colnames(mtcars), "mpg")
#' fit_lm(vars, "mpg", data)
#' fit_lm(c("disp", "hp", "wt", "qsec", "am"), "mpg", data)
fit_lm <- function(variables,
                   target,
                   data,
                   model_has_intercept = TRUE,
                   concise = TRUE) {
    fml <- make_formula(variables, target, model_has_intercept * 1)
    fit <- stats::lm(fml, data)
    ce <- fit$coefficients
    if (model_has_intercept) {
        wts <- parameters_to_weights(ce)
    } else {
        wts <- parameters_to_weights(c(0, ce))
    }
    preds <- stats::predict(fit, data)
    actual <- data[[target]]
    r2 <- make_r2(preds, actual, model_has_intercept)
    k <- length(variables)
    adjr2 <- make_adjr2(preds, actual, k, model_has_intercept)
    dxy <- Hmisc::rcorr.cens(preds, actual)["Dxy"]

    if (concise) {
        metrics <- c(r2, adjr2, dxy)
        names(metrics) <- c("r2", "adjr2", "dxy")
        return(list(
            "fml" = fml,
            "fit" = fit$coefficients,
            "weights" = round(wts$weights * 100, 2),
            "signs" = wts$signs,
            "metrics" = metrics
        ))
    } else {
        print(summary(fit))
        return(list(
            "fml" = fml,
            "fit" = fit,
            "weights" = wts,
            "r2" = r2,
            "adjr2" = adjr2,
            "dxy" = dxy
        ))
    }
}
