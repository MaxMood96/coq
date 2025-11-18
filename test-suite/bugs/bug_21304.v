(* NB this test can be removed once dynamic scheme declaration is removed
   (ie when warning "missing-scheme" is replaced by an error) *)
Inductive equal T (x : T) : T -> Type := Equal : equal T x x.

Lemma foo : forall a b, equal nat a b -> a = b.
Proof.
intros a b H.
rewrite <- H, H.
Abort.
