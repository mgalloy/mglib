IDL=idl
NAME=mg_introspection
EXT=so

.PHONY: clean

$(NAME).*.$(EXT) : $(NAME).c $(NAME).dlm
	$(IDL) -e "mg_make_dll, filepath('$(NAME).c', root=mg_src_root()), /show_all_output"

clean:
	rm -rf $(NAME).*.$(EXT)
