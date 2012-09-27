IDL=idl
FLOW_SO=mg_flow.darwin.x86_64.so
#FLOW_SO=vis_flow.`idl -quiet -IDL_QUIET 1 -e "print, mg_platform_extension(/extension)"`

.PHONY: clean

$(FLOW_SO): mg_flow.c mg_flow.dlm
	$(IDL) -e "mg_build_flow, /show_all_output, /verbose"

clean:
	rm -rf mg_flow.*.so
