; docformat = 'rst'

;+
; Simple tree map model.
;
; :Properties:
;   items
;     list of `MGgrRect` items
;   bounds
;     `MGgrRect` representing bounds
;-


;= property access

;+
; Get properties.
;-
pro mggrsimpletreemapmodel::getProperty, items=items, bounds=bounds
  compile_opt strictarr

  if (arg_present(items)) then items = self.items
  if (arg_present(bounds)) then bounds = self.bounds
end


;+
; Set properties.
;-
pro mggrsimpletreemapmodel::setProperty, items=items, bounds=bounds
  compile_opt strictarr

  if (n_elements(items) gt 0L) then self.items = items
  if (n_elements(bounds) gt 0L) then self.bounds = bounds
end


;= lifecycle methods

;+
; Free resources.
;-
pro mggrsimpletreemapmodel::cleanup
  compile_opt strictarr

  obj_destroy, [self.items, self.bounds]
end


;+
; Create simple treemap model.
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mggrsimpletreemapmodel::init, items=items, bounds=bounds
  compile_opt strictarr

  self.items = n_elements(items) eq 0L ? obj_new() : items
  self.bounds = n_elements(bounds) eq 0L ? obj_new() : bounds

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   items
;     `IDL_Container` of TreemapItems
;   bounds
;     Rect of bounds
;-
pro mggrsimpletreemapmodel__define
  compile_opt strictarr

  define = { MGgrSimpleTreemapModel, $
             items: obj_new(), $
             bounds: obj_new() $
           }
end
