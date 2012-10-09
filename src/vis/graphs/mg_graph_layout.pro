; docformat = 'rst'

;+
; Create a [graphs graph].
;
; :Returns:
;    IDLgrView
;
; :Params:
;    graph : in, required, type=object
;       IDL_Container containing the nodes of the graph; each node should have
;       two properties: `MG_NODE_NAME` (string) and `MG_NODE_CHILDREN` (array
;       object references to other nodes or -1L if no children)
;-
function mg_graph_layout, graph
  compile_opt strictarr

end