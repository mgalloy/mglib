; docformat = 'rst'


;+
; Get the value of a given atrribute for a given node in the graph.
;
; :Private:
;
; :Returns:
;    color name as string
;
; :Params:
;    node : in, required, type=object
;       object with a `getProperty` method
;    attrname : in, required, type=string
;       name of attribute (property) to retrieve
;-
function mg_graph2dot_getattr, node, attrname
  compile_opt strictarr
  
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, !null
  endif
  
  case strlowcase(attrname) of
    'color': node->getProperty, color=attrvalue
    'name': node->getProperty, name=attrvalue
  endcase
  
  return, attrvalue
end


;+
; Writes a Graphviz `.dot` file representing a graph.
;
; The Graphviz website provides a formal specification of the 
; `dot language <http://www.graphviz.org/content/dot-language>`
;
; :Todo:
;    handle more node, edge, and graph attributes
;
; :Params:
;    filename : in, required, type=string
;       filename of `.dot` file to write
;    graph : in, required, type=IDL_Container
;       `IDL_Container` of objects with `CHILDREN` and `NAME` properties
;-
pro mg_graph2dot, filename, graph
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    if (n_elements(lun) gt 0L) then free_lun, lun
    return
  endif
  
  openw, lun, filename, /get_lun
  
  graph_name = mg_graph2dot_getattr(graph, 'name')
  printf, lun, n_elements(graph_name) eq 0L ? '' : (graph_name + ' '), $
          format='(%"strict digraph %s{")'

  for n = 0L, graph->count() - 1L do begin
    node = graph->get(position=n)
    node->getProperty, name=node_name
    
    attrstr = ' '
    
    ; we only check for COLOR, but there are actually a lot of possible 
    ; attributes: http://www.graphviz.org/doc/info/attrs.html
    color = mg_graph2dot_getattr(node, 'color')
    if (n_elements(color) gt 0L) then begin
      if (size(color, /type) eq 7L) then begin
        if (color ne '') then begin
          attrstr = string(color, format='(%" [color=%s]")')
        endif
      endif else begin
        message, 'unknown COLOR property type'
      endelse
    endif

    printf, lun, node_name, attrstr eq ' ' ? '' : attrstr, format='(%"  %s%s;")'    
  endfor
  
  for n = 0L, graph->count() - 1L do begin
    node = graph->get(position=n)
    node->getProperty, name=node_name, children=children
    for c = 0L, n_elements(children) - 1L do begin
      (children[c])->getProperty, name=child_name
      printf, lun, node_name, child_name, format='(%"  %s -> %s;")'
    endfor
  endfor
  
  printf, lun, format='(%"}")'
  free_lun, lun
end

; main-level example program

; strict digraph  {
;   WeightInPlanet   [color=red];
;   planetprop   [color=green];
;   WeightInPlanet -> planetprop   [color=blue];
;   calculate_g  [color=green];
;   WeightInPlanet -> calculate_g  [color=blue];
;   isstruct   [color=green];
;   calculate_g -> isstruct  [color=blue];
;   calculate_g -> planetprop  [color=blue];
; }

; create nodes
weightInPlanetNode = obj_new('MG_Graph_Democlass', $
                             name='WeightInPlanet', color='red')
planetpropNode = obj_new('MG_Graph_Democlass', $
                         name='planetprop', color='green')
calculate_gNode = obj_new('MG_Graph_Democlass', $
                          name='calculate_g', color='green')
isstructNode = obj_new('MG_Graph_Democlass', $
                       name='isstruct', color='green')

; create edges
weightInPlanetNode->addChild, planetpropNode
weightInPlanetNode->addChild, calculate_gNode
calculate_gNode->addChild, isstructNode
calculate_gNode->addChild, planetPropNode

; create graph
graph = obj_new('IDL_Container')
graph->add, [weightInPlanetNode, planetpropNode, $
             calculate_gNode, isstructNode]


mg_graph2dot, 'dependencies.dot', graph

end

