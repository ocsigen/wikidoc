
CAMLC = ocamlfind ocamlc
CAMLDUCEC = ocamlducefind ocamlc
CAMLOPT = ocamlfind ocamlopt
CAMLDUCEOPT = ocamlducefind ocamlopt
CAMLDEP = ocamlfind ocamldep
CAMLDUCEDEP = ocamlducefind ocamldep

OCAMLDOCPATH := $(shell ocamlfind printconf stdlib)/ocamldoc
COMPILERLIBSPARSING := \
	-I $(shell ocamlfind printconf stdlib)/compiler-libs/parsing \
	-I $(shell ocamlfind printconf stdlib)/compiler-libs/typing

OCAMLDUCEDOCPATH := $(shell ocamlducefind printconf stdlib)/ocamlduce/ocamldoc
COMPILERDUCELIBSPARSING := \
	-I $(shell ocamlfind printconf stdlib)/ocamlduce/compiler-libs/parsing \
	-I $(shell ocamlfind printconf stdlib)/ocamlduce/compiler-libs/typing

.PHONY: customdoc
all: customdoc customdocduce

customdoc: odoc_wiki.cma odoc_import.cmxs
customdocduce: odoc_duce_wiki.cma odoc_duce_wiki.cmxs

odoc_import.cmo: odoc_import.ml
	${CAMLC} -c -I ${OCAMLDOCPATH} $(COMPILERLIBSPARSING) $<
odoc_import.cmx: odoc_import.ml
	${CAMLOPT} -c -I ${OCAMLDOCPATH} $(COMPILERLIBSPARSING) $<

odoc_wiki.cmo: odoc_wiki.ml
	${CAMLC} -c -I ${OCAMLDOCPATH} $(COMPILERLIBSPARSING) $<
odoc_wiki.cmx: odoc_wiki.ml
	${CAMLOPT} -c -I ${OCAMLDOCPATH} $(COMPILERLIBSPARSING) $<

odoc_wiki.cma: odoc_import.cmo odoc_wiki.cmo
	${CAMLC} -a -o $@ $^
odoc_wiki.cmxa: odoc_import.cmx odoc_wiki.cmx
	${CAMLOPT} -a -o $@ $^

odoc_duce_import.cmo: odoc_duce_import.ml
	${CAMLDUCEC} -c -I ${OCAMLDUCEDOCPATH} $(COMPILERDUCELIBSPARSING) $< -o $@
odoc_duce_import.cmx: odoc_duce_import.ml
	${CAMLDUCEOPT} -c -I ${OCAMLDUCEDOCPATH} $(COMPILERDUCELIBSPARSING) $< -o $@

odoc_duce_wiki.cmo: odoc_duce_wiki.ml
	${CAMLDUCEC} -c -I ${OCAMLDUCEDOCPATH} $(COMPILERDUCELIBSPARSING) $< -o $@
odoc_duce_wiki.cmx: odoc_duce_wiki.ml
	${CAMLDUCEOPT} -c -I ${OCAMLDUCEDOCPATH} $(COMPILERDUCELIBSPARSING) $< -o $@

odoc_duce_wiki.cma: odoc_duce_import.cmo odoc_duce_wiki.cmo
	${CAMLC} -a -o $@ $^
odoc_duce_wiki.cmxa: odoc_duce_import.cmx odoc_duce_wiki.cmx
	${CAMLOPT} -a -o $@ $^

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
	$(CAMLC) -thread -c $<
.ml.cmo:
	$(CAMLC) -thread -c $<
.ml.cmx:
	$(CAMLOPT) -thread -c $<

.cmxa.cmxs:
	$(CAMLOPT) -thread -linkall -shared -o $*.cmxs $<

###

clean:
	-rm -f *.cm[ioxa] *.o *.a *.cmx[sa]
	-rm -f odoc_duce_wiki.ml odoc_duce_import.ml

