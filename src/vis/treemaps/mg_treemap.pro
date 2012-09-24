; docformat = 'rst'

pro mg_treemap, items, vertices=vertices, polygons=polygons
  compile_opt strictarr
  
  algorithm = obj_new('MGgrSquarifiedTreemapLayout')
  algorithm->layout, items, obj_new('MGgrRect', x=0, y=0, height=1.0, width=1.0)
  
  allItems = items->get(/all)
  
  obj_destroy, algorithm
end


; main-level example program

end
