; docformat = 'rst'

;+
; Determine if connected to the internet.
;
; :Returns:
;   1 if connected, 0 if not
;
; :Requires:
;   IDL 6.4
;-
function mg_connected
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    obj_destroy, url
    return, 0B
  endif

  url = obj_new('IDLnetURL', url_hostname='www.google.com')
  result = url->get(/string_array)
  url->getProperty, response_code=response_code
  obj_destroy, url

  return, 1B
end
