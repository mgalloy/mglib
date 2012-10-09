; docformat = 'rst'

;+
; Prints out help information for a variable. Recursively descends through
; a nested structure.
;
; :Examples:
;    For example, try::
;
;       IDL> mg_help, { s1: { f1: 0., f2: 0., s2: { f3: 0. } } }
;       ** Structure <21068a8>, 1 tags, length=12, data length=12, refs=1:
;          S1: ** Structure <2106748>, 3 tags, length=12, data length=12, refs=2:
;             F1              FLOAT     =       0.00000
;             F2              FLOAT     =       0.00000
;             S2: ** Structure <21063e8>, 1 tags, length=4, data length=4, refs=2:
;                F3              FLOAT     =       0.00000
;
; :Params:
;    var : in, required, type=any
;       variable to print information about
;
; :Keywords:
;    indent : in, optional, type=string
;       spaces to indent output
;    tag_name : in, optional, type=string
;       name of tag, if variable is a tag of a parent structure
;-
pro mg_help, var, indent=indent, tag_name=tagname
  compile_opt strictarr, hidden

  maxVarnameLen = 16
  format = '(A-' + strtrim(maxVarnameLen, 2) + ', A-10, "= ", A)'

  varname = arg_present(var) ? scope_varname(var, level=-1) : '<Expression>'

  _indent = n_elements(indent) eq 0 ? '' : indent
  _tagname = n_elements(tagname) eq 0 ? '' : tagname

  type = size(var, /type)

  if (type eq 8L) then begin
    help, var, /structures, output=output
    print, _indent + _tagname + (strlen(_tagname) eq 0L ? '' : ': ') + output[0]
    tnames = tag_names(var)
    for t = 0L, n_tags(var) - 1L do begin
      mg_help, var.(t), indent=_indent + '   ', tag_name=tnames[t]
    endfor
  endif else begin
    help, var, output=output
    oldQuiet = !quiet
    !quiet = 1
    tokens = strsplit(output[0], /extract)
    !quiet = oldQuiet

    case type of
      10: begin
          value = size(var, /n_dimensions) eq 0L ? tokens[3] : strjoin(tokens[3:*], ' ')
          if (n_elements(var) eq 1) then begin
            if (ptr_valid(var)) then begin
              help, *var, output=output
              value += ' -> ' + output
            endif
          endif
        end
      11: value = size(var, /n_dimensions) eq 0L ? tokens[3] : strjoin(tokens[3:*], ' ')
      else: value = size(var, /n_dimensions) eq 0L  && type ne 0 ? (type eq 7 ? '''' + var + '''' : string(var)) : strjoin(tokens[3:*], ' ')
    endcase

    if (n_elements(tagname) gt 0) then begin
      desc = string(_tagname, tokens[1], value, format=format)
      print, _indent + desc
    endif else begin
      if (strlen(varname) gt maxVarnameLen) then begin
        print, varname
        print, string('', tokens[1], value, format=format)
      endif else begin
        print, string(varname, tokens[1], value, format=format)
      endelse
    endelse
  endelse
end
