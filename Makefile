-include Makefile.local
include Makefile.config

include Makefile.odoc
include Makefile.book

###

clean::
	-find -name \*~ -delete

distclean:: clean
	-rm -rf wiki tex
