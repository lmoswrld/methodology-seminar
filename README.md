# STAT 293 Half-Way Project: SCORE

This folder contains the current first-draft report and reproducible R analysis code for the study of SCORE (Jin, 2015).

## Files

- `FinalReport.Rmd`: report source. It contains the title, abstract, introduction, methods, preliminary numerical experiments, future steps, and references.
- `FinalReport.pdf`: PDF draft generated from the report text for convenient review. **It is not an R Markdown knit from this environment.** Knit `FinalReport.Rmd` in RStudio or with `rmarkdown::render()` to produce the required final PDF after verifying the code.
- `00_requirements.R`: installs missing packages and loads packages used in the project.
- `01_score_functions.R`: DCBM generator, SCORE, ordinary spectral clustering, normalized spectral clustering, and evaluation functions.
- `02_run_analysis.R`: loads the `gsbm::blogosphere` data, runs the three real-data methods, runs 30 synthetic replications, and writes CSV/PNG outputs.

## Reproduce

1. Open this folder as the R working directory.
2. Run `source("00_requirements.R")`.
3. Run `source("01_score_functions.R")`.
4. Run `source("02_run_analysis.R")`.
5. The script writes `political_blogs_results.csv`, `synthetic_simulation_results.csv`, `synthetic_simulation_summary.csv`, `synthetic_error_boxplot.png`, and `synthetic_ari_boxplot.png`.
6. Knit `FinalReport.Rmd` to PDF after checking the generated outputs and updating the synthetic-results discussion.
