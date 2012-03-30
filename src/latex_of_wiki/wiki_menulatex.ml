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
   Pretty print wiki menus to LaTeX
   @author Vincent Balat
*)

open Wikicreole
open Wiki_latex

let (>>=) = Lwt.bind

let unsup = "unsupported syntax in menu"
let failed _ _ = failwith unsup
let failed1 _ = failwith unsup

let offset_file = open_out ".latex_of_wiki_offsets"

let item i attribs il =
  Lwt_list.map_s (fun x -> x) il >>= function
    | Menu_link (addr, _)::_ ->
      output_string offset_file addr;
      output_string offset_file " ";
      output_string offset_file (string_of_int (i - 2));
      output_string offset_file "\n";
      flush offset_file;
      Lwt.return (Node3 ("\\input{", [Leaf addr], "}\n"))
    | il ->
      output_string offset_file "===";
      Lwt.return (Nodelist [sect i; Nodelist il; close_sect ()])

let plugin_fun = function
  | _ ->
    (true, fun () args content -> `Phrasing_without_interactive (Lwt.return (Leaf "")))
(* implement at least somthing for a_file? *)

module LatexMenuBuilder  = struct

  include Wiki_latex.LatexBuilder

  let p_elem = failed
  let pre_elem = failed
  let h1_elem = item 1
  let h2_elem = item 2
  let h3_elem = item 3
  let h4_elem = item 4
  let h5_elem = item 5
  let h6_elem = item 6
  let ol_elem = failed
  let dl_elem = failed
  let hr_elem = failed1
  let table_elem = failed
  let a_elem_phrasing attribs addr c =
    Lwt_list.map_s (fun x -> x) c >>= fun c ->
    Lwt.return
      (Menu_link (addr,
                  Node (Nodelist c, Leaf "}")))
  let a_elem_flow = a_elem_phrasing
  let ul_elem = failed
  let plugin_fun = plugin_fun

end

let builder =
  (module LatexMenuBuilder : Wikicreole.Builder with type param = unit and type flow = rope Lwt.t)

let menu_of_wiki s =
  Lwt_list.map_s (fun x -> x) (Wikicreole.from_string ~sectioning:false () builder s)
