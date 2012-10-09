; docformat = 'rst'

;+
; Makes a string safe for inclusion in an XML file by expanding special
; characters into their XML entities.
;
; :Returns:
;    string
;
; :Params:
;    chars : in, required, type=string
;       input string
;-
function mg_escape_xml, chars
  compile_opt strictarr

  s = mg_streplace(chars, '&', '&amp;', /global)
  s = mg_streplace(s, '<', '&lt;', /global)
  s = mg_streplace(s, '>', '&gt;', /global)

  return, s
end
