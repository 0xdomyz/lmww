# conditions
Rosenbrock <- function(x) {
    x1 <- x[1]
    x2 <- x[2]
    100 * (x2 - x1 * x1)^2 + (1 - x1)^2
}

Rosenbrock_cap <- function(x) {
    if (x[1] + x[2] <= 3) {
        r <- Inf
    } else {
        r <- Rosenbrock(x)
    }
    return(r)
}

lower <- c(-10, -10)
upper <- -lower

set.seed(1234)
DEoptim::DEoptim(Rosenbrock, lower, upper)
DEoptim::DEoptim(Rosenbrock_cap, lower, upper)



## Rosenbrock Banana function
## The function has a global minimum f(x) = 0 at the point (1,1).
## Note that the vector of parameters to be optimized must be the first
## argument of the objective function passed to DEoptim.
Rosenbrock <- function(x) {
    x1 <- x[1]
    x2 <- x[2]
    100 * (x2 - x1 * x1)^2 + (1 - x1)^2
}

## DEoptim searches for minima of the objective function between
## lower and upper bounds on each parameter to be optimized. Therefore
## in the call to DEoptim we specify vectors that comprise the
## lower and upper bounds; these vectors are the same length as the
## parameter vector.
lower <- c(-10, -10)
upper <- -lower

## run DEoptim and set a seed first for replicability
set.seed(1234)
DEoptim(Rosenbrock, lower, upper)

## increase the population size
DEoptim(Rosenbrock, lower, upper, DEoptim.control(NP = 100))

## change other settings and store the output
outDEoptim <- DEoptim(Rosenbrock, lower, upper, DEoptim.control(
    NP = 80,
    itermax = 400, F = 1.2, CR = 0.7
))

## plot the output
plot(outDEoptim)

## 'Wild' function, global minimum at about -15.81515
Wild <- function(x) {
    10 * sin(0.3 * x) * sin(1.3 * x^2) +
        0.00001 * x^4 + 0.2 * x + 80
}

plot(Wild, -50, 50, n = 1000, main = "'Wild function'")

outDEoptim <- DEoptim(Wild,
    lower = -50, upper = 50,
    control = DEoptim.control(trace = FALSE)
)

plot(outDEoptim)

DEoptim(Wild,
    lower = -50, upper = 50,
    control = DEoptim.control(NP = 50)
)

## The below examples shows how the call to DEoptim can be
## parallelized.
## Note that if your objective function requires packages to be
## loaded or has arguments supplied via \code{...}, these should be
## specified using the \code{packages} and \code{parVar} arguments
## in control.

Genrose <- function(x) {
    ## One generalization of the Rosenbrock banana valley function (n parameters)
    n <- length(x)
    ## make it take some time ...
    Sys.sleep(.001)
    1.0 + sum(100 * (x[-n]^2 - x[-1])^2 + (x[-1] - 1)^2)
}

# get some run-time on simple problems
maxIt <- 250
n <- 5

oneCore <- system.time(DEoptim(
    fn = Genrose, lower = rep(-25, n), upper = rep(25, n),
    control = list(NP = 10 * n, itermax = maxIt)
))

withParallel <- system.time(DEoptim(
    fn = Genrose, lower = rep(-25, n), upper = rep(25, n),
    control = list(NP = 10 * n, itermax = maxIt, parallelType = 1)
))

## Compare timings
(oneCore)
(withParallel)
