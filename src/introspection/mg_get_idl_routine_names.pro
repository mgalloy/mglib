; docformat = 'rst'

function mg_get_idl_routine_names, root
  compile_opt strictarr

  dir = filepath('', $
                 subdir=['help', 'online_help', 'IDL', 'Content', $
                         'Reference Material'], $
                 root=n_elements(root) eq 0L ? filepath('') : root)
  files = file_search(dir, '*.html', /quote)

  basenames = file_basename(files, '.html')

  ; eliminate [A-Z]_list
  barr = stregex(basenames, '^[A-Z]_list', /boolean)
  ind = where(barr eq 0L, count)
  if (count gt 0L) then basenames = basenames[ind]

  ; eliminate WHILE__DO
  barr = stregex(basenames, '___', /boolean)
  ind = where(barr eq 0L, count)
  if (count gt 0L) then basenames = basenames[ind]

  ; remove _Procedure
  barr = stregex(basenames, '^.*_Procedure', /boolean)
  ind = where(barr, count)
  if (count gt 0L) then begin
    names = stregex(basenames[ind], '^(.*)_Procedure', /extract, /subexpr)
    basenames[ind] = names[1, *]
  endif

  ; eliminate duplicates (because there are functions and procedures with the
  ; the names and now that we have eliminated "_Procedure" they have the same
  ; names
  basenames = basenames[uniq(basenames, sort(basenames))]

  ; eliminate names that start with "_"
  barr = stregex(basenames, '^_.*', /boolean)
  ind = where(barr eq 0L, count)
  if (count gt 0L) then basenames = basenames[ind]

  ; eliminate names that contain lowercase (this gets random topics plus
  ; IDL_Container and its methods, some Java classes)
  barr = stregex(basenames, '[a-z]+', /boolean)
  ind = where(barr eq 0L, count)
  if (count gt 0L) then basenames = basenames[ind]

  ; eliminate reserved words
  reserved_words = ['AND', 'BEGIN', 'BREAK', 'CASE', 'COMMON', 'COMPILE_OPT', $
                    'CONTINUE', 'DO', 'ELSE', 'END', 'ENDCASE', 'ELSEELSE', $
                    'ENDFOR', 'ENDFOREACH', 'ENDIF', 'ENDREP', 'ENDSWITCH', $
                    'ENDWHILE', 'EQ', 'FOR', 'FOREACH', 'FORWARD_FUNCTION', $
                    'FUNCTION', 'GE', 'GOTO', 'GT', 'IF', 'INHERITS', 'LE', $
                    'LT', 'MOD', 'NE', 'NOT', 'OF', 'ON_IOERROR', 'OR', 'PRO', $
                    'REPEAT', 'SWITCH', 'THEN', 'UNTIL', 'WHILE', 'XOR']
  for i = 0L, n_elements(reserved_words) - 1L do begin
    ind = where(basenames eq reserved_words[i], complement=cind, count)
    if (count gt 0L) then begin
      basenames = basenames[cind]
    endif
  endfor

  return, basenames
end


; main-level example program

output_filename = n_elements(output_filename) eq 0L $
                    ? 'routine_names.txt' $
                    : output_filename

names = mg_get_idl_routine_names()
openw, lun, output_filename, /get_lun
printf, lun, transpose(names)
free_lun, lun

end
