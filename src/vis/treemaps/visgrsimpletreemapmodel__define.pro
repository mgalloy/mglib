; docformat = 'rst'

pro visgrsimpletreemapmodel::getProperty, items=items, bounds=bounds
  compile_opt strictarr

  if (arg_present(items)) then items = self.items
  if (arg_present(bounds)) then bounds = self.bounds  
end


pro visgrsimpletreemapmodel::setProperty, items=items, bounds=bounds
  compile_opt strictarr
  
  if (n_elements(items) gt 0L) then self.items = items
  if (n_elements(bounds) gt 0L) then self.bounds = bounds
end


pro visgrsimpletreemapmodel::cleanup
  compile_opt strictarr
  
  obj_destroy, [self.items, self.bounds]
end


function visgrsimpletreemapmodel::init, items=items, bounds=bounds
  compile_opt strictarr

  self.items = n_elements(items) eq 0L ? obj_new() : items
  self.bounds = n_elements(bounds) eq 0L ? obj_new() : bounds
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    items
;       IDL_Container of TreemapItems
;    bounds
;       Rect of bounds
;-
pro visgrsimpletreemapmodel__define
  compile_opt strictarr
  
  define = { VISgrSimpleTreemapModel, $
             items: obj_new(), $
             bounds: obj_new() $
           }
end