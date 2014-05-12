; docformat = 'rst'

;+
; Determine if a name represents an IDL library function, procedure, or class
; and return the URL to the online help if it does.
;
; :Returns:
;   string URL or -1L if symbol not found
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
;     -1 = unknown, 1 = function, 2 = procedure, 3 = class
;   root_url : in, optional, type=http://exelisvis.com/docs/
;     root URL for documentation, change to specify a different copy of the
;     documentation
;-
function mg_onlinehelp_lookup, name, found=found, type=type, root_url=root_url
  compile_opt strictarr
  on_error, 2

  _root = n_elements(root_url) eq 0L ? 'http://exelisvis.com/docs/' : root_url

  ; -1 = unknown, 1 = function, 2 = procedure, 3 = class
  type = -1L
  found = 0B

  ; determine if there is help for the given name

  ; TODO: match name against function, procedure, and class name lists
  type = 1

  ; create URL to documentation link
  case type of
    -1: return, -1L
    1: begin
         found = 1B
         url = string(_root, strupcase(name), format='(%"%s/%s.html")')
       end
    2: begin
         found = 1B
         url = string(_root, strupcase(name),
                      format='(%"%s/%s_Procedure.html")')
       end
    3: begin
         found = 1B
         url = string(_root, name, format='(%"%s/%s.html")')
       end
    else: message, 'unknown symbol type'
  endcase

  return, url
end
