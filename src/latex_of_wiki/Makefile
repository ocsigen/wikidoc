
-include ../../Makefile.local
include ../../Makefile.config

OCAMLFIND     ?= ocamlfind
OCAMLDUCEFIND ?= ocamlducefind

OCAMLDOC     ?= ${OCAMLFIND} ocamldoc
OCAMLDUCEDOC ?= ${OCAMLDUCEFIND} ocamldoc

OCAMLC       ?= ${OCAMLFIND} ocamlc
OCAMLDUCEC   ?= ${OCAMLDUCEFIND} ocamlc
OCAMLOPT     ?= ${OCAMLFIND} ocamlopt
OCAMLDUCEOPT ?= ${OCAMLDUCEFIND} ocamlopt
OCAMLDEP     ?= ${OCAMLFIND} ocamldep
OCAMLDUCEDEP ?= ${OCAMLDUCEFIND} ocamldep
OCAMLLEX     ?= ocamllex

##

OBJS := util.cmo \
        ocsigen_messages.cmo wikicreole.cmo \
	wiki_latex.cmo wiki_menulatex.cmo \
	doclink.cmo latex_of_wiki.cmo
LIBS := -package str,lwt.preemptive,netstring

PREDEP := wikicreole.ml

latex_of_wiki: ${OBJS}
	${OCAMLC} -linkpkg -thread ${LIBS} -o $@ $^

# Common rules

%.cmi: %.mli
	${OCAMLC} -thread ${LIBS} -c $<
%.cmo: %.ml
	${OCAMLC} -thread ${LIBS} -c $<
%.cmx: %.ml
	${OCAMLOPT} -thread ${LIBS} -c $<

%.ml: %.mll
	${OCAMLLEX} $<

## Clean up

clean:
	-rm -f *.cm[ioax] *.cmxa *.cmxs *.o *.a *.annot
	-rm -f ${PREDEP}

distclean: clean
	-rm -f *~ \#* .\#*

## Dependencies

depend: ${PREDEP}
	${OCAMLDEP} ${LIBS} *.mli *.ml > .depend

FORCE:
-include .depend
