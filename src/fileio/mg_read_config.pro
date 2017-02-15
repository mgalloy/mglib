; docformat = 'rst'

;+
; Reads a configuration file and returns an `MGffOptions` object with the
; results.
;
; Options and their values are listed one option per line, though the value can
; extend over multiple lines by indenting at least one space on the continued
; lined. There must be either a ":" or an "=" after the option name. Leading
; space before the first character in the value is ignored. For example::
;
;   option1: value1
;   option2 =    value2
;   option3 : a very long
;     value3
;
; The values of options 1, 2, and 3 are "value1", "value2", and
; "a very long value3", respectively.
;
; Comments have "#" or ";" as the first character on a line and are ignored.
;
; Sections break a configuration file into namespaces. They are specified by
; placing a name in square brackets, such as::
;
;   [ section_name ]
;
; Options after this declaration and before the next such section declaration
; are in the "section_name" section. Options before the first section
; declaration are in the default section (the entire configuration file can be
; in the default section).
;
; Interpolation can be used to substitute values from one option into another.
; Only options from the default section or the current section can be used.
; Interpolation uses `MG_SUBS` and hence its syntax, in this case::
;
;   %(option_name)s
;
; where the "s" stands for string (`MG_SUBS` can substitute numeric quantities
; and uses the C format codes, but options are always strings so "s" is always
; used in this case).
;
; :Returns:
;   `MGffOptions` object
;
; :Examples:
;   For example, suppose the following configuration file is in `config.ini`::
;
;     [My Section]
;     foodir: %(dir)s/whatever
;     dir=frob
;     long: this value continues
;        in the next line
;
;   It can be read into an `MGffOptions` object with::
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
;   This example is found as a main-level program at the end of this file. Run
;   it with::
;
;     IDL> .run mg_read_config
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
;   use_environment : in, optional, type=boolean
;     set to use environment variables for substitution
;-
function mg_read_config, filename, $
                         defaults=defaults, $
                         error=error, $
                         fold_case=fold_case, $
                         use_environment=use_environment
  compile_opt strictarr
  on_error, 2

  error = 0L

  if (~file_test(filename)) then begin
    error = -1L
    message, string(filename, format='(%"%s not found")'), /informational
    return, obj_new()
  endif

  ; start with copy of the defaults hash, if present, otherwise an empty hash
  h = obj_new('mgffoptions', fold_case=fold_case, use_environment=use_environment)
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
    is_variable = stregex(line, '^[-.[:alnum:]_$]+[[:space:]]*[=:]', /boolean)
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

          section_tokens = stregex(line, '^\[[[:space:]]*([^]\]+)', $
                                   /extract, /subexpr)
          section_name = strtrim(section_tokens[1], 2)
        end
      is_variable: begin
          if (continuing) then begin
            continuing = 0B
            h->put, name, value, section=section_name
          endif

          tokens = stregex(line, '^([-.[:alnum:]_$]+)[[:space:]]*[=:](.*)', $
                           /extract, /subexpr)
          name = tokens[1]
          value = strtrim(tokens[2], 2)

          continuing = 1B
        end
      is_continuation: begin
          if (continuing) then begin
            value += ' ' + strtrim(line, 2)
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


; main-level example program

config = mg_read_config(filepath('config.ini', root=mg_src_root()))
print, config->has_option('foodir', section='My Section')
print, config->get('foodir', section='My Section')
print, config->get('value1', section='My Section', /boolean)
print, config->get('value2', section='My Section', /boolean)
print, config->get('value3', section='My Section', /boolean, default=1B)

end
