# Methods for fitting SCORE and spectral clustering to an adjacency matrix.

# Check that A is a symmetric, binary adjacency matrix without self-loops.
check_adjacency <- function(A) {
  if (!is.matrix(A) || !is.numeric(A) || nrow(A) != ncol(A) || nrow(A) < 3L) {
    stop("A must be a numeric square adjacency matrix.", call. = FALSE)
  }
  if (any(!is.finite(A)) || any(!A %in% c(0, 1))) {
    stop("A must contain only finite 0/1 values.", call. = FALSE)
  }
  if (!isTRUE(all.equal(A, t(A), check.attributes = FALSE))) {
    stop("A must be symmetric.", call. = FALSE)
  }
  if (any(diag(A) != 0)) stop("A must have a zero diagonal.", call. = FALSE)
  invisible(TRUE)
}

# Compute eigenvectors for the K eigenvalues with largest absolute magnitude.
# Accepts any finite symmetric matrix, including the normalized adjacency matrix.
leading_eigenvectors <- function(M, K = 2L) {
  if (!is.matrix(M) || !is.numeric(M) || nrow(M) != ncol(M) ||
      any(!is.finite(M)) ||
      !isTRUE(all.equal(M, t(M), check.attributes = FALSE))) {
    stop("M must be a finite, symmetric numeric matrix.", call. = FALSE)
  }
  if (length(K) != 1L || K < 1L || K != as.integer(K) || K >= nrow(M)) {
    stop("K must be an integer between 1 and nrow(M) - 1.", call. = FALSE)
  }
  if (!requireNamespace("RSpectra", quietly = TRUE)) {
    stop("Install RSpectra to compute the leading eigenvectors.", call. = FALSE)
  }
  
  decomposition <- RSpectra::eigs_sym(M, k = K, which = "LM")
  ordering <- order(abs(decomposition$values), decreasing = TRUE)
  
  list(
    values = decomposition$values[ordering],
    vectors = decomposition$vectors[, ordering, drop = FALSE]
  )
}

# Apply k-means to node feature rows and return labels and coordinates.
cluster_coordinates <- function(coordinates, K, nstart = 100L, seed = 1L) {
  coordinates <- as.matrix(coordinates)
  if (any(!is.finite(coordinates))) {
    stop("Clustering coordinates must all be finite.", call. = FALSE)
  }
  if (nrow(coordinates) <= K) stop("There must be more nodes than clusters.", call. = FALSE)
  if (length(nstart) != 1L || nstart < 1L) stop("nstart must be positive.", call. = FALSE)
  
  set.seed(seed)
  fit <- stats::kmeans(coordinates, centers = K, nstart = nstart)
  list(labels = fit$cluster, coordinates = coordinates,
       withinss = fit$tot.withinss)
}

# SCORE: cluster entrywise ratios of the leading adjacency eigenvectors.
score_cluster <- function(A, K = 2L, threshold = log(nrow(A)),
                          nstart = 100L, seed = 1L) {
  check_adjacency(A)
  if (K < 2L) stop("SCORE requires K >= 2.", call. = FALSE)
  if (length(threshold) != 1L || !is.finite(threshold) || threshold <= 0) {
    stop("threshold must be a positive finite number.", call. = FALSE)
  }
  
  eig <- leading_eigenvectors(A, K)
  U <- eig$vectors
  denominator <- U[, 1L]
  floor_value <- sqrt(.Machine$double.eps)
  small <- abs(denominator) < floor_value
  denominator[small] <- ifelse(denominator[small] < 0, -floor_value, floor_value)
  
  ratios <- sweep(U[, -1L, drop = FALSE], 1L, denominator, "/")
  ratios <- pmax(pmin(ratios, threshold), -threshold)
  fit <- cluster_coordinates(ratios, K, nstart, seed)
  fit$eigenvalues <- eig$values
  fit
}

# oPCA: cluster leading eigenvectors of the unnormalized adjacency matrix.
opca_cluster <- function(A, K = 2L, nstart = 100L, seed = 1L) {
  check_adjacency(A)
  eig <- leading_eigenvectors(A, K)
  fit <- cluster_coordinates(eig$vectors, K, nstart, seed)
  fit$eigenvalues <- eig$values
  fit
}

# nPCA: cluster eigenvectors of D^(-1/2) A D^(-1/2).
npca_cluster <- function(A, K = 2L, nstart = 100L, seed = 1L) {
  check_adjacency(A)
  degree <- rowSums(A)
  inv_sqrt_degree <- ifelse(degree > 0, 1 / sqrt(degree), 0)
  normalized_A <- sweep(A, 1L, inv_sqrt_degree, `*`)
  normalized_A <- sweep(normalized_A, 2L, inv_sqrt_degree, `*`)
  
  eig <- leading_eigenvectors(normalized_A, K)
  fit <- cluster_coordinates(eig$vectors, K, nstart, seed)
  fit$eigenvalues <- eig$values
  fit
}
