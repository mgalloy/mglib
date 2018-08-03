; docformat = 'rst'


;+
; ::
;
;   [logging]
;   log_dir         : type=str
;   level           : type=str, default=DEBUG
;   max_log_version : type=long
;-
pro mg_parse_spec_line, spec_line, $
                        type=type, $
                        extract=extract, $
                        default=default
  compile_opt strictarr

  type = 7
  default_found = 0B
  extract = 0B
  default = !null

  expressions = strsplit(spec_line, ',', /extract, count=n_expressions)
  last_start = 0L
  for e = 1L, n_expressions - 1L do begin
    if (strpos(expressions[e], '=') ne -1) then begin
      last_start = e
    endif else begin
      expressions[last_start] += ',' + expressions[e]
      expressions[e] = ''
    endelse
  endfor

  expressions = strtrim(expressions[where(expressions ne '')], 2)

  for e = 0L, n_elements(expressions) - 1L do begin
    tokens = strsplit(expressions[e], '=', /extract, count=n_tokens)
    case strlowcase(tokens[0]) of
      'type': type = mg_get_type(tokens[1])
      'default': begin
          default = tokens[1]
          default_found = 1B
        end
      'extract': begin
          extract = mg_convert_boolean(tokens[1])
        end
      else:
    endcase
  endfor

  if (default_found) then default = mg_apply_type(default, $
                                                  type, $
                                                  extract=extract)
end
