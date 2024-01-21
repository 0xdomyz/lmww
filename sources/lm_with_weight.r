import::here(stringr, str_c)
import::here(Hmisc, rcorr.cens)
import::here(
    ggplot2,
    ggplot,
    aes_string,
    geom_point,
    ggtitle
)

# Calculate standardization variables
std <- function(v) {
    if (FALSE) {
        # Examples
        std(c(1, 2, 3, 4, 5, NA, 7))
        # [1] -1.2344268 -0.7715167 -0.3086067  0.1543033  0.6172134         NA  1.5430335

        # apply std on data
        purrr::map(mtcars, std) |> dplyr::bind_cols()
    }
    (v - mean(v, na.rm = TRUE)) / sqrt(var(v, na.rm = TRUE))
}


std_fit <- function(data) {
    if (FALSE) {
        # Examples
        a <- std_fit(mtcars)
        a$stds
        #   mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
        # 1  6.03  1.79  124.  68.6 0.535 0.978  1.79 0.504 0.499 0.738  1.62
    }
    means <- purrr::map_df(data, function(v) mean(v, na.rm = TRUE))
    stds <- purrr::map_df(data, function(v) sqrt(var(v, na.rm = TRUE)))

    return(list(
        "variables" = colnames(means),
        "means" = means,
        "stds" = stds
    ))
}


std_transform <- function(parameters, data) {
    if (FALSE) {
        # Examples
        std_paras <- std_fit(mtcars[c("hp", "mpg", "vs")])
        std_transform(std_paras, mtcars) |> summary()
        std_transform(std_paras, rbind(mtcars, mtcars)) |> summary()
        std_transform(std_paras, mtcars[c("vs", "mpg")]) |> summary()
        std_transform(std_paras, mtcars[c("carb", "wt")]) |> summary()
    }
    common_var <- intersect(colnames(data), parameters$variables)
    data <- data[common_var]
    means <- as.numeric(parameters$means[common_var])
    stds <- as.numeric(parameters$stds[common_var])
    purrr::pmap(
        list(data, means, stds),
        function(v, m, std) (v - m) / std
    ) |> dplyr::bind_cols()
}

std_fit_transform <- function(data) {
    if (FALSE) {
        # Examples
        res <- std_fit_transform(mtcars[c("hp", "mpg", "vs")])
        res
        res |> summary()
        res |> var()
        std_fit_transform(mtcars) |> summary()
    }
    return(std_transform(std_fit(data), data))
}

# Make adjusted/unadjusted R squared
#
# Examples
# --------------
# > fit = lm(mpg ~ cyl + disp, mtcars); summary(fit)
#
# Residuals:
#     Min      1Q  Median      3Q     Max
# -4.4213 -2.1722 -0.6362  1.1899  7.0516
#
# Residual standard error: 3.055 on 29 degrees of freedom
# Multiple R-squared:  0.7596,    Adjusted R-squared:  0.743
# F-statistic: 45.81 on 2 and 29 DF,  p-value: 1.058e-09
#
# > make_r2(predict(fit, mtcars), mtcars$mpg)
# [1] 0.7595658
# > make_adjr2(predict(fit, mtcars), mtcars$mpg, 2)
# [1] 0.7429841
# > fit = lm(mpg ~ 0 + cyl + disp, mtcars); summary(fit)
#
# Residual standard error: 8.164 on 30 degrees of freedom
# Multiple R-squared:  0.8576,    Adjusted R-squared:  0.8481
# F-statistic: 90.33 on 2 and 30 DF,  p-value: 2.008e-13
#
# > make_r2(predict(fit, mtcars), mtcars$mpg, model_has_intercept = FALSE)
# [1] 0.8575967
# > make_adjr2(predict(fit, mtcars), mtcars$mpg, 2, model_has_intercept = FALSE)
# [1] 0.8481031
make_r2 <- function(preds, actual, model_has_intercept = TRUE) {
    if (model_has_intercept) {
        rss <- sum((preds - actual)^2, na.rm = TRUE)
        tss <- sum((actual - mean(actual))^2, na.rm = TRUE)
        return(1 - rss / tss)
    } else if (!model_has_intercept) {
        rss <- sum((preds - actual)^2, na.rm = TRUE)
        tss <- sum((actual)^2, na.rm = TRUE)
        return(1 - rss / tss)
    } else {
        return("invalid model_has_intercept")
    }
}

make_adjr2 <- function(preds, actual, k, model_has_intercept = TRUE) {
    n <- sum(!is.na(preds))
    r2 <- make_r2(preds, actual, model_has_intercept)
    if (model_has_intercept) {
        return(1 - (1 - r2) * (n - 1) / (n - k - 1))
    } else if (!model_has_intercept) {
        return(1 - (1 - r2) * (n) / (n - k))
    } else {
        return("invalid model_has_intercept")
    }
}

# Make rmse
#
# Examples
# -----------
# > fit = lm(mpg~cyl+disp, mtcars)
# > summary(fit)
# > make_rmse(fit$fitted.value, mtcars$mpg)
# > sqrt(sum(fit$residuals^2)/length(fit$residuals))
make_rmse <- function(preds, actual) {
    sqrt(mean((preds - actual)^2, na.rm = TRUE))
}

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

