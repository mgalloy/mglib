; docformat = 'rst'

;+
; Class representing a URI request: GET, PUT, POST, DELETE, HEAD, OPTIONS,
; TRACE, and CONNECT.
;
; :Todo:
;    Things to do:
;
;       * handle HTTPS requests besides GET, PUT, and POST
;       * handle proxies
;       * write some tests
;
; :Examples:
;    For example::
;
;       b = obj_new('MGnetRequest', 'brightkite.com/people/mgalloy.xml')
;       b->setProperty, debug=1
;       r = b->get(response_header=h)
;       obj_destroy, b
;
; :Properties:
;    debug : type=boolean
;       set to print debugging messages to standard output
;-


;+
; Callback function when using IDLnetURL object.
;
; :private:
;
; :Returns:
;    1 for success
;
; :Params:
;    status : in, required, type=string
;       status message
;    progress : in, required, type=lonarr
;       information about the progress of the call in a lon64arr(5)::
;
;          [isValid, isChunked, nBytesDownloaded, nBytesToBeUploaded, nBytesUploaded]
;
;    request : in, required, type=object
;       CALLBACK_DATA variable from IDLnetURL, in our case an MGnetRequest
;       object
;-
function mgnetrequest_callback, status, progress, request
  compile_opt strictarr

  request->getProperty, debug=debug
  if (debug) then begin
    if (strpos(status, 'Verbose: Header Out:  ') ne -1L) then begin
      print, strmid(status, 22)
    endif
  endif

  return, 1
end


;+
; Sends its output to the given socket LUN and, if self.debug is set, to
; standard output.
;
; :Params:
;    lun : in, required, type=long
;       logical unit number of the socket connection to send the output to
;    s : in, required, type=any
;       variable to be printed
;-
pro mgnetrequest::_printf, lun, s
  compile_opt strictarr

  printf, lun, s
  if (self.debug) then print, s
end


;+
; Send the headers in the headers hash table to the given LUN.
;
; :Params:
;    lun : in, required, type=long
;       logical unit number of the socket/file to send the headers to
;-
pro mgnetrequest::_sendHeaders, lun
  compile_opt strictarr

  headerKeys = self.headers->keys(count=nHeaders)
  headerValues = self.headers->values()

  ; Host header should be first
  hostname = self.headers->get('Host')
  self->_printf, lun, 'Host: ' + hostname

  for h = 0L, nHeaders - 1L do begin
    if (headerKeys[h] eq 'Host') then continue
    self->_printf, lun, headerKeys[h] + ': ' + headerValues[h]
  endfor
end


pro mgnetrequest::_sendHeadersNetUrl, netUrl
  compile_opt strictarr

  headerKeys = self.headers->keys(count=nHeaders)
  headerValues = self.headers->values()

  for h = 0L, nHeaders - 1L do begin
    if (headerKeys[h] eq 'Host') then continue
    netUrl->setProperty, headers=headerKeys[h] + ': ' + headerValues[h]
  endfor
end

;+
; Add some default headers that are always present (but can be changed).
;-
pro mgnetrequest::_initializeHeaders
  compile_opt strictarr

  urlparts = parse_url(self.url)
  self.headers->put, 'Host', urlparts.host
  self.headers->put, 'User-agent', 'IDL-MGnetRequest/' + self.version
end


