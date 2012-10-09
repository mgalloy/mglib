function mg_loadct_ut::test1
  compile_opt strictarr

  mg_loadct, get_names=names, /silent
  assert, n_elements(names) eq 41, $
          'correct number of names in default color tables'
  mg_loadct, get_names=names, /brewer, /silent
  assert, n_elements(names) eq 35, $
          'correct number of names in brewer color tables'
  mg_loadct, get_names=names, /gist, /silent
  assert, n_elements(names) eq 7, $
          'correct number of names in gist color tables'
  mg_loadct, get_names=names, /mpl, silent
  assert, n_elements(names) eq 16, $
          'correct number of names in matplotlib color tables'

  return, 1
end


pro mg_loadct_ut__define
  compile_opt strictarr

  define = { mg_loadct_ut, inherits MGutLibTestCase }
end