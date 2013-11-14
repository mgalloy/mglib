; docformat = 'rst'

function mg_responsecode_message_general, code, description=description, found=found
  compile_opt strictarr

  found = 1B
  case code of
      1: return, keyword_set(description) ? 'The URL you passed uses an unsupported protocol. The problem might be an unused compile-time option or a misspelled protocol string.' : 'UNSUPPORTED_PROTOCOL'
      2: return, keyword_set(description) ? 'Very early initialization code failed. This is likely an internal error or problem.' : 'FAILED_INIT'
      3: return, keyword_set(description) ? 'The URL was not properly formatted.' : 'URL_MALFORMAT'
      4: return, keyword_set(description) ? 'Not used.' : 'URL_MALFORMAT_USER'
      5: return, keyword_set(description) ? 'The given proxy host could not be resolved.' : 'COULDNT_RESOLVE_PROXY'
      6: return, keyword_set(description) ? 'The given remote host was not resolved.' : 'COULDNT_RESOLVE_HOST'
      7: return, keyword_set(description) ? 'Failed to connect to host or proxy.' : 'COULDNT_CONNECT'
      8: return, keyword_set(description) ? 'After connecting to an FTP server, the IDLnetURL object received a strange or bad reply. The remote server is probably not an OK FTP server.' : 'FTP_WEIRD_SERVER_REPLY'
      9: return, keyword_set(description) ? 'A service was denied by the FTP server due to lack of access. When a login fails, this is not returned.' : 'FTP_ACCESS_DENIED'
     10: return, keyword_set(description) ? 'This is never returned.' : 'FTP_USER_PASSWORD_INCORRECT'
     11: return, keyword_set(description) ? 'After sending the FTP password to the server, an unexpected code was received.' : 'FTP_WEIRD_PASS_REPLY'
     12: return, keyword_set(description) ? 'After sending a user name to the FTP server, an unexpected code was received.' : 'FTP_WEIRD_USER_REPLY'
     13: return, keyword_set(description) ? 'The IDLnetURL object did not receive a sensible result from the server in response to either a PASV or EPSV command.' : 'FTP_WEIRD_PASV_REPLY'
     14: return, keyword_set(description) ? 'FTP servers return a 227-line as a response to a PASV command. This code is returned if the IDLnetURL object fails to parse that line.' : 'FTP_WEIRD_227_FORMAT'
     15: return, keyword_set(description) ? 'Indicates an internal failure when looking up the host used for the new connection.' : 'FTP_CANT_GET_HOST'
     16: return, keyword_set(description) ? 'A bad return code for either the PASV or EPSV command was sent by the FTP server, preventing the IDLnetURL object from continuing.' : 'FTP_CANT_RECONNECT'
     17: return, keyword_set(description) ? 'An error was received when trying to set the transfer mode to binary.' : 'FTP_COULDNT_SET_BINARY'
     18: return, keyword_set(description) ? 'A file transfer was shorter or larger than expected. This happens when the server first reports an expected transfer size, and then delivers data that doesn''t match the previously-given size.' : 'PARTIAL_FILE'
     19: return, keyword_set(description) ? 'Either the server returned a weird reply to a RETR command, or a zero-byte transfer was completed.' : 'FTP_COULDNT_RETR_FILE'
     20: return, keyword_set(description) ? 'After a completed file transfer, the FTP server did not send a proper "transfer successful" code.' : 'FTP_WRITE_ERROR'
     21: return, keyword_set(description) ? 'When sending custom QUOTE commands to the remote server, one of the commands returned an error code of 400 or higher.' : 'FTP_QUOTE_ERROR'
     22: return, keyword_set(description) ? 'This is returned if CURLOPT_FAILONERROR is TRUE and the HTTP server returns an error code that is >= 400.' : 'HTTP_RETURNED_ERROR'
     23: return, keyword_set(description) ? 'An error occurred when writing received data to a local file, or an error was returned from a write callback.' : 'WRITE_ERROR'
     24: return, keyword_set(description) ? 'Not used' : 'MALFORMAT_USER'
     25: return, keyword_set(description) ? 'The server denied the STOR operation. The error buffer usually contains the server''s explanation.' : 'FTP_COULDNT_STOR_FILE'
     26: return, keyword_set(description) ? 'There was a problem reading a local file, or the read callback returned an error.' : 'READ_ERROR'
     27: return, keyword_set(description) ? 'A memory allocation request failed. This is not a good thing.' : 'OUT_OF_MEMORY'
     28: return, keyword_set(description) ? 'The specified time-out period was exceeded.' : 'OPERATION_TIMEOUTED'
     29: return, keyword_set(description) ? 'Failed to set ASCII transfer type (TYPE A).' : 'FTP_COULDNT_SET_ASCII'
     30: return, keyword_set(description) ? 'The FTP PORT command returned an error. This often happens when the address is improper.' : 'FTP_PORT_FAILED'
     31: return, keyword_set(description) ? 'The FTP REST command failed.' : 'FTP_COULDNT_USE_REST'
     32: return, keyword_set(description) ? 'The FTP SIZE command failed. SIZE is not a fundamental FTP command; it is an extension and not all servers support it. This is not a surprising error.' : 'FTP_COULDNT_GET_SIZE'
     33: return, keyword_set(description) ? 'The HTTP server does not support or accept range requests.' : 'HTTP_RANGE_ERROR'
     34: return, keyword_set(description) ? 'This is an odd error that mainly occurs due to internal confusion.' : 'HTTP_POST_ERROR'
     35: return, keyword_set(description) ? 'A problem occurred somewhere in the SSL/TLS handshake. Check the error buffer for more information.' : 'SSL_CONNECT_ERROR'
     36: return, keyword_set(description) ? 'An FTP resume was attempted beyond the file size.' : 'AD_DOWNLOAD_RESUME'
     37: return, keyword_set(description) ? 'A file in the format of "FILE://" couldn''t be opened, most likely because the file path is invalid. File permissions may also be the culprit.' : 'FILE_COULDNT_READ_FILE'
     38: return, keyword_set(description) ? 'The LDAP bind operation failed.' : 'LDAP_CANNOT_BIND'
     39: return, keyword_set(description) ? 'LDAP search failed.' : 'LDAP_SEARCH_FAILED'
     40: return, keyword_set(description) ? 'The LDAP library was not found.' : 'LIBRARY_NOT_FOUND'
     41: return, keyword_set(description) ? 'A required LDAP function was not found.' : 'FUNCTION_NOT_FOUND'
     42: return, keyword_set(description) ? 'A callback returned an abort code.' : 'ABORTED_BY_CALLBACK'
     43: return, keyword_set(description) ? 'Internal error. A function was called with a bad parameter.' : 'BAD_FUNCTION_ARGUMENT'
     44: return, keyword_set(description) ? 'Not used.' : 'BAD_CALLING_ORDER'
     45: return, keyword_set(description) ? 'A specified outgoing interface could not be used. Use CURLOPT_INTERFACE to set the interface for outgoing connections.' : 'INTERFACE_FAILED'
     46: return, keyword_set(description) ? 'Not used.' : 'BAD_PASSWORD_ENTERED'
     47: return, keyword_set(description) ? 'Too many redirects. When following redirects, IDL hit the maximum amount. Set your limit with CURLOPT_MAXREDIRS.' : 'TOO_MANY_REDIRECTS'
     48: return, keyword_set(description) ? 'An option set with CURLOPT_TELNETOPTIONS was not recognized.' : 'UNKNOWN_TELNET_OPTION'
     49: return, keyword_set(description) ? 'A TELNET option string was malformed.' : 'TELNET_OPTION_SYNTAX'
     50: return, keyword_set(description) ? 'Not used.' : 'OBSOLETE'
     51: return, keyword_set(description) ? 'The remote server''s SSL certificate is invalid.' : 'SSL_PEER_CERTIFICATE'
     52: return, keyword_set(description) ? 'The server returned nothing. In certain circumstances, getting nothing is considered an error.' : 'GOT_NOTHING'
     53: return, keyword_set(description) ? 'The specified crypto engine wasn''t found.' : 'SSL_ENGINE_NOTFOUND'
     54: return, keyword_set(description) ? 'Can not set the selected SSL crypto engine as the default.' : 'SSL_ENGINE_SETFAILED'
     55: return, keyword_set(description) ? 'Sending network data failed.' : 'SEND_ERROR'
     56: return, keyword_set(description) ? 'Failure in receiving network data.' : 'RECV_ERROR'
     57: return, keyword_set(description) ? 'Share is in use.' : 'SHARE_IN_USE'
     58: return, keyword_set(description) ? 'There is a problem with the local certificate.' : 'SSL_CERTPROBLEM'
     59: return, keyword_set(description) ? 'Could not use the specified cipher.' : 'SSL_CIPHER'
     60: return, keyword_set(description) ? 'The peer certificate cannot be authenticated with known CA certificates.' : 'SSL_CACERT'
     61: return, keyword_set(description) ? 'Unrecognized transfer encoding.' : 'BAD_CONTENT_ENCODING'
     62: return, keyword_set(description) ? 'Invalid LDAP URL.' : 'LDAP_INVALID_URL'
     63: return, keyword_set(description) ? 'Maximum file size exceeded.' : 'FILESIZE_EXCEEDED'
     64: return, keyword_set(description) ? 'Requested FTP SSL level failed.' : 'FTP_SSL_FAILED'
     65: return, keyword_set(description) ? 'Sending the data required rewinding the data to retransmit, but the rewind operation failed.' : 'SEND_FAIL_REWIND'
     66: return, keyword_set(description) ? 'Failed to initialize the SSL engine.' : 'SSL_ENGINE_INITFAILED'
     67: return, keyword_set(description) ? 'The user password (or similar) was not accepted and the login failed.' : 'LOGIN_DENIED'
     68: return, keyword_set(description) ? 'File not found on TFTP server.' : 'TFTP_NOTFOUND'
     69: return, keyword_set(description) ? 'There is a permission problem on the TFTP server.' : 'TFTP_PERM'
     70: return, keyword_set(description) ? 'TFTP server is out of disk space.' : 'TFTP_DISKFULL'
     71: return, keyword_set(description) ? 'Illegal TFTP operation.' : 'TFTP_ILLEGAL'
     72: return, keyword_set(description) ? 'Unknown TFTP transfer ID.' : 'TFTP_UNKNOWNID'
     73: return, keyword_set(description) ? 'TFTP file already exists.' : 'TFTP_EXISTS'
     74: return, keyword_set(description) ? 'No such TFTP user.' : 'TFTP_NOSUCHUSER'
     else: begin
             found = 0B
             return, ''
           end
  endcase
