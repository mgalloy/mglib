; docformat = 'rst'

function logb, z
  compile_opt strictarr

  return, fix(floor(log2(z)), type=size(z, /type))
end
