(* Example from #9521 *)
Declare Custom Entry expr.

Module A.

Notation "expr0:( s )" := s (s custom expr at level 0).
Notation "#" := 0 (in custom expr at level 0).
Check expr0:(#). (* Should not be an anomaly "unknown level 0" *)

End A.

(* Another example from a comment at #11561 *)

Module B.

Declare Custom Entry special.
Notation "## x" := (S x) (in custom expr at level 10, x custom special at level 10).
Notation "[ e ]" := e (e custom expr at level 10).
Notation "1" := 1 (in custom special).
Check [ ## 1 ].

End B.
