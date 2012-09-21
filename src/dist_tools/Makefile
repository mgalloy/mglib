IDL=idl

.PHONY: clean

dist_tools.*.so: dist_tools.c dist_tools.dlm
	$(IDL) -e mg_build_dist_tools

clean:
	rm -rf dist_tools*.so
	cd bindings; make clean

