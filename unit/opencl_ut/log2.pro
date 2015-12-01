; docformat = 'rst'

function log2, z
  compile_opt strictarr

  return, alog(z) / alog(fix(2, type=size(z, /type)))
end
