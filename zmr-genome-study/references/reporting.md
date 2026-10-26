# Tables and figures

Use inspectable `.tsv` or `.csv` tables and vector PDF figures. Keep meaningful trait, tissue, method, and locus order explicit. Prefer `ggplot2`, `theme_bw()` or a simple custom theme, restrained manual palettes, visible axes, and readable confidence intervals.

- MR forest plots: label the exposure unit and outcome scale, show instrument counts, and group sensitivity estimators with the primary result. Use a null line at zero for beta or one for OR; a log axis is appropriate for OR. Avoid comparing incompatible units as if they were the same quantity.
- Locus plots: show genomic coordinates, region boundaries, trait identity, and association strength. Explain LD coloring and its reference panel when used. Plotting a shared peak is not itself a coloc result.
- Evidence heatmaps: distinguish estimated effects, p-values, and posterior probabilities. Use a diverging palette only for quantities with a meaningful midpoint. Keep missing, failed, and tested-negative results visually distinct.

Produce a long-form estimate table keyed by study pair, tissue, method, and run, with SNP count, estimate, SE/CI, p-value, and adjusted p-value where applicable. Retain separate diagnostics and locus/probe tables; validate join cardinality before merging them. Report the correction family instead of silently correcting only selected positive results.

Record the input version/build, parameters, analysis date, package versions, and unresolved limitations. Inspect logs and output before sharing; remove account identifiers, local absolute paths, credential-bearing request objects, and restricted input records. Do not relabel a script smoke test as a completed scientific analysis.
