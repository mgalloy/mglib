function mg_merge_arrays_ut::test_overlap
  compile_opt strictarr

  x = [0.0, 1.0, 2.0, 3.0]
  y = [0.5, 1.5, 2.5, 3.5]
  standard = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]

  result = mg_merge_arrays(x, y, indices=indices)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_merge_arrays_ut::test_disjoint
  compile_opt strictarr

  x = [0.0, 1.0, 2.0, 3.0]
  y = [4.0, 5.0, 6.0, 7.0]
  standard = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]

  result = mg_merge_arrays(x, y, indices=indices)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_merge_arrays_ut::test_duplicate
  compile_opt strictarr

  x = [0.0, 1.0, 2.0, 3.0]
  y = [2.0, 3.0, 4.0, 5.0]
  standard = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]

  result = mg_merge_arrays(x, y, indices=indices)
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


pro mg_merge_arrays_ut__define
  compile_opt strictarr

  define = { mg_merge_arrays_ut, inherits MGutLibTestCase }
end
