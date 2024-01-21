# Linear regression parameters and weights conversion
#
# Examples
# -----------
# > data = purrr::map(mtcars, std) |> dplyr::bind_cols()
# > data$mpg = mtcars$mpg
# > ce = lm(mpg ~ cyl+disp, data)$coefficients; ce
# (Intercept)         cyl        disp
#   20.090625   -2.834752   -2.551109
# > w = parameters_to_weights(ce); w
# $weights
#       cyl      disp
# 0.5263322 0.4736678
#
# $signs
#  cyl disp
#   -1   -1
#
# $calibration
#         a         b
#  5.385861 20.090625
#
# > weights_to_parameters(w$weights, w$signs, w$calibration[1])
#       cyl      disp
# -2.834752 -2.551109
parameters_to_weights <- function(parameters) {
    inter <- parameters[1]
    names(inter) <- NULL
    non_inter <- parameters[2:length(parameters)]
    list(
        "weights" = abs(non_inter) / sum(abs(non_inter)),
        "signs" = ifelse(non_inter > 0, 1, -1),
        "calibration" = c("a" = sum(abs(non_inter)), "b" = inter)
    )
}

# does not give intercept back
weights_to_parameters <- function(weights, signs, calibration_a) {
    weights * signs * sum(abs(calibration_a))
}

# Linear regression parameters to parameters that would have achived if normalised prior to regression
#
# Examples
# --------------
# > std <- function(v) (v-mean(v, na.rm = TRUE))/sqrt(var(v, na.rm = TRUE))
# > means = (purrr::map(mtcars, mean) |> unlist())[c('cyl','disp')]
# > stds = (purrr::map(mtcars, ~sqrt(var(., na.rm = TRUE))) |> unlist())[c('cyl'$
# > ce = lm(mpg ~ cyl+disp, mtcars)$coefficients; ce
# (Intercept)         cyl        disp
# 34.66099474 -1.58727681 -0.02058363
# > parameters_to_norm_parameters(ce[1], ce[2:length(ce)], means, stds)
# $norm_intercept
# (Intercept)
#    20.09062
#
# $norm_parameters
#       cyl      disp
# -2.834752 -2.551109
#
# > norm_data = purrr::map(mtcars, std) |> dplyr::bind_cols()
# > norm_data['mpg'] = mtcars['mpg']
# > lm(mpg ~ cyl+disp, norm_data)$coefficients
# (Intercept)         cyl        disp
#   20.090625   -2.834752   -2.551109
parameters_to_norm_parameters <- function(intercept, parameters, means, stds) {
    list(
        "norm_intercept" = sum(parameters * means) + intercept,
        "norm_parameters" = parameters * stds
    )
}
