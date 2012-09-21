IDL=idl

.PHONY: all clean

idlgsl.*.so: mg_make_gsl_bindings.pro idlgsl_*bindings.h
	$(IDL) -e mg_make_gsl_bindings

clean:
	rm -rf idlgsl.*
