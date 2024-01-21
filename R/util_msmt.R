make_r2 <- function(preds, actual, model_has_intercept = TRUE) {
    if (model_has_intercept) {
        rss <- sum((preds - actual)^2, na.rm = TRUE)
        tss <- sum((actual - mean(actual))^2, na.rm = TRUE)
        return(1 - rss / tss)
    } else {
        rss <- sum((preds - actual)^2, na.rm = TRUE)
        tss <- sum((actual)^2, na.rm = TRUE)
        return(1 - rss / tss)
    }
}

#' Make adjusted/unadjusted R squared
#'
#' @param preds numeric vector
#' @param actual numeric vector
#' @param k number of predictors
#' @param model_has_intercept logical
#'
#' @return numeric
#' @export
#'
#' @examples
#' fit <- lm(mpg ~ cyl + disp, mtcars)
#'
#' summary(fit)
#' # make_r2(predict(fit, mtcars), mtcars$mpg)
#' make_adjr2(predict(fit, mtcars), mtcars$mpg, 2)
#'
#' fit <- lm(mpg ~ 0 + cyl + disp, mtcars)
#'
#' summary(fit)
#' # make_r2(predict(fit, mtcars), mtcars$mpg, model_has_intercept = FALSE)
#' make_adjr2(predict(fit, mtcars), mtcars$mpg, 2, model_has_intercept = FALSE)
make_adjr2 <- function(preds, actual, k, model_has_intercept = TRUE) {
    n <- sum(!is.na(preds))
    r2 <- make_r2(preds, actual, model_has_intercept)
    if (model_has_intercept) {
        return(1 - (1 - r2) * (n - 1) / (n - k - 1))
    } else {
        return(1 - (1 - r2) * (n) / (n - k))
    }
}


#' Make rmse
#'
#' @param preds numeric vector
#' @param actual numeric vector
#'
#' @return numeric
#' @export
#'
#' @examples
#' fit <- lm(mpg ~ cyl + disp, mtcars)
#' summary(fit)
#' make_rmse(fit$fitted.value, mtcars$mpg)
#' sqrt(sum(fit$residuals^2) / length(fit$residuals))
make_rmse <- function(preds, actual) {
    sqrt(mean((preds - actual)^2, na.rm = TRUE))
}
