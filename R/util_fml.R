# # Linear regression parameters to R formula
# parameters_to_formula <- function(parameters, target) {
#     if (FALSE) {
#         # Examples
#         #-----------
#         fit <- lm(mpg ~ cyl + disp, mtcars)
#         ce <- fit$coefficients
#         ce
#         # (Intercept)         cyl        disp
#         # 34.66099474 -1.58727681 -0.02058363
#         fml <- parameters_to_formula(ce, "mpg")
#         fml
#         # mpg ~ 34.6609947413328 + -1.58727680900718 * cyl + -0.0205836333707016 *
#         #    disp
#         #<environment: 0x000000000b9ac710>
#         pred_from_fml <- eval(parse(text = fml), mtcars)
#         pred_from_fit <- predict(fit, mtcars)
#         names(pred_from_fit) <- NULL
#         sum(abs(pred_from_fml - pred_from_fit) > 1e-10)
#         # [1] 0
#     }
#     inter <- parameters[1]
#     non_inter <- parameters[2:length(parameters)]
#     fml_no_inter <- stringr::str_c(non_inter, names(non_inter), sep = " * ", collapse = " + ")
#     fml <- stringr::str_c(inter, fml_no_inter, sep = " + ")
#     fml_target <- stringr::str_c(target, fml, sep = " ~ ")
#     as.formula(fml_target)
# }

# predict_from_formula <- function(formula, data) {
#     if (FALSE) { # Examples
#         fit <- lm(mpg ~ cyl + disp, mtcars)
#         # save model as a formula
#         fml <- parameters_to_formula(fit$coefficients, "mpg")
#         fml
#         # mpg ~ 34.6609947413328 + -1.58727680900718 * cyl + -0.0205836333707016 *
#         #  disp
#         #<environment: 0x000001c323afa760>
#         # apply formula to new data
#         predict_from_formula(fml, mtcars * 2 - 1)[1:5]
#         # [1] 10.634771 10.634771 19.124576  6.600379 -3.947790
#         # check against hard code calc
#         data <- mtcars * 2 - 1
#         res <- (34.6609947413328 + -1.58727680900718 * data["cyl"] + -0.0205836333707016 * data["disp"])
#         dplyr::pull(res)[1:5]
#         # [1] 10.634771 10.634771 19.124576  6.600379 -3.947790

#         # predict into a new column
#         data <- mtcars * 2 - 1
#         data["calc"] <- predict_from_formula(fml, data)
#     }
#     eval(parse(text = formula), data)
# }

# # Make R formula from linear regression variable choice specifications
# #
# # Examples
# # -------------
# # > fml = make_formula(c('cyl', 'disp', 'hp', 'drat'), 'mpg')
# # > lm(fml, mtcars)$coefficients
# # (Intercept)         cyl        disp          hp        drat
# # 23.98524441 -0.81402201 -0.01389625 -0.02317068  2.15404553
# # > fml = make_formula(c('cyl', 'disp', 'hp', 'drat'), 'mpg', 0)
# # > lm(fml, mtcars)$coefficients
# #          cyl         disp           hp         drat
# #  0.711008285 -0.009176678 -0.043640211  6.701808900
# make_formula <- function(variables, target, intercept = 1) {
#     fml <- stringr::str_c(c(intercept, variables), collapse = " + ")
#     fml_target <- stringr::str_c(target, fml, sep = " ~ ")
#     as.formula(fml_target)
# }
