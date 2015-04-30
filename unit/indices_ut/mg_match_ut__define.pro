; docformat = 'rst'

function mg_match_ut::test_basic
  compile_opt strictarr

  a = [0, 1, 3, 4, 5]
  b = [3, 5, 6, 7, 0, 2]

  standard_n_matches = 3L

  a_matches = mg_match(a, b, $
                       b_matches=b_matches, $
                       n_matches=n_matches)

  assert, n_matches eq standard_n_matches, $
          'incorrect number of matches %d (correct is %d)', $
          n_matches, standard_n_matches

  for m = 0L, n_matches - 1L do begin
    assert, a[a_matches[m]] eq b[b_matches[m]], $
            'match %d not equal, a[%d] = %d, but b[%d] = %d', $
            m, a_matches[m], a[a_matches[m]], b_matches[m], b[b_matches[m]]
  endfor

  return, 1
end


function mg_match_ut::test_single
  compile_opt strictarr

  a = [0]
  b = [3, 5, 6, 7, 0, 2]

  standard_n_matches = 1L

  a_matches = mg_match(a, b, $
                       b_matches=b_matches, $
                       n_matches=n_matches)

  assert, n_matches eq standard_n_matches, $
          'incorrect number of matches %d (correct is %d)', $
          n_matches, standard_n_matches

  for m = 0L, n_matches - 1L do begin
    assert, a[a_matches[m]] eq b[b_matches[m]], $
            'match %d not equal, a[%d] = %d, but b[%d] = %d', $
            m, a_matches[m], a[a_matches[m]], b_matches[m], b[b_matches[m]]
  endfor

  return, 1
end


function mg_match_ut::test_nomatches
  compile_opt strictarr

  a = [1]
  b = [3, 5, 6, 7, 0, 2]

  standard_n_matches = 0L

  a_matches = mg_match(a, b, $
                       b_matches=b_matches, $
                       n_matches=n_matches)

  assert, n_matches eq standard_n_matches, $
          'incorrect number of matches %d (correct is %d)', $
          n_matches, standard_n_matches

  for m = 0L, n_matches - 1L do begin
    assert, a[a_matches[m]] eq b[b_matches[m]], $
            'match %d not equal, a[%d] = %d, but b[%d] = %d', $
            m, a_matches[m], a[a_matches[m]], b_matches[m], b[b_matches[m]]
  endfor

  return, 1
end


function mg_match_ut::test_strings
  compile_opt strictarr

  a = ['boulder', 'denver', 'fort collins', 'colorado springs']
  b = ['denver', 'san francisco']

  standard_n_matches = 1L

  a_matches = mg_match(a, b, $
                       b_matches=b_matches, $
                       n_matches=n_matches)

  assert, n_matches eq standard_n_matches, $
          'incorrect number of matches %d (correct is %d)', $
          n_matches, standard_n_matches

  for m = 0L, n_matches - 1L do begin
    assert, a[a_matches[m]] eq b[b_matches[m]], $
            'match %d not equal, a[%d] = %d, but b[%d] = %d', $
            m, a_matches[m], a[a_matches[m]], b_matches[m], b[b_matches[m]]
  endfor

  return, 1
end


function mg_match_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_match', /is_function

  return, 1
end


pro mg_match_ut__define
  compile_opt strictarr

  define = { mg_match_ut, inherits MGutLibTestCase }
end