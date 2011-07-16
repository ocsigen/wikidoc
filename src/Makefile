
CAMLC = ocamlfind ocamlc
CAMLDUCEC = ocamlducefind ocamlc
CAMLOPT = ocamlfind ocamlopt
CAMLDUCEOPT = ocamlducefind ocamlopt
CAMLDEP = ocamlfind ocamldep
CAMLDUCEDEP = ocamlducefind ocamldep

OCAMLDOCPATH := $(shell ocamlfind printconf stdlib)/ocamldoc
COMPILERLIBSPARSING :=  $(shell ocamlfind printconf stdlib)/compiler-libs/parsing

OCAMLDUCEDOCPATH := $(shell ocamlducefind printconf stdlib)/ocamlduce/ocamldoc
COMPILERDUCELIBSPARSING :=  $(shell ocamlfind printconf stdlib)/ocamlduce/compiler-libs/parsing

.PHONY: customdoc
all: odoc_wiki.cmo odoc_duce_wiki.cmo odoc_wiki.cmxs odoc_duce_wiki.cmxs

odoc_wiki.cmo: odoc_wiki.ml
	${CAMLC} -c -I ${OCAMLDOCPATH} -I $(COMPILERLIBSPARSING) $<
odoc_wiki.cmx: odoc_wiki.ml
	${CAMLOPT} -c -I ${OCAMLDOCPATH} -I $(COMPILERLIBSPARSING) $<

odoc_duce_wiki.cmo: odoc_wiki.ml
	${CAMLDUCEC} -c -I ${OCAMLDUCEDOCPATH} -I $(COMPILERLIBSPARSING) $< -o $@
odoc_duce_wiki.cmx: odoc_wiki.ml
	${CAMLDUCEOPT} -c -I ${OCAMLDUCEDOCPATH} -I $(COMPILERLIBSPARSING) $< -o $@

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
.cmx.cmxs:
	$(CAMLOPT) -thread -shared -o $*.cmxs $<

###

clean:
	-rm -f *.cm[ioxa] *.o *.a *.cmx[sa]

