; docformat = 'rst'


;= lifecycle methods

;+
; Free resources.
;-
pro mggrtreemapmodel::cleanup
  compile_opt strictarr

  self->mggrsimpletreemapmodel::cleanup
end


;+
; Create treemap model object.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords;
;     keywords to `MGgrSimpleTreeMapModel::init`
;-
function mggrtreemapmodel::init, _extra=e
  compile_opt strictarr

  if (~self->mggrsimpletreemapmodel::init(_extra=e)) then return, 0

  return, 1
end


;+
; Define instance variables.
;-
pro mggrtreemapmodel__define
  compile_opt strictarr

  define = { MGgrTreemapModel, inherits MGgrSimpleTreemapModel }
end
