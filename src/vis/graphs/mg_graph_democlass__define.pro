; docformat = 'rst'

;+
; Example class for creating a graph.
;
; :Properties:
;   name
;     graph name
;   children
;     array of child nodes
;   color
;     graph color
;-

;+
; Add a child node.
;
; :Params:
;   node : in, required, type=`MG_GRAPH_DEMOCLASS` object
;     child node
;-
pro mg_graph_democlass::addChild, node
  compile_opt strictarr

  self.children->add, node
end

;= property access

;+
; Get properties.
;-
pro mg_graph_democlass::getProperty, name=name, $
                                     children=children, $
                                     color=color
  compile_opt strictarr

  if (arg_present(name)) then name = self.name
  if (arg_present(children)) then begin
    if (self.children->count() gt 0L) then begin
      children = self.children->get(/all)
    endif else children = !null
  end
  if (arg_present(color)) then color = self.color
end


;+
; Set properties.
;-
pro mg_graph_democlass::setProperty, name=name, color=color
  compile_opt strictarr

  if (n_elements(name) gt 0L) then self.name = name
  if (n_elements(color) gt 0L) then self.color = color
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_graph_democlass::cleanup
  compile_opt strictarr

  obj_destroy, self.children
end


;+
; Create graph demo class.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     properties
;-
function mg_graph_democlass::init, _extra=e
  compile_opt strictarr

  self.children = obj_new('IDL_Container')

  self->setProperty, _extra=e

  return, 1
end


;+
; Define instance variables.
;-
pro mg_graph_democlass__define
  compile_opt strictarr

  define = { MG_Graph_DemoClass, $
             inherits IDL_Object, $
             children: obj_new(), $
             name: '', $
             color: '' $
           }
end
