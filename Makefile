
SRCROOT     := /opt/ocsigen/src

CAMLDOC     ?= ocamlfind ocamldoc
CAMLDUCEDOC ?= ocamlducefind ocamldoc

all: lwt js_of_ocaml tyxml server eliom oclosure

install: lwt.install js_of_ocaml.install tyxml.install \
	 server.install eliom.install oclosure.install

customdoc:
	${MAKE} -C src

####### WIKIDOC LWT #######

LWT_DIR ?= ${SRCROOT}/lwt

LWT_DOC := $(wildcard ${LWT_DIR}/_build/syntax/*.mli) \
	   $(wildcard ${LWT_DIR}/_build/src/*/*.mli)

LWTDOCINCLUDESDIR=${wildcard ${LWT_DIR}/_build/src/*} ${LWT_DIR}/_build/syntax
LWTDOCINCLUDES= ${addprefix -I ,$(LWTDOCINCLUDESDIR)} \
	-package react,ssl,text

.PHONY: lwt
lwt: customdoc
	rm -rf docwiki_$@
	mkdir -p docwiki_$@
	$(CAMLDOC) -g src/odoc_wiki.cmo -d docwiki_$@ \
	  -intro ${LWT_DIR}/apiref-intro -colorize-code \
	  ${LWTDOCINCLUDES} $(LWT_DOC)

LWT_VERSION ?= dev
lwt.install:
	${call docwiki_install,docwiki_lwt,lwt,${LWT_VERSION}}

######## WIKIDOC JS_OF_OCAML ########

JS_OF_OCAML_DIR ?= ${SRCROOT}/js_of_ocaml

DERIVING := "YES"
-include ${JS_OF_OCAML_DIR}/Makefile.filelist

JS_OF_OCAML_DOC := ${addprefix ${JS_OF_OCAML_DIR}/,${DOC}}

.PHONY:js_of_ocaml
js_of_ocaml: customdoc
	rm -rf docwiki_$@
	mkdir -p docwiki_$@
	$(CAMLDOC) -stars  -g src/odoc_wiki.cmo -d docwiki_$@ \
	-intro ${JS_OF_OCAML_DIR}/doc/api-index \
	-I ${JS_OF_OCAML_DIR}/lib -I ${JS_OF_OCAML_DIR}/lib/deriving_json \
	-package lwt ${JS_OF_OCAML_DOC}

JS_OF_OCAML_VERSION ?= dev
js_of_ocaml.install:
	${call docwiki_install,docwiki_js_of_ocaml,js_of_ocaml,${JS_OF_OCAML_VERSION}}

######## WIKIDOC TYXML ########

TYXML_DIR ?= ${SRCROOT}/tyxml

OCAMLDUCE := YES
-include ${TYXML_DIR}/Makefile.filelist

TYXML_DOC := ${addprefix ${TYXML_DIR}/,${DOC}}

.PHONY: tyxml
tyxml: customdoc
	rm -rf docwiki_$@
	mkdir -p docwiki_$@
	$(CAMLDUCEDOC) -stars -g src/odoc_duce_wiki.cmo -d docwiki_$@ \
	  -intro ${TYXML_DIR}/doc/indexdoc -colorize-code \
	  -package ocamlduce -I ${TYXML_DIR}/lib ${TYXML_DOC}

TYXML_VERSION ?= dev
tyxml.install:
	${call docwiki_install,docwiki_tyxml,tyxml,${TYXML_VERSION}}

####### WIKIDOC OCSIGENSERVER #######

SERVER_DIR ?= ${SRCROOT}/ocsigenserver

-include ${SERVER_DIR}/src/Makefile.filelist

SERVER_DOC := ${addprefix ${SERVER_DIR}/src/,${DOC} ${PLUGINS_DOC}}

.PHONY: server
server: customdoc
	rm -rf docwiki_$@
	mkdir -p docwiki_$@
	OCAMLPATH=${SERVER_DIR}/src/files:${OCAMLPATH} \
	  $(CAMLDOC) -g src/odoc_wiki.cmo \
	  -d docwiki_server -intro ${SERVER_DIR}/doc/indexdoc \
	  -package ocsigenserver $(SERVER_DOC)

SERVER_VERSION ?= dev
server.install:
	${call docwiki_install,docwiki_server,ocsigenserver,${SERVER_VERSION}}

####### WIKIDOC ELIOM #######

ELIOM_DIR ?= ${SRCROOT}/eliom

OCAMLDUCE := YES
-include ${ELIOM_DIR}/src/server/Makefile.filelist

TMP := $(shell mktemp -d)

ELIOM_SERVER_DOC :=  ${addprefix ${TMP}/server/,${DOC}}

SERVER_NOP4_INTF := ${NOP4}

$(filter-out $(addprefix ${TMP}/server/,${SERVER_NOP4_INTF}), ${ELIOM_SERVER_DOC}): \
${TMP}/server/%.mli: ${ELIOM_DIR}/src/server/%.mli
	camlp4o ${ELIOM_DIR}/src/syntax/pa_include.cmo -printer o $< > $@

$(addprefix ${TMP}/server/,${SERVER_NOP4_INTF}): \
${TMP}/server/%.mli: ${ELIOM_DIR}/src/server/%.mli
	cp $< $@

${TMP}/server:
	mkdir -p $@
	mkdir -p $@/extensions

-include ${ELIOM_DIR}/src/client/Makefile.filelist

ELIOM_CLIENT_DOC := ${addprefix ${TMP}/client/,${DOC}}

CLIENT_NOP4_INTF := ${NOP4}

$(filter-out $(addprefix ${TMP}/client/,${CLIENT_NOP4_INTF}), ${ELIOM_CLIENT_DOC}): \
${TMP}/client/%.mli: ${ELIOM_DIR}/src/client/%.mli
	camlp4o ${ELIOM_DIR}/src/syntax/pa_include.cmo -printer o $< > $@

$(addprefix ${TMP}/client/,${CLIENT_NOP4_INTF}): \
${TMP}/client/%.mli: ${ELIOM_DIR}/src/client/%.mli
	cp $< $@

${TMP}/client:
	mkdir -p $@

## Need to call ocamlfind by hand: because "ocamlfind ocamldoc" does
## not accept custom option, i.e. -subproject from odoc_wiki.
ELIOM_SERVER_INC := \
	$(shell OCAMLPATH=${ELIOM_DIR}/src/files:${OCAMLPATH} \
	    ocamlfind query -i-format -r eliom.server)
ELIOM_CLIENT_INC := \
	$(shell OCAMLPATH=${ELIOM_DIR}/src/files:${OCAMLPATH} \
	    ocamlfind query -i-format -r eliom.client)

.PHONY:eliom
eliom: customdoc \
	       ${TMP}/server ${ELIOM_SERVER_DOC} \
	       ${TMP}/client ${ELIOM_CLIENT_DOC}
	rm -rf docwiki_$@/server docwiki_$@/client
	mkdir -p docwiki_$@/server docwiki_$@/client
	 ## Server
	ocamlducedoc -g src/odoc_duce_wiki.cmo \
          -d docwiki_eliom/server -intro ${ELIOM_DIR}/doc/server/indexdoc \
          -colorize-code -subproject server \
          ${ELIOM_SERVER_INC} -I ${ELIOM_DIR}/src/server/extensions \
         $(ELIOM_SERVER_DOC)
	 ## Client
	ocamldoc -g src/odoc_wiki.cmo \
          -d docwiki_eliom/client -intro ${ELIOM_DIR}/doc/client/indexdoc \
          -colorize-code -subproject client \
	  ${ELIOM_CLIENT_INC} $(ELIOM_CLIENT_DOC)
	rm -r ${TMP}

ELIOM_VERSION ?= dev
eliom.install:
	${call docwiki_install,docwiki_eliom,eliom,${ELIOM_VERSION}}
	# cat ${ELIOM_DIR}/doc/index.wiki | \
	#    ssh ocsigen.org "sudo sh -c 'cat > /var/www/apiwiki/eliom/${ELIOM_VERSION}/index.wiki'"

######## WIKIDOC OCSIGEN 1.3 ########

# OCSIGEN13_DIR=${SRCROOT}/ocsigen-1.3/
# -include Makefile.oldfilelist

# DOC13INCLUDES = ${addprefix -I ${OCSIGEN13_DIR}/,${DOC13INCLUDESDIR}} \
# 	-package ocsigen,ocamlduce,lwt

# .PHONY:ocserveliom13
# ocserveliom13: customdoc
# 	rm -rf docwiki_$@
# 	mkdir -p docwiki_$@
# 	OCAMLPATH=${OCSIGEN13_DIR}/files:${OCAMLPATH} \
# 	  $(CAMLDUCEDOC) -g src/odoc_duce_wiki.cmo \
# 	    -d docwiki_$@ -intro ${OCSIGEN13_DIR}/files/indexdoc -colorize-code \
# 	    ${DOC13INCLUDES} ${addprefix ${OCSIGEN13_DIR}/,$(DOC13)}

# OCSIGEN13_VERSION ?= 1.3
# docwiki_ocserveliom13.install:
# 	${call docwiki_install,docwiki_ocserveliom13,oscigenserver,${OCSIGEN13_VERSION}}

######## WIKIDOC OCSIGEN 1.2 ########

# OCSIGEN12_DIR=${SRCROOT}/ocsigen-1.2/
# -include Makefile.oldfilelist

# DOC12INCLUDES = ${addprefix -I ${OCSIGEN12_DIR}/,${DOC12INCLUDESDIR}} \
# 	-package ocsigen,ocamlduce,lwt

# .PHONY:ocserveliom12
# ocserveliom12: customdoc
# 	rm -rf docwiki_$@
# 	mkdir -p docwiki_$@
# 	OCAMLPATH=${OCSIGEN12_DIR}:${OCAMLPATH} \
# 	  $(CAMLDUCEDOC) -g src/odoc_duce_wiki.cmo \
# 	    -d docwiki_$@ -intro ${OCSIGEN12_DIR}/files/indexdoc -colorize-code \
# 	    ${DOC12INCLUDES} ${addprefix ${OCSIGEN12_DIR}/,$(DOC10)}

# OCSIGEN12_VERSION ?= 1.2
# ocserveliom12.install:
# 	${call docwiki_install,docwiki_ocserveliom12,ocsigenserver,${OCSIGEN12_VERSION}}

######## WIKIDOC OCLOSURE ########

OCLOSURE_DIR ?= ${SRCROOT}/oclosure

OCLOSURE_INCLUDESDIR := async date disposable events fx gdom \
	geditor geditor/plugins ggraphics i18n math positioning \
	spell structs timer ui ui/editor ui/tree userAgent
OCLOSURE_INCLUDES := \
	${addprefix -I ${OCLOSURE_DIR}/,${OCLOSURE_INCLUDESDIR}} \
	-package js_of_ocaml

OCLOSURE_DOC := ${OCLOSURE_DIR}/goog/goog.mli

.PHONY: docdiv_oclosure
oclosure: customdoc
	rm -rf docwiki_$@
	mkdir -p docwiki_$@
	$(CAMLDOC) -stars  -g src/odoc_wiki.cmo -d docwiki_$@ \
	-intro ${OCLOSURE_DIR}/doc/apiref-overview -colorize-code \
	-pp "cpp -traditional-cpp" \
	${OCLOSURE_INCLUDES} ${OCLOSURE_DOC}

OCLOSURE_VERSION ?= dev
oclosure.install:
	${call docwiki_install,docwiki_oclosure,oclosure,${OCLOSURE_VERSION}}

###

clean:
	${MAKE} -C src clean
	-rm -rf docwiki_*
	-find -name \*~ -delete


docwiki_install= \
	@echo TODO

        # ssh ocsigen.org -t "sudo rm -fr /var/www/apiwiki/$(2)/$(3)/"; \
        # ssh ocsigen.org -t "sudo mkdir -p /var/www/apiwiki/$(2)/$(3)/"; \
        # ssh ocsigen.org -t "sudo chown www-data:www-data /var/www/apiwiki/$(2)/$(3)/"; \
        # ssh ocsigen.org -t "sudo chmod 775 /var/www/apiwiki/$(2)/$(3)"; \
        # cd $(1) && tar cz . | \
        #     ssh ocsigen.org "sudo sh -c 'cd /var/www/apiwiki/$(2)/$(3)/; tar xz'"; \
        # ssh ocsigen.org -t \
        #     "sudo find /var/www/apiwiki/$(2)/$(3)/ -name \*.wiki -exec chown www-data:www-data {} \;"


