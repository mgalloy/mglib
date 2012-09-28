IDL=idl
REVISION=r`svn info | sed -n 's/Revision: \(.*\)/\1/p'`

.PHONY: all clean dist unit doc userdoc webdoc

all:
	cd src; make IDL=$(IDL)

clean:
	rm -rf logs
	rm -rf api-docs
	rm -rf api-userdocs
	cd src; make clean
	rm -rf idllib-$(REVISION)
	if [ -e idllib*.tar.gz ]; then rm idllib*.tar.gz; fi
	if [ -e idllib*.zip ]; then rm idllib*.zip; fi

dist:
	if [ -e idllib-$(REVISION) ]; then rm -rf idllib-$(REVISION); fi
	mkdir idllib-$(REVISION)
	
	svn export src/ idllib-$(REVISION)/src/
	svn export unittests/ idllib-$(REVISION)/unittests/

	cp COPYING idllib-$(REVISION)
	cp Makefile idllib-$(REVISION)

	make doc
	cp -r api-docs/ idllib-$(REVISION)/api-docs/
	make userdoc
	cp -r api-userdocs/ idllib-$(REVISION)/api-userdocs/
	
	#tar zcf idllib-$(REVISION).tar.gz idllib-$(REVISION)
	zip -r idllib-$(REVISION).zip idllib-$(REVISION)/*
	rm -rf idllib-$(REVISION)

unit:
	$(IDL) -e "mgunit, 'mglib_uts', /html, filename='logs/tests_`date +%Y-%m-%d_%H%M`.html'"

doc:
	$(IDL) -e mg_doc_library

userdoc:
	$(IDL) -e mg_userdoc_library

webdoc:
	$(IDL) -e mg_userdoc_library
	scp -r api-userdocs/* idldev.com:~/docs.idldev.com/idllib
