(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

module Dyn = Dyn.Make ()

module Stage = struct

type t = Synterp | Interp

let equal x y =
  match x, y with
  | Synterp, Synterp -> true
  | Synterp, Interp -> false
  | Interp, Interp -> true
  | Interp, Synterp -> false

end

type 'a summary_declaration = {
  stage : Stage.t;
  freeze_function : marshallable:bool -> 'a;
  unfreeze_function : 'a -> unit;
  init_function : unit -> unit }

module Decl = struct type 'a t = 'a summary_declaration end
module DynMap = Dyn.Map(Decl)

type ml_modules = (string option * string) list

let sum_mod : ml_modules summary_declaration option ref = ref None
let sum_map_synterp = ref DynMap.empty
let sum_map_interp = ref DynMap.empty

let mangle id = id ^ "-SUMMARY"

let declare_ml_modules_summary decl =
  sum_mod := Some decl

let check_name sumname = match Dyn.name sumname with
| None -> ()
| Some (Dyn.Any t) ->
  CErrors.anomaly ~label:"Summary.declare_summary"
    Pp.(str "Colliding summary names: " ++ str sumname
      ++ str " vs. " ++ str (Dyn.repr t) ++ str ".")

let declare_summary_tag sumname decl =
  let () = check_name (mangle sumname) in
  let tag = Dyn.create (mangle sumname) in
  let sum_map = match decl.stage with Synterp -> sum_map_synterp | Interp -> sum_map_interp in
  let () = sum_map := DynMap.add tag decl !sum_map in
  tag

let declare_summary sumname decl =
  ignore(declare_summary_tag sumname decl)

module ID = struct type 'a t = 'a end
module Frozen = Dyn.Map(ID)
module HMap = Dyn.HMap(Decl)(ID)

module type FrozenStage = sig

  (** The type [frozen] is a snapshot of the states of all the registered
      tables of the system. *)

  type frozen

  val empty_frozen : frozen
  val freeze_summaries : marshallable:bool -> frozen
  val unfreeze_summaries : ?partial:bool -> frozen -> unit
  val init_summaries : unit -> unit

end

let freeze_summaries ~marshallable sum_map =
  let map = { HMap.map = fun tag decl -> decl.freeze_function ~marshallable } in
  HMap.map map sum_map

let warn_summary_out_of_scope =
  CWarnings.create ~name:"summary-out-of-scope" ~default:Disabled Pp.(fun name ->
      str "A Coq plugin was loaded inside a local scope (such as a Section)." ++ spc() ++
      str "It is recommended to load plugins at the start of the file." ++ spc() ++
      str "Summary entry: " ++ str name)

let unfreeze_summaries ?(partial=false) sum_map summaries =
  (* We must be independent on the order of the map! *)
  let ufz (DynMap.Any (name, decl)) =
    try decl.unfreeze_function Frozen.(find name summaries)
    with Not_found ->
      if not partial then begin
        warn_summary_out_of_scope (Dyn.repr name);
        decl.init_function ()
      end
  in
  DynMap.iter ufz sum_map

let init_summaries sum_map =
  DynMap.iter (fun (DynMap.Any (_, decl)) -> decl.init_function ()) sum_map

module Synterp = struct

  type frozen =
    {
        summaries : Frozen.t;
        (** Ordered list w.r.t. the first component. *)
        ml_module : ml_modules option;
        (** Special handling of the ml_module summary. *)
    }

  let empty_frozen = { summaries = Frozen.empty; ml_module = None }

  let freeze_summaries ~marshallable =
    let summaries = freeze_summaries ~marshallable !sum_map_synterp in
    { summaries; ml_module = Option.map (fun decl -> decl.freeze_function ~marshallable) !sum_mod }

  let unfreeze_summaries ?(partial=false) { summaries; ml_module } =
    (* The unfreezing of [ml_modules_summary] has to be anticipated since it
    * may modify the content of [summaries] by loading new ML modules *)
    begin match !sum_mod with
    | None -> CErrors.anomaly Pp.(str "Undeclared ML-MODULES summary.")
    | Some decl -> Option.iter decl.unfreeze_function ml_module
    end;
    unfreeze_summaries ~partial !sum_map_synterp summaries

  let init_summaries () =
    init_summaries !sum_map_synterp

end

module Interp = struct

type frozen = Frozen.t

let empty_frozen = Frozen.empty

  let freeze_summaries ~marshallable =
    freeze_summaries ~marshallable !sum_map_interp

  let unfreeze_summaries ?(partial=false) summaries =
    unfreeze_summaries ~partial !sum_map_interp summaries

  let init_summaries () =
    init_summaries !sum_map_interp

  (** Summary projection *)
  let project_from_summary summaries tag =
    Frozen.find tag summaries

  let modify_summary summaries tag v =
    let () = assert (Frozen.mem tag summaries) in
    Frozen.add tag v summaries

  let remove_from_summary summaries tag =
    let () = assert (Frozen.mem tag summaries) in
    Frozen.remove tag summaries

end

(** For global tables registered statically before the end of coqtop
    launch, the following empty [init_function] could be used. *)

let nop () = ()

(** All-in-one reference declaration + registration *)

let ref_tag ?(stage=Stage.Interp) ~name x =
  let r = ref x in
  let tag = declare_summary_tag name
    { stage;
      freeze_function = (fun ~marshallable:_ -> !r);
      unfreeze_function = ((:=) r);
      init_function = (fun () -> r := x) } in
  r, tag

let ref ?(stage=Stage.Interp) ?(local=false) ~name x =
  if not local then fst @@ ref_tag ~stage ~name x
  else
    let r = ref x in
    let () = declare_summary name
        { stage;
          freeze_function = (fun ~marshallable -> if marshallable then Some !r else None);
          unfreeze_function = (function Some v -> r := v | None -> r := x);
          init_function = (fun () -> r := x); }
    in
    r

module Local = struct

type 'a local_ref = 'a ref

let ref ?stage ~name x = ref ?stage ~name ~local:true x
let (!) = (!)
let (:=) = (:=)

end

let dump = Dyn.dump
