IDL=idl
FLOW_SO=vis_flow.darwin.x86_64.so
#FLOW_SO=vis_flow.`idl -quiet -IDL_QUIET 1 -e "print, mg_platform_extension(/extension)"`

.PHONY: clean

$(FLOW_SO): vis_flow.c vis_flow.dlm
	$(IDL) -e vis_build_flow

clean:
	rm -rf vis_flow.*.so
