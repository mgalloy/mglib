; docformat = 'rst'

function mg_net_get, url, _extra=e
  compile_opt strictarr

  ; TODO: this requires rewriting MGnetRequest
  return, mgnetrequest('get', url=url, _extra=e)
end
