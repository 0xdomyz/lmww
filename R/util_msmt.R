# # Make adjusted/unadjusted R squared
# #
# # Examples
# # --------------
# # > fit = lm(mpg ~ cyl + disp, mtcars); summary(fit)
# #
# # Residuals:
# #     Min      1Q  Median      3Q     Max
# # -4.4213 -2.1722 -0.6362  1.1899  7.0516
# #
# # Residual standard error: 3.055 on 29 degrees of freedom
# # Multiple R-squared:  0.7596,    Adjusted R-squared:  0.743
# # F-statistic: 45.81 on 2 and 29 DF,  p-value: 1.058e-09
# #
# # > make_r2(predict(fit, mtcars), mtcars$mpg)
# # [1] 0.7595658
# # > make_adjr2(predict(fit, mtcars), mtcars$mpg, 2)
# # [1] 0.7429841
# # > fit = lm(mpg ~ 0 + cyl + disp, mtcars); summary(fit)
# #
# # Residual standard error: 8.164 on 30 degrees of freedom
# # Multiple R-squared:  0.8576,    Adjusted R-squared:  0.8481
# # F-statistic: 90.33 on 2 and 30 DF,  p-value: 2.008e-13
# #
# # > make_r2(predict(fit, mtcars), mtcars$mpg, model_has_intercept = FALSE)
# # [1] 0.8575967
# # > make_adjr2(predict(fit, mtcars), mtcars$mpg, 2, model_has_intercept = FALSE)
# # [1] 0.8481031
# make_r2 <- function(preds, actual, model_has_intercept = TRUE) {
#     if (model_has_intercept) {
#         rss <- sum((preds - actual)^2, na.rm = TRUE)
#         tss <- sum((actual - mean(actual))^2, na.rm = TRUE)
#         return(1 - rss / tss)
#     } else if (!model_has_intercept) {
#         rss <- sum((preds - actual)^2, na.rm = TRUE)
#         tss <- sum((actual)^2, na.rm = TRUE)
#         return(1 - rss / tss)
#     } else {
#         return("invalid model_has_intercept")
#     }
# }
#
# make_adjr2 <- function(preds, actual, k, model_has_intercept = TRUE) {
#     n <- sum(!is.na(preds))
#     r2 <- make_r2(preds, actual, model_has_intercept)
#     if (model_has_intercept) {
#         return(1 - (1 - r2) * (n - 1) / (n - k - 1))
#     } else if (!model_has_intercept) {
#         return(1 - (1 - r2) * (n) / (n - k))
#     } else {
#         return("invalid model_has_intercept")
#     }
# }
#
# # Make rmse
# #
# # Examples
# # -----------
# # > fit = lm(mpg~cyl+disp, mtcars)
# # > summary(fit)
# # > make_rmse(fit$fitted.value, mtcars$mpg)
# # > sqrt(sum(fit$residuals^2)/length(fit$residuals))
# make_rmse <- function(preds, actual) {
#     sqrt(mean((preds - actual)^2, na.rm = TRUE))
# }
