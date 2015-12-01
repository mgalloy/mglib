; docformat = 'rst'

function expm1, z
  compile_opt strictarr

  return, exp(z) - 1
end
