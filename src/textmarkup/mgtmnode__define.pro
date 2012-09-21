; docformat = 'rst'

;+
; Base class for any objects in a text markup hierarchy, i.e., tags and text 
; objects.
;-


;+
; Interface that `MGtmTag` and `MGtmText` should implement. Helper routine for 
; debugging.
;
; :Abstract:
;
; :Keywords:
;    indent : in, optional, type=string
;       prefix to print before each line, usually set to several spaces
;-
pro mgtmnode::_print, indent=indent
  compile_opt strictarr
  
end


;+
; Get properties of the node.
;     
; :Keywords:
;    type : out, optional, type=string
;       type code of the node
;-
pro mgtmnode::getProperty, type=type
  compile_opt strictarr

  type = self.type
end


;+
; Free resources of node.
;-
pro mgtmnode::cleanup
  compile_opt strictarr
  
end


;+
; Implement cloning.
;
; :Returns:
;    `MGtmNode` object
;-
function mgtmnode::_clone
  compile_opt strictarr
  
  return, obj_new('MGtmNode', type=self.type)
end


;+
; Create a node in the markup tree.
;   
; :Returns: 
;    1 for success, 0 for failure
;
; :Keywords:
;    type : in, optional, type=string
;       type code indicating type of node
;-
function mgtmnode::init, type=type
  compile_opt strictarr

  self.type = n_elements(type) eq 0 ? '' : type

  return, 1
end


;+
; Node representing text or markup of some kind.
;     
; :Fields:
;    type 
;       type of node
;-
pro mgtmnode__define
  compile_opt strictarr

  define = { MGtmNode, type: '' }
end
