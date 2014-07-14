
opam pin add --no-action wikidoc .
opam install --deps-only wikidoc
opam install --verbose wikidoc

do_build_doc () {
  # Nothing...
  echo -n
}

do_remove () {
  opam remove --verbose wikidoc
}

