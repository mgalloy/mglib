IDL=idl

.PHONY: clean
	
mg_net.*.so: mg_net.c mg_net.dlm
	$(IDL) -e mg_build_net
	
clean:
	rm -rf mg_net.*.so
