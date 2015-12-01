; docformat = 'rst'

function cbrt, z
  compile_opt strictarr

  return, z ^ (1./3.)
end
