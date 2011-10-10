-include Makefile.local
include Makefile.config

SRCROOT         ?= ../src

LWT_DIR         ?= ${SRCROOT}/lwt
JS_OF_OCAML_DIR ?= ${SRCROOT}/js_of_ocaml
SERVER_DIR      ?= ${SRCROOT}/ocsigenserver
ELIOM_DIR       ?= ${SRCROOT}/eliom
OCLOSURE_DIR    ?= ${SRCROOT}/oclosure
MACAQUE_DIR     ?= ${SRCROOT}/macaque
TUTORIAL_DIR    ?= ${SRCROOT}/tutorial

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

include Makefile.odoc
include Makefile.book

###

clean::
	-find -name \*~ -delete

distclean:: clean
	-rm -rf wiki tex
