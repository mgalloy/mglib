; docformat = 'rst'

;+
; See `Python configparser <http://docs.python.org/2/library/configparser.html>`
; for more details.
;
; :Returns:
;   hash
;
; :Examples:
;
;   For example, the following configuration file::
;
;     [My Section]
;     foodir: %(dir)s/whatever
;     dir=frob
;     long: this value continues
;        in the next line
;
; :Params:
;   filename : in, required, type=string
;     filename of configuration file to read
;
; :Keywords:
;   defaults : in, optional, type=hash
;     hash containing default values for items to be specified in configuration
;     file
;   error : out, optional, type=long
;     set to a named variable to retrieve any error code from attempting to read
;     the configuration file; 0 for OK, -1 for file not found, -2 for invalid
;     syntax in configuration file
;-
function mg_readconfig, filename, defaults=defaults, error=error
  compile_opt strictarr
  on_error, 2

  error = 0L

  if (~file_test(filename)) then begin
    error = -1L
    message, string(filename, format='(%"%s not found")'), /informational
    return, obj_new()
  endif

  ; start with copy of the defaults hash, if present, otherwise an empty hash
  h = isa(defaults, 'hash') ? defaults[*] : hash()

  ; read file
  nlines = file_lines(filename)
  lines = strarr(nlines)
  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun

  continuing = 0B
  value = ''

  foreach line, lines, l do begin
    is_comment = stregex(line, '^[[:space:]]*[;#]', /boolean)
    is_section = stregex(line, '^\[', /boolean)
    is_blank = stregex(line, '^[[:space:]]*$', /boolean)
    is_variable = stregex(line, '^[[:alnum:]_$]+[[:space:]]*[=:]', /boolean)
    is_continuation = stregex(line, '^[[:space:]]+', /boolean)

    case 1 of
      is_comment || is_blank || is_section: begin
          if (continuing) then begin
            continuing = 0B
            h[name] = value
          endif
        end
      is_variable: begin
          if (continuing) then begin
            continuing = 0B
            h[name] = value
          endif

          tokens = stregex(line, '^([[:alnum:]_$]+)[=:](.*)', /extract, /subexpr)
          name = tokens[1]
          value = strtrim(tokens[2], 1)
          continuing = 1B
        end
      is_continuation: begin
          if (continuing) then begin
            value += ' ' + strtrim(line, 1)
          endif else begin
            error = -2L
            message, string(l, line, format='(%"invalid line %d: ''%s''")'), $
                     /informational
            return, obj_new()
          endelse
        end
      else: begin
          error = -2L
          message, string(l, line, format='(%"invalid line %d: ''%s''")'), $
                   /informational
          return, obj_new()
        end
    endcase
  endforeach

  if (continuing) then h[name] = value

  ; substitution
  foreach value, h, key do begin
    if (stregex(value, '%\([[:alnum:]_$]+\)', /boolean)) then begin
      h[key] = mg_subs(value, h)
    endif
  endforeach

  return, h
end
