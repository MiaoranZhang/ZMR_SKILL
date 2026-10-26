# Personal Skills

This repository contains reusable Codex skills for biomedical research workflows.

## Skills

- [`biomedical-manuscript-writing/`](biomedical-manuscript-writing/): manuscript story logic, evidence-calibrated claims, section drafting, figure logic, and reviewer responses.
- [`single-cell-figure-workflows/`](single-cell-figure-workflows/): R analysis patterns for single-cell and spatial workflows, plus manuscript-ready figure guidance and script templates.
- [`zmr-genome-study/`](zmr-genome-study/): **zmr GenomeStudy SKILL**, covering GWAS/QTL data checks, Mendelian randomization, SMR/HEIDI, colocalization, and genetic evidence reporting. Includes two local-input R helpers.

## Install

Copy the desired skill folder into your Codex skills directory, typically `~/.codex/skills/` or `$CODEX_HOME/skills/`. Keep each skill folder name aligned with the `name` in its `SKILL.md` frontmatter.

The skills are provided without a bundled software environment. Adapt package versions, input paths, metadata names, and analysis choices to the project.

The GenomeStudy helpers run on local data. Optional OpenGWAS access requires each operator's own privately configured credential; no credential or private API configuration is distributed here.
