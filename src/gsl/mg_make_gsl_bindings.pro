; docformat = 'rst'

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
  
  dlm->addInclude, ['gsl_math.h', 'gsl_sf_zeta.h', 'gsl_sf_ellint.h'], $
                   header_directory=_header_directory, $
                   lib_directory=_lib_directory, $
                   lib_files='gsl'
                   
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_sf_ellint_bindings.h', $
                                           root=mg_src_root())                   
  dlm->addRoutinesFromHeaderFile, filepath('mg_gsl_sf_zeta_bindings.h', $
                                           root=mg_src_root())
  
  dlm->addPoundDefineAccessor, 'M_EULER', type=5L
  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)
  
  obj_destroy, dlm
end

