; docformat = 'rst'

;+
; Send a message via Prowl.
;
; :Params:
;   msg : in, optional, type=string
;     message to send
;
; :Keywords:
;   application : in, optional, type=string, default='MG_PROWL'
;     name of application to send message as
;   event : in, optional, type=string, default=''
;     Prowl event
;   apikey : in, required, type=string
;     Prowl API key
;   error : out, optional, type=string
;     error message if failure
;-
pro mg_prowl, msg, $
              application=application, $
              event=event, $
              apikey=apikey, $
              error=error
  compile_opt strictarr
  on_error, 2

  if (n_elements(apikey) eq 0L) then message, 'API key required'

  _app = n_elements(application) eq 0L ? 'MG_PROWL' : application
  _event = n_elements(event) eq 0L ? '' : event
  _msg = n_elements(msg) eq 0L || strlen(msg) eq 0L ? ' ' : msg
  _apikey = strtrim(apikey, 2)

  _app = mg_urlquote(_app)
  _event = mg_urlquote(_event)
  _msg = mg_urlquote(_msg)

  apidomain = 'https://prowl.weks.net/publicapi'
  urlFormat = '(%"%s/add?application=%s&event=%s&description=%s&apikey=%s")'
  url = string(apidomain, _app, _event, _msg, _apikey, format=urlFormat)

  content = mg_get_url_content(url, ssl_verify_peer=0, $
                               error_message=error, $
                               response_code=responseCode, $
                               response_header=responseHeader)
end
