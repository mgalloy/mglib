; docformat = 'rst'


pro mggrtreemapmodel::cleanup
  compile_opt strictarr

  self->mggrsimpletreemapmodel::cleanup
end


function mggrtreemapmodel::init, _extra=e
  compile_opt strictarr

  if (~self->mggrsimpletreemapmodel::init(_extra=e)) then return, 0

  return, 1
end


pro mggrtreemapmodel__define
  compile_opt strictarr

  define = { MGgrTreemapModel, inherits MGgrSimpleTreemapModel }
end