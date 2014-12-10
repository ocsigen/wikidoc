(* Ocsimore
 * Copyright (C) 2010 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
(**
   Pretty print wiki to LaTeX
   @author Vincent Balat
*)

open Wikicreole

let (>>=) = Lwt.bind

type rope =
  | Menu_link of string * rope (* used only in menus *)
  | Leaf of string
  | Leaf_unquoted of string
  | Node of rope * rope
  | Node3 of string * rope list * string
  | Nodelist of rope list

let reg0' = Str.regexp_string "WIKIBACKSLASHWIKI"
let reg0 = Str.regexp_string "\\"
let reg1 = Str.regexp_string "_"
let reg2 = Str.regexp_string "$"
let reg3 = Str.regexp_string "&"
let reg4 = Str.regexp_string "%"
let reg5 = Str.regexp_string "#"
let reg6 = Str.regexp_string "^"
let reg7 = Str.regexp_string "-"
let regs = [
  (reg0, "WIKIBACKSLASHWIKI");
  (reg1, "\\_");
  (reg2, "\\$");
  (reg3, "\\&");
  (reg4, "\\%");
  (reg5, "$\\sharp$");
  (reg6, "\\^");
  (Str.regexp_string "{", "\\{");
  (Str.regexp_string "}", "\\}");
  (Str.regexp_string "~", "{\\texttildelow}");
  (reg0', "$\\backslash$");
]

let escape s =
  List.fold_left (fun s (reg, subst) -> Str.global_replace reg subst s) s regs

let escape_ref s =
  let s = Str.global_replace reg1 "=" s in
  let s = Str.global_replace reg2 "+" s in
  let s = Str.global_replace reg3 "," s in
  let s = Str.global_replace reg4 ";" s in
  let s = Str.global_replace reg5 "*" s in
  s

let escape_label s =
  List.fold_left (fun s (reg, subst) -> Str.global_replace reg subst s) s [reg7,":"; reg1,"-"; reg4, "-pc"]

let reg_u = Str.regexp_string "~>>"
let regs_unquoted = [
  (reg_u, ">>");
]

let escape_code s =
  List.fold_left (fun s (reg, subst) -> Str.global_replace reg subst s) s regs_unquoted

let rec print_rope = function
  | Menu_link _ -> print_string "{\\bfseries ** Error in menu}"
  | Leaf s -> print_string (escape s)
  | Leaf_unquoted s -> print_string (escape_code s)
  | Node (r1, r2) -> print_rope r1; print_rope r2
  | Node3 (s1, rl, s2) -> print_string s1; List.iter print_rope rl; print_string s2
  | Nodelist l -> List.iter print_rope l

let offset = try int_of_string Sys.argv.(2) with _ -> 0
let label_prefix = escape_label Sys.argv.(1)

let sect n = match n+offset with
  | 1 -> Leaf_unquoted "\n\\part{"
  | 2 -> Leaf_unquoted "\n\\chapter{"
  | 3 -> Leaf_unquoted "\n\\section{"
  | 4 -> Leaf_unquoted "\n\\subsection{"
  | 5 -> Leaf_unquoted "\n\\subsubsection{"
  | 6 -> Leaf_unquoted "\n\\paragraph{"
  | _ -> Leaf_unquoted "\n\n{"

let close_sect ?id () =
  match id with
  | Some id -> Node3 ("}\n\\label{",[Leaf_unquoted id],"}\n")
  | None -> Leaf_unquoted "}\n"

let get_id attribs =
  try Some (label_prefix ^ ":" ^ escape_label (List.assoc "id" attribs))
  with Not_found -> None

let is_inline = ref 0

module LatexBuilder = struct

  type href = string
  type param = unit
  type phrasing_without_interactive = rope Lwt.t
  type phrasing = rope Lwt.t
  type flow = rope Lwt.t
  type flow_without_interactive = rope Lwt.t
  type uo_list = rope Lwt.t

  let list x = x
  let flow x = x
  let phrasing x = x
  let section_elem _ x =
    Lwt_list.map_s (fun x -> x) x >>= fun l -> Lwt.return (Nodelist l)


  let chars s = Lwt.return (Leaf s)
  let strong_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    Lwt.return (Node3 ("{\\bfseries ", inlinelist, "}"))
  let em_elem attribs inlinelist=
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    Lwt.return (Node3 ("\\emph{", inlinelist, "}"))
  let br_elem attribs = Lwt.return (Leaf_unquoted "\\mbox{}\\\\")
  let img_elem attribs addr alt =
        Lwt.return (Node3 ("\\includegraphics{", [Leaf addr], "}"))
  let tt_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("{\\tt ", inlinelist, "}"))
  let monospace_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("{\\tt ", inlinelist, "}"))
  let underlined_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("\\underline{", inlinelist, "}"))
  let linethrough_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("\\linethrough{", inlinelist, "}"))
  let subscripted_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("$_{\\mbox{", inlinelist, "}}$"))
  let superscripted_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        Lwt.return (Node3 ("$^{\\mbox{", inlinelist, "}}$"))
  let nbsp = Lwt.return (Leaf_unquoted "~")
  let endash = Lwt.return (Leaf_unquoted "--")
  let emdash = Lwt.return (Leaf_unquoted "---")
  let a_elem_phrasing attribs addr c =
        Lwt_list.map_s (fun x -> x) c >>= fun c ->
        Lwt.return (
          Node (Node3("\\hyperref[", [Leaf (escape_ref addr)], "]{"),
                Node (Nodelist c, Leaf_unquoted "}")))
  let a_elem_flow = a_elem_phrasing (* FIXME wrap in paragraph ?? *)
  let make_href _ a fragment = match fragment with
        | None -> a
        | Some f -> a ^"#"^f
  let p_elem attribs inlinelist =
        Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
        if !is_inline > 0
        then Lwt.return (Nodelist inlinelist)
        else Lwt.return (Node3 ("\n", inlinelist, "\n\n"))
  let pre_elem attribs stringlist =
        Lwt.return (Node3 ("\n\\begin{verbatim}\n",
                           List.map (fun s -> Leaf_unquoted s) stringlist,
                           "\\end{verbatim}\n\\medskip\n\n\\noindent"))
  let h1_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = Some label_prefix in
    Lwt.return (Nodelist [sect 2; Nodelist inlinelist; close_sect ?id ()])
  let h2_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = get_id attribs in
    Lwt.return (Nodelist [sect 3; Nodelist inlinelist; close_sect ?id  ()])
  let h3_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = get_id attribs in
    Lwt.return (Nodelist [sect 4; Nodelist inlinelist; close_sect ?id  ()])
  let h4_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = get_id attribs in
    Lwt.return (Nodelist [sect 5; Nodelist inlinelist; close_sect ?id  ()])
  let h5_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = get_id attribs in
    Lwt.return (Nodelist [sect 6; Nodelist inlinelist; close_sect ?id  ()])
  let h6_elem attribs inlinelist =
    Lwt_list.map_s (fun x -> x) inlinelist >>= fun inlinelist ->
    let id = get_id attribs in
    Lwt.return (Nodelist [sect 7; Nodelist inlinelist; close_sect ?id  (); Leaf "\n"])
  let ul_elem attribs l =
        Lwt_list.map_s (fun (il, flopt, _) ->
          Lwt_list.map_s (fun x -> x) il >>= fun il ->
          match flopt with
            | None -> Lwt.return (Node (Leaf_unquoted "\\item ", Nodelist il))
            | Some fl -> fl >>= fun fl ->
              Lwt.return (Node (Node (Leaf_unquoted "\\item ", Nodelist il), fl))
        ) l >>= fun l ->
        Lwt.return (
          Node3 ("\n\\begin{itemize}\n", l, "\n\\end{itemize}\n"))
  let ol_elem attribs l =
        Lwt_list.map_s (fun (il, flopt, _) ->
          Lwt_list.map_s (fun x -> x) il >>= fun il ->
          match flopt with
            | None -> Lwt.return (Node3 ("\n\\item", il, ""))
            | Some fl -> fl >>= fun fl ->
              Lwt.return (Node3 ("\n\\item", il@[fl], ""))
        ) l >>= fun l ->
         Lwt.return (
           Node3 ("\n\\begin{enumerate}\n",
                  l,
                 "\n\\end{enumerate}\n"))
  let dl_elem attribs l =
        let rec aux = function
          | (true, title, _)::(false, c, _)::l ->
            (Lwt_list.map_s (fun x -> x) title >>= fun title ->
             Lwt_list.map_s (fun x -> x) c >>= fun c ->
             aux l >>= fun l ->
             Lwt.return (
               Node3 ("\n\\item[{",
                      title@(Leaf_unquoted "}] "::c),
                      "")
                                       ::l))
          | (true, title, _)::l ->
            (Lwt_list.map_s (fun x -> x) title >>= fun title ->
             aux l >>= fun l ->
             Lwt.return (
               Node3 ("\n\\item[{", title, "}]")
               ::l))
          | (false, c, _)::l ->
            (Lwt_list.map_s (fun x -> x) c >>= fun c ->
             aux l >>= fun l ->
             Lwt.return (
               Nodelist ((Leaf_unquoted "\n\\item[]")::c)
                                             ::l))
          | [] -> Lwt.return []
        in
        aux l >>= fun l ->
        Lwt.return (
          Node3 ("\n\\begin{description}\n",
                 l,
                 "\n\\end{description}\n"))
  let hr_elem _ = Lwt.return (Leaf_unquoted "\n\n")
  let table_elem _ l =
        let rec get_colspan = function
          | [] -> 1
          | ("colspan", v)::_ -> int_of_string v
          | _::l -> get_colspan l
        in
        let nbcol = match l with
          | [] -> 0
          | l1::_ ->
            List.fold_left
              (fun nb (_, attrs, _) -> nb+get_colspan attrs)
              0 (fst l1)
        in
        let sizecol = "p{"^string_of_float (1./.float nbcol)^"\\textwidth}" in
        let rec aux n v = if n = 0 then [] else v::aux (n-1) v in
        let format = String.concat "" (aux nbcol sizecol) in
        let make_multicol header nb l =
          if not header && nb = 1
          then Nodelist l
