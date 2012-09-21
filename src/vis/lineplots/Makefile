IDL=idl
VIS_LINEPLOTS_SO=vis_lineplots.darwin.x86_64.so
#VIS_LINEPLOTS_SO=vis_lineplots.`idl -quiet -IDL_QUIET 1 -e "print, mg_platform_extension(/extension)"`

.PHONY: clean

$(VIS_LINEPLOTS_SO): vis_lineplots.c vis_lineplots.dlm
	$(IDL) -e vis_build_lineplots

clean:
	rm -rf vis_lineplots.*.so
