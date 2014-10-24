; docformat = 'rst'

pro mg_nc_list_ut::check_results, filename, path, $
                                  standard, $
                                  attributes=attributes, $
                                  groups=groups, $
                                  variables=variables
  compile_opt strictarr

  result = mg_nc_list(filename, path, $
                      attributes=attributes, $
                      groups=groups, $
                      variables=variables, $
                      count=n, $
                      error=error)
  case 1B of
    keyword_set(attributes): type = 'attributes'
    keyword_set(groups): type = 'groups'
    keyword_set(variables): type = 'variables'
    else: assert, 0, 'ATTRIBUTES, GROUPS, or VARIABLES not set'
  endcase

  assert, error eq 0L, 'MG_NC_LIST error = %d', error

  assert, n eq n_elements(standard), 'incorrect number of %s in %s: %d', $
          type, path, n
  if (n_elements(standard) gt 0L and n gt 0L) then begin
    assert, array_equal(result, standard), $
            'incorrect %s names in %path: %s', $
            type, $
            path, $
            n_elements(result) eq 0L $
              ? '!null' $
              : strjoin(strtrim(result, 2), ', ')
  endif
end


function mg_nc_list_ut::test_sample
  compile_opt strictarr

  filename = file_which('sample.nc')

  self->check_results, filename, '/', ['TITLE', 'GALAXY', 'PLANET'], /attributes
  self->check_results, filename, '/', !null, /groups
  self->check_results, filename, '/', ['image'], /variables

  self->check_results, filename, 'image', ['TITLE'], /attributes
  self->check_results, filename, 'image', !null, /groups
  self->check_results, filename, 'image', !null, /variables

  return, 1
end


function mg_nc_list_ut::test_group
  compile_opt strictarr

  filename = file_which('ncgroup.nc')

  self->check_results, filename, '/', !null, /attributes
  self->check_results, filename, '/', ['Submarine'], /groups
  self->check_results, filename, '/', !null, /variables

  self->check_results, filename, '/Submarine', !null, /attributes
  self->check_results, filename, '/Submarine', ['Diesel_Electric', 'Nuclear'], /groups
  self->check_results, filename, '/Submarine', !null, /variables

  self->check_results, filename, '/Submarine/Diesel_Electric', !null, /attributes
  self->check_results, filename, '/Submarine/Diesel_Electric', !null, /groups
  self->check_results, filename, '/Submarine/Diesel_Electric', ['Sub Depth'], /variables

  self->check_results, filename, '/Submarine/Diesel_Electric/Sub Depth', !null, /attributes
  self->check_results, filename, '/Submarine/Diesel_Electric/Sub Depth', !null, /groups
  self->check_results, filename, '/Submarine/Diesel_Electric/Sub Depth', !null, /variables

  self->check_results, filename, '/Submarine/Nuclear', !null, /attributes
  self->check_results, filename, '/Submarine/Nuclear', ['Attack', 'Missile'], /groups
  self->check_results, filename, '/Submarine/Nuclear', !null, /variables

  self->check_results, filename, '/Submarine/Nuclear/Attack', !null, /attributes
  self->check_results, filename, '/Submarine/Nuclear/Attack', !null, /groups
  self->check_results, filename, '/Submarine/Nuclear/Attack', ['Sub Depth'], /variables

  self->check_results, filename, '/Submarine/Nuclear/Attack/Sub Depth', !null, /attributes
  self->check_results, filename, '/Submarine/Nuclear/Attack/Sub Depth', !null, /groups
  self->check_results, filename, '/Submarine/Nuclear/Attack/Sub Depth', !null, /variables

  self->check_results, filename, '/Submarine/Nuclear/Missile', !null, /attributes
  self->check_results, filename, '/Submarine/Nuclear/Missile', !null, /groups
  self->check_results, filename, '/Submarine/Nuclear/Missile', ['Sub Depth'], /variables

  self->check_results, filename, '/Submarine/Nuclear/Missile/Sub Depth', !null, /attributes
  self->check_results, filename, '/Submarine/Nuclear/Missile/Sub Depth', !null, /groups
  self->check_results, filename, '/Submarine/Nuclear/Missile/Sub Depth', !null, /variables

  return, 1
end


function mg_nc_list_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_nc_list', /is_function

  return, 1
end


pro mg_nc_list_ut__define
  compile_opt strictarr

  define = { mg_nc_list_ut, inherits MGutLibTestCase }
end