end


function mg_responsecode_message_http, code
  compile_opt strictarr

  case code of
    ; HTTP response codes
    100: return, 'Continue'
    101: return, 'Switching Protocols'
    200: return, 'OK'
    201: return, 'Created'
    202: return, 'Accepted'
    203: return, 'Non-Authoritative Information'
    204: return, 'No Content'
    205: return, 'Reset Content'
    206: return, 'Partial Content'
    207: return, 'Multi-Status'
    300: return, 'Multiple Choices'
    301: return, 'Moved Permanently'
    302: return, 'Found'
    303: return, 'See Other (since HTTP/1.1)'
    304: return, 'Not Modified'
    305: return, 'Use Proxy (since HTTP/1.1)'
    306: return, 'Switch proxy'
    307: return, 'Temporary Redirect (since HTTP/1.1)'
    400: return, 'Bad Request'
    401: return, 'Unauthorized'
    402: return, 'Payment Required'
    403: return, 'Forbidden'
    404: return, 'Not Found'
    405: return, 'Method Not Allowed'
    406: return, 'Not Acceptable'
    407: return, 'Proxy Authentication Required'
    408: return, 'Request Timeout'
    409: return, 'Conflict'
    410: return, 'Gone'
    411: return, 'Length Required'
    412: return, 'Precondition Failed'
    413: return, 'Request Entity Too Large'
    414: return, 'Request-URI Too Long'
    415: return, 'Unsupported Media Type'
    416: return, 'Requested Range Not Satisfiable'
    417: return, 'Expectation Failed'
    449: return, 'Retry'
    500: return, 'Internal Server Error'
    501: return, 'Not Implemented'
    502: return, 'Bad Gateway'
    503: return, 'Service Unavailable'
    504: return, 'Gateway Timeout'
    505: return, 'HTTP Version Not Supported'
    509: return, 'Bandwidth Limit Exceeded'
    else: begin
            _code = ': ' + strtrim(code, 2)
            case 1 of
              code ge 100L && code lt 200L: return, 'Unknown Informational response code' + _code
              code ge 200L && code lt 300L: return, 'Unknown Success response code' + _code
              code ge 300L && code lt 400L: return, 'Unknown Redirection response code' + _code
              code ge 400L && code lt 500L: return, 'Unknown Client Error response code' + _code
              code ge 500L && code lt 600L: return, 'Unknown Server Error response code' + _code
              else: return, 'Unknown response code' + _code
            endcase
          end
  endcase