# Linear regression parameters to R formula
parameters_to_formula <- function(parameters, target) {
    if (FALSE) {
        # Examples
        #-----------
        fit <- lm(mpg ~ cyl + disp, mtcars)
        ce <- fit$coefficients
        ce
        # (Intercept)         cyl        disp
        # 34.66099474 -1.58727681 -0.02058363
        fml <- parameters_to_formula(ce, "mpg")
        fml
        # mpg ~ 34.6609947413328 + -1.58727680900718 * cyl + -0.0205836333707016 *
        #    disp
        #<environment: 0x000000000b9ac710>
        pred_from_fml <- eval(parse(text = fml), mtcars)
        pred_from_fit <- predict(fit, mtcars)
        names(pred_from_fit) <- NULL
        sum(abs(pred_from_fml - pred_from_fit) > 1e-10)
        # [1] 0
    }
    inter <- parameters[1]
    non_inter <- parameters[2:length(parameters)]
    fml_no_inter <- str_c(non_inter, names(non_inter), sep = " * ", collapse = " + ")
    fml <- str_c(inter, fml_no_inter, sep = " + ")
    fml_target <- str_c(target, fml, sep = " ~ ")
    as.formula(fml_target)
}

predict_from_formula <- function(formula, data) {
    if (FALSE) { # Examples
        fit <- lm(mpg ~ cyl + disp, mtcars)
        # save model as a formula
        fml <- parameters_to_formula(fit$coefficients, "mpg")
        fml
        # mpg ~ 34.6609947413328 + -1.58727680900718 * cyl + -0.0205836333707016 *
        #  disp
        #<environment: 0x000001c323afa760>
        # apply formula to new data
        predict_from_formula(fml, mtcars * 2 - 1)[1:5]
        # [1] 10.634771 10.634771 19.124576  6.600379 -3.947790
        # check against hard code calc
        data <- mtcars * 2 - 1
        res <- (34.6609947413328 + -1.58727680900718 * data["cyl"] + -0.0205836333707016 * data["disp"])
        dplyr::pull(res)[1:5]
        # [1] 10.634771 10.634771 19.124576  6.600379 -3.947790

        # predict into a new column
        data <- mtcars * 2 - 1
        data["calc"] <- predict_from_formula(fml, data)
    }
    eval(parse(text = formula), data)
}

# Make R formula from linear regression variable choice specifications
#
# Examples
# -------------
# > fml = make_formula(c('cyl', 'disp', 'hp', 'drat'), 'mpg')
# > lm(fml, mtcars)$coefficients
# (Intercept)         cyl        disp          hp        drat
# 23.98524441 -0.81402201 -0.01389625 -0.02317068  2.15404553
# > fml = make_formula(c('cyl', 'disp', 'hp', 'drat'), 'mpg', 0)
# > lm(fml, mtcars)$coefficients
#          cyl         disp           hp         drat
#  0.711008285 -0.009176678 -0.043640211  6.701808900
make_formula <- function(variables, target, intercept = 1) {
    fml <- str_c(c(intercept, variables), collapse = " + ")
    fml_target <- str_c(target, fml, sep = " ~ ")
    as.formula(fml_target)
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

# Make scatter plot
#
# Examples
# -----------
# > plot_scatter(mtcars, 'mpg', 'disp')
# > data = mtcars
# > data['cyl_gt_5'] = ifelse(data['cyl'] > 5, 1, 0)
# > plot_scatter(data, 'mpg', 'disp', 'cyl_gt_5')
plot_scatter <- function(data, x, y, z = NA) {
    if (is.na(z)) {
        plt <- ggplot(data, aes_string(x = x, y = y)) +
            geom_point() +
            ggtitle(paste0(x, " vs ", y))
    } else {
        plt <- ggplot(data, aes_string(x = x, y = y, colour = z)) +
            geom_point() +
            ggtitle(paste0(x, " vs ", y, " coloured by ", z))
    }
    return(plt)
}

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
fit_lm <- function(variables,
                   target,
                   data,
                   k,
                   model_has_intercept = TRUE,
                   concise = TRUE) {
    fml <- make_formula(variables, target, model_has_intercept * 1)
    fit <- lm(fml, data)
    ce <- fit$coefficients
    if (model_has_intercept) {
        wts <- parameters_to_weights(ce)
    } else {
        wts <- parameters_to_weights(c(0, ce))
    }
    preds <- predict(fit, data)
    actual <- data[[target]]
    r2 <- make_r2(preds, actual, model_has_intercept)
    adjr2 <- make_adjr2(preds, actual, k, model_has_intercept)
    dxy <- rcorr.cens(preds, actual)["Dxy"]

    plt_data <- data.frame(fitted = preds, actual = actual)
    plt <- plot_scatter(plt_data, "fitted", "actual")

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
        plt
        return(list(
            "fml" = fml,
            "fit" = fit,
            "weights" = wts,
            "r2" = r2,
            "adjr2" = adjr2,
            "dxy" = dxy,
            "plt" = plt
        ))
    }
}

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
test_wts <- function(variables,
                     weights,
                     signs,
                     target,
                     data,
                     k,
                     concise = TRUE) {
    man_wts <- weights
    names(man_wts) <- variables
    fml <- parameters_to_formula(c(0, man_wts * signs), target)
    x <- eval(parse(text = fml), data)
    y <- data[[target]]
    ce <- lm(y ~ 1 + x)$coefficients
    calibration_a <- ce[2]
    calibration_b <- ce[1]

    preds <- eval(parse(text = fml), data) * calibration_a + calibration_b
    actual <- data[[target]]
    r2 <- make_r2(preds, actual)
    adjr2 <- make_adjr2(preds, actual, k)
    dxy <- rcorr.cens(preds, actual)["Dxy"]

    plt_data <- data.frame(fitted = preds, actual = actual)
    plt <- plot_scatter(plt_data, "fitted", "actual")

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
        plt
        return(list(
            "fml" = fml,
            "calibration_a" = calibration_a,
            "calibration_b" = calibration_b,
            "weights" = weights,
            "r2" = r2,
            "adjr2" = adjr2,
            "dxy" = dxy,
            "plt" = plt
        ))
    }
}

if (identical(environment(), globalenv())) {
    1
}
