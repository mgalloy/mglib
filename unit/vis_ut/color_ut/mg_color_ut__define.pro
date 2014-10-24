function mg_color_ut::test_index
  compile_opt strictarr

  black = mg_color('black', /index)
  assert, black eq '000000'x, 'black color value not correct'

  salmon = mg_color('salmon', /index)
  assert, salmon eq '7280fa'x, 'salmon color value not correct'

  return, 1
end


function mg_color_ut::test_basic
  compile_opt strictarr

  black = mg_color('black')
  assert, array_equal(black, [0B, 0B, 0B], /no_typeconv), $
          'black color value not correct'

  salmon = mg_color('salmon')
  assert, array_equal(salmon, [250B, 128B, 114B], /no_typeconv), $
          'salmon color value not correct'

  return, 1
end


function mg_color_ut::test_dimensions
  compile_opt strictarr

  black = mg_color('black', /index)
  assert, size(black, /n_dimensions) eq 0L, 'should be scalar'

  red = mg_color('red')
  assert, size(red, /n_dimensions) eq 1, 'should be 1-dimensional'
  assert, array_equal(size(red, /dimensions), [3L]), $
          'should be 3 elements'

  colors = mg_color(['red', 'green'])
  assert, size(colors, /n_dimensions) eq 2, 'should be 2-dimensional'
  assert, array_equal(size(colors, /dimensions), [2L, 3L]), $
          'should be 2 by 3'

  return, 1
end


function mg_color_ut::test_names
  compile_opt strictarr

  names = mg_color(/names)

  assert, size(names, /type) eq 7, 'incorrect type for string names'
  assert, n_elements(names) eq 147, 'incorrect number of colors'

  assert, names[0] eq 'aliceblue', $
          'incorrect value for aliceblue, names[0]'
  assert, names[146] eq 'yellowgreen', $
          'incorrect value for yellowgreen, names[146]'

  return, 1
end


function mg_color_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_color', /is_function

  return, 1
end


pro mg_color_ut__define
  compile_opt strictarr

  define = { mg_color_ut, inherits MGutLibTestCase }
end
