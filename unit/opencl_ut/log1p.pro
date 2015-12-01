; docformat = 'rst'

function log1p, z
  compile_opt strictarr

  return, alog(z + fix(1, type=size(z, /type)))
end
