; docformat = 'rst'

;+
; A `MGtmText` object is a `MGtmNode` that contains text.
;
; :Properties:
;    text
;       text stored in node
;    _ref_extra
;       properties of `MGtmNode`
;-


;+
; Helper routine for debugging.
;
; :Keywords:
;    indent : in, optional, type=string
;       prefix to print before each line, usually set to several spaces
;-
pro mgtmtext::_print, indent=indent
  compile_opt strictarr
  
  _indent = n_elements(indent) eq 0L ? '' : indent
  print, _indent, *self.text, format='(%"%s+ text: \"%s\"")'
end


;+
; Indicates whether this is a blank line.
;
; :Returns:
;    1 if line is blank, 0 if not
;-
function mgtmtext::isBlank
  compile_opt strictarr
  
  return, *self.text eq ''
end


;+
; Get properties of the text node.
;-
pro mgtmtext::getProperty, text=text, _ref_extra=e
  compile_opt strictarr

  if (arg_present(text)) then text = *self.text

  if (n_elements(e) gt 0) then begin
    self->mgtmnode::getProperty, _strict_extra=e
  endif  
end


;+
; Implement cloning.
;
; :Returns:
;    `MGtmNode` object
;-
function mgtmtext::_clone
  compile_opt strictarr
  
  return, obj_new('MGtmText', type=self.type, text=*self.text)
end


;+
; Free resources of the text node.
;-
pro mgtmtext::cleanup
  compile_opt strictarr

  ptr_free, self.text

  self->mgtmnode::cleanup
end


;+
; Creates a text node.
;     
; :Returns: 1 for success, 0 for failure
;
; :Keywords:
;    text : in, optional, type=string/strarr, default=''
;       text to store
;    _extra : in, optional, type=keywords
;       keywords to `MGtmNode::init`
;-
function mgtmtext::init, text=text, _extra=e
  compile_opt strictarr

  if (~self->mgtmnode::init(_strict_extra=e)) then return, 0

  self.text = ptr_new(n_elements(text) eq 0 ? '' : text)

  return, 1
end


;+
; Defines `MGtmText` which is a `MGtmNode` that contains text.
;
; :Fields:     
;    text 
;       pointer to `strarr`
;-
pro mgtmtext__define
  compile_opt strictarr

  define = { MGtmText, inherits MGtmNode, $
             text: ptr_new() $
           }
end