;+
; Connect via IDLnetURL instead of SOCKET.
;
; :Returns:
;    strarr representing the body of the response to the request
;
; :Params:
;    method : in, required, type=string
;       method to use to send the request: GET, PUT, POST, HEAD, DELETE,
;       OPTIONS, TRACE, or CONNECT
;    data : in, optional, type=any
;       data to send in PUT and POST methods
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::_sendNetUrl, method, data, $
                                    response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  urlparts = parse_url(self.url)

  netUrl = obj_new('IDLnetURL')

  netUrl->setProperty, /verbose, $
                       callback_function='mgnetrequest_callback', $
                       callback_data=self
  self->_sendHeadersNetUrl, netUrl

  if (self.debug) then begin
    print, urlparts.host, self.port, format='(%"connect: (%s, %d)\n")'
    print, 'send: '''
  endif

  case strupcase(method) of
    'GET': content = netUrl->get(url=self.url, /string_array)
    'PUT': content = netUrl->put(data, url=self.url, /buffer)
    'POST': content = netUrl->post(data, url=self.url, /post, /buffer)
    else: message, 'method not supported'
  endcase

  if (self.debug) then begin
    print, ''''
    print
  endif

  netUrl->getProperty, response_header=responseHeaderArray
  if (self.debug) then begin
    print, 'response header: '''
    print, responseHeaderArray
    print, ''''
  endif

  obj_destroy, netUrl

  return, content
end


;+
; General method for sending a request.
;
; :Returns:
;    strarr representing the body of the response to the request
;
; :Params:
;    method : in, required, type=string
;       method to use to send the request: GET, PUT, POST, HEAD, DELETE,
;       OPTIONS, TRACE, or CONNECT
;    data : in, optional, type=any
;       data to send in PUT and POST methods
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::_send, method, data, response_header=responseHeaderArray
  compile_opt strictarr

  urlparts = parse_url(self.url)

  socket, lun, urlparts.host, self.port, /get_lun
  if (self.debug) then print, urlparts.host, self.port, format='(%"connect: (%s, %d)\n")'

  if (self.debug) then print, 'send: '''

  queryLocation = urlparts.path  + (urlparts.query eq '' ? '' : '?') + urlparts.query
  requestMethod = method + ' /' + queryLocation + ' HTTP/1.0'
  self->_printf, lun, requestMethod

  self->_sendHeaders, lun

  if (self.debug) then print, ''''
  self->_printf, lun, ''

  responseHeader = obj_new('MGcoArrayList', type=7)
  response = obj_new('MGcoArrayList', type=7)
  inContent = 0B

  if (self.debug) then print, 'response header: '''
  line = ''
  while (~eof(lun)) do begin
    readf, lun, line

    if (~inContent && line eq '') then begin
      inContent = 1B
      continue
    endif

    if (inContent) then begin
      response->add, line
    endif else begin
      if (self.debug) then print, line
      responseHeader->add, line
    endelse
  endwhile
  if (self.debug) then print, ''''

  free_lun, lun

  responseArray = response->get(/all)
  responseHeaderArray = responseHeader->get(/all)

  obj_destroy, [responseHeader, response]

  return, responseArray
end


;+
; Send a GET request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::get, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('GET', response_header=responseHeaderArray)
    'https': return, self->_sendNetUrl('GET', response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a HEAD request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::head, response_header=responseHeaderArray
  compile_opt strictarr

  return, self->_send('HEAD', response_header=responseHeaderArray)
end


;+
; Send a PUT request.
;
; :Todo:
;    add content body of request
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::put, data, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('PUT', data, response_header=responseHeaderArray)
    'https': return, self->_sendNetUrl('PUT', response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a POST request.
;
; :Todo:
;    add content body of request
;
; :Params:
;    data : in, required, type=any
;       data to be transferred
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::post, data, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('POST', data, response_header=responseHeaderArray)
    'https': return, self->_sendNetUrl('POST', response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a DELETE request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::delete, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('DELETE', data, response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a OPTIONS request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::options, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('OPTIONS', data, response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a TRACE request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::trace, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('TRACE', data, response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Send a CONNECT request.
;
; :Keywords:
;    response_header : out, optional, type=strarr
;       header of the response
;-
function mgnetrequest::connect, response_header=responseHeaderArray
  compile_opt strictarr
  on_error, 2

  case strlowcase(self.scheme) of
    'http': return, self->_send('CONNECT', data, response_header=responseHeaderArray)
    else: message, 'scheme not implemented yet'
  endcase
end


;+
; Add a header field to the request. If the header already exists in the
; request, then it is replaced by the next value.
;
; :Params:
;    key : in, required, type=string
;       header field name
;    value : in, required, type=string
;       header field value
;-
pro mgnetrequest::addHeader, key, value
  compile_opt strictarr

  self.headers->put, key, value
end


;+
; Get property values.
;-
pro mgnetrequest::getProperty, debug=debug
  compile_opt strictarr

  if (arg_present(debug)) then debug = self.debug
end


;+
; Set property values.
;-
pro mgnetrequest::setProperty, debug=debug
  compile_opt strictarr

  if (n_elements(debug) gt 0L) then self.debug = keyword_set(debug)
end


;+
; Free resources.
;-
pro mgnetrequest::cleanup
  compile_opt strictarr

  obj_destroy, self.headers
end


;+
; Create a request object.
;
; :Params:
;    url_param : in, optional, type=string
;       URL to send request to; either url_param parameter or URL keyword must
;       be set to the URL to send the request to
;
; :Keywords:
;    url : in, optional, type=string
;       URL to send request to; either url_param parameter or URL keyword must
;       be set to the URL to send the request to
;-
function mgnetrequest::init, url_param, url=url, debug=debug
  compile_opt strictarr
  on_error, 2

  self.version = '1.0'

  self.url = n_params() gt 0L ? url_param : url

  urlparts = parse_url(self.url)
  if (urlparts.scheme eq '') then self.url = 'http://' + self.url

  urlparts = parse_url(self.url)
  self.scheme = urlparts.scheme

  if (urlparts.port eq 80L) then begin
    case urlparts.scheme of
      'http': self.port = 80L
      'https': self.port = 443L
      else: message, 'unsupported scheme'
    endcase
  endif else begin
    self.port = urlparts.port
  endelse

  self.debug = keyword_set(debug)

  self.headers = obj_new('MGcoHashTable', key_type=7, value_type=7)
  self->_initializeHeaders

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    version
;       MGnetRequest version
;    url
;       URL for request
;    port
;       port for request
;    headers
;       hash table of headers
;    debug
;       prints out header information sent and received if debug field is set
;-
pro mgnetrequest__define
  compile_opt strictarr

  define = { MGnetRequest, $
             version: '', $
             url: '', $
             port: 0L, $
             scheme: '', $
             headers: obj_new(), $
             debug: 0B $
           }
end


; main-level example program

; standard GET request
bk = obj_new('MGnetRequest', 'brightkite.com/people/mgalloy.xml')
bk->setProperty, debug=1
bk_response = bk->get(response_header=bk_header)
obj_destroy, bk


; GET with HTTPS example
username = ''
read, username, prompt='Username: '
password = ''
read, password, prompt='Password: '

del = obj_new('MGnetRequest', 'https://api.del.icio.us/v1/posts/recent')
del->setProperty, debug=1
del->addHeader, 'Authorization', $
                'Basic ' + mg_base64encode(username + ':' + password)
del_response = del->get(response_header=del_header)
obj_destroy, del


; TODO: need a PUT or POST example

end
