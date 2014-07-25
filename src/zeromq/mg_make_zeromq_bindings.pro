; docformat = 'rst'

;+
; Make 0MQ bindings.
;
; :Keywords:
;   header_directory : in, optional, type=string
;     directory containing 0MQ include files
;   lib_directory : in, optional, type=string
;     directory containing 0MQ library files
;   show_all_output : in, optional, type=boolean
;     set to show all build output
;-
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

  ; version
  dlm->addVariableAccessor, 'ZMQ_VERSION_MAJOR', type=3L
  dlm->addVariableAccessor, 'ZMQ_VERSION_MINOR', type=3L
  dlm->addVariableAccessor, 'ZMQ_VERSION_PATCH', type=3L
  dlm->addVariableAccessor, 'ZMQ_VERSION', type=3L

  ; context
  dlm->addVariableAccessor, 'ZMQ_IO_THREADS', type=3L
  dlm->addVariableAccessor, 'ZMQ_MAX_SOCKETS', type=3L
  dlm->addVariableAccessor, 'ZMQ_IO_THREADS_DFLT', type=3L
  dlm->addVariableAccessor, 'ZMQ_MAX_SOCKETS_DFLT', type=3L

  ; socket types
  dlm->addVariableAccessor, 'ZMQ_PAIR', type=3L
  dlm->addVariableAccessor, 'ZMQ_PUB', type=3L
  dlm->addVariableAccessor, 'ZMQ_SUB', type=3L
  dlm->addVariableAccessor, 'ZMQ_REQ', type=3L
  dlm->addVariableAccessor, 'ZMQ_REP', type=3L
  dlm->addVariableAccessor, 'ZMQ_DEALER', type=3L
  dlm->addVariableAccessor, 'ZMQ_ROUTER', type=3L
  dlm->addVariableAccessor, 'ZMQ_PULL', type=3L
  dlm->addVariableAccessor, 'ZMQ_PUSH', type=3L
  dlm->addVariableAccessor, 'ZMQ_XPUB', type=3L
  dlm->addVariableAccessor, 'ZMQ_XSUB', type=3L
  dlm->addVariableAccessor, 'ZMQ_STREAM', type=3L

  ; socket options
  dlm->addVariableAccessor, 'ZMQ_AFFINITY', type=3L
  dlm->addVariableAccessor, 'ZMQ_IDENTITY', type=3L
  dlm->addVariableAccessor, 'ZMQ_SUBSCRIBE', type=3L
  dlm->addVariableAccessor, 'ZMQ_UNSUBSCRIBE', type=3L
  dlm->addVariableAccessor, 'ZMQ_RATE', type=3L
  dlm->addVariableAccessor, 'ZMQ_RECOVERY_IVL', type=3L
  dlm->addVariableAccessor, 'ZMQ_SNDBUF', type=3L
  dlm->addVariableAccessor, 'ZMQ_RCVBUF', type=3L
  dlm->addVariableAccessor, 'ZMQ_RCVMORE', type=3L
  dlm->addVariableAccessor, 'ZMQ_FD', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENTS', type=3L
  dlm->addVariableAccessor, 'ZMQ_TYPE', type=3L
  dlm->addVariableAccessor, 'ZMQ_LINGER', type=3L
  dlm->addVariableAccessor, 'ZMQ_RECONNECT_IVL', type=3L
  dlm->addVariableAccessor, 'ZMQ_BACKLOG', type=3L
  dlm->addVariableAccessor, 'ZMQ_RECONNECT_IVL_MAX', type=3L
  dlm->addVariableAccessor, 'ZMQ_MAXMSGSIZE', type=3L
  dlm->addVariableAccessor, 'ZMQ_SNDHWM', type=3L
  dlm->addVariableAccessor, 'ZMQ_RCVHWM', type=3L
  dlm->addVariableAccessor, 'ZMQ_MULTICAST_HOPS', type=3L
  dlm->addVariableAccessor, 'ZMQ_RCVTIMEO', type=3L
  dlm->addVariableAccessor, 'ZMQ_SNDTIMEO', type=3L
  dlm->addVariableAccessor, 'ZMQ_LAST_ENDPOINT', type=3L
  dlm->addVariableAccessor, 'ZMQ_ROUTER_MANDATORY', type=3L
  dlm->addVariableAccessor, 'ZMQ_TCP_KEEPALIVE', type=3L
  dlm->addVariableAccessor, 'ZMQ_TCP_KEEPALIVE_CNT', type=3L
  dlm->addVariableAccessor, 'ZMQ_TCP_KEEPALIVE_IDLE', type=3L
  dlm->addVariableAccessor, 'ZMQ_TCP_KEEPALIVE_INTVL', type=3L
  dlm->addVariableAccessor, 'ZMQ_TCP_ACCEPT_FILTER', type=3L
  dlm->addVariableAccessor, 'ZMQ_IMMEDIATE', type=3L
  dlm->addVariableAccessor, 'ZMQ_XPUB_VERBOSE', type=3L
  dlm->addVariableAccessor, 'ZMQ_ROUTER_RAW', type=3L
  dlm->addVariableAccessor, 'ZMQ_IPV6', type=3L
  dlm->addVariableAccessor, 'ZMQ_MECHANISM', type=3L
  dlm->addVariableAccessor, 'ZMQ_PLAIN_SERVER', type=3L
  dlm->addVariableAccessor, 'ZMQ_PLAIN_USERNAME', type=3L
  dlm->addVariableAccessor, 'ZMQ_PLAIN_PASSWORD', type=3L
  dlm->addVariableAccessor, 'ZMQ_CURVE_SERVER', type=3L
  dlm->addVariableAccessor, 'ZMQ_CURVE_PUBLICKEY', type=3L
  dlm->addVariableAccessor, 'ZMQ_CURVE_SECRETKEY', type=3L
  dlm->addVariableAccessor, 'ZMQ_CURVE_SERVERKEY', type=3L
  dlm->addVariableAccessor, 'ZMQ_PROBE_ROUTER', type=3L
  dlm->addVariableAccessor, 'ZMQ_REQ_CORRELATE', type=3L
  dlm->addVariableAccessor, 'ZMQ_REQ_RELAXED', type=3L
  dlm->addVariableAccessor, 'ZMQ_CONFLATE', type=3L
  dlm->addVariableAccessor, 'ZMQ_ZAP_DOMAIN', type=3L

  ; message options
  dlm->addVariableAccessor, 'ZMQ_MORE', type=3L

  ; send/recv options
  dlm->addVariableAccessor, 'ZMQ_DONTWAIT', type=3L
  dlm->addVariableAccessor, 'ZMQ_SNDMORE', type=3L

  ; security mechanism
  dlm->addVariableAccessor, 'ZMQ_NULL', type=3L
  dlm->addVariableAccessor, 'ZMQ_PLAIN', type=3L
  dlm->addVariableAccessor, 'ZMQ_CURVE', type=3L

  ; socket transport events
  dlm->addVariableAccessor, 'ZMQ_EVENT_CONNECTED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_CONNECT_DELAYED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_CONNECT_RETRIED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_LISTENING', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_BIND_FAILED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_ACCEPTED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_ACCEPT_FAILED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_CLOSED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_CLOSE_FAILED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_DISCONNECTED', type=3L
  dlm->addVariableAccessor, 'ZMQ_EVENT_MONITOR_STOPPED', type=3L

  ; multiplexing
  dlm->addVariableAccessor, 'ZMQ_POLLIN', type=3L
  dlm->addVariableAccessor, 'ZMQ_POLLOUT', type=3L
  dlm->addVariableAccessor, 'ZMQ_POLLERR', type=3L
  dlm->addVariableAccessor, 'ZMQ_POLLITEMS_DFLT', type=3L

  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)

  obj_destroy, dlm
end

