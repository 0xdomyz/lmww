# Test linear model specified via weights, report calibration parameters, and metrics
#
# Examples
# -------------
# > std <- function(v) (v-mean(v, na.rm = TRUE))/sqrt(var(v, na.rm = TRUE))
# > data = purrr::map(mtcars, std) |> dplyr::bind_cols()
# > data$mpg = mtcars$mpg
# > fit = fit_lm(c('disp', 'hp', 'wt', 'qsec', 'am'), 'mpg', data, 5)
# > fit
# > test_wts(c('disp', 'hp', 'wt', 'qsec', 'am'), c(0.1, 0.15, 0.4, 0.2, 0.15),
# >     fit$signs, 'mpg', data, 5)
# > test_wts(c('disp', 'hp', 'wt', 'qsec', 'am'), c(0, 0.2, 0.4, 0.2, 0.2),
# >     fit$signs, 'mpg', data, 4)
# test_wts <- function(variables,
#                      weights,
#                      signs,
#                      target,
#                      data,
#                      k,
#                      concise = TRUE) {
#     man_wts <- weights
#     names(man_wts) <- variables
#     fml <- parameters_to_formula(c(0, man_wts * signs), target)
#     x <- eval(parse(text = fml), data)
#     y <- data[[target]]
#     ce <- lm(y ~ 1 + x)$coefficients
#     calibration_a <- ce[2]
#     calibration_b <- ce[1]

#     preds <- eval(parse(text = fml), data) * calibration_a + calibration_b
#     actual <- data[[target]]
#     r2 <- make_r2(preds, actual)
#     adjr2 <- make_adjr2(preds, actual, k)
#     dxy <- rcorr.cens(preds, actual)["Dxy"]

#     plt_data <- data.frame(fitted = preds, actual = actual)
#     plt <- plot_scatter(plt_data, "fitted", "actual")

#     if (concise) {
#         metrics <- c(r2, adjr2, dxy)
#         names(metrics) <- c("r2", "adjr2", "dxy")
#         return(list(
#             "fml" = fml,
#             "calibration" = ce,
#             "weights" = round(weights * 100, 2),
#             "metrics" = metrics
#         ))
#     } else {
#         plt
#         return(list(
#             "fml" = fml,
#             "calibration_a" = calibration_a,
#             "calibration_b" = calibration_b,
#             "weights" = weights,
#             "r2" = r2,
#             "adjr2" = adjr2,
#             "dxy" = dxy,
#             "plt" = plt
#         ))
#     }
# }
