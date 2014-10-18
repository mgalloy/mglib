; docformat = 'rst'

; define empty setup/teardown because IDL initializes a GRIB system that would
; be detected as a memory leak by mgunit

pro mg_grib_list_ut::setup
  compile_opt strictarr
end


pro mg_grib_list_ut::teardown
  compile_opt strictarr
end


function mg_grib_list_ut::test_sample
  compile_opt strictarr

  filename = filepath('atl.grb2', root=mg_src_root())

  for r = 1, grib_count(filename) do begin
    grib_list, filename, r, output=output
    keys = mg_grib_list(filename, record=r, count=count)
    assert, array_equal(output[1, *], keys), $
            'incorrect keys for record %d', r
    assert, count eq n_elements(output[1, *]), $
            'incorrect number of keys for record %d: %d', r, count
  endfor

  return, 1
end


function mg_grib_list_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_grib_list', /is_function

  return, 1
end


pro mg_grib_list_ut__define
  compile_opt strictarr

  define = { mg_grib_list_ut, inherits MGutLibTestCase }
end
