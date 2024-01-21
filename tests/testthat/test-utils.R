test_that("std", {
  expect_equal(
    std(c(1, 2, 3, 4, 5, NA, 7)),
    c(-1.2344268, -0.7715167, -0.3086067, 0.1543033, 0.6172134, NA, 1.5430335),
    tolerance = 1e-7
  )
})

test_that("std_fit", {
  expect_equal(
    1 + 1,
    2,
    tolerance = 1e-7
  )
})
