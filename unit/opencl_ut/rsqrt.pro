; docformat = 'rst'

function rsqrt, z
  compile_opt strictarr

  return, 1 / sqrt(z)
end
