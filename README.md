# STAT 293 Half-Way Project: SCORE

This package contains the project report, analysis R Markdown files, and functions for reproducing the political-blogs comparison and the preliminary simulated-network experiment.

## Files

- `FinalReport.Rmd`: main project report source.
- `FinalReport.pdf`: older PDF from the supplied project package; it has not been regenerated from the current R Markdown.
- `001_requirements.R`: installs missing packages and loads them.
- `002_requirements_lite.R`: checks and loads packages without installing them; used by the analysis R Markdown files.
- `01_funct_GeneratingSimData.R`: DCBM network generator. It samples each undirected edge once and mirrors the result.
- `02_funct_MethodImplementation.R`: SCORE, oPCA, nPCA, eigenvector, and clustering helpers.
- `03_funct_ModelEvaluation.R`: two-community evaluation metrics and one-replication simulation helper.
- `11_RMD_PoliticalBlogsReplication.Rmd`: real-data replication on the political blogs network.
- `21_RMD_PreliminarySims.Rmd`: one simulated example plus the 30-replication DCBM pilot.

## Reproduce

1. Open this folder as the R working directory.
2. Install packages once if needed by running `source("001_requirements.R")`.
3. Knit `11_RMD_PoliticalBlogsReplication.Rmd` to reproduce the political blogs results and nPCA seed-sensitivity check.
4. Knit `21_RMD_PreliminarySims.Rmd` to regenerate the illustrative network, 30 simulation replications, summary table, and comparison plots.
5. Knit `FinalReport.Rmd` to produce the report. Its results tables and interpretation are written directly in the report; the two analysis Rmds contain the executable calculations.

The preliminary simulation matches the earlier analysis settings: 500 nodes, two balanced communities, within-community and between-community probabilities 0.08 and 0.02, degree heterogeneity `sigma = 0.55`, and 30 replications. The revised generator samples only the upper triangle before mirroring, as required for the undirected DCBM. Its simulation results may differ from the earlier R Markdown version, which sampled both directions independently before combining them.

## Preliminary simulation takeaways

The two boxplots in `21_RMD_PreliminarySims.Rmd` summarize performance over the 30 simulated networks. The misclassification-rate plot shows that nPCA generally made fewer errors than SCORE and oPCA. The ARI plot tells the same story: nPCA usually had stronger agreement with the true communities. SCORE and oPCA were relatively close, with SCORE slightly better overall. All three methods performed well under this simulation design.

These plots describe only the current DCBM setup; they do not establish a universal ranking. In particular, the political blogs analysis favored SCORE, while this pilot simulation favored nPCA. This difference suggests that method performance depends on network conditions and motivates the planned experiments varying degree heterogeneity, sparsity, and community separation.
