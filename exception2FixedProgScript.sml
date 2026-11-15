(*
  exception2FixedProgScript.sml
  Resolved cross-theory CakeML monadic translator extension for problem_with_exceptions.
  Demonstrates how exception2ProgTheory inherits the monadic state and exception
  configuration from exceptionProgTheory via m_translation_extends without
  re-declaring state_exn or re-running start_translation.
*)
open preamble ml_monad_translator_interfaceLib
open exceptionProgTheory

val _ = new_theory "exception2FixedProg";
val _ = m_translation_extends "exceptionProg";
val _ = patternMatchesLib.ENABLE_PMATCH_CASES();

(* Re-bind parser overloadings to the parent theory's generated exception combinators *)
Overload failwith = ``exceptionProg$raise_Fail1``
Overload handle_fail = ``exceptionProg$handle_Fail1``

(* Define new monadic functions in the child theory reusing exceptionProg's monad *)
val assert2_def = Define `
  assert2 b = if b then failwith "assert2" else return ()`;

val decrease2_def = Define `
  decrease2 n = monad_ignore_bind (assert2 (n = (0:num))) (return (n - 1))`;

val handle_decrease2_def = Define `
  handle_decrease2 n = handle_fail (decrease2 n) (\e. return 0)`;

(*
  Translate directly using m_translate!
  Do NOT call `start_translation config` again in the child theory because
  `m_translation_extends "exceptionProg"` already initializes the translator state
  from exceptionProgTheory's persisted theory data.
  Also pass `assert2_def` (not `assert_def`) to `m_translate`.
*)
val assert2_v_thm = assert2_def |> m_translate;
val decrease2_v_thm = decrease2_def |> m_translate;
val handle_decrease2_v_thm = handle_decrease2_def |> m_translate;

val _ = export_theory ();
