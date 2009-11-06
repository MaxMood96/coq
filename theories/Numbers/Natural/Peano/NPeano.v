(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)
(*                      Evgeny Makarov, INRIA, 2007                     *)
(************************************************************************)

(*i $Id$ i*)

Require Import Arith.
Require Import Min.
Require Import Max.
Require Import NSub.

Module NPeanoAxiomsMod <: NAxiomsSig.
Module Export NZOrdAxiomsMod <: NZOrdAxiomsSig.
Module Export NZAxiomsMod <: NZAxiomsSig.

Definition NZ := nat.
Definition NZeq := (@eq nat).
Definition NZ0 := 0.
Definition NZsucc := S.
Definition NZpred := pred.
Definition NZadd := plus.
Definition NZsub := minus.
Definition NZmul := mult.

Instance NZeq_equiv : Equivalence NZeq.
Program Instance NZsucc_wd : Proper (eq==>eq) NZsucc.
Program Instance NZpred_wd : Proper (eq==>eq) NZpred.
Program Instance NZadd_wd : Proper (eq==>eq==>eq) NZadd.
Program Instance NZsub_wd : Proper (eq==>eq==>eq) NZsub.
Program Instance NZmul_wd : Proper (eq==>eq==>eq) NZmul.

Theorem NZinduction :
  forall A : nat -> Prop, Proper (eq==>iff) A ->
    A 0 -> (forall n : nat, A n <-> A (S n)) -> forall n : nat, A n.
Proof.
intros A A_wd A0 AS. apply nat_ind. assumption. intros; now apply -> AS.
Qed.

Theorem NZpred_succ : forall n : nat, pred (S n) = n.
Proof.
reflexivity.
Qed.

Theorem NZadd_0_l : forall n : nat, 0 + n = n.
Proof.
reflexivity.
Qed.

Theorem NZadd_succ_l : forall n m : nat, (S n) + m = S (n + m).
Proof.
reflexivity.
Qed.

Theorem NZsub_0_r : forall n : nat, n - 0 = n.
Proof.
intro n; now destruct n.
Qed.

Theorem NZsub_succ_r : forall n m : nat, n - (S m) = pred (n - m).
Proof.
intros n m; induction n m using nat_double_ind; simpl; auto. apply NZsub_0_r.
Qed.

Theorem NZmul_0_l : forall n : nat, 0 * n = 0.
Proof.
reflexivity.
Qed.

Theorem NZmul_succ_l : forall n m : nat, S n * m = n * m + m.
Proof.
intros n m; now rewrite plus_comm.
Qed.

End NZAxiomsMod.

Definition NZlt := lt.
Definition NZle := le.
Definition NZmin := min.
Definition NZmax := max.

Program Instance NZlt_wd : Proper (eq==>eq==>iff) NZlt.
Program Instance NZle_wd : Proper (eq==>eq==>iff) NZle.
Program Instance NZmin_wd : Proper (eq==>eq==>eq) NZmin.
Program Instance NZmax_wd : Proper (eq==>eq==>eq) NZmax.

Theorem NZlt_eq_cases : forall n m : nat, n <= m <-> n < m \/ n = m.
Proof.
intros n m; split.
apply le_lt_or_eq.
intro H; destruct H as [H | H].
now apply lt_le_weak. rewrite H; apply le_refl.
Qed.

Theorem NZlt_irrefl : forall n : nat, ~ (n < n).
Proof.
exact lt_irrefl.
Qed.

Theorem NZlt_succ_r : forall n m : nat, n < S m <-> n <= m.
Proof.
intros n m; split; [apply lt_n_Sm_le | apply le_lt_n_Sm].
Qed.

Theorem NZmin_l : forall n m : nat, n <= m -> NZmin n m = n.
Proof.
exact min_l.
Qed.

Theorem NZmin_r : forall n m : nat, m <= n -> NZmin n m = m.
Proof.
exact min_r.
Qed.

Theorem NZmax_l : forall n m : nat, m <= n -> NZmax n m = n.
Proof.
exact max_l.
Qed.

Theorem NZmax_r : forall n m : nat, n <= m -> NZmax n m = m.
Proof.
exact max_r.
Qed.

End NZOrdAxiomsMod.

Definition recursion : forall A : Type, A -> (nat -> A -> A) -> nat -> A :=
  fun A : Type => nat_rect (fun _ => A).
Implicit Arguments recursion [A].

Theorem succ_neq_0 : forall n : nat, S n <> 0.
Proof.
intros; discriminate.
Qed.

Theorem pred_0 : pred 0 = 0.
Proof.
reflexivity.
Qed.

Instance recursion_wd (A : Type) (Aeq : relation A) :
 Proper (Aeq ==> (eq==>Aeq==>Aeq) ==> eq ==> Aeq) (@recursion A).
Proof.
intros A Aeq a a' Ha f f' Hf n n' Hn. subst n'.
induction n; simpl; auto. apply Hf; auto.
Qed.

Theorem recursion_0 :
  forall (A : Type) (a : A) (f : nat -> A -> A), recursion a f 0 = a.
Proof.
reflexivity.
Qed.

Theorem recursion_succ :
  forall (A : Type) (Aeq : relation A) (a : A) (f : nat -> A -> A),
    Aeq a a -> Proper (eq==>Aeq==>Aeq) f ->
      forall n : nat, Aeq (recursion a f (S n)) (f n (recursion a f n)).
Proof.
unfold Proper, respectful in *; induction n; simpl; auto.
Qed.

End NPeanoAxiomsMod.

(* Now we apply the largest property functor *)

Module Export NPeanoSubPropMod := NSubPropFunct NPeanoAxiomsMod.

