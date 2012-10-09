; docformat = 'rst'

;+
; Replace special characters in the input string using the `%xx` escape codes.
;
; :Returns:
;    string
;
; :Params:
;    s : in, required, type=string
;       string to quote
;
; :Keywords:
;    safe : in, optional, type=string
;       string of safe characters, i.e., ones that don't need replacing
;    unquote : in, optional, type=boolean
;       set to unquote instead of quote
;    plus : in, optional, type=boolean
;       set to quote/unquote plus
;-
function mg_urlquote, s, safe=safe, unquote=unquote, plus=plus
  compile_opt strictarr

  quoter = obj_new('MGnetURLQuoter', safe=safe)

  case keyword_set(unquote) of
    0: case keyword_set(plus) of
         0: _result = quoter->quote(s)
         1: _result = quoter->quotePlus(s)
       endcase
    1: case keyword_set(plus) of
         0: _result = quoter->unquote(s)
         1: _result = quoter->unquotePlus(s)
       endcase
  endcase

  obj_destroy, quoter

  return, _result
end
