# Generate an undirected two-community degree-corrected block model (DCBM).
# Inputs: n (nodes), B (2x2 block probabilities), sigma (degree spread), seed.
# Output: adjacency matrix A, true labels, degree weights, and settings.
generate_dcbm <- function(
    n = 500L,
    B = matrix(c(0.08, 0.02, 0.02, 0.08), 2L, byrow = TRUE),
    sigma = 0.55,
    seed = NULL) {
  
  if (!is.null(seed)) set.seed(seed)
  if (length(n) != 1L || !is.finite(n) || n < 4L || n != as.integer(n)) {
    stop("n must be an integer of at least 4.", call. = FALSE)
  }
  if (!is.matrix(B) || !is.numeric(B) || !all(dim(B) == c(2L, 2L)) ||
      any(!is.finite(B)) || any(B < 0) || any(B > 1) ||
      !isTRUE(all.equal(B, t(B), check.attributes = FALSE)) || max(B) <= 0) {
    stop("B must be a nonzero, symmetric 2 by 2 probability matrix.",
         call. = FALSE)
  }
  if (length(sigma) != 1L || !is.finite(sigma) || sigma < 0) {
    stop("sigma must be one finite, nonnegative number.", call. = FALSE)
  }
  
  # Randomize node order while keeping the two groups as balanced as possible.
  labels <- sample(rep(1:2, length.out = n))
  
  # Lognormal relative degree weights, normalized to mean one.
  theta <- exp(stats::rnorm(n, mean = 0, sd = sigma))
  theta <- theta / mean(theta)
  
  # Cap extreme weights so every Bernoulli probability stays <= 0.99.
  # The cap slightly truncates the upper tail of the lognormal distribution.
  theta_cap <- sqrt(0.99 / max(B))
  theta <- pmin(theta, theta_cap)
  
  edge_probability <- outer(theta, theta) *
    B[labels, labels, drop = FALSE]
  edge_probability <- pmin(edge_probability, 0.99)
  
  # Draw each undirected edge once from the upper triangle, then mirror it.
  A <- matrix(0L, nrow = n, ncol = n)
  upper_pairs <- which(upper.tri(A), arr.ind = TRUE)
  A[upper_pairs] <- stats::rbinom(
    nrow(upper_pairs), size = 1,
    prob = edge_probability[upper_pairs]
  )
  A <- A + t(A)
  
  list(A = A, labels = labels, theta = theta, B = B, sigma = sigma)
}
