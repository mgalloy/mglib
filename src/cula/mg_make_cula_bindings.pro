; docformat = 'rst'

;+
; Build CULA wrappers.
;-
pro mg_make_cula_bindings
  compile_opt strictarr

  dlm = mg_dlm(basename='idlcula', $
               name='IDLCULA', $
               description='IDL bindings for CULAtools', $
               version='1.0', $
               source='Michael Galloy')

  cuda_root = '/usr/local/cuda-4.1' ; '~/software/cula'
  cula_root = '~/software/cula'
  dlm->addInclude, 'cula.h', $
                   header_directory=filepath('include', root=cula_root)
  dlm->addLibrary, ['cula_core', 'cula_lapack', 'cublas', 'cudart'], $
                   lib_directory=[filepath('lib64', root=cula_root), $
                                  filepath('lib', root=cuda_root)]

  dlm->addRoutinesFromHeaderFile, filepath('idlcula_bindings.h', root=mg_src_root())
  dlm->addRoutinesFromHeaderFile, filepath('idlcula_lapack_bindings.h', root=mg_src_root())
  dlm->addRoutinesFromHeaderFile, filepath('idlcula_blas_bindings.h', root=mg_src_root())

  dlm->write
  dlm->build, /show_all_output

  obj_destroy, dlm
end
