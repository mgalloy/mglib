IDL=idl

.PHONY: clean

cmdline_tools.*.so: mg_cmdline_tools.c mg_cmdline_tools.dlm
	$(IDL) -e mg_build_cmdline_tools

clean:
	rm -rf mg_cmdline_tools.*.so

