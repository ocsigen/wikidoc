
let map_option f o = match o with
  | None -> None
  | Some v -> Some (f v)

module String = struct

  include String

(* Returns a copy of the string from beg to endd,
   removing spaces at the beginning and at the end *)
  let remove_spaces s beg endd =
    let rec find_not_space s i step =
      if (i > endd) || (beg > i)
      then i
      else
	if s.[i] = ' '
	then find_not_space s (i+step) step
	else i
    in
    let first = find_not_space s beg 1 in
    let last = find_not_space s endd (-1) in
    if last >= first
    then String.sub s first (1+ last - first)
    else ""

  let rec split ?(multisep=false) char s =
    let longueur = String.length s in
    let rec aux deb =
      if deb >= longueur
      then []
      else
	try
          let firstsep = String.index_from s deb char in
          if multisep && firstsep = deb then
            aux (deb + 1)
          else
            (remove_spaces s deb (firstsep-1))::
              (aux (firstsep+1))
	with Not_found -> [remove_spaces s deb (longueur-1)]
    in
    aux 0

  let remove_re = Netstring_pcre.regexp "(?s-m)\\A\\s*(\\S(.*\\S)?)\\s*\\z"
  let remove_spaces s =
    match Netstring_pcre.string_match remove_re s 0 with
      | None -> s
      | Some r -> Netstring_pcre.matched_group r 1 s

end


