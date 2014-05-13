; docformat = 'rst'

;+
; :Private:
;-
function mg_onlinehelp_lookup_routines
  compile_opt strictarr
  common mg_onlinehelp, basenames
  on_error, 2

  if (n_elements(basenames) eq 0L) then begin
    dir = filepath('', $
                   subdir=['help', 'online_help', 'IDL', 'Content', $
                           'Reference Material'], $
                   root=n_elements(root) eq 0L ? filepath('') : root)

    files = file_search(dir, '*.htm', /quote, count=nfiles)
    if (nfiles gt 0L) then begin
      basenames = file_basename(files, '.htm')
    endif else begin
      files = file_search(dir, '*.html', /quote, count=nfiles)
      basenames = file_basename(files, '.html')
    endelse
  endif

  return, basenames
end


;+
; Determine if a name represents an IDL library function, procedure, or class
; and return the URL to the online help if it does.
;
; :Returns:
;   string URL or '' if symbol not found
;
; :Params:
;   name : in, required, type=string
;     name of function, procedure, or class to lookup
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to return whether the name was found
;   type : out, optional, type=long
;     set to a named variable to return the type of the matching name;
;     -1 = unknown, 1 = function, 2 = procedure, 3 = other
;   root_url : in, optional, type=http://exelisvis.com/docs/
;     root URL for documentation, change to specify a different copy of the
;     documentation
;-
function mg_onlinehelp_lookup, name, found=found, type=type, root_url=root_url
  compile_opt strictarr
  on_error, 2

  _root = n_elements(root_url) eq 0L ? 'http://exelisvis.com/docs/' : root_url

  ; -1 = unknown, 1 = function, 2 = procedure, 3 = other
  type = -1L
  found = 0B

  ; determine if there is help for the given name (and what type it is)
  basenames = mg_onlinehelp_lookup_routines()
  if (total(basenames eq strupcase(name)) gt 0L) then begin
    type = 1L
    _name = name
  endif else if (total(basenames eq strupcase(name) + '_Procedure') gt 0L) then begin
    type = 2L
    _name = name
  endif else if (total(strmatch(basenames, name, /fold_case)) gt 0L) then begin
    type = 3L
    mask = strmatch(basenames, name, /fold_case)
    _name = basenames[(where(mask))[0]]
  endif

  ; create URL to documentation link
  case type of
    -1: return, ''
    1: begin
         found = 1B
         url = string(_root, strupcase(_name), format='(%"%s/%s.html")')
       end
    2: begin
         found = 1B
         url = string(_root, strupcase(_name), $
                      format='(%"%s/%s_Procedure.html")')
       end
    3: begin
         found = 1B
         url = string(_root, _name, format='(%"%s/%s.html")')
       end
    else: message, 'unknown symbol type'
  endcase

  return, url
end
