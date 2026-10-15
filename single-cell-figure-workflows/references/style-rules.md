# Style Rules

## Purpose

Read this file when editing existing scripts or writing new code that follows a project's established conventions.

## Coding Style

- Prefer biologically meaningful object names over abstract names
- Keep code linear when the script is clearly analysis-first
- Add helper functions only when they remove obvious repetition or improve safety
- Preserve existing path assumptions when a workflow depends on them; centralize project-specific paths when creating a reusable scaffold
- Keep outputs explicit: write the `pdf`, `csv`, and `rds` files directly

## Refactor Discipline

Use the smallest safe change:

- legacy script with many downstream dependencies: patch in place
- new repeated logic inside one script: extract a local helper
- cross-project reusable routine: consider a cleaner function, but do not force a package-like structure

Avoid:

- renaming every object to generic software names
- moving everything into classes or modules without a user need
- rewriting working Seurat slot access just for style

## Naming Habits

Common object names are short and biological:

- `Epi`
- `Fib`
- `Macro`
- `Myeloid`
- `CD4T`
- `CD8T`
- `LNCD4T`
- `Tumor`
- `Bcell`

Common output names encode:

- project
- biology
- date
- comparison

Examples:

- `PCA_plot0914.pdf`
- `IE_DEG_BSvsHC0918.csv`
- `stacked_bar_niches1021.pdf`

## Plotting Habits

- use manual palettes often stored near the top of the script
- use `theme_classic`, `guides`, factor releveling, and explicit figure dimensions
- write figures to PDF directly
- treat plot order as a biological argument, not just aesthetics

## Biological Framing Rules

- code is usually built around one comparison that matters biologically
- subsetting is part of the logic, not just preprocessing
- scoring and communication analyses are used to support a figure sentence
- if a branch does not help the biological claim, cut it

## Safe Editing Rules For This Corpus

- inspect downstream object names before changing upstream code
- keep metadata column names stable unless the whole script is being modernized
- when adding new analyses, use the existing assay and grouping logic already present in the script
- if there are existing color maps or factor orders, reuse them unless the figure goal changed
