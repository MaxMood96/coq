(************************************************************************)
(*         *      The Rocq Prover / The Rocq Development Team           *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

open Names
open Tac2expr
open EConstr
open Genredexpr
open Tac2types
open Proofview

(** Local reimplementations of tactics variants from Rocq *)

val intros_patterns : evars_flag -> intro_pattern list -> unit tactic

val apply : advanced_flag -> evars_flag ->
  constr_with_bindings thunk list ->
  (Id.t * intro_pattern option) option -> unit tactic

val induction_destruct : rec_flag -> evars_flag ->
  induction_clause list -> constr_with_bindings option -> unit tactic

val elim : evars_flag -> constr_with_bindings -> constr_with_bindings option ->
  unit tactic

val general_case_analysis : evars_flag -> constr_with_bindings ->  unit tactic

val generalize : (constr * occurrences * Name.t) list -> unit tactic

val constructor_tac : evars_flag -> int option -> int -> bindings -> unit tactic

val left_with_bindings  : evars_flag -> bindings -> unit tactic
val right_with_bindings : evars_flag -> bindings -> unit tactic
val split_with_bindings : evars_flag -> bindings -> unit tactic

val specialize : constr_with_bindings -> intro_pattern option -> unit tactic

val change : Pattern.constr_pattern option -> (constr array, constr) Tac2ffi.fun1 -> clause -> unit tactic

val rewrite :
  evars_flag -> rewriting list -> clause -> unit thunk option -> unit tactic

val setoid_rewrite :
  orientation -> constr_with_bindings tactic -> occurrences -> Id.t option -> unit tactic

val rewrite_strat : Rewrite.strategy -> Id.t option -> unit tactic

module RewriteStrats :
sig
  val fix : Tac2val.closure -> Rewrite.strategy tactic

  val hints : Id.t -> Rewrite.strategy

  val old_hints : Id.t -> Rewrite.strategy

  val one_lemma : Ltac_pretype.closed_glob_constr -> bool -> Rewrite.strategy

  val lemmas : Ltac_pretype.closed_glob_constr list -> Rewrite.strategy
end

val symmetry : clause -> unit tactic

val forward : bool -> unit tactic option option ->
  intro_pattern option -> constr -> unit tactic

val assert_ : assertion -> unit tactic

val letin_pat_tac : evars_flag -> (bool * intro_pattern_naming) option ->
  Name.t -> (Evd.evar_map option * constr) -> clause -> unit tactic

val reduce_in : Redexpr.red_expr -> clause -> unit tactic

val reduce_constr : Redexpr.red_expr -> constr -> constr tactic

val simpl : Tac2types.red_flag -> Tac2types.red_context -> Redexpr.red_expr tactic

val cbv : Tac2types.red_flag -> Redexpr.red_expr tactic

val cbn : GlobRef.t glob_red_flag -> Redexpr.red_expr tactic

val lazy_ : GlobRef.t glob_red_flag -> Redexpr.red_expr tactic

val unfold : (GlobRef.t * occurrences) list -> Redexpr.red_expr tactic

val pattern : (constr * occurrences) list -> Redexpr.red_expr

val vm : Tac2types.red_context -> Redexpr.red_expr

val native : Tac2types.red_context -> Redexpr.red_expr

val discriminate : evars_flag -> destruction_arg option -> unit tactic

val injection : evars_flag -> intro_pattern list option -> destruction_arg option -> unit tactic

val autorewrite : all:bool -> unit thunk option -> Id.t list -> clause -> unit tactic

val trivial : Hints.debug -> GlobRef.t list -> Id.t list option ->
  unit Proofview.tactic

val auto : Hints.debug -> int option -> GlobRef.t list ->
  Id.t list option -> unit Proofview.tactic

val eauto : Hints.debug -> int option -> GlobRef.t list ->
  Id.t list option -> unit Proofview.tactic

val typeclasses_eauto : Class_tactics.search_strategy option -> int option ->
  Id.t list option -> unit Proofview.tactic

val unify : constr -> constr -> unit tactic

val inversion : Inv.inversion_kind -> destruction_arg -> intro_pattern option -> Id.t list option -> unit tactic

val contradiction : constr_with_bindings option -> unit tactic

val current_transparent_state : unit -> TransparentState.t tactic

val evarconv_unify : TransparentState.t -> constr -> constr -> unit tactic

(** Internal *)

val mk_intro_pattern : intro_pattern -> Tactypes.intro_pattern

val congruence : int option -> constr list option -> unit Proofview.tactic

val simple_congruence : int option -> constr list option -> unit Proofview.tactic

val f_equal : unit Proofview.tactic
