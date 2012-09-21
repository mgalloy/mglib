IDL=idl

.PHONY: all clean

mg_markdown.*.so: mg_make_markdown_bindings.pro mg_markdown.c mg_markdown.dlm
	$(IDL) -e mg_make_markdown_bindings

clean:
	rm -rf mg_markdown.*.so
