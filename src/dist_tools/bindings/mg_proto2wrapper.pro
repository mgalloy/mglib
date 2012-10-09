; docformat = 'rst'

;+
; Convenience routine to convert a C prototype line to C wrapper code.
;
; :Returns:
;    string
;
; :Params:
;    prototype : in, required, type=string
;       C prototype as found in a header file
;-
function mg_proto2wrapper, prototype
  compile_opt strictarr

  name = mg_parse_cprototype(prototype, params=params, return_type=return_type)

  r = mg_routinebinding(name=name, return_type=return_type, prototype=proto)

  if (params[0] ne '') then begin
    for i = 0L, n_elements(params) - 1L do begin
      param_type = mg_parse_cdeclaration(params[i], $
                                         pointer=pointer, array=array, $
                                         device=device)
      if (param_type ne 0) then begin
        r->addParameter, type=param_type, $
                         pointer=pointer, array=array, device=device, $
                         prototype=params[i]
      endif
    endfor
  endif

  result = r->output()
  obj_destroy, r

  return, result
end