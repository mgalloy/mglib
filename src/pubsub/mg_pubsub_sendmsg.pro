; docformat = 'rst'

pro mg_pubsub_sendmsg, topic, arg1, _extra=e
  compile_opt strictarr
  on_error, 2
  common mg_pubsub_common, mg_pubsub_registry

  if (n_elements(topic) eq 0L) then message, 'no pubsub topic given'

  ; if no subscribers, don't do anything
  if (~obj_valid(mg_pubsub_registry)) then return
  if (~mg_pubsub_registry->hasKey(topic)) then return

  foreach cb, mg_pubsub_registry[topic] do call_procedure, cb, arg1, _extra=e
end
