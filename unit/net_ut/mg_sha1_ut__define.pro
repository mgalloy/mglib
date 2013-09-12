function mg_sha1_ut::test_empty
  compile_opt strictarr

  result = mg_sha1('')
  assert, result eq 'da39a3ee5e6b4b0d3255bfef95601890afd80709', $
          'incorrect result: %s', result

  return, 1
end

 

function mg_sha1_ut::test_string1
  compile_opt strictarr

  result = mg_sha1('The quick brown fox jumps over the lazy dog')
  assert, result eq '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12', $
          'incorrect result: %s', result

  return, 1
end


function mg_sha1_ut::test_string2
  compile_opt strictarr

  result = mg_sha1('The quick brown fox jumps over the lazy cog')
  assert, result eq 'de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3', $
          'incorrect result: %s', result

  return, 1
end


function mg_sha1_ut::test_file
  compile_opt strictarr

  result = mg_sha1(filepath('sha1.txt', root=mg_src_root()))
  assert, result eq '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12', $
          'incorrect result: %s', result

  return, 1
end


pro mg_sha1_ut__define
  compile_opt strictarr

  define = { mg_sha1_ut, inherits MGutLibTestCase }
end
