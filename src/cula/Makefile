IDL=idl

.PHONY: all clean

idlcula.*.so: mg_make_cula_bindings.pro idlcula_*bindings.h
	$(IDL) -e mg_make_cula_bindings

clean:
	rm -rf idlcula.*
