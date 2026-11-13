# Load project dependencies, assuming they have already been installed.

required_packages <- c(
  "gsbm",
  "mclust",
  "ggplot2",
  "knitr",
  "rmarkdown"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0L) {
  stop(
    "Missing package(s): ", paste(missing_packages, collapse = ", "),
    ". Install them by running source(\"001_requirements.R\").",
    call. = FALSE
  )
}

for (pkg in required_packages) {
  suppressPackageStartupMessages(
    library(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  )
}