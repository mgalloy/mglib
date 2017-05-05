; docformat = 'rst'

;+
; Retrieve the value of a keyword from a FITS header.
;
; If a keyword (except HISTORY or COMMENT) occurs more than once in a header, a
; warning is given, and the *last* occurrence is used.
;
; Code follows most of the same logic as `SXPAR`.
;
; :Examples:
;   For example, try for some FITS file `f`:
;
;     IDL> header = headfits(f)
;     IDL> values = mg_fits_getkeyword(header, 'solar_*', names=names)
;     IDL> print, values
;          -23.5700     -3.88000      41.1230
;     IDL> print, names
;     SOLAR_P0 SOLAR_B0 SOLAR_RA
;
;
; :Returns:
;   if keyword value is double, float, long or string, the result is that type;
;   single quotes are stripped from strings; if the parameter is boolean, 1b is
;   returned for T, and 0b is returned for F; if `name` was of form 'keyword*'
;   then a vector of values are returned
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;   name : in, required, type=string
;     FITS keyword name
;
; :Keywords:
;   names : out, optional, type=strarr
;   count : out, optional, type=long
;   comments : out, optional, type=long
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the access; 0 for
;     success, 1 for a warning, 2 for an error
;-
function mg_fits_getkeyword, header, name, $
                             names=names, $
                             count=count, $
                             comments=comments, $
                             status=status, $
                             error_message=error_message
  compile_opt strictarr
  on_error, 2

  status = 0L
  error_message = 'success'

  if (size(header, /n_dimensions) ne 1 || size(header, /type) ne 7) then begin
    status = 2L
    error_message = 'FITS header must be a string array'
    if (arg_present(status) || arg_present(error_message)) then begin
      return, !null
    endif else message, error_message
  endif

  _name = strtrim(strupcase(name), 2)

  contains_wildcard = strpos(_name, '*') ge 0L $
                        || strpos(_name, '?') ge 0L $
                        || strpos(_name, '[') ge 0L $
                        || strpos(_name, ']') ge 0L

  special_name = _name eq 'HISTORY ' || _name eq 'COMMENT ' || _name eq ''

  all_keywords = strtrim(strmid(header, 0, 8), 2)
  match_ind = where(strmatch(all_keywords, _name), count)

  ; warn if a keyword found more than once, unless it is HISTORY or COMMENT
  if (count gt 1L && ~special_name) then begin
    status = 1
    error_message = 'keyword ' + _name + ' found more than once'
    if (~arg_present(status) && ~arg_present(error_message)) then begin
      message, error_message, /informational
    endif
  endif

  if (count eq 0L) then return, !null

  line = header[match_ind]
  svalue = strtrim(strmid(line, 9, 71), 2)
  if (special_name) then begin
    value = strtrim(strmid(line, 8, 71), 2)
  endif else begin
    for i = 0L, count - 1L do begin
      if (strmid(svalue[i], 0, 1) eq "'" ) then begin   ; test if string
        test = strmid(svalue[i], 1, strlen(svalue[i]) - 1)
        next_char = 0
        off = 0
        value = '' 

        next_singlequote:
        end_singlequote = strpos(test, "'", next_char)   ; ending single quote
        if (end_singlequote lt 0) then begin
          status = 2L
          error_message = 'value of ' + name + ' invalid'
          if (arg_present(status) || arg_present(error_message)) then begin
            return, !null
          endif else message, error_message
        endif
        value += strmid(test, next_char, end_singlequote - next_char)

        ; test if next char is single quote, if so, then just an escaped single
        ; quote
        if (strmid(test, end_singlequote + 1, 1) eq "'") then begin    
          value = value + "'"
          next_char = end_singlequote + 2
          goto, next_singlequote
        endif      

        ; extract the comment, if any
        slash = strpos(test, '/', end_singlequote)
        if (slash lt 0L) then begin
          comment = ''
        endif else begin
          comment = strmid(test, slash + 1L, strlen(test) - slash - 1L)
        endelse
        
        ; check to make sure string is not continued on next line:
        ;   1. ends with '&'
        ;   2. next line is CONTINUE
        ;   3. LONGSTRN keyword is present
        off++
        val = strtrim(value, 2)

        if (strlen(val) gt 0) && $
            (strmid(val, strlen(val) - 1L, 1) eq '&') && $
            (strmid(header[match_ind[i] + off], 0, 8) eq 'CONTINUE') then begin
          if (~array_equal(all_keywords eq 'LONGSTRN', 0B)) then begin 
            value = strmid(val, 0, strlen(val) - 1)
            test = header[match_ind[i] + off]
            test = strmid(test, 8, strlen(test) - 8L)
            test = strtrim(test, 2)
            if (strmid(test, 0, 1) ne "'") then begin
              status = 2L
              error_message = 'invalidly continued string'
              if (arg_present(status) || arg_present(error_message)) then begin
                return, !null
              endif else message, error_message
            endif
            next_char = 1
            goto, next_singlequote
          endif
        endif
      endif else begin
        ; process numeric value: boolean, float, double, long
        test = svalue[i]
        slash = strpos(test, '/')
        if (slash gt 0) then begin
          comment = strmid(test, slash + 1, strlen(test) - slash - 1)
          test = strmid(test, 0, slash)
        endif else begin
          comment = ''
        endelse

        ; find the first word in test; check if it is a boolean value, 'T' or 'F'
        test2 = test
        value = mg_strtoken(test2, ' ')
        if (value eq 'T') then value = 1b else begin
          if (value eq 'F') then value = 0b else begin
            
            ; test if value is complex number: complex if value and the next
            ; word are both valid
            if (strlen(test2) eq 0L) then goto, not_complex
            value2 = mg_strtoken(test2, ' ') 
            if (value2 eq '') then goto, not_complex

            on_ioerror, not_complex
            value2 = float(value2)
            value = complex(value, value2)
            goto, value_correct
            
            ; if value is not a complex number, decide between a float, double,
            ; or long
            not_complex:
            on_ioerror, value_correct
            if (strpos(value, '.') ge 0L) $
                  || (strpos(value, 'E') gt 0L) $
                  || (strpos(value, 'D') ge 0L) then begin   ; float/double
              if (strpos(value, 'D') gt 0L) $                ; double
                    || (strlen(value) ge 8) then begin
                value = double(value)
              endif else begin
                value = float(value)
              endelse
            endif else begin                                 ; long
              lmax = 2.0D^31 - 1.0d
              lmin = -2.0D^31
              value = long64(value)
              if (value ge lmin) && (value le lmax) then value = long(value) 
            endelse
          endelse
          
          value_correct:
          on_ioerror, null
        endelse
      endelse
      
      ; add to vector if required
      if (contains_wildcard) then begin
        ; set result type and allocate results first time through
        if (i eq 0) then begin
          result_type = size(value, /type)
          result = make_array(count, type=result_type)
          names = strarr(count)
          comments = strarr(count)
        endif 

        ; change type, if necessary
        if (size(value, /type) gt result_type) then begin
          result += 0 * value
          result_type = size(value, /type)
        endif

        ; store results
        result[i] = value
        names[i] = all_keywords[match_ind[i]]
        comments[i] = comment
      endif else comments = comment
    endfor
  endelse

  return, contains_wildcard ? result : value
end


; main-level example program

f = '/hao/mahidata1/Data/CoMP/process/20170503/level1/20170503.200347.comp.1074.iv.5.fts.gz'

header = headfits(f)

solar_values = mg_fits_getkeyword(header, 'solar_*', $
                                  count=n_solar_values, $
                                  names=solar_names, $
                                  status=status, $
                                  comments=comments)
for i = 0L, n_solar_values - 1L do begin
  print, solar_names[i], solar_values[i], strtrim(comments[i], 2), $
         format='(%"%-9s = %7.3f %s")'
endfor

crosstalk = mg_fits_getkeyword(header, '?_to_?', $
                               count=n_crosstalk, $
                               names=crosstalk_names, $
                               status=status, $
                               comments=comments)
for i = 0L, n_crosstalk - 1L do begin
  print, crosstalk_names[i], crosstalk[i], strtrim(comments[i], 2), $
         format='(%"%-9s = %7.3f %s")'
endfor

end
