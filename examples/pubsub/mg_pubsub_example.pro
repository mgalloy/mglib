; docformat = 'rst'

pro mg_pubsub_example_listener, arg1, key1=key1
  compile_opt strictarr

  print, arg1, keyword_set(key1) ? 'YES' : 'NO', $
         format='Received message sent at: %s, keyword set: %s'
end


pro mg_pubsub_example
  compile_opt strictarr

  mg_pubsub_subscribe, 'mg_pubsub_example_listener', 'example_topic'
  mg_pubsub_sendmsg, 'example_topic', systime(), /key1
  mg_pubsub_cleanup
end
