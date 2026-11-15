# Project Overview: CakeML Exception Translation and Reuse Experiments (`problem_with_exceptions`)

## 1. Purpose and Scope
`problem_with_exceptions` (`/botworkspace/problem_with_exceptions`) investigates reusing CakeML translator configurations and exception-handling state across HOL4 proof scripts (`*ProgScript.sml`) without re-declaring redundant translator configurations.

## 2. Key Files and Structure
- [exceptionProgScript.sml](file:///botworkspace/problem_with_exceptions/exceptionProgScript.sml) — Base HOL4/CakeML translation script defining exception constructors and baseline translated functions.
- [exception2ProgScript.sml](file:///botworkspace/problem_with_exceptions/exception2ProgScript.sml) — Original attempt at inheriting the translated exception environment in a downstream HOL4 script.
- [exception2FixedProgScript.sml](file:///botworkspace/problem_with_exceptions/exception2FixedProgScript.sml) — Corrected HOL4/CakeML script resolving translation state inheritance and exception registration.
- [Holmakefile](file:///botworkspace/problem_with_exceptions/Holmakefile) — HOL4 build configuration linking CakeML translator dependencies.
- [MANUSCRIPT_AND_PROOF_INDEX.md](file:///botworkspace/problem_with_exceptions/MANUSCRIPT_AND_PROOF_INDEX.md) and [PROOF_COMPLETIONS_AND_EXTENSIONS.md](file:///botworkspace/problem_with_exceptions/PROOF_COMPLETIONS_AND_EXTENSIONS.md) — Detailed analysis of CakeML `translation_extends` and exception state reuse.
- `tests/` — Automated Python verification suite (`tests/test_*.py`).

## 3. Verification
```bash
python3 -m unittest discover -s /botworkspace/problem_with_exceptions/tests -p "test_*.py"
```
