; docformat = 'rst'

;+
; Reads a configuration file and returns an `mgffoptions` object with the
; results.
;
; See `Python configparser <http://docs.python.org/2/library/configparser.html>`
; for more details.
;
; :Returns:
;   `mgffoptions` object
;
; :Examples:
;
;   For example, suppose the following configuration file is in `config.ini`::
;
;     [My Section]
;     foodir: %(dir)s/whatever
;     dir=frob
;     long: this value continues
;        in the next line
;
;   It can be read into an `mgffoptions` object with::
;
;     IDL> config = mg_read_config('config.ini')
;
;   The result can be queried for values::
;
;     IDL> print, config->has_option('foodir', section='My Section')
;        1
;     IDL> print, config->get('foodir', section='My Section')
;     frob/whatever
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
;   fold_case : in, optional, type=boolean
;     set for case-insensitive results (for section and option names, but not
;     for values)
;-
function mg_read_config, filename, $
                         defaults=defaults, $
                         error=error, $
                         fold_case=foldcase
  compile_opt strictarr
  on_error, 2

  error = 0L

  if (~file_test(filename)) then begin
    error = -1L
    message, string(filename, format='(%"%s not found")'), /informational
    return, obj_new()
  endif

  ; start with copy of the defaults hash, if present, otherwise an empty hash
  h = mgffoptions(fold_case=fold_case)
  case 1 of
    isa(defaults, 'mgffoptions'): begin
        foreach section, defaults, section_name do begin
          foreach value, section, option_name do begin
            h->put, option_name, value, section=section_name
          endforeach
        endforeach
      end
    isa(defaults, 'hash'): begin
        foreach value, defaults, key do h->put, key, value
      end
    else:
  endcase

  ; read file
  nlines = file_lines(filename)
  lines = strarr(nlines)
  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun

  continuing = 0B
  value = ''
  section_name = ''

  foreach line, lines, l do begin
    is_comment = stregex(line, '^[[:space:]]*[;#]', /boolean)
    is_section = stregex(line, '^\[', /boolean)
    is_blank = stregex(line, '^[[:space:]]*$', /boolean)
    is_variable = stregex(line, '^[[:alnum:]_$]+[[:space:]]*[=:]', /boolean)
    is_continuation = stregex(line, '^[[:space:]]+', /boolean)

    case 1 of
      is_comment || is_blank: begin
          if (continuing) then begin
            continuing = 0B
            h->put, name, value, section=section_name
          endif
        end
      is_section: begin
          if (continuing) then begin
            continuing = 0B
            h->put, name, value, section=section_name
          endif

          section_tokens = stregex(line, '^\[[[:space:]]*([[:alnum:]_$ ]+)', $
                                   /extract, /subexpr)
          section_name = section_tokens[1]
        end
      is_variable: begin
          if (continuing) then begin
            continuing = 0B
            h->put, name, value, section=section_name
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

  if (continuing) then h->put, name, value, section=section_name

  return, h
end
