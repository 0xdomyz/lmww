#' Standardize a numeric vector
#'
#' @param v, a numeric vector, NA is allowed.
#'
#' @return a numeric vector.
#' @export
#'
#' @examples
#' std(c(1, 2, 3, 4, 5, NA, 7))
#'
#' # apply std on data
#' purrr::map(mtcars, std) |> dplyr::bind_cols()
std <- function(v) {
    (v - mean(v, na.rm = TRUE)) / sqrt(stats::var(v, na.rm = TRUE))
}


#' Standardize a dataframe to get a parameters list
#'
#' @param data dataframe of numeric columns.
#'
#' @return list with 3 defined values.
#'  - variables: a character vector of column names.
#' - means: a numeric vector of means.
#' - stds: a numeric vector of standard deviations.
#' @export
#'
#' @examples
#' a <- std_fit(mtcars)
#' a$means
#' a$stds
std_fit <- function(data) {
    means <- purrr::map_df(data, function(v) mean(v, na.rm = TRUE))
    stds <- purrr::map_df(data, function(v) sqrt(stats::var(v, na.rm = TRUE)))

    return(list(
        "variables" = colnames(means),
        "means" = means,
        "stds" = stds
    ))
}


#' Standardize a numeric vector, using a list of standardization parameters
#'
#' The list is expected to be generated from the std_fit function.
#'
#' @param parameters list competible with std_fit return value.
#' @param data dataframe of numeric columns.
#'
#' @return dataframe.
#' @export
#'
#' @examples
#' std_paras <- std_fit(mtcars[c("hp", "mpg", "vs")])
#'
#' std_transform(std_paras, mtcars) |> summary()
#' std_transform(std_paras, rbind(mtcars, mtcars)) |> summary()
#' std_transform(std_paras, mtcars[c("vs", "mpg")]) |> summary()
#' std_transform(std_paras, mtcars[c("carb", "wt")]) |> summary()
std_transform <- function(parameters, data) {
    common_var <- intersect(colnames(data), parameters$variables)
    data <- data[common_var]
    means <- as.numeric(parameters$means[common_var])
    stds <- as.numeric(parameters$stds[common_var])
    purrr::pmap(
        list(data, means, stds),
        function(v, m, std) (v - m) / std
    ) |> dplyr::bind_cols()
}
