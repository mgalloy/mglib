; docformat = 'rst'

;+
; Make GSL bindings.
;
; :Keywords:
;   header_directory : in, optional, type=string
;     directory containing GSL include files
;   lib_directory : in, optional, type=string
;     directory containing GSL library files
;   show_all_output : in, optional, type=boolean
;     set to show all build output
;-
pro mg_make_gsl_bindings, header_directory=header_directory, $
                          lib_directory=lib_directory, $
                          show_all_output=show_all_output
  compile_opt strictarr

  _header_directory = n_elements(header_directory) eq 0L $
                        ? '/usr/local/include/gsl' $
                        : header_directory
  _lib_directory = n_elements(lib_directory) eq 0L $
                     ? '/usr/local/lib' $
                     : lib_directory
  dlm = mg_dlm(basename='mg_gsl', $
               prefix='MG_', $
               name='mg_gsl', $
               description='IDL bindings for GSL', $
               version='1.0', $
               source='Michael Galloy')

  dlm->addInclude, ['gsl/gsl_math.h', $
                    'gsl/gsl_sf_zeta.h', $
                    'gsl/gsl_sf_ellint.h', $
                    'gsl/gsl_rng.h', $
                    'gsl/gsl_randist.h'], $
                   header_directory=_header_directory
  dlm->addLibrary, 'libgsl.a', $
                   lib_directory=_lib_directory, $
                   /static
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_sf_ellint_bindings.h', $
                                           root=mg_src_root())
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_sf_zeta_bindings.h', $
                                           root=mg_src_root())
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_rng_bindings.h', $
                                           root=mg_src_root())
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_randist_bindings.h', $
                                           root=mg_src_root())

  dlm->addVariableAccessor, 'M_EULER', type=5L

  dlm->addRoutineFromFile, filepath('mg_gsl_randomu.c', root=mg_src_root()), $
                           name='mg_gsl_randomu', $
                           /is_function, $
                           has_keywords=0B, $
                           n_parameters=[2, 9], $
                           cprefix='IDL'
  
  filename = filepath('gsl_rng_types.txt', root=mg_src_root())
  rng_types = strarr(file_lines(filename))
  openr, lun, filename, /get_lun
  readf, lun, rng_types
  free_lun, lun

  foreach t, rng_types do dlm->addVariableAccessor, t, type=14L

  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)

  obj_destroy, dlm
end

