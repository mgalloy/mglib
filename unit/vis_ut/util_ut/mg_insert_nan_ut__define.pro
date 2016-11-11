function mg_insert_nan_ut::test_basic
  compile_opt strictarr

  x = findgen(5)
  y = 2.0 * findgen(5)
  new_y = mg_insert_nan(x, y, [0.5, 3.5], new_x=new_x, locations=locs)
  standard_x = [0.0, 0.5, 1.0, 2.0, 3.0, 3.5, 4.0]
  standard_y = [0.0, !values.f_nan, 2.0, 4.0, 6.0, !values.f_nan, 8.0]

  assert, array_equal(new_x, standard_x), 'incorrect x-values'
  finite_ind = where(finite(standard_y), n_finite, complement=nan_ind, ncomplement=n_nan)
  assert, array_equal(new_y[finite_ind], standard_y[finite_ind]), 'incorrect y-values'
  !null = where(~finite(new_y), n_new_nan)
  assert, n_new_nan eq n_nan, 'incorrect number of NaNs inserted into y-values: %d', n_new_nan

  return, 1
end


function mg_insert_nan_ut::test_double
  compile_opt strictarr

  x = findgen(5)
  y = 2.0 * findgen(5)
  new_y = mg_insert_nan(x, y, [0.5, 0.75], new_x=new_x, locations=locs)
  standard_x = [0.0, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0]
  standard_y = [0.0, !values.f_nan, !values.f_nan, 2.0, 4.0, 6.0, 8.0]

  assert, array_equal(new_x, standard_x), 'incorrect x-values'
  finite_ind = where(finite(standard_y), n_finite, complement=nan_ind, ncomplement=n_nan)
  assert, array_equal(new_y[finite_ind], standard_y[finite_ind]), 'incorrect y-values'
  !null = where(~finite(new_y), n_new_nan)
  assert, n_new_nan eq n_nan, 'incorrect number of NaNs inserted into y-values: %d', n_new_nan

  return, 1
end


function mg_insert_nan_ut::test_ends
  compile_opt strictarr

  x = findgen(5)
  y = 2.0 * findgen(5)
  new_y = mg_insert_nan(x, y, [-0.5, 4.5], new_x=new_x, locations=locs)
  standard_x = [-0.5, 0.0, 1.0, 2.0, 3.0, 4.0, 4.5]
  standard_y = [!values.f_nan, 0.0, 2.0, 4.0, 6.0, 8.0, !values.f_nan]

  assert, array_equal(new_x, standard_x), 'incorrect x-values'
  finite_ind = where(finite(standard_y), n_finite, complement=nan_ind, ncomplement=n_nan)
  assert, array_equal(new_y[finite_ind], standard_y[finite_ind]), 'incorrect y-values'
  !null = where(~finite(new_y), n_new_nan)
  assert, n_new_nan eq n_nan, 'incorrect number of NaNs inserted into y-values: %d', n_new_nan

  return, 1
end


function mg_insert_nan_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mg_insert_nan'], $
                           /is_function

  return, 1
end


pro mg_insert_nan_ut__define
  compile_opt strictarr

  define = { mg_insert_nan_ut, inherits MGutLibTestCase }
end
