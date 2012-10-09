; docformat = 'rst'

;+
; Print the contents of a markup tree. Useful for debugging.
;
; :Params:
;    tree : in, required, type=object
;       root of markup tree to dump
;
; :Keywords:
;    indent : in, optional, type=string, default=''
;       string to indent output with
;-
pro mg_tm_dump, tree, indent=indent
  compile_opt strictarr
  on_error, 2

  _indent = n_elements(indent) eq 0L ? '' : indent

  case 1 of
    obj_isa(tree, 'MGtmText'): begin
        tree->getProperty, text=text
        print, _indent + 'text: "' + text + '"'
      end
    obj_isa(tree, 'MGtmTag'): begin
        tree->getProperty, type=type, $
                           n_attributes=nattributes, $
                           attribute_names=attributeNames
        if (nattributes gt 0L) then begin
          _attrs = ': '
          for a = 0L, nattributes - 1L do begin
            namevalue = string(attributeNames[a], $
                               tree->getAttribute(attributeNames[a]), $
                               format='(%"%s=\"%s\"")')
            _attrs += namevalue + (a eq nattributes - 1L ? '' : ', ')
          endfor
        endif else _attrs = ''
        print, _indent + type + _attrs

        tree->getProperty, n_children=nchildren
        for c = 0L, nchildren - 1L do begin
          mg_tm_dump, tree->getChild(c), indent=_indent + '  '
        endfor
      end
    obj_isa(tree, 'MGtmNode'): begin
         tree->getProperty, type=type
         print, _indent + type
      end
    else: message, 'invalid tree node encountered'
  endcase
end
