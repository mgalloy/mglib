; docformat = 'rst'

pro mg_make_zeromq_bindings, header_directory=header_directory, $
                             lib_directory=lib_directory, $
                             show_all_output=show_all_output
  compile_opt strictarr

  _header_directory = n_elements(header_directory) eq 0L $
                        ? '/usr/local/include' $
                        : header_directory
  _lib_directory = n_elements(lib_directory) eq 0L $
                     ? '/usr/local/lib' $
                     : lib_directory
  dlm = mg_dlm(basename='mg_zeromq', $
               prefix='MG_', $
               name='mg_zeromq', $
               description='IDL bindings for 0MQ', $
               version='1.0', $
               source='Michael Galloy')

  dlm->addInclude, 'zmq.h', $
                   header_directory=_header_directory
  dlm->addLibrary, 'libzmq.a', $
                   lib_directory=_lib_directory, $
                   /static
  dlm->addRoutinesFromHeaderFile, filepath('mg_zeromq_bindings.h', $
                                           root=mg_src_root())

  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_MAJOR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_MINOR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_PATCH', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION', type=3L

  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)

  obj_destroy, dlm
end

