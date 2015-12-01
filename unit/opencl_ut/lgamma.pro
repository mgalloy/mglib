; docformat = 'rst'

function lgamma, z
  compile_opt strictarr

  return, lngamma(z)
end
