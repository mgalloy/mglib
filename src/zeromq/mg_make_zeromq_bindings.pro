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

  ; version
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_MAJOR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_MINOR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION_PATCH', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_VERSION', type=3L

  ; context
  dlm->addPoundDefineAccessor, 'ZMQ_IO_THREADS', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_MAX_SOCKETS', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_IO_THREADS_DFLT', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_MAX_SOCKETS_DFLT', type=3L

  ; socket types
  dlm->addPoundDefineAccessor, 'ZMQ_PAIR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PUB', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SUB', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_REQ', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_REP', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_DEALER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_ROUTER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PULL', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PUSH', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_XPUB', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_XSUB', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_STREAM', type=3L

  ; socket options
  dlm->addPoundDefineAccessor, 'ZMQ_AFFINITY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_IDENTITY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SUBSCRIBE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_UNSUBSCRIBE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RATE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RECOVERY_IVL', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SNDBUF', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RCVBUF', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RCVMORE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_FD', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENTS', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TYPE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_LINGER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RECONNECT_IVL', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_BACKLOG', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RECONNECT_IVL_MAX', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_MAXMSGSIZE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SNDHWM', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RCVHWM', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_MULTICAST_HOPS', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_RCVTIMEO', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SNDTIMEO', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_LAST_ENDPOINT', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_ROUTER_MANDATORY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TCP_KEEPALIVE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TCP_KEEPALIVE_CNT', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TCP_KEEPALIVE_IDLE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TCP_KEEPALIVE_INTVL', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_TCP_ACCEPT_FILTER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_IMMEDIATE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_XPUB_VERBOSE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_ROUTER_RAW', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_IPV6', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_MECHANISM', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PLAIN_SERVER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PLAIN_USERNAME', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PLAIN_PASSWORD', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CURVE_SERVER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CURVE_PUBLICKEY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CURVE_SECRETKEY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CURVE_SERVERKEY', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PROBE_ROUTER', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_REQ_CORRELATE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_REQ_RELAXED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CONFLATE', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_ZAP_DOMAIN', type=3L

  ; message options
  dlm->addPoundDefineAccessor, 'ZMQ_MORE', type=3L

  ; send/recv options
  dlm->addPoundDefineAccessor, 'ZMQ_DONTWAIT', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_SNDMORE', type=3L

  ; security mechanism
  dlm->addPoundDefineAccessor, 'ZMQ_NULL', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_PLAIN', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_CURVE', type=3L

  ; socket transport events
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_CONNECTED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_CONNECT_DELAYED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_CONNECT_RETRIED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_LISTENING', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_BIND_FAILED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_ACCEPTED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_ACCEPT_FAILED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_CLOSED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_CLOSE_FAILED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_DISCONNECTED', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_EVENT_MONITOR_STOPPED', type=3L

  ; multiplexing
  dlm->addPoundDefineAccessor, 'ZMQ_POLLIN', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_POLLOUT', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_POLLERR', type=3L
  dlm->addPoundDefineAccessor, 'ZMQ_POLLITEMS_DFLT', type=3L

  dlm->write
  dlm->build, show_all_output=keyword_set(show_all_output)

  obj_destroy, dlm
end

