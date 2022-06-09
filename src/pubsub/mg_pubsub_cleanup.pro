; docformat = 'rst'

pro mg_pubsub_cleanup
  compile_opt strictarr
  common mg_pubsub_common, mg_pubsub_registry

  if (~obj_valid(mg_pubsub_registry)) then return
  foreach callback_list, mg_pubsub_registry do obj_destroy, callback_list
  obj_destroy, mg_pubsub_registry
end
