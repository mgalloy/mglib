; docformat = 'rst'


;+
; Determine if a variable is a hash/structure or not.
;
; :Private:
;
; :Returns:
;   0B or 1B
;
; :Params:
;   o : in, required, type=any
;     variable to check
;-
function mg_yaml_dump_ishash, h
  compile_opt strictarr

  return, (size(h, /type) eq 11 && obj_isa(h, 'HASH')) || (size(h, /type) eq 8)
end


;+
; Get the "keys" of a hash or structure.
;
; :Private:
;
; :Returns:
;   `strarr` or `lindgen(n)`
;
; :Params:
;   h : in, required, type=hash or structure
;     hash or structure to find keys for
;-
function mg_yaml_dump_hashkeys, h
  compile_opt strictarr

  if (size(h, /type) eq 11) then begin
    return, h->keys()
  endif else begin
    return, lindgen(n_tags(h))
  endelse
end


;+
; Get the real key for a hash or structure, i.e., convert an index into a tag
; name in the case of a structure.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   h : in, required, type=hash or structure
;     hash or structure to find key for
;   key : in, required, type=string or long
;     "key" into the hash/structure
;-
function mg_yaml_dump_hashkey, h, key
  compile_opt strictarr

  if (size(h, /type) eq 11) then begin
    return, key
  endif else begin
    return, (tag_names(h))[key]
  endelse
end


;+
; Use a "key" to access an element of a hash.
;
; :Private:
;
; :Returns:
;   any
;
; :Params:
;   h : in, required, type=hash or structure
;     hash or structure to find value in
;   key : in, required, type=string or long
;     "key" into the hash/structure
;-
function mg_yaml_dump_hashelement, h, key
  compile_opt strictarr

  if (size(h, /type) eq 11) then begin
    return, h[key]
  endif else begin
    return, h.(key)
  endelse
end


;+
; Convert an the last two characters of an indent to "- ".
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   indent : in, required, type=string
;     current indent
;-
function mg_yaml_dump_firstindent, indent
  compile_opt strictarr

  len = strlen(indent)
  case 1 of
    len eq 0: return, ''
    len eq 2: return, '- '
    else: return, string(bytarr(len - 2) + (byte(' '))[0]) + '- '
  endcase
end


;+
; Determine if a variable is a list/array or not.
;
; :Private:
;
; :Returns:
;   0B or 1B
;
; :Params:
;   o : in, required, type=any
;     variable to check
;-
function mg_yaml_dump_islist, o
  compile_opt strictarr

  return, (size(o, /type) eq 11 && obj_isa(o, 'LIST')) $
            || (size(o, /type) ne 11 && size(o, /n_dimensions) gt 0)
end


;+
; Handle the output for the current level of indentation.
;
; :Private:
;
; :Params:
;   o : in, required, type=combination of list/array and hash/structure
;     variable to dump
;
; :Keywords:
;   from_list : in, optional, type=boolean
;     set to indicate that the current variable is from a list and its first
;     item should have a "- " at the end of its indent
;   result : in, required, type=list
;     list of strings which are output
;-
pro mg_yaml_dump_level, o, indent=indent, from_list=from_list, result=result
  compile_opt strictarr
  on_error, 2

  _indent = n_elements(indent) eq 0L ? '' : indent
  if (keyword_set(from_list)) then begin
    _first_indent = mg_yaml_dump_firstindent(_indent)
  endif else begin
    _first_indent = _indent
  endelse

  case 1 of
    mg_yaml_dump_ishash(o): begin
        keys = mg_yaml_dump_hashkeys(o)
        foreach k, keys, i do begin
          el = mg_yaml_dump_hashelement(o, k)
          if (mg_yaml_dump_ishash(el) || mg_yaml_dump_islist(el)) then begin
            result->add, string(i eq 0 ? _first_indent : _indent, $
                                strtrim(mg_yaml_dump_hashkey(o, k), 2), $
                                format='(%"%s%s:")')
            mg_yaml_dump_level, el, indent=_indent + '  ', result=result
          endif else begin
            result->add, string(i eq 0 ? _first_indent : _indent, $
                                strtrim(mg_yaml_dump_hashkey(o, k), 2), $
                                strtrim(el, 2), $
                                format='(%"%s%s: %s")')
          endelse
        endforeach
      end
    mg_yaml_dump_islist(o): begin
        foreach el, o, i do begin
          case 1 of
            mg_yaml_dump_ishash(el): begin
                mg_yaml_dump_level, el, indent=_indent + '  ', /from_list, result=result
              end
            mg_yaml_dump_islist(el): begin
                mg_yaml_dump_level, el, indent=_indent + '  ', /from_list, result=result
              end
            else: result->add, string(i eq 0 ? _first_indent : _indent, $
                                      strtrim(el, 2), $
                                      format='(%"%s- %s")')
          endcase
        endforeach
      end
    else: message, 'unknown type'
  endcase
end


;+
; Write a combination of lists/arrays and hashes/structures to a YAML-formatted
; string.
;
; :Examples:
;   For example, try:
;
;     IDL> print, mg_yaml_dump(list({a: [1, 2], b: 2 }, 'c', 'd'))
;     - A:
;         - 1
;         - 2
;       B: 2
;     - c
;     - d
;
; :Returns:
;   string
;
; :Params:
;   o : in, required, type=object
;     combination of lists/arrays and hashes/structures
;
; :Keywords:
;   filename : in, optional, type=string
;     if present, write the string to a file with this filename also
;-
function mg_yaml_dump, o, filename=filename
  compile_opt strictarr

  result = list()
  mg_yaml_dump_level, o, indent='', result=result
  s = mg_strmerge(result->toArray())
  obj_destroy, result

  if (n_elements(filename) gt 0L) then begin
    openw, lun, filename, /get_lun
    printf, lun, s
    free_lun, lun
  endif

  return, s
end


; main-level example program

print, '---'
print, mg_yaml_dump([1, 2, 3])
print, '---'
print, mg_yaml_dump({a: 1, b: 2, c: 3})
print, '---'
print, mg_yaml_dump({a: 1, b: [2, 3], c: [3, 4, 5]})
print, '---'
print, mg_yaml_dump(list({a: [1, 2], b: 2 }, 'c', 'd'))
print, '---'
print, mg_yaml_dump(list({a: {e: [1, 2], f: 2}, b: 2 }, 'c', 'd'))
print, '---'

end
