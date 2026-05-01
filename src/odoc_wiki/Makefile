
-include ../../Makefile.local
include ../../Makefile.config

OCAMLFIND     ?= ocamlfind

OCAMLDOC     ?= ${OCAMLFIND} ocamldoc

OCAMLC       ?= ${OCAMLFIND} ocamlc -package str
OCAMLOPT     ?= ${OCAMLFIND} ocamlopt -package str
OCAMLDEP     ?= ${OCAMLFIND} ocamldep
OCAMLLEX     ?= ocamllex

OCAMLDOCPATH ?= $(shell ${OCAMLFIND} printconf stdlib)/ocamldoc
COMPILERLIBSPARSING ?= \
	-I $(shell ${OCAMLFIND} printconf stdlib)/compiler-libs/ \
	-I $(shell ${OCAMLFIND} printconf stdlib)/compiler-libs/parsing \
	-I $(shell ${OCAMLFIND} printconf stdlib)/compiler-libs/typing

##

all:: byte opt

byte:: odoc_wiki.cma
opt:: odoc_wiki.cmxs

odoc_import.cmo: odoc_import.ml
	${OCAMLC} -c -I ${OCAMLDOCPATH} ${COMPILERLIBSPARSING} $<
odoc_import.cmx: odoc_import.ml
	${OCAMLOPT} -c -I ${OCAMLDOCPATH} ${COMPILERLIBSPARSING} $<

odoc_wiki.cmo: odoc_wiki.ml
	${OCAMLC} -c -I ${OCAMLDOCPATH} ${COMPILERLIBSPARSING} $<
odoc_wiki.cmx: odoc_wiki.ml
	${OCAMLOPT} -c -I ${OCAMLDOCPATH} ${COMPILERLIBSPARSING} $<

odoc_wiki.cma: odoc_import.cmo odoc_wiki.cmo
	${OCAMLC} -a -o $@ $^
odoc_wiki.cmxa: odoc_import.cmx odoc_wiki.cmx
	${OCAMLOPT} -a -o $@ $^

###

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx .cmxa .cmxs

%.ml: %.mll
	ocamllex $<

.mli.cmi:
	${OCAMLC} -thread -c $<
.ml.cmo:
	${OCAMLC} -thread -c $<
.ml.cmx:
	${OCAMLOPT} -thread -c $<

.cmxa.cmxs:
	${OCAMLOPT} -thread -linkall -shared -o $*.cmxs $<

###

clean:
	-rm -f *.cm[ioxa] *.o *.a *.cmx[sa]
