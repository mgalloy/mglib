; docformat = 'rst'

;+
; Grab the next token from a string/strarr, returning the new token, and
; removing the token from the given string(s).
;
; :Returns:
;   string/strarr
;
; :Params:
;   str : in, out, required, type=string/strarr
;     string to grab next token from
;   delim : in, optional, type=string
;     delimiter, as regular expression
;
; :Keywords:
;   no_advance : in, optional, type=boolean
;     set to not modify `str`
;-
function mg_strtoken, str, delim, no_advance=no_advance
  compile_opt strictarr

  ; start with the full string
  token = str

  delim_pos = stregex(str, delim, length=delim_length)

  delim_ind = where(delim_pos gt -1L, n_delim, $
                    complement=no_delim_ind, ncomplement=n_no_delim)

  if (n_no_delim gt 0L && ~keyword_set(no_advance)) then str[no_delim_ind] = ''

  if (n_delim gt 0L) then begin
    ; size of first dimension of delim_pos determines stride of STRMID
    delim_pos = reform(delim_pos[delim_ind], 1, n_delim)

    token[delim_ind] = strmid(str[delim_ind], 0, delim_pos)

    if (~keyword_set(no_advance)) then begin
      str[delim_ind] = strmid(str[delim_ind], $
                              delim_pos + delim_length[delim_ind])
    endif
  endif

  return, token
end