end

function mg_responsecode_message_ftp, code
  compile_opt strictarr

  case code of
    110: return, 'Restart marker reply.'
    120: return, 'Service ready in nnn minutes.'
    125: return, 'Data connection already open; transfer starting.'
    150: return, 'File status okay; about to open data connection.'
    200: return, 'Command okay.'
    202: return, 'Command not implemented, superfluous at this site.'
    211: return, 'System status, or system help reply.'
    212: return, 'Directory status.'
    213: return, 'File status.'
    214: return, 'Help message.'
    215: return, 'NAME system type.'
    220: return, 'Service ready for new user.'
    221: return, 'Service closing control connection.'
    225: return, 'Data connection open; no transfer in progress.'
    226: return, 'Closing data connection.'
    227: return, 'Entering Passive Mode (h1,h2,h3,h4,p1,p2).'
    230: return, 'User logged in, proceed.'
    250: return, 'Requested file action okay, completed.'
    257: return, '"PATHNAME" created.'
    331: return, 'User name okay, need password.'
    332: return, 'Need account for login.'
    350: return, 'Requested file action pending further information.'
    421: return, 'Service not available, closing control connection.'
    425: return, 'Can''t open data connection.'
    426: return, 'Connection closed; transfer aborted.'
    450: return, 'Requested file action not taken.'
    451: return, 'Requested action aborted: local error in processing.'
    452: return, 'Requested action not taken.'
    500: return, 'Syntax error, command unrecognized.'
    501: return, 'Syntax error in parameters or arguments.'
    502: return, 'Command not implemented.'
    503: return, 'Bad sequence of commands.'
    504: return, 'Command not implemented for that parameter.'
    530: return, 'Not logged in.'
    532: return, 'Need account for storing files.'
    550: return, 'Requested action not taken.'
    551: return, 'Requested action aborted: page type unknown.'
    552: return, 'Requested file action aborted.'
    553: return, 'Requested action not taken. File name not allowed.'

    else: begin
            _code = ': ' + strtrim(code, 2)
            case 1 of
              code ge 100L && code lt 200L: return, 'Unknown Positive Preliminary reply response code' + _code
              code ge 200L && code lt 300L: return, 'Unknown Positive Completion reply response code' + _code
              code ge 300L && code lt 400L: return, 'Unknown Positive Intermediate reply response code' + _code
              code ge 400L && code lt 500L: return, 'Unknown Transient Negative Completion reply response code' + _code
              code ge 500L && code lt 600L: return, 'Unknown Permanent Negative Completion reply response code' + _code
              code ge 600L && code lt 700L: return, 'Unknown Protected reply response code' + _code
              else: return, 'Unknown FTP response code' + _code
            endcase
          end
  endcase
end


function mg_responsecode_message, code, description=description, ftp=ftp
  compile_opt strictarr

  msg = mg_responsecode_message_general(code, description=description, found=found)
  if (found) then begin
    return, msg
  endif else begin
    if (keyword_set(ftp)) then begin
      return, mg_responsecode_message_ftp(code)
    endif else begin
      return, mg_responsecode_message_http(code)
    endelse
  endelse
end
