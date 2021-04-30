(*
  An example showing how to use the monadic translator to translate
  monadic functions using exceptions (no references, no arrays).
*)
open preamble ml_monad_translator_interfaceLib
open exceptionProgTheory

val _ = new_theory "exceptionProg2";

val _ = patternMatchesLib.ENABLE_PMATCH_CASES();
(*** COMMENTED, WE WANT USE THE SAME CONFIGURATION, AS IN exceptionProgScript.sml
(* No references/arays, so use unit for the state type *)
val state_type = ``:unit``;

(* Data type for the exceptions *)
Datatype:
  state_exn = Fail1 string | Fail2 int
End

(* Translator configuration *)
val config = global_state_config |>
             with_exception ``:state_exn``;

(* Parser overloadings for exceptions *)
Overload failwith = ``raise_Fail1``
Overload handle_fail = ``handle_Fail1``

(* It is possible to define the exception handling functions by hand:

val failwith2_def = Define `
  failwith x = \(state : state_refs). (Failure (Fail1 x), state)`;
val handle_fail_def = Define `
  handle_fail x f = \(state : state_refs). dtcase x state of
    (Success x, state) => (Success x, state)
  | (Failure (Fail1 e), state) => f e state
  | other => other`
...

*)

(*
 * It is now possible to use these functions in new definitions:
 *)
***)

val assert2_def = Define `
  assert2 b = if b then failwith "assert2" else return ()`;
(**
val decrease_def = Define `
  decrease n = monad_ignore_bind (assert (n > (0:num))) (return (n-1))`;

val handle_decrease_def = Define `
  handle_decrease n = handle_fail (decrease n) (\e. return 0)`;
**)
(* Translate *)
val _ = start_translation exceptionProgTheory.config; (* this doesn't work *)

val assert2_v_thm = assert_def |> m_translate; (* even if previos line is commented this also doesn't work *)
(**
val decrease_v_thm = decrease_def |> m_translate;
val handle_decrease = handle_decrease_def |> m_translate;
**)
(**********)

val _ = export_theory();
