; docformat = 'rst'

;+
; Calculates the size of a string.
;
; :Returns:
;   returns `lonarr(2)`, i.e., `[width, height]`
;
; :Params:
;   s : in, required, type=string
;     string to determine the size of
;
; :Keywords:
;   fontname : in, optional, type=string
;     name of font to use for calculation
;-
function mg_fontsize, s, fontname=fontname
  compile_opt strictarr

  base = widget_base()

  if (n_elements(fontname) gt 0L) then begin
    sz = widget_info(base, string_size=[s, fontname])
  endif else begin
    sz = widget_info(base, string_size=s)
  endelse

  widget_control, base, /destroy
  return, sz
end

