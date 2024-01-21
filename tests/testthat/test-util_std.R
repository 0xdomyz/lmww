test_that("std", {
  expect_equal(
    std(c(1, 2, 3, 4, 5, NA, 7)),
    c(-1.2344268, -0.7715167, -0.3086067, 0.1543033, 0.6172134, NA, 1.5430335),
    tolerance = 1e-7
  )
})

test_that("std_fit", {
  a <- std_fit(mtcars)

  expect_equal(
    as.numeric(a$means),
    c(20.090625, 6.1875, 230.721875, 146.6875, 3.5965625, 3.21725, 17.84875, 0.4375, 0.40625, 3.6875, 2.8125),
    tolerance = 1e-7
  )
  expect_equal(
    as.numeric(a$stds),
    c(6.0269480520891, 1.78592164694654, 123.938693831382, 68.5628684893206, 0.534678736070971, 0.978457442989697, 1.78694323609684, 0.504016128774185, 0.498990917235846, 0.737804065256947, 1.61519997763185),
    tolerance = 1e-7
  )
  expect_equal(
    a$variables,
    c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb"),
    tolerance = 1e-7
  )
})

test_that("std_transform", {
  std_paras <- std_fit(mtcars)
  stded_col <- std_transform(std_paras, mtcars)["mpg"][[1]]

  expect_equal(
    mean(stded_col),
    0,
    tolerance = 1e-7
  )

  expect_equal(
    var(stded_col),
    1,
    tolerance = 1e-7
  )
})