(*          else Node3 ("\\multicolumn{"^string_of_int nb^"}{p{"^
                         string_of_float (float nb/.float nbcol)^
                         "\\textwidth}}{",
                      l, "}") *)
          else Node3 ("\\multicolumn{"^string_of_int nb^
                         "}{l}{\\begin{minipage}{"^
                         string_of_float (float nb/.float nbcol)^
                         "\\textwidth}"^
                         (if header then "\\centering " else ""),
                      l,
                        "\\end{minipage}}")
        in
        let l = List.map (fun (il, _) ->
          (match il with
            | [] -> Lwt.return []
            | (header, attrs, a)::ll ->
              Lwt_list.map_s (fun x -> x) a >>= fun a ->
              let a = make_multicol header (get_colspan attrs) a in
              Lwt_list.map_s (fun (header, attrs, i) ->
                Lwt_list.map_s (fun x -> x) i >>= fun i ->
                let i = make_multicol header (get_colspan attrs) i in
                Lwt.return (Node (Leaf_unquoted "&", i))) ll
              >>= fun r ->
              Lwt.return (a::r)) >>= fun r ->
          Lwt.return (Node (Nodelist r, Leaf_unquoted "\\\\\n"))
        ) l
        in
        Lwt_list.map_s (fun x -> x) l >>= fun l ->
        Lwt.return (
          Node3 ("\n\\noindent\n\\begin{tabular}{"^format^"}\n",
                 l,
                 "\\end{tabular}\n"))

  let inline i = i
  let error s = Lwt.return (Node3 ("{\\bfseries Error {\\em ", [Leaf s], "}}"))

  type syntax_extension =
      (flow,
       (href * attribs * flow_without_interactive),
       phrasing_without_interactive,
       (href * attribs * phrasing_without_interactive)) ext_kind

  let errmsg ?(err = Leaf "Unsupported plugin") name =
    Lwt.return
      (Nodelist [Leaf_unquoted "{\\bfseries ** Plugin error {\\em ";
                 Leaf name;
                 Leaf_unquoted  "} (";
                 err;
                 Leaf_unquoted ")}"])

  let plugin_fun : (string -> bool * (param, syntax_extension) plugin) ref =
    ref (fun name -> (true, (fun () args  content -> `Flow5 (errmsg name))))

  let plugin name = !plugin_fun name
  let plugin_action _ _ _ _ _ _ = ()
  let link_action _ _ _ _ _ = ()

end

let builder =
  (module LatexBuilder : Wikicreole.Builder with type param = unit and type flow = rope Lwt.t)

let tex_of_wiki s =
  Lwt_list.map_s (fun x -> x) (Wikicreole.from_string ~sectioning:false () builder s)

let inlinetex_of_wiki s =
  incr is_inline;
  tex_of_wiki s  >>= fun r ->
  decr is_inline;
  Lwt.return r
