sinclude ../../Makeconf


# Set this extension to the same as the language extension in src/help.cc
EXT=pt_BR

pre-pkg/%::
	@cp ../base/src/{help.icc,md5.h,md5.c} src/
	if [ ! -e inst/ ]; then \
	  mkdir inst/; \
	fi; \
	find help -name "*.$(EXT)" -exec cp {} inst/ \; 

post-pkg/%::
	@rm -f inst/*.$(EXT) src/{help.icc,md5.h.md5.c}; \
	if [ -z $$(ls -1A inst/) ]; then \
	  rmdir inst/; \
	fi

clean:
	@rm -f inst/*.$(EXT) src/{help.icc,md5.h.md5.c}; \
	if [ -z $$(ls -1A inst/) ]; then \
	  rmdir inst/; \
	fi
