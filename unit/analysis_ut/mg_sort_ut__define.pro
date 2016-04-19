function mg_sort_ut::test_basic
  compile_opt strictarr

  n = 10L
  x = [findgen(n), fltarr(10) + n - 1., findgen(n) + n]
  result = mg_sort(x)
  standard = lindgen(3 * n)

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sort_ut::test_2keys
  compile_opt strictarr

  data = [{x: 1, name: 'Mike'}, $
          {x: 2, name: 'George'}, $
          {x: 2, name: 'Bill'}, $
          {x: 4, name: 'Henry'}]

  result = mg_sort(data.x, data.name)
  standard = [0, 2, 1, 3]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sort_ut::test_3keys
  compile_opt strictarr

  data = [{x: 1, y: 0, name: 'Mike'}, $
          {x: 2, y: 2, name: 'George'}, $
          {x: 2, y: 3, name: 'Bill'}, $
          {x: 2, y: 2, name: 'Bob'}, $
          {x: 4, y: 1, name: 'Henry'}]

  result = mg_sort(data.x, data.y, data.name)
  standard = [0, 3, 1, 2, 4]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sort_ut::test_stable
  compile_opt strictarr

  x = [1, 2, 3, 2, 4, 0, 1]
  result = mg_sort(x)
  standard = [5, 0, 6, 1, 3, 2, 4]

  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function mg_sort_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_sort', /is_function

  return, 1
end


pro mg_sort_ut__define
  compile_opt strictarr

  define = { mg_sort_ut, inherits MGutLibTestCase }
end
