# Install missing packages, then load all project dependencies.

required_packages <- c(
  "gsbm",      # Political blogs network data
  "RSpectra",  # Computes eigenvalues
  "mclust",    # Adjusted Rand Index
  "ggplot2",   # Simulation plots
  "knitr",     # R Markdown knitting
  "rmarkdown"  # Report rendering
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0L) {
  install.packages(
    missing_packages,
    repos = "https://cloud.r-project.org",
    dependencies = TRUE
  )
}

# Confirm installation succeeded before loading.
still_missing <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(still_missing) > 0L) {
  stop(
    "Could not install: ", paste(still_missing, collapse = ", "),
    call. = FALSE
  )
}

for (pkg in required_packages) {
  suppressPackageStartupMessages(
    library(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  )
}
