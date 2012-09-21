; docformat = 'rst'

;+
; Set the value of a given atrribute for a given node in the graph.
;
; :Private:
;
; :Params:
;    node : in, required, type=object
;       object with a `setProperty` method
;    attrname : in, required, type=string
;       name of attribute (property) to set
;    attrvalue : in, required, type=any
;       value of attribute (property) to set
;-
pro vis_graph2dot_getattr, node, attrname, attrvalue
  compile_opt strictarr
  
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    help, error, attrname
    return
  endif
  
  case strlowcase(attrname) of
    'color': node->setProperty, color=attrvalue
    'name': node->setProperty, name=attrvalue
  endcase
end


;+
; Create a graph representation from a `.dot` file.

; The Graphviz website provides a formal specification of the 
; `dot language <http://www.graphviz.org/content/dot-language>`
;
; :Todo:
;    handle more node, edge, and graph attributes
;
; :Returns:
;    `IDL_Container` of objects with `CHILDREN` and `NAME` properties
;
; :Params:
;    filename : in, required, type=string
;       filename of `.dot` file to read
;
; :Keywords:
;    graph_class : in, optional, type=string, default=IDL_Container
;       classname for graph class
;    node_class : in, required, type=string
;       classname for nodes
;-
function vis_dot2graph, filename, $
                        graph_class=graph_class, $
                        node_class=node_class
  compile_opt strictarr
  
  ; TODO: implement
end


; main-level example program

if (~file_test('dependencies.dot')) then begin
  message, 'run vis_graph2dot first', /informational
endif else begin
  graph = vis_dot2graph('dependencies.dot', graph_class='IDL_Container', $
                        node_class='VIS_Graph_Democlass')
endelse

end
