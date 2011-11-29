open Util
open Wiki_latex

let default_project : string option ref = ref None

let get_attrib name = fun args ->
  try Some (List.assoc name args) with Not_found -> None

let get_language = get_attrib "language"
let get_class = get_attrib "class"
(* let get_file = get_attrib "file" *)
(* let get_fragment = get_attrib "fragment" *)

let get_project args =
  try Some (List.assoc "project" args)
  with Not_found -> !default_project
let get_sub args =
  try String.split '/' (List.assoc "subproject" args)
  with Not_found -> []
let get_text ~default args =
  try List.assoc "text" args
  with Not_found -> default
let get_chapter args =
  try List.assoc "chapter" args
  with Not_found -> raise (Doclink.Error "Missing chapter argument")


let _ =
  let plugin_fun = !LatexBuilder.plugin_fun in
  LatexBuilder.plugin_fun :=
    (fun name -> match name with
      | "webonly" ->
	(true, fun () args content -> `Flow5 (Lwt.return (Leaf "")))
      | "pdfonly" ->
	(true, fun () args -> function
	  | None -> `Phrasing_without_interactive (Lwt.return (Leaf ""))
	  | Some content ->
	    `Flow5
	      (tex_of_wiki content >>= fun r ->
	       (Lwt.return (Nodelist r))))
      | "code" ->
        (false,
         fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
             (match content, get_language args with
               | None, _ -> Lwt.return (Leaf "")
               | Some content, Some "ocaml" ->
                 Lwt.return (Node3 ("\n\\lstset{language=[Objective]Caml}\\begin{lstlisting}\n",
                                    [Leaf_unquoted content],
                                    "\n\\end{lstlisting}\n\\medskip\n\n\\noindent"))
               | Some content, Some l ->
                 Lwt.return (Node3 ("\n\\lstset{language="^l^"}\\begin{lstlisting}",
                                    [Leaf_unquoted content],
                                    "\\end{lstlisting}\n\\medskip\n\n\\noindent"))
               | Some content, None ->
		 LatexBuilder.errmsg ~err:(Leaf "missing language argument") name))
      | "code-inline" ->
        (false,
         fun () args content ->
           let content = map_option String.remove_spaces content in
           `Phrasing_without_interactive
             (match content, get_language args with
               | None, _ -> Lwt.return (Leaf "")
               | Some content, Some "ocaml" ->
                 Lwt.return (Node3 ("\\lstinline£", [Leaf content], "£"))
               | Some content, Some l ->
		   LatexBuilder.errmsg ~err:(Leaf "unssupported language")  name
               | Some content, None ->
                 (Lwt.return (Node3 ("{\\tt ", [Leaf content], "}")))))
      | "paragraph" ->
        (true,
         fun () args content ->
           let content = map_option String.remove_spaces content in
           `Phrasing_without_interactive
             (match content with
               | None -> Lwt.return (Leaf "")
               | Some content ->
                  inlinetex_of_wiki content >>= fun r ->
                  Lwt.return (Node3 ("\\paragraph{",
                                     r,
                                     "}"))))
      | "span" ->
        (true,
         fun () args content ->
           let content = map_option String.remove_spaces content in
           `Phrasing_without_interactive
             (match content, get_class args with
               | None, _ -> Lwt.return (Leaf "")
               | Some content, Some "code" ->
                 (inlinetex_of_wiki content >>= fun r ->
                  Lwt.return (Node3 ("{\\tt ", [Nodelist r], "}")))
               | Some content, Some "new" ->
                 (inlinetex_of_wiki content >>= fun r ->
                  Lwt.return (Node3 ("{\\tiny\\bfseries ",
                                     [Nodelist r], "}")))
               | Some content, _ ->
                 (inlinetex_of_wiki content >>= fun r ->
                  Lwt.return (Nodelist r))))
      | "outline" -> (* Ignore outline TODO ?? *)
	  (true, fun () _ _ -> `Flow5 (Lwt.return (Leaf "")))
      | "" -> (true, fun () _ _ -> `Flow5 (Lwt.return (Leaf "")))
      | "header" | "nav" | "footer" | "div" ->
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
	     (match content with
	       | Some content ->
		 (tex_of_wiki content >>= fun r ->
		  Lwt.return (Nodelist r))
               | None -> Lwt.return (Leaf ""))))
      | "pre" ->
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
	     (match content with
	       | Some content ->
		 (tex_of_wiki content >>= fun r ->
		  Lwt.return (Node3 ("\n\n\\begin{alltt}",
                                     r,
                                     "\\end{alltt}\n\n")))
               | None -> Lwt.return (Leaf ""))))
      | "concepts" ->
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
	     (match content with
	       | Some content ->
		 (tex_of_wiki content >>= fun r ->
		  Lwt.return (Node3 ("\n\n\\begin{concepts}",
                                     r,
                                     "\\end{concepts}\n\n")))
               | None -> Lwt.return (Leaf ""))))
      | "concept" -> (* FIXME title *)
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
	     (match content with
	       | Some content ->
		 (tex_of_wiki content >>= fun r ->
                  Lwt.return (Node3 ("\n\n\\begin{encadre}",
                                     r,
                                     "\\end{encadre}\n\n")))
               | None -> Lwt.return (Leaf ""))))
      | "wip" ->
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
	     (match content with
	       | Some content ->
		 (tex_of_wiki content >>= fun r ->
		  Lwt.return (Node3 ("\n\n\\begin{wip}",
                                     r,
                                     "\\end{wip}\n\n")))
               | None -> Lwt.return (Leaf ""))))
      | "wip-inline" ->
        (true,
         fun () args content ->
           let content = map_option String.remove_spaces content in
           `Phrasing_without_interactive
             (match content with
               | None -> Lwt.return (Leaf "")
               | Some content ->
                  inlinetex_of_wiki content >>= fun r ->
                  Lwt.return (Node3 ("\\wipinline{",
                                     r,
                                     "}"))))
      | "menu" ->
        (true,
         (fun () args content ->
           let content = map_option String.remove_spaces content in
           `Flow5
             (match content with
               | None -> Lwt.return (Leaf "")
               | Some content ->
                 (Wiki_menulatex.menu_of_wiki content >>= fun r ->
                  Lwt.return (Nodelist r)))))

      | "a_api" -> (* TODO link *)

	(false,
	 (fun () args contents ->

           let contents = map_option String.remove_spaces contents in
	   `Phrasing_without_interactive
	     (try
		(* Get arguments *)
		(* let project = get_project args in *)
		(* let sub = get_subproject args in *)

		(* TODO add hyperlink: API-project-ID *)

		let id = Doclink.parse_api_contents args contents in
		let body = get_text ~default:(Doclink.string_of_id ~spacer:".​" id) args in
		Lwt.return (Node3 ("{\\tt ", [Leaf body], "}"))
	      with Doclink.Error s ->
		LatexBuilder.errmsg ~err:(Leaf s) name)))

      | "a_manual" ->

	(true,

	 (fun () args contents ->

           let contents = map_option String.remove_spaces contents in
	   `Phrasing_without_interactive
	     (try
	     (* Get arguments *)
	     (* let project = get_project args in *)
	     (* let chapter = get_chapter args in *)
	     (* let fragment = get_fragment args in *)

	     (* TODO add \label on h1... when when attribute id is present (in wiki_latex.ml ?) *)
	     (* TODO add hyperlink: project-chapter-fragment *)

	     (* Parse contents *)
		(match contents with
		    | Some contents -> Wiki_latex.inlinetex_of_wiki contents
		    | None -> raise (Doclink.Error "Empty contents")) >>= fun contents ->
		Lwt.return (Nodelist contents)

	      with Doclink.Error s ->
		LatexBuilder.errmsg ~err:(Leaf "s") name)))

      | "a_img" (* TODO include graphics... *)
      | "a_file" (* TODO hyperlink and footnote with the URL. *)
	->
	(false, (fun () args content ->
          `Phrasing_without_interactive
	    (Lwt.return (Node3 ("\\textbf{** TODO ", [Leaf name], " **}")))))

      (* | "ocsigendoc" -> *)
        (* (true, *)
         (* (fun () args content -> *)
           (* let content = map_option String.remove_spaces content in *)
           (* `Phrasing_without_interactive *)
             (* (match content, get_file args with *)
               (* | None, Some f -> *)
                 (* (Lwt.return *)
                    (* (Node3("\\hyperref["^escape_ref f^"]{", [Leaf "-"], "}"))) *)
               (* | Some content, Some f -> *)
                 (* (inlinetex_of_wiki content >>= fun r -> *)
                  (* Lwt.return (Node3("\\hyperref["^escape_ref f^"]{", r, "}"))) *)
               (* | _ ->  LatexBuilder.errmsg ~err:(Leaf "Missing file attribute") name))) *)

      | name -> plugin_fun name
    )

let _ =
  Lwt_unix.run
    (Wikicreole.from_channel ~sectioning:true () Wiki_latex.builder Lwt_io.stdin >>= fun l ->
     Lwt_list.iter_s
       (fun t -> t >>= fun t -> print_rope t; Lwt.return ()) l)

let _ = close_out Wiki_menulatex.offset_file
