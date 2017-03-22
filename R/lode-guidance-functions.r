#' @name lode-guidance-functions
#' @title Lode guidance functions
#' @param n Numeric, a positive integer
#' @param i Numeric, a positive integer at most \code{n}
NULL

#' Zigzag outward order
#' 
#' Order the numbers 1 through \code{n}, starting at some index and zigzagging
#' outward.
#' 
#' @rdname lode-guidance-functions
lode_zigzag <- function(n, i) {
  
  # Radii
  r1 <- i - 1
  r2 <- n - i
  r <- min(r1, r2)
  
  # Attempt cohesion in the direction of the closer end
  leftward <- (i <= n / 2)
  
  # Setup
  sgn <- if(r1 == r2) 0 else (r2 - r1) / abs(r2 - r1)
  rem <- (i + sgn * (r + 1)):((n+1)/2 + sgn * (n-1)/2)
  zz <- (1 - 2 * leftward) * c(1, -1)
  
  # Order
  c(i,
    if(r == 0) c() else sapply(1:r, function(j) i + j * zz),
    if(sgn == 0) c() else rem)
}

#' Rightward order
#' 
#' Order the numbers 1 through \code{n}, starting at some index \code{i} and
#' putting the remaining indices in increasing order.
#' 
#' @rdname lode-guidance-functions
lode_rightward <- function(n, i) {
  if (i == 1) 1:n else if (i == n) c(n, 1:(n-1)) else c(i, 1:(i-1), (i+1):n)
}

#' Leftward order
#' 
#' Order the numbers 1 through \code{n}, starting at some index \code{i} and
#' putting the remaining indices in decreasing order.
#' 
#' @rdname lode-guidance-functions
lode_leftward <- function(n, i) {
  if (i == 1) c(i, n:2) else if (i == n) n:1 else c(i, n:(i+1), (i-1):1)
}

#' Right-left order
#' 
#' Order the numbers 1 through \code{n}, starting at some index \code{i},
#' proceeding rightward to \code{n}, then proceeding leftward to \code{1}.
#' 
#' @rdname lode-guidance-functions
lode_rightleft <- function(n, i) {
  if (i == 1) 1:n else if (i == n) n:1 else c(i, (i+1):n, (i-1):1)
}

#' Left-right order
#' 
#' Order the numbers 1 through \code{n}, starting at some index \code{i},
#' proceeding leftward to \code{1}, then proceeding rightward to \code{n}.
#' 
#' @rdname lode-guidance-functions
lode_leftright <- function(n, i) {
  if (i == 1) 1:n else if (i == n) n:1 else c(i, (i-1):1, (i+1):n)
}
