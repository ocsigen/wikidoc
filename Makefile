-include Makefile.local
include Makefile.config

BINDIR    ?= /usr/local/bin
INSTALL   ?= install

OCAMLDUCE ?= NO

SRCROOT         ?= ../src

LWT_DIR         ?= ${SRCROOT}/lwt
JS_OF_OCAML_DIR ?= ${SRCROOT}/js_of_ocaml
SERVER_DIR      ?= ${SRCROOT}/ocsigenserver
ELIOM_DIR       ?= ${SRCROOT}/eliom
OCLOSURE_DIR    ?= ${SRCROOT}/oclosure
MACAQUE_DIR     ?= ${SRCROOT}/macaque
TUTORIAL_DIR    ?= ${SRCROOT}/tutorial
TYXML_DIR       ?= ${SRCROOT}/tyxml

OCAMLFIND     ?= ocamlfind

OCAMLC       ?= ${OCAMLFIND} ocamlc
OCAMLOPT     ?= ${OCAMLFIND} ocamlopt
OCAMLDEP     ?= ${OCAMLFIND} ocamldep
OCAMLDOC     ?= ${OCAMLFIND} ocamldoc
OCAMLLEX     ?= ocamllex

ifeq "${OCAMLDUCE}" "YES"
OCAMLDUCEFIND ?= ocamlducefind
OCAMLDUCEC    ?= ${OCAMLDUCEFIND} ocamlc
OCAMLDUCEOPT  ?= ${OCAMLDUCEFIND} ocamlopt
OCAMLDUCEDEP  ?= ${OCAMLDUCEFIND} ocamldep
OCAMLDUCEDOC  ?= ${OCAMLDUCEFIND} ocamldoc
else
OCAMLDUCEDOC  ?= ${OCAMLFIND} ocamldoc
endif

include Makefile.odoc
include Makefile.book

###

clean::
	-find -name \*~ -delete

distclean:: clean
	-rm -rf wiki tex


reinstall:: uninstall install