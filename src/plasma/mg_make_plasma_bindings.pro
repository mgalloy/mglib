; docformat = 'rst'

;+
; Make Plasma bindings.
;
; :Keywords:
;   header_directory : in, optional, type=string
;     directory containing Plasma include files
;   lib_directory : in, optional, type=string
;     directory containing Plasma library files
;   show_all_output : in, optional, type=boolean
;     set to show all build output
;-
pro mg_make_plasma_bindings, header_directory=header_directory, $
                             lib_directory=lib_directory, $
                             show_all_output=show_all_output
  compile_opt strictarr

  _header_directory = n_elements(header_directory) eq 0L $
                        ? '/usr/local/include/plasma' $
                        : header_directory
  _lib_directory = n_elements(lib_directory) eq 0L $
                     ? '/usr/local/lib' $
                     : lib_directory
  dlm = mg_dlm(basename='mg_plasma', $
               prefix='MG_', $
               name='mg_plasma', $
               description='IDL bindings for Plasma', $
               version='1.0', $
               source='Michael Galloy')

  dlm->addInclude, ['plasma.h', $
                    'plasma_s.h', $
                    'plasma_d.h', $
                    'plasma_ds.h', $
                    'plasma_c.h', $
                    'plasma_z.h', $
                    'plasma_zc.h'], $
                   header_directory=_header_directory
  dlm->addLibrary, 'libplasma.a', $
                   lib_directory=_lib_directory, $
                   /static
  dlm->addLibrary, 'libquark.a', $
                   lib_directory=_lib_directory, $
                   /static
  dlm->addLibrary, 'hwloc', $
                   lib_directory='/usr/local/lib'

  dlm->addRoutinesFromHeaderFile, filepath('mg_plasma_bindings.h', $
                                           root=mg_src_root())

  dlm->addVariableAccessor, 'PLASMA_SCHEDULING_MODE', type=3L
  dlm->addVariableAccessor, 'PLASMA_DYNAMIC_SCHEDULING', type=3L

  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)

  obj_destroy, dlm
end

