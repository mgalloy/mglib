; docformat = 'rst'


pro visgrtreemapmodel::cleanup
  compile_opt strictarr
  
  self->visgrsimpletreemapmodel::cleanup
end


function visgrtreemapmodel::init, _extra=e
  compile_opt strictarr

  if (~self->visgrsimpletreemapmodel::init(_extra=e)) then return, 0
  
  return, 1
end


pro visgrtreemapmodel__define
  compile_opt strictarr
  
  define = { VISgrTreemapModel, inherits VISgrSimpleTreemapModel }
end