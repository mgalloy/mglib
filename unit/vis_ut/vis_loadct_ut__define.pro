function vis_loadct_ut::test1
  compile_opt strictarr

  vis_loadct, get_names=names, /silent
  assert, n_elements(names) eq 41, $
          'correct number of names in default color tables'
  vis_loadct, get_names=names, /brewer, /silent
  assert, n_elements(names) eq 35, $
          'correct number of names in brewer color tables'
  vis_loadct, get_names=names, /gist, /silent
  assert, n_elements(names) eq 7, $
          'correct number of names in gist color tables'
  vis_loadct, get_names=names, /mpl, silent
  assert, n_elements(names) eq 16, $
          'correct number of names in matplotlib color tables'
    
  return, 1
end


pro vis_loadct_ut__define
  compile_opt strictarr
  
  define = { vis_loadct_ut, inherits VISutTestCase }
end