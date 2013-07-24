; docformat = 'rst'

;+
; String substitution routine which substitutes values into a given string
; using the correspondences found in the provided hash or structure.
;
; :Examples:
;   A single hash or structure can be created with all the possible values
;   needed and then a template string can selectively access the desired
;   values. For example, create a hash of a couple values::
;
;      IDL> h = hash('name', 'Mike', 'height', 72)
;
;   If desired, the `name` key can be used to access just one of the keys in
;   the hash::
;
;      IDL> print, mg_subs('Name: %(name)s', h)
;      Name: Mike
;
;    But the other (or all of the other) attributes can also be accessed::
;
;      IDL> print, mg_subs('Height: %(height)d inches', h)
;      Height: 72 inches
;
;    The main-level program at the end of this file also contains examples.
;    Run them with::
;
;       IDL> .run mg_subs
;
;    This does the following examples::
;
;       IDL> print, mg_subs('%(name)s is located in zip code %(zipcode)05d.', $
;       IDL>                { name: 'Exelis VIS', zipcode: 80301 })
;       Exelis VIS is located in zip code 80301.
;       IDL> h = hash('loc', 'Boulder, CO', 'temp', 80, 'units', 'degrees F')
;       IDL> print, mg_subs('It is %(temp)d %(units)s in %(loc)s today!', h)
;       It is 80 degrees F in Boulder, CO today!
;       IDL> obj_destroy, h
;
; :Requires:
;    IDL 8.0
;-


;+
; Perform a lookup in a hash or structure given a name of the key/field.
;
; :Private:
;
; :Returns:
;    value of the key/field
;
; :Params:
;    hash : in, required, type=hash/structure
;       hash or structure to lookup key in; if structure, then key lookup is
;       done case-insensitively; if hash object, the hash mush have a `hasKey`
;       method and allow hash lookup using overloaded `[]`s
;    name : in, required, type=string
;       name of key/field to lookup
;
; :Keywords:
;    found : out, optional, type=boolean
;       set to a named variable to get whether the `name` was found in the
;       `hash`
;-
function mg_subs_getvalue, hash, name, found=found
  compile_opt strictarr
  on_error, 2

  case size(hash, /type) of
     8: begin
        ind = where(tag_names(hash) eq strupcase(name), found)
        return, found ? hash.(ind[0]) : -1L
      end
    11: begin
        found = hash->hasKey(name)
        return, found ? hash[name] : -1L
      end
    else: message, 'unknown hash type'
  endcase
end


;+
; String substitution routine which substitutes values into a given string
; using the correspondences found in the provided hash or structure.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    template : in, optional, type=string
;       string to substitute into
;    hash : in, required, type=hash/structure
;       hash table or structure with key-value pairs to subsitute into the
;       template
;
; :Keywords:
;   unresolved_keys : out, optional, type=long
;     set to a named variable to retrieve the number of keys that were not
;     found in the hash; if passed, no error message is output
;-
function mg_subs_iter, template, hash, unresolved_keys=unresolved_keys
  compile_opt strictarr
  on_error, 2

  unresolved_keys = 0L
  result = ''
  re = '%\(([[:alnum:]_]+)\)([[:digit:].]*[[:alpha:]])'

  cur = 0L
  while (cur lt strlen(template)) do begin
    pos = stregex(strmid(template, cur), re, length=len, /subexpr) + cur

    if (pos[0] lt cur) then begin
      pos[0] = strlen(template)
      len[0] = 0
    endif

    ; add normal string since last substitution
    result += strmid(template, cur, pos[0] - cur)

    ; lookup key and substitute it
    if (pos[0] lt strlen(template)) then begin
      name = strmid(template, pos[1], len[1])
      value = mg_subs_getvalue(hash, name, found=found)

      if (~found) then begin
        if (arg_present(unresolved_keys)) then begin
          unresolved_keys++
          result += strmid(template, pos[0], len[0])
        endif else begin
          message, string(name, $
                          format='(%"format key error: key \"%s\" not found")')
        endelse
      endif else begin
        format = string('%' + strmid(template, pos[2], len[2]), $
                        format='(%"(\%\"%s\")")')
        result += string(value, format=format)
      endelse
    endif

    cur = pos[0] + len[0]
  endwhile

  return, result
end


;+
; String substitution routine which substitutes values into a given string
; using the correspondences found in the provided hash or structure.
;
; :Returns:
;    string
;
; :Params:
;    template : in, optional, type=string
;       string to substitute into
;    hash : in, required, type=hash/structure
;       hash table or structure with key-value pairs to subsitute into the
;       template
;
; :Keywords:
;   unresolved_keys : out, optional, type=long
;     set to a named variable to retrieve the number of keys that were not
;     found in the hash; if passed, no error message is output
;-
function mg_subs, template, hash, unresolved_keys=unresolved_keys
  compile_opt strictarr
  on_error, 2

  result = template
  new_result = mg_subs_iter(result, hash, unresolved_keys=unresolved_keys)

  repeat begin
    tmp = new_result
    new_result = mg_subs_iter(new_result, hash, unresolved_keys=unresolved_keys)
    result = tmp
  endrep until (result eq new_result)

  return, result
end


; main-level example program

print, mg_subs('%(name)s is located in zip code %(zipcode)05d.', $
               { name: 'Exelis VIS', zipcode: 80301 })

h = hash('loc', 'Boulder, CO', 'temp', 80, 'units', 'degrees F')
print, mg_subs('It is %(temp)d %(units)s in %(loc)s today!', h)
obj_destroy, h

end
