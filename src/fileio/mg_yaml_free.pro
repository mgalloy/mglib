; docformat = 'rst'

;+
; Free a combination of lists/arrays and hash/structures as used by
; `MG_YAML_LOAD` and `MG_YAML_DUMP`.
;
; :Params:
;   o : in, required, type=any
;     variable to free heap portion of
;-
pro mg_yaml_free, o
  compile_opt strictarr

  if (size(o, /n_dimensions) gt 0L|| size(o, /type) eq 11L) then begin
    if (size(o, /type) ne 8L || n_elements(o) ne 1) then begin
      foreach el, o do mg_yaml_free, el
    endif
  endif

  case size(o, /type) of
    8: for s = 0L, n_tags(o) - 1L do mg_yaml_free, o.(s)
    10: begin
        mg_yaml_free, *o
        ptr_free, o
      end
    11: obj_destroy, o
    else:
  endcase
end
