
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

OCAMLDOCPATH ?= $(shell ${OCAMLFIND} printconf stdlib)/ocamldoc
COMPILERLIBSPARSING ?= \
	-I $(shell ${OCAMLFIND} printconf stdlib)/compiler-libs/parsing \
	-I $(shell ${OCAMLFIND} printconf stdlib)/compiler-libs/typing

OCAMLDUCEDOCPATH ?= $(shell ${OCAMLDUCEFIND} printconf stdlib)/ocamlduce/ocamldoc
COMPILERDUCELIBSPARSING ?= \
	-I $(shell ${OCAMLFIND} printconf stdlib)/ocamlduce/compiler-libs/parsing \
	-I $(shell ${OCAMLFIND} printconf stdlib)/ocamlduce/compiler-libs/typing

##

all:: byte opt

byte:: odoc_wiki.cma
opt:: odoc_wiki.cmxs

OCAMLDUCE ?= NO

ifeq "${OCAMLDUCE}" "YES"
byte:: odoc_duce_wiki.cma
opt:: odoc_duce_wiki.cmxs
endif

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

odoc_duce_import.cmo: odoc_duce_import.ml
	${OCAMLDUCEC} -c -I ${OCAMLDUCEDOCPATH} ${COMPILERDUCELIBSPARSING} $< -o $@
odoc_duce_import.cmx: odoc_duce_import.ml
	${OCAMLDUCEOPT} -c -I ${OCAMLDUCEDOCPATH} ${COMPILERDUCELIBSPARSING} $< -o $@

odoc_duce_wiki.cmo: odoc_duce_wiki.ml
	${OCAMLDUCEC} -c -I ${OCAMLDUCEDOCPATH} ${COMPILERDUCELIBSPARSING} $< -o $@
odoc_duce_wiki.cmx: odoc_duce_wiki.ml
	${OCAMLDUCEOPT} -c -I ${OCAMLDUCEDOCPATH} ${COMPILERDUCELIBSPARSING} $< -o $@

odoc_duce_wiki.cma: odoc_duce_import.cmo odoc_duce_wiki.cmo
	${OCAMLC} -a -o $@ $^
odoc_duce_wiki.cmxa: odoc_duce_import.cmx odoc_duce_wiki.cmx
	${OCAMLOPT} -a -o $@ $^

odoc_duce_import.ml: odoc_import.ml
	sed s/Odoc_import/Odoc_duce_import/g odoc_import.ml > odoc_duce_import.ml
odoc_duce_wiki.ml: odoc_wiki.ml
	sed s/Odoc_import/Odoc_duce_import/g odoc_wiki.ml > odoc_duce_wiki.ml

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
	-rm -f odoc_duce_wiki.ml odoc_duce_import.ml

