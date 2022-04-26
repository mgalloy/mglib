; docformat = 'rst'

pro mg_pubsub_subscribe, callback, topic_name
  compile_opt strictarr
  common mg_pubsub_common, mg_pubsub_registry

  if (~obj_valid(mg_pubsub_registry)) then mg_pubsub_registry = hash()
  if (~mg_pubsub_registry->hasKey(topic_name)) then begin
    mg_pubsub_registry[topic_name] = list()
  endif

  (mg_pubsub_registry[topic_name])->add, callback
end
