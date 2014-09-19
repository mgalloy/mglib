; docformat = 'rst'


;+
; Treemap item object.
;
; :Properties:
;   size
;     size of item
;   bounds
;     `MGgrRect` giving bounds
;   depth
;     depth of item
;   order
;     order of item
;-


;= property access

;+
; Get properties.
;-
pro mggrtreemapitem::getProperty, size=size, bounds=bounds, depth=depth, $
                                  order=order
  compile_opt strictarr

  if (arg_present(size)) then size = self.size
  if (arg_present(bounds)) then bounds = self.bounds
  if (arg_present(depth)) then depth = self.depth
  if (arg_present(order)) then order = self.order
end


;+
; Set properties.
;-
pro mggrtreemapitem::setProperty, size=size, bounds=bounds, depth=depth, $
                                  order=order
  compile_opt strictarr

  if (n_elements(size) gt 0L) then self.size = size
  if (n_elements(bounds) gt 0L) then self.bounds = bounds
  if (n_elements(depth) gt 0L) then self.depth = depth
  if (n_elements(order) gt 0L) then self.order = order
end


;= lifecycle methods

;+
; Free resources.
;-
pro mggrtreemapitem::cleanup
  compile_opt strictarr

  obj_destroy, self.bounds
end


;+
; Create treemap item object.
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mggrtreemapitem::init, size=size, bounds=bounds, $
                                depth=depth, order=order
  compile_opt strictarr

  return, 1
end


;+
; Define instance variables.
;-
pro mggrtreemapitem__define
  compile_opt strictarr

  define = { MGgrTreemapItem, $
             size: 0.0, $
             bounds: obj_new(), $
             depth: 0L, $
             order: 0L $
           }
end
