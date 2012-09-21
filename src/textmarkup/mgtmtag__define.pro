; docformat = 'rst'


;+
; Helper routine for debugging.
;
; :Keywords:
;    indent : in, optional, type=string
;       prefix to print before each line, usually set to several spaces
;-
pro mgtmtag::_print, indent=indent
  compile_opt strictarr
  
  _indent = n_elements(indent) eq 0L ? '' : indent
  
  attrnames = self.attributes->keys(count=nattrs)
  attrvalues = self.attributes->values()
  attrs = nattrs gt 0L ? strjoin(attrnames + '=' + attrvalues, ', ') : ''
  print, _indent, self.type, attrs, format='(%"%s+ %s: %s")'
  
  for c = 0L, self.children->count() - 1L do begin
    child = self.children->get(position=c)
    child->_print, indent=_indent + '  '
  endfor
end


;+
; Get properties of the text node.
; 
; :Keywords:
;    n_children : out, optional, type=long
;       number of children of the node
;    n_attributes : out, optional, type=long
;       number of attributes of the node
;    attribute_names : out, optional, type=strarr
;       names of the attributes of this node
;    _ref_extra : out, optional, type=keywords
;       keywords to `MGtmNode::getProperty`
;-
pro mgtmtag::getProperty, n_children=nChildren, n_attributes=nattributes, $
                          attribute_names=attributeNames, _ref_extra=e
  compile_opt strictarr

  if (arg_present(nchildren)) then nChildren = self.children->count()
  if (arg_present(nattributes)) then nattributes = self.attributes->count()
  if (arg_present(attributeNames)) then attributeNames = self.attributes->keys()
  
  if (n_elements(e) gt 0) then begin
    self->mgtmnode::getProperty, _strict_extra=e
  endif
end


;+
; Get child at pos of the node.
;     
; :Returns: 
;    `MGtmNode`
;
; :Params:
;    pos : in, required, type=long
;       position of the child to get
;
; :Keywords:
;    last : in, optional, type=boolean
;       set to get the last child
;-
function mgtmtag::getChild, pos, last=last
  compile_opt strictarr

  if (keyword_set(last)) then begin
    return, self.children->get(position=self.children->count() - 1L)
  endif
  
  return, self.children->get(position=pos)
end


;+
; Add a child to the node.
;     
; :Params:
;    child : in, required, type=objref
;       `MGtmNode` object to add as a child
;       
; :Keywords:
;    position : in, optional, type=long
;       position to add child at, default to end of children      
;-
pro mgtmtag::addChild, child, position=position
  compile_opt strictarr

  self.children->add, child, position=position
end


;+
; Indicates if this tag has any children.
; 
; :Returns:
;    1 if no children, 0 if has children
;-
function mgtmtag::isEmpty
  compile_opt strictarr
  
  return, self.children->count() eq 0
end


;+
; Remove a child from the node.
;     
; :Params:
;    pos : in, required, type=long
;       position of child to remove
;
; :Keywords:
;    last : in, optional, type=boolean
;       set to remove the last child
;-
pro mgtmtag::removeChild, pos, last=last
  compile_opt strictarr

  _pos =  keyword_set(last) ? (self.children->count() - 1L) : pos
  self.children->remove, position=_pos
end


;+
; Get the value of an attribute.
;
; :Returns:
;    attribute value
;
; :Params:
;    name : in, required, type=string
;       name of attribute
;
; :Keywords:
;    found : out, required, type=boolean
;       set to a named variable to get whether the attribute name is found
;-
function mgtmtag::getAttribute, name, found=found
  compile_opt strictarr
  
  return, self.attributes->get(name, found=found)
end


;+
; Add an attribute to the tag.
;     
; :Params:
;    name : in, required, type=string
;       name of the attribute
;    value : in, required, type=string
;       value of the attribute
;-
pro mgtmtag::addAttribute, name, value
  compile_opt strictarr

  self.attributes->put, name, value
end


;+
; Implement cloning.
;
; :Returns:
;    `MGtmNode` object
;-
function mgtmtag::_clone
  compile_opt strictarr
  
  tag = obj_new('MGtmTag', type=self.type)
  
  for c = 0L, self.children->count() - 1L do begin
    child = self.children->get(position=c)
    tag->addChild, child->_clone()
  endfor
  
  keys = self.attributes->keys(count=nkeys)
  for k = 0L, nkeys - 1L do begin
    tag->addAttribute, keys[k], self.attributes->get(keys[k])
  endfor
  
  return, tag
end


;+
; Free resources.
;-
pro mgtmtag::cleanup
  compile_opt strictarr

  obj_destroy, [self.children, self.attributes]
end


;+
; Create a markup tag node.
;
; :Returns: 
;    1 for success, 0 for otherwise
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to `MGtmNode::init`
;-
function mgtmtag::init, _extra=e
  compile_opt strictarr

  if (~self->mgtmnode::init(_strict_extra=e)) then return, 0

  ; initialize children array list
  self.children = obj_new('MGcoArrayList', type=11, block_size=8)  
  self.attributes = obj_new('MGcoHashTable', key_type=7, value_type=7, $
                            array_size=8)

  return, 1
end


;+
; Define a tag node.
;     
; :Fields:
;    attributes 
;       attributes of the tag
;    children 
;       array list of the children
;-
pro mgtmtag__define
  compile_opt strictarr

  define = { MGtmTag, inherits MGtmNode, $
             attributes: obj_new(), $
             children: obj_new() $
           }
end

