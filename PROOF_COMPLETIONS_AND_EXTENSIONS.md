# Proof Completions and Mathematical Extensions: problem_with_exceptions

## 1. Root-Cause Diagnosis of `exception2ProgScript.sml`

In [exceptionProgScript.sml](file:///botworkspace/problem_with_exceptions/exceptionProgScript.sml) and [exception2ProgScript.sml](file:///botworkspace/problem_with_exceptions/exception2ProgScript.sml), the goal is to define a CakeML monadic translator configuration with exceptions (`state_exn = Fail1 string | Fail2 int`) in a base HOL4 theory (`exceptionProg`) and extend that translation in a child theory (`exception2Prog`) via `m_translation_extends "exceptionProg"` without re-defining the exception datatype or state configuration.

In [exception2ProgScript.sml](file:///botworkspace/problem_with_exceptions/exception2ProgScript.sml), translation failed due to three specific issues:

1. **Unqualified Parser Overloadings Across Theory Boundaries**:
   - In `exceptionProgScript.sml`, `with_exception ``:state_exn``` generates the HOL4 constants `exceptionProg$raise_Fail1` and `exceptionProg$handle_Fail1`, and binds local parser overloadings `Overload failwith = ``raise_Fail1``` and `Overload handle_fail = ``handle_Fail1```.
   - In `exception2ProgScript.sml` (lines 24--25), those `Overload` declarations were commented out inside the `(*** ... ***)` block, leaving `failwith` in `assert2_def` (line 47) parsed as a free variable rather than `exceptionProg$raise_Fail1`.
2. **Attempting to Call `start_translation exceptionProgTheory.config` (Line 56)**:
   - `val config = global_state_config |> with_exception ``:state_exn``` in `exceptionProgScript.sml` is an SML value in the script execution environment, not an exported HOL theorem in `exceptionProgTheory.sig`.
   - More importantly, calling `start_translation` in a child theory is neither possible nor needed: `val _ = m_translation_extends "exceptionProg";` (line 9) already deserializes the complete monadic translator state (including exception types and state references) stored by `exceptionProgTheory` via HOL4's `ThmSetData` / `TheoryReader` mechanism.
3. **Passing `assert_def` Instead of `assert2_def` on Line 58**:
   - Line 58 of `exception2ProgScript.sml` wrote `val assert2_v_thm = assert_def |> m_translate;` (attempting to re-translate the parent theory's `assert_def`) instead of `val assert2_v_thm = assert2_def |> m_translate;`.

---

## 2. Complete Resolution in `exception2FixedProgScript.sml`

The companion script [exception2FixedProgScript.sml](file:///botworkspace/problem_with_exceptions/exception2FixedProgScript.sml) resolves all three issues cleanly:

1. **Calls `m_translation_extends "exceptionProg"`** once at theory initialization (without calling `start_translation`).
2. **Restores Qualified Parser Overloadings**:
   ```sml
   Overload failwith = ``exceptionProg$raise_Fail1``
   Overload handle_fail = ``exceptionProg$handle_Fail1``
   ```
3. **Defines and Translates `assert2_def`, `decrease2_def`, and `handle_decrease2_def`**:
   ```sml
   val assert2_v_thm = assert2_def |> m_translate;
   val decrease2_v_thm = decrease2_def |> m_translate;
   val handle_decrease2_v_thm = handle_decrease2_def |> m_translate;
   ```
   producing verified CakeML deep-embedding synthesis certificates over the inherited `(unit, 'a, state_exn) M` exception monad.
