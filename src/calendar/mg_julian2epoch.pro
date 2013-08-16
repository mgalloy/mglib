; docformat = 'rst'

function mg_julian2epoch, jdates
  compile_opt strictarr

  return, (jdates - julday(1, 1, 1970, 0, 0, 0)) * (24. * 60. * 60.)
end
