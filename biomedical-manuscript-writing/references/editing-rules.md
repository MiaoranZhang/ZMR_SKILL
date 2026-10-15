# Editing Rules

## Publication-first editing

Present the paper's strongest supported logic rather than its work history. Remove material with no argumentative role from the main line. Do not use phrases such as `unfortunately`, `only`, `still lagged behind`, or `limited effect` merely to pre-empt criticism. Preserve necessary quantitative and scope limitations.

When the paper does not win on a metric, first ask whether that metric answers the paper's actual question. A scientifically justified comparison, use case, or tradeoff may be more appropriate, but must not be selected post hoc and presented as prespecified.

Do not end an abstract or conclusion with a new self-negating sentence. Limitations belong where they improve interpretation, expressed in proportion to their effect on the central conclusion.

## Manuscript register, not work-report register

The manuscript should read as a scientific argument rather than a project report, execution log, frozen analysis specification, handoff document, or troubleshooting guide. Remove operational language that describes how the project was managed instead of what was scientifically done and learned.

Review the following terms in context rather than banning them mechanically:

- `threshold`: retain for a real quantitative or prespecified decision threshold; otherwise use the actual criterion, cutoff, inclusion rule, or biological boundary instead of a metaphorical hurdle.
- `freeze` or `frozen`: retain only when a locked model, database release, or prespecified analysis state is methodologically important; otherwise use `prespecified`, `finalized`, `fixed`, or omit the project-status detail.
- `feature panel`: replace with the scientifically exact object, such as `feature set`, `selected variables`, `marker set`, `gene signature`, `antibody panel`, or `predictor set`.
- `troubleshooting guide`: omit from article prose. If a diagnostic procedure is essential for reproducibility, describe it as quality control, sensitivity analysis, validation, or a prespecified decision procedure in Methods.
- `reported` or `the reported ...`: use only for genuine attribution to prior literature or an explicitly presented estimate. Prefer a direct subject and verb for the present study instead of bureaucratic constructions such as `the reported results showed`.

Also remove neighboring workflow idioms such as `pipeline checkpoint`, `gate`, `locked version`, `handoff`, `failure mode`, and `debugging` when they function as project-management metaphors. Preserve them when they are established technical terms and no more precise scientific term exists.

## Minimal-edit mode

When the user supplies text for checking or revision:

1. inspect all supplied text in order;
2. identify every defensive or self-weakening expression, not merely examples;
3. report `location / original phrase -> problem -> minimal revision`;
4. preserve the author's vocabulary and paragraph structure;
5. change a word, phrase, or sentence before considering paragraph-level rewriting;
6. leave sound text unchanged;
7. if a minimal edit cannot repair the logic, say so and propose a local structural fix;
8. do not add unsupported results, mechanisms, advantages, or explanations.

This focused mode takes precedence over full manuscript diagnosis unless the user also requests restructuring.

## Gene and protein formatting

Choose typography from biological meaning, not symbol appearance:

- italicize genes, transcripts, gene expression, and in-silico gene perturbations, such as *GSTP1* or *NRTN*;
- use roman type for proteins, protein structures, enzymatic activities, inhibitors, and drug targets;
- use roman type for pathways, signaling activities, and gene-set names;
- use roman type for clinical protein biomarkers such as HER2, PD-L1, and CLDN18.2.

If a sentence mixes gene and protein meanings, rewrite it so the referent is explicit before applying formatting.

## Terminology discipline

Use `program` or `programs` only for evidence-supported coordinated biological processes when no more precise term works. Prefer:

- `pathway` or `signature` for enrichment results;
- `transcriptional state`, `expression pattern`, or `transcriptional change` for expression findings;
- `process`, `response`, or a named biological activity for phenotype and function.

Review every occurrence in context; do not make a blind global replacement.

## Negative statements and section placement

Results should report the analyses performed, the observations obtained, and the conclusions directly supported by those observations. Do not use Results to list every stronger proposition that was not tested or supported.

Avoid defensive contrast sentences such as:

- `But this is not an equivalence test.`
- `However, this application does not support a universally invariant treatment-comparison magnitude.`

First decide whether the distinction is necessary:

1. If it does not affect interpretation of the tested result, omit it.
2. If it defines the analysis scope but is not itself a result, state the positive scope in Methods or Discussion. For example: `The analysis was designed to compare directional consistency rather than establish formal equivalence.`
3. If it is an important limitation or guards against a likely overinterpretation, discuss it in Discussion after stating the supported conclusion. For example: `The treatment contrast was evaluated within the tested application and range; its transportability across settings remains to be determined.`
4. If a negative, null, or contrary finding materially changes the central conclusion, belongs to a prespecified endpoint, or is required by reporting standards, report it accurately in Results. Do not hide it; reserve causal explanation, implications, and broader limitations for Discussion.

Prefer affirmative scope control (`was designed to assess`, `was evaluated within`, `supports X under Y conditions`) over sentence-opening `but`, `however`, `does not prove`, `is not equivalent`, or `does not support universal...` constructions. This is a placement and framing rule, not permission to overstate evidence.
