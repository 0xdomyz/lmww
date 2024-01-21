# Fit linear model, additionally report weights, additional metrics
#
# Examples
# ------------
# > std <- function(v) (v-mean(v, na.rm = TRUE))/sqrt(var(v, na.rm = TRUE))
# > data = purrr::map(mtcars, std) |> dplyr::bind_cols()
# > data$mpg = mtcars$mpg
# > fit_lm(c('cyl', 'disp'), 'mpg', data, 2)
# > fit_lm(c('cyl', 'disp'), 'mpg', data, 2, concise=FALSE)
# > vars = setdiff(colnames(mtcars),'mpg')
# > fit_lm(vars, 'mpg', data, 10)
# > fit_lm(c('disp', 'hp', 'wt', 'qsec', 'am'), 'mpg', data, 5)
# fit_lm <- function(variables,
#                    target,
#                    data,
#                    k,
#                    model_has_intercept = TRUE,
#                    concise = TRUE) {
#     fml <- make_formula(variables, target, model_has_intercept * 1)
#     fit <- lm(fml, data)
#     ce <- fit$coefficients
#     if (model_has_intercept) {
#         wts <- parameters_to_weights(ce)
#     } else {
#         wts <- parameters_to_weights(c(0, ce))
#     }
#     preds <- predict(fit, data)
#     actual <- data[[target]]
#     r2 <- make_r2(preds, actual, model_has_intercept)
#     adjr2 <- make_adjr2(preds, actual, k, model_has_intercept)
#     dxy <- rcorr.cens(preds, actual)["Dxy"]

#     plt_data <- data.frame(fitted = preds, actual = actual)
#     plt <- plot_scatter(plt_data, "fitted", "actual")

#     if (concise) {
#         metrics <- c(r2, adjr2, dxy)
#         names(metrics) <- c("r2", "adjr2", "dxy")
#         return(list(
#             "fml" = fml,
#             "fit" = fit$coefficients,
#             "weights" = round(wts$weights * 100, 2),
#             "signs" = wts$signs,
#             "metrics" = metrics
#         ))
#     } else {
#         print(summary(fit))
#         plt
#         return(list(
#             "fml" = fml,
#             "fit" = fit,
#             "weights" = wts,
#             "r2" = r2,
#             "adjr2" = adjr2,
#             "dxy" = dxy,
#             "plt" = plt
#         ))
#     }
# }
