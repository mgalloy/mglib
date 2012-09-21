IDL=idl

.PHONY: clean all


mg_strings.*.so: mg_make_strings.pro mg_strings.c mg_strings.dlm
	$(IDL) -e mg_make_strings

clean:
	rm -rf mg_strings.*.so
	rm -f spell_hash.sav
	