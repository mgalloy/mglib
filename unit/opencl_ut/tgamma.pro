; docformat = 'rst'

function tgamma, z
  compile_opt strictarr

  return, gamma(z)
end
