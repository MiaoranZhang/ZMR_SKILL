# Computational Manuscript Language

Use this reference when drafting or editing Methods, Results, legends, figure labels, and reviewer responses that describe computational analyses. It addresses project-management language entering an article; it is not a requirement to rename standard computational methods.

## Decide what the words describe

- **Scientific method or object:** name the dataset, gene set, comparison, statistical unit, criterion, or measured result directly. A numerical threshold, workflow diagram, data-provenance statement, or flow-cytometry gate can be technically correct and should remain when relevant.
- **Internal project state:** replace version labels (`V6`), stage identifiers (`P4`), and execution codes (`FOUND_VALID`, `P3_FAIL_CONFIRMED`) with the specific meaning a reader needs. Keep the mapping in code or supporting records when useful for reproducibility.
- **Timing or registration claim:** check what was specified, when it was specified relative to analysis or outcome inspection, and which record supports that claim. `Prespecified` does not automatically mean publicly preregistered; a public registration needs its actual registry, identifier, and date. An internal list of analyses is not evidence of either timing or formal registration by itself. If timing is unknown, describe the criterion neutrally and flag the unresolved provenance separately. Do not erase known post-hoc selection or imply it was prospective.

## Preserve the measured object

Read the source table or panel before choosing a replacement. A row may represent a file record, a data-preparation task, an analysis, a sample, or an independent donor; these are not interchangeable. Do not turn a manifest of derived analysis files into an inventory of raw data, or count administrative entries as biological experiments.

The following examples are contextual, not automatic replacements:

| Original wording | Suitable wording in that case | Condition |
| --- | --- | --- |
| `Frozen input records` | `Analysis file records` | The count includes analysis-file records, not solely raw inputs. |
| `Registered analyses` | `Analysis and data-preparation entries` | The internal list includes data-preparation tasks; it is not a registration record. |
| `Prespecified sensitivity gates` | `Assessment criteria` | Criteria are known, but their prospective timing has not been verified. |
| `P4_FAIL_CONFIRMED` | `Cross-cohort criterion not met` | The original result is failure to meet a defined cross-cohort criterion. |
| `V6 main question` | `Main study question` | The version number identifies a working draft, not a relevant dataset or software release. |
| `Frozen classification labels` | `Assigned categories` | The figure displays classifications, not a methodologically important locking procedure. |
| `Availability and SHA256 audit` | `Analysis file availability` | The panel plots availability counts and does not display checksum comparisons. |

## Keep real reproducibility information

SHA256 is a valid checksum method. Retain it in Methods or file manifests when it was actually used, and distinguish computing/storing a checksum from verifying a file against an expected checksum. Do not claim an audit, independent review, or completed validation on the basis of file presence alone. For example, `SHA256 checksums were computed for the input files` is appropriate only if that action is documented; it does not establish that the files matched the intended source or that the analyses were correct.

Replacing workflow jargon cannot satisfy a request for complete code, package versions, input manifests, access dates, authorization records, or execution logs. Keep those as explicit outstanding tasks when unavailable. Do not invent a repository, date, permission, preregistration, or author verification. Necessary disclosure and reproducibility statements are not removable merely because they concern computation.

## Preserve evidence when simplifying

- Retain effect directions, counts, denominators, uncertainty, relevant numerical criteria, and negative or contrary results. `5/9 compartments met both criteria` must not become `the reference was validated`.
- Prefer the actual observation over an internal failure label. Use a short criterion label only when the criterion and result are already clear nearby.
- A shorter topic list must retain every material analysis category. Do not drop class-switching, cross-disease, or another distinct analysis merely to shorten a caption; expand unfamiliar internal codes into their actual meanings.
- Do not replace `threshold` or `cutoff` mechanically. Preserve the numerical value and distinguish a display cutoff from a statistical or decision criterion.
- Keep figure legends tied to visible groups, axes, symbols, lines, and numerical marks. Put additional interpretation in the appropriate manuscript section.

## Apply during drafting and revision

Check relevant prose and figure text for `frozen`, `registered`, `prespecified`, `gate`, `audit`, version labels, and software status codes. Inspect each occurrence in context; search hits are prompts for judgment, not errors by definition. Align a changed label with its caption and first in-text description. Preserve panel capitalization and object numbering unless the task requires a coordinated correction.

When a change record is requested, provide source order and location, original English, Chinese translation, revised English, Chinese translation, and a short reason. Keep reviewer quotations unchanged. Clearly distinguish language edits, scientific changes, and any unresolved reproducibility requests.

Use examples only to illustrate the decision rule; inspect the current evidence before reusing any wording. Project-specific revision records should remain with the relevant manuscript materials and should not be treated as universal templates.
