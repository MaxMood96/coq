Goal True.
Proof.
  Fail assert (h:forall x:bar, True).
(*
Toplevel input, characters 11-12:
>   assert (h:forall x:bar, True).
>           ^
Error: The variable bar was not found in the current environment.
*)
Abort.
