; docformat = 'rst'

pro mg_make_gsl_bindings
  compile_opt strictarr
  
  dlm = mg_dlm(basename='idlgsl', $
               name='IDLGSL', $
               description='IDL bindings for GSL', $
               version='1.0', $
               source='Michael Galloy')
  
  dlm->addInclude, ['gsl_math.h', 'gsl_sf_zeta.h', 'gsl_sf_ellint.h'], $
                   header_directory='/usr/local/include/gsl', $
                   lib_directory='/usr/local/lib', $
                   lib_files='gsl'
                   
  dlm->addRoutinesFromHeaderFile, filepath('idlgsl_gsl_sf_ellint_bindings.h', root=mg_src_root())                   
  dlm->addRoutinesFromHeaderFile, filepath('idlgsl_gsl_sf_zeta_bindings.h', root=mg_src_root())
  
  dlm->addPoundDefineAccessor, 'M_EULER', type=5L
  dlm->write
  dlm->build, /show_all_output
  
  obj_destroy, dlm
end

