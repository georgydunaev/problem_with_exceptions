# Manuscript and Proof Index: problem_with_exceptions

## 1. Repository Overview and Scope

`problem_with_exceptions` is a formal verification case study in **HOL4** and the **CakeML Monadic Translator** (`ml_monad_translator_interfaceLib`). It investigates a concrete modularity problem in CakeML's characteristic-formula monadic translation framework: when a base theory (`exceptionProgScript.sml`) defines an exception-raising state monad configuration (`config`) over unit state (`:unit`) with a custom exception datatype (`state_exn = Fail1 string | Fail2 int`) and translates monadic functions into verified CakeML ASTs, how can a downstream child theory (`exception2ProgScript.sml`) extend that translation (`m_translation_extends "exceptionProg"`) and translate new monadic functions (`assert2_def`) reusing the parent theory's exception configuration without re-declaring the state and exception datatypes?

---

## 2. Inventory of Source Proof and Code Files

| File | Lines | Language / System | Role and Contents |
| :--- | :--- | :--- | :--- |
| `exceptionProgScript.sml` | 62 | HOL4 / CakeML | **Base Monadic Translation Theory (`exceptionProgTheory`)**. Opens `preamble` and `ml_monad_translator_interfaceLib`, sets `state_type = ``:unit```, defines `Datatype: state_exn = Fail1 string | Fail2 int End`, constructs `val config = global_state_config |> with_exception ``:state_exn``` with parser overloadings `failwith = raise_Fail1` and `handle_fail = handle_Fail1`, defines three monadic functions (`assert_def`, `decrease_def`, `handle_decrease_def`), starts translation (`start_translation config`), and proves the CakeML monadic synthesis theorems `assert_v_thm`, `decrease_v_thm`, and `handle_decrease`. |
| `exception2ProgScript.sml` | 65 | HOL4 / CakeML | **Child Extension Theory (`exception2ProgTheory`)**. Opens `exceptionProgTheory`, invokes `val _ = m_translation_extends "exceptionProg"`, defines `assert2_def` (`assert2 b = if b then failwith "assert2" else return ()`), and demonstrates the cross-theory configuration inheritance failure when calling `assert_def |> m_translate` (or `assert2_def |> m_translate`) after `m_translation_extends`. |
| `Holmakefile` | 14 | HOL4 Build | Configures `CAKEMLDIR` include paths (`misc`, `semantics`, `basis`, `translator`, `characteristic`, `compiler`, `translator/monadic`, `translator/monadic/monad_base`) for `Holmake`. |
| `tests/test_exceptions.py` | 115 | Python | Verification test suite modeling the state-exception monad $(\text{State} \to (\text{Result}(\alpha, \text{Exn}) \times \text{State}))$, verifying `assert`, `decrease`, `handle_decrease`, and `assert2` semantics, and validating the HOL4 script structure. |

---

## 3. Core Mathematical and Verification Results Established

1. **Monadic Exception Semantics over Pure State (`exceptionProgScript.sml`)**:
   - Models pure stateful computations with exceptions in HOL4 as functions of type $\text{unit} \to (\alpha, \text{state\_exn})\,\text{exc} \times \text{unit}$, where:
     - $\text{failwith}(x) = \lambda s.\,(\text{Failure}(\text{Fail1}\;x), s)$ (`raise_Fail1`).
     - $\text{handle\_fail}(m, f) = \lambda s.\,\text{case } m(s) \text{ of } (\text{Success}\;v, s') \Rightarrow (\text{Success}\;v, s') \mid (\text{Failure}(\text{Fail1}\;e), s') \Rightarrow f\;e\;s' \mid \text{other} \Rightarrow \text{other}$ (`handle_Fail1`).
   - Formalizes three monadic specifications:
     - `assert_def`: $\text{assert}(b) = \text{if } b \text{ then failwith}(\text{"assert"}) \text{ else return}\;()$
     - `decrease_def`: $\text{decrease}(n) = \text{assert}(n > 0) \gg \text{return}(n - 1)$
     - `handle_decrease_def`: $\text{handle\_decrease}(n) = \text{handle\_fail}(\text{decrease}(n), \lambda e.\,\text{return}\;0)$
   - Generates verified CakeML deep-embedding closure theorems (`assert_v_thm`, `decrease_v_thm`, `handle_decrease`) via `start_translation config` and `m_translate`.

2. **Diagnosis of the Cross-Theory Monadic Translator Problem (`exception2ProgScript.sml`)**:
   - In `exception2ProgScript.sml`, calling `val _ = m_translation_extends "exceptionProg";` followed by `m_translate` exposes two distinct issues in how `ml_monad_translator_interfaceLib` serializes translator state across HOL4 theory boundaries:
     1. **Overloadings and SML Value Export**: In `exceptionProgScript.sml`, `val config = ...` is an SML-level value of type `translator_config`, not a HOL4 term constant exported in `exceptionProgTheory.sig`, which is why `exceptionProgTheory.config` is unbound in SML (`start_translation exceptionProgTheory.config` fails).
     2. **Parser Overload Persistence (`failwith` / `handle_fail`)**: Because `Overload failwith = ``raise_Fail1``` in `exceptionProgScript.sml` is Check/local or relies on the generated monadic raise combinators, `assert2_def` in `exception2ProgScript.sml` requires `raise_Fail1` (and the monadic type abbreviations) to be in scope when `assert2_def |> m_translate` is invoked (note also line 58 of `exception2ProgScript.sml` accidentally passes `assert_def` instead of `assert2_def` to `m_translate`).

---

## 4. Open Questions and Resolution Path

1. **Fixing `exception2ProgScript.sml` to Complete Cross-Theory Monadic Translation**:
   - In `exception2ProgScript.sml`:
     - Re-declare or export the parser overloadings `Overload failwith = ``exceptionProg$raise_Fail1``` and `Overload handle_fail = ``exceptionProg$handle_Fail1``` (or qualify `raise_Fail1` directly in `assert2_def`).
     - Rely solely on `val _ = m_translation_extends "exceptionProg";` (do *not* call `start_translation` a second time, as `m_translation_extends` already reloads the saved monadic translation configuration from `exceptionProgTheory`'s theory data segment).
     - Change line 58 from `val assert2_v_thm = assert_def |> m_translate;` to `val assert2_v_thm = assert2_def |> m_translate;` so that `m_translate` translates the newly defined `assert2_def` rather than re-translating `assert_def` from the parent theory.
2. **Tickets 7506 and 7507 Cleanup**:
   - Note that `tickets/ticket_7506_problem_with_exceptions.md` and `tickets/ticket_7507_problem_with_exceptions.md` were auto-generated by a generic ticket template assuming C++ exceptions/RAII, whereas this repository is exclusively a **HOL4 / CakeML monadic translator** project (`exceptionProgScript.sml`, `exception2ProgScript.sml`). Future tickets should target HOL4 `m_translation_extends` and CakeML characteristic-formula exception verification.
