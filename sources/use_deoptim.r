get_data <- function() {
    std <- function(v) (v - mean(v, na.rm = TRUE)) / sqrt(var(v, na.rm = TRUE))
    data <- purrr::map(mtcars, std) |> dplyr::bind_cols()
    data
}

fml <- "mpg ~ disp + hp + wt + qsec + am"

all_standardised <- FALSE
use_nls <- FALSE
first_principle <- FALSE
solve_lm <- FALSE


if (all_standardised) {
    data <- get_data()
    fit <- lm(fml, data = data)
    fit
    fit$coefficients
    sum(abs(fit$coefficients))

    # reverse negatives
    data$hp <- -mtcars$hp
    data$wt <- -mtcars$wt
    fit <- lm(fml, data = data)
    fit
    fit$coefficients
    sum(abs(fit$coefficients))
} else {
    data <- get_data()
    data$mpg <- mtcars$mpg
    fit <- lm(fml, data = data)
    fit
    fit$coefficients
    sum(abs(fit$coefficients))
}


if (use_nls) {
    data <- get_data()
    fit <- nls("mpg ~ a + b1 * disp + b2 * hp + b3 * wt + b4 * qsec + b5 * am",
        data = data,
        start = list(a = 0, b1 = 0.0, b2 = 0, b3 = 0, b4 = 0, b5 = 0),
        lower = c(a = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0),
        upper = c(a = Inf, b1 = Inf, b2 = Inf, b3 = Inf, b4 = Inf, b5 = Inf),
        algorithm = "port"
    )

    fit
}


if (first_principle) {
    Boston <- MASS::Boston
    y <- Boston$medv
    X <- as.matrix(Boston[-ncol(Boston)])
    int <- rep(1, length(y))
    X <- cbind(int, X)
    betas <- solve(t(X) %*% X) %*% t(X) %*% y
    betas <- round(betas, 2)
    print(betas)
}


# to do: start with intercept
if (solve_lm) {
    data <- get_data()
    data$mpg <- mtcars$mpg

    fit <- lm(fml, data = data)
    fit
    summary(fit)
    ce <- fit$coefficients
    ce
    abs(ce[-1]) / sum(abs(ce[-1]))

    target <- "mpg"
    vars <- c("disp", "hp", "wt", "qsec", "am")
    X <- data[vars]
    int <- rep(1, nrow(X))
    X <- cbind(int, X)
    actual <- dplyr::pull(data[target])
    cons_vars <- c("hp", "qsec")
    cons_idx <- which(vars %in% cons_vars) + 1
    cons <- c(0.2, 0.2)
    obj <- function(x) {
        if (
            any(abs(x[cons_idx]) / sum(abs(x[-1])) > cons)
        ) {
            r <- Inf
        } else {
            preds <- as.numeric(as.matrix(X) %*% x)
            r <- sqrt(mean((preds - actual)^2, na.rm = TRUE))
        }
        return(r)
    }

    lower <- rep(-25, length(vars) + 1)
    upper <- -lower

    set.seed(0)
    DEoptim::DEoptim(obj, lower, upper)
}
