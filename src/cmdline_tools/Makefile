IDL=idl

.PHONY: clean
	
cmdline_tools.*.so: cmdline_tools.c cmdline_tools.dlm
	$(IDL) -e mg_build_cmdline_tools
	
clean:
	rm -rf cmdline_tools.*.so

