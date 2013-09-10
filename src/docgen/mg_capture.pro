; docformat = 'rst'

function mg_capture, cmd, status=status
  compile_opt strictarr

  mg_tout_push
  status = execute(cmd)
  output = mg_tout_pop()
  return, mg_strunmerge(output)
end
