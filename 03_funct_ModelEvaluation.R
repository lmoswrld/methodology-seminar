# Evaluation and one-replication simulation helpers.

# Evaluate a two-community partition, accounting for arbitrary cluster labels.
# Returns the minimum number of errors, error rate, and Adjusted Rand Index (ARI).
evaluate_clustering <- function(actual, predicted) {
  if (length(actual) != length(predicted) || length(actual) == 0L ||
      anyNA(actual) || anyNA(predicted)) {
    stop("actual and predicted must have equal nonzero lengths and no missing values.",
         call. = FALSE)
  }
  actual <- as.character(actual)
  predicted <- as.character(predicted)
  actual_levels <- sort(unique(actual))
  predicted_levels <- sort(unique(predicted))
  if (length(actual_levels) != 2L || length(predicted_levels) != 2L) {
    stop("This evaluation function currently supports exactly two communities.",
         call. = FALSE)
  }
  
  tab <- table(
    factor(actual, levels = actual_levels),
    factor(predicted, levels = predicted_levels)
  )
  errors_direct <- sum(tab) - sum(diag(tab))
  errors_switched <- sum(tab) -
    sum(diag(tab[, 2L:1L, drop = FALSE]))
  errors <- min(errors_direct, errors_switched)
  
  if (!requireNamespace("mclust", quietly = TRUE)) {
    stop("Install mclust to calculate the adjusted Rand index.", call. = FALSE)
  }
  
  data.frame(
    errors = errors,
    error_rate = errors / length(actual),
    ARI = mclust::adjustedRandIndex(actual, predicted)
  )
}

# Generate one DCBM network, fit SCORE/oPCA/nPCA, and return metrics by method.
run_one_simulation <- function(
    n = 500L,
    sigma = 0.55,
    seed = 1L,
    B = matrix(c(0.08, 0.02, 0.02, 0.08), 2L, byrow = TRUE),
    nstart = 100L,
    threshold = log(n)) {
  
  sim <- generate_dcbm(n = n, B = B, sigma = sigma, seed = seed)
  fits <- list(
    SCORE = score_cluster(sim$A, K = 2L, threshold = threshold,
                          nstart = nstart, seed = seed),
    oPCA = opca_cluster(sim$A, K = 2L, nstart = nstart, seed = seed),
    nPCA = npca_cluster(sim$A, K = 2L, nstart = nstart, seed = seed)
  )
  
  results <- do.call(rbind, lapply(names(fits), function(method) {
    cbind(
      data.frame(method = method),
      evaluate_clustering(sim$labels, fits[[method]]$labels)
    )
  }))
  results$sigma <- sigma
  results$seed <- seed
  results
}
