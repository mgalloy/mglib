; docformat = 'rst'

;+
; The MGnetSocket class implements client and server-side internet sockets
; using the TCP/IP or UDP/IP protocols.
;
; This class was originally developed to provide UDP/IP support in IDL. While
; it provides a few methods that may be convienient, if you need TCP/IP client
; sockets you may want to consider the built in support in IDL.
;
; This class depends on the idl_net DLM which provides the interface to the OS
; sockets library. This DLM is based *heavily* on Randall Frank's `idl_sock.c`
; code distributed with his idl_tools DLM.
;
; Note on byteswapping: Make sure you swap in the correct place.  If you are
; reading into the buffer, and you are extracting other than byte type you
; need to swap on the call to ReadBuffer. If you are simply receiving data via
; ::receive or extracting byte data from `::readBuffer` then you can swap on
; either the call to `::receive` or `::readBuffer`.
;
; :Todo:
;    Should add in a network endianess property so that swapping is automagic.
;    This would require Receive to be modified such that Rx'ing to buffer
;    would not swap even if the local and remote endianess were different.
;    Further, if receiving to buffer, data should not be returned to the
;    caller so there is no confusion. If this endianess property is undefined
;    (the default) no swapping is performed.
;
; :Categories:
;    networking
;
; :Examples:
;    Try the main-level program at the end of this file::
;
;       IDL> .run mgnetsocket__define
;
; :History:
;    Original written by Randall Frank in idl_sock.c in his idl_tools DLM
;    Modified by Rick Towler, 20 July 2007
;    Modified by Michael Galloy
;
; :Properties:
;    localhost
;    localport
;    open
;       true if the socket is open, false if not
;    remotehost
;    remoteport
;    type
;       type of connection: 'LISTEN_TCP', 'UDP', 'IO_TCP', 'PEERED_UDP'
;-


;+
;  Connect to a TCP socket listener on a specified host and port or
;  opens a UDP socket and sets its default destination host and port.
;-
function mgnetsocket::connect, destHost, $
                               destPort, $
                               buffer=buffer, $
                               localPort=locPort, $
                               nodelay=nodelay, $
                               udp=udp, $
                               tcp=tcp
  compile_opt strictarr

  ;  check if socket is currently open
  if (self.sockId ge 0L) then self->close

  ;  process keywords
  locPort = (n_elements(locPort) ne 1) ? 0L : locPort

  ;  resolve hostname and get hostid
  if (size(destHost, /type) ne 13L) then begin
    ; destination host specified as string - resolve
    self.hostId = mg_net_name2host(destHost[0])
    if (self.hostId eq 0L) then begin
      message, string(destHost[0], $
                      format='(%"unable to resolve hostname ''%s''")'), $
               /continue
      return, -2L
    endif
  endif else begin
    ; host ID has already been converted to ULONG
    self.hostId = destHost[0]
  endelse

  if (keyword_set(udp)) then begin
    ; open UDP port and set default destination
    sId = mg_net_connect(self.hostID, destPort[0], /udp, local_port=locPort)
    if (sId lt 0) then begin
      message, string(locPort, format='(%"unable to open port %d")'), /continue
      return, -2L
    endif
    self.type = 3B
  endif else begin
    ; connect using TCP sockets
    if (n_elements(buffer) eq 1) then begin
      sId = mg_net_connect(self.hostId, destPort[0], $
                           /tcp, local_port=locPort, $
                           nodelay=keyword_set(nodelay), buffer=buffer)
    endif else begin
      sId = mg_net_connect(self.hostId, destPort[0], $
                           /tcp, local_port=locPort, $
                           nodelay=keyword_set(nodelay))
    endelse
    if (sId lt 0L) then begin
      message, string(destHost, destPort, $
                      format='(%"unable to connect to host %s at port %d")'), $
                /continue
      return, -2L
    endif
    self.type = 2B
  endelse

  ; get local port if auto assigned
  if (locPort eq 0L) then err = mg_net_query(sId, local_port=locPort)

  self.destPort = destPort[0]
  self.locPort = locPort
  self.sockID = sId
  *self.buffer = 0B

  return, 1L
end


;+
; Creates a socket listening on the specified port. Socket can be either TCP
; or UDP based. Specify a local port of 0 to allow the OS to select an open
; port for you.
;
; :Returns:
;
; :Params:
;    locPort : in, optional, type=long
;       port to create; the OS will select an open port if this parameter is
;       undefined or set to 0
;
; :Keywords:
;    tcp : in, optional, type=boolean
;       set to create a TCP port
;    udp : in, optional, type=boolean
;       set to create a UDP port
;-
function mgnetsocket::createPort, locPort, tcp=tcp, udp=udp
  compile_opt strictarr

  ; check if socket is currently open
  if (self.sockId ge 0L) then self->close

  ; provide default value for locPort
  if (n_params() eq 0L) then locPort = 0L

  if (keyword_set(udp)) then begin
    ; create UDP socket
    sId = mg_net_createport(locPort[0], /udp)
    self.type = 1B
  endif else begin
    ; create LISTENER TCP socket
    sId = mg_net_createport(locPort[0], /tcp)
    self.type = 0B
  endelse

  ;  get local port if auto assigned
  if (locPort eq 0) then err = mg_net_query(sId, local_port=locPort)

  if (sId lt 0) then begin
    message, string(locPort, format='(%"unable to open port %d")'), /continue
    return, -2L
  endif

  self.locPort = locPort[0]
  self.sockId = sId
  *self.buffer = 0B

  return, 1L
end


;+
; Accepts a requested TCP/IP connection and returns an MGnetSocket on which
; I/O can be performed.
;
; :Returns:
;    MGnetSocket object
;
; :Keywords:
;    buffer
;    nodelay
;    timeout : in, optional, type=long, default=0L
;       timeout
;-
function mgnetsocket::accept, buffer=buffer, nodelay=nodelay, timeout=timeout
  compile_opt strictarr

  newSock = obj_new()

  if (self.type gt 0) then begin
    message, 'I/O sockets cannot accept connections', /continue
    return, newSock
  endif

  ; check if there are any pending connections
  if (n_elements(timeout) eq 1L) then begin
    pc = mg_net_select(self.sockID, timeout)
  endif else begin
    pc = mg_net_select(self.sockID, 0L)
  endelse

  if (pc gt 0L) then begin
    ; connection has been requested - accept
    if (n_elements(buffer) eq 1L) then begin
      newSId = mg_net_accept(self.sockId, nodelay=keyword_set(nodelay), $
                             buffer=buffer)
    endif else begin
      newSId = mg_net_accept(self.sockId, nodelay=keyword_set(nodelay))
    endelse

    if (newSId ge 0L) then begin
      newSock = obj_new('MGnetSocket', newSId)
    endif else begin
      message, 'error accepting socket connection', /continue
      return, newSock
    endelse
  endif else begin
    ; no connection pending
    return, newSock
  endelse
end


;+
; Send data.
;
; :Returns:
;    number of bytes send
;
; :Params:
;    data : in, required, type=array
;       data to send
;-
function mgnetsocket::send, data
  compile_opt strictarr

  ; check if socket is open
  if (self.sockId lt 0L) then begin
    message, 'socket is closed; cannot send data', /continue
    return, 0L
  endif

  ; check if we can send data
  if (self.type eq 0L) then begin
    message, 'cannot send data from a socket in a listening state', /continue
    return, 0L
  endif

  ; send the data
  if (self.type gt 1L) then begin
    ns = mg_net_send(self.sockId, data)
  endif else begin
    message, 'UDP Socket is not peered; use the sendTo method', /continue
    return, 0L
  endelse

  return, ns
end


;+
; Send data to a specified host and port.
;
; :Returns:
;    number of bytes sent
;
; :Params:
;    data : in, required, type=array
;       data to send
;    destHost : in, required, type=string or ulong
;       host to sent data to specified as a hostname or host identifier
;    destPort : in, required, type=long
;       host port
;-
function mgnetsocket::sendTo, data, destHost, destPort
  compile_opt strictarr

  ; check if socket is open
  if (self.sockId lt 0L) then begin
    message, 'socket is closed; cannot send data', /continue
    return, 0L
  endif

  ; check if we can send data
  if (self.type eq 0L) then begin
    message, 'cannot send data from a socket in a listening state', /continue
    return, 0L
  endif

  if (size(destHost, /type) ne 13L) then begin
    ; destination host specified as string - resolve
    destHost = self->name2Host(destHost)
  endif

  ; send the data
  ns = mg_net_sendto(self.sockId, data, destHost, destPort)

  return, ns
end


;+
; Receive data.
;
; :Returns:
;    number of bytes received as a long; errors will return a negative value
;
; :Keywords:
;    byteswap : in, optional, type=boolean
;       set to swap the byte order of the returned data
;    data : out, optional, type=array
;       set to a named variable to return the received data
;    tobuffer : in, optional, type=boolean
;       set to put data in buffer to be read later by readBuffer method
;-
function mgnetsocket::receive, byteswap=byteswap, $
                               data=data, $
                               tobuffer=tobuffer
  compile_opt strictarr

  if (self.sockId lt 0L) then begin
   message, 'socket is closed, nothing to read.', /continue
   return, -2L
  endif

  ; check if we can receive data
  if (self.type eq 0) then begin
    message, 'cannot receive data from a socket in a listening state', /continue
    return, -2L
  endif

  ; check for data in the socket buffer
  err = mg_net_query(self.sockId, available_bytes=nr)
  if (nr eq 0L) then return, nr

  ; read data from socket buffer
  nr = mg_net_recv(self.sockId, data)

  ; swap, if requested
  if (keyword_set(byteswap)) then swap_endian_inplace, data

  if (keyword_set(tobuffer)) then begin
    ; copy data to buffer
    if (self.bsize eq 0L) then begin
      *self.buffer = data
    endif else begin
      ; TODO: probably should implement more efficient buffering here...
      *self.buffer = [*self.buffer, data]
    endelse
    self.bsize += nr
  endif else begin
    ; simply return data to caller
    *self.buffer = 0B
    self.bsize = 0L
  endelse

  return, nr
end


;+
; Return data stored in the local (object's) buffer. This method can be used
; to return specific data types, even mixed types, from the buffer by
; specifying the type.
;
; Returns NaN if the buffer is empty.
;
; :Returns:
;    array of the type specified by the TYPE keyword
;
; :Params:
;    nbytes : out, optional, type=long
;       number of bytes read
;
; :Keywords:
;    type : in, optional, type=string, default=''
;       type of data: 'integer', 'double', 'float', 'long', 'string', 'uint',
;       'ulong', 'l64', or 'ul64'; if not specified or not one of the above
;       types, data is returned as bytes
;    peek : in, optional, type=boolean
;       set the peek keyword to "take a peek" at data but not remove it from
;       the buffer
;    skipbytes : in, optional, type=long
;       bytes to skip at the beginning of the buffer
;    byteswap : in, optional, type=boolean
;       set to swap endianness of data
;    nels : in, out, optional, type=long
;       the number of elements read; if not specified, as many elements as
;       possible are read
;-
function mgnetsocket::readBuffer, nbytes, $
                                  byteswap=byteswap, $
                                  nels=nels, $
                                  peek=peek, $
                                  skipbytes=skipbytes, $
                                  type=type
  compile_opt strictarr

  _type = (n_elements(type) gt 0) ? type[0] : ''
  nels = (n_elements(nels) gt 0) ? nels[0] : -1L

  _skipbytes = (n_elements(skipbytes) gt 0L) ? skipbytes[0] : 0L
  ts = 1L

  ; check if there is any more data unread in the buffer
  if (self.bsize le 0L) then begin
    nbytes = 0L
    return, !values.f_nan
  endif

  ;  extract requested data by type
  case strlowcase(_type) of
    'integer': begin
        ts = 2L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = fix((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'double': begin
        ts = 8L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = double((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'float': begin
        ts = 4L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = float((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'long': begin
        ts = 4L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = long((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'string': begin
        if (nels lt 0L) then nels = self.bsize
        eidx = 0L > nels - 1L < (self.bsize - 1L)
        data = string((*self.buffer)[_skipbytes:eidx])
      end

    'uint': begin
        ts = 2L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = uint((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'ulong': begin
        ts = 4L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1 < (self.bsize - 1)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = ulong((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'l64': begin
        ts = 8L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1L) mod ts
        nels = (eidx + 1L) / ts
        data = long64((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    'ul64': begin
        ts = 8L
        if (nels lt 0L) then nels = self.bsize / ts
        eidx = 0L > (nels * ts) - 1L < (self.bsize - 1L)
        eidx -= (eidx + 1) mod ts
        nels = (eidx + 1) / ts
        data = ulong64((*self.buffer)[_skipbytes:eidx], 0L, nels)
      end

    else: begin
        if (nels lt 0L) then nels = n_elements(*self.buffer)
        eidx = 0L > nels - 1L < (self.bsize - 1L)
        data = (*self.buffer)[_skipbytes:eidx]
      end
  endcase

  ; swap, if requested
  if (keyword_set(byteswap)) then swap_endian_inplace, data

  nbytes = nels * ts

  if (~keyword_set(peek)) then begin
    if (eidx eq self.bsize -1) then begin
      *self.buffer = 0B
      self.bsize = 0L
    endif else begin
      *self.buffer = (*self.buffer)[eidx + 1L:self.bsize - 1L]
      self.bsize = self.bsize - (nbytes + _skipbytes)
    endelse
  end

  return, data
end


;+
; Return a host ID as ULONG given a string hostname.
;
; :Returns:
;    long
;
; :Params:
;    name : in, optional, type=string
;       hostname
;-
function mgnetsocket::name2Host, name
  compile_opt strictarr

  if (size(name, /type) ne 7L) then begin
    message, 'hostname must be passed as a string'
  endif

  if (n_params() eq 0L) then begin
    hostId = mg_net_name2host()
  endif else begin
    hostid = mg_net_name2host(name)
  endelse

  if (hostID eq 0L) then begin
    message, string(name, format='(%"unable to resolve hostname ''%s''")'), $
             /continue
  endif

  return, hostId
end


;+
; Return a hostname as string given a ULONG host ID.
;
; :Returns:
;    string
;
; :Params:
;    hostId : in, optional, type=ulong
;       host identifier
;-
function mgnetsocket::host2Name, hostId
  compile_opt strictarr
  on_error, 2

  if (size(hostID, /type) ne 13L) then begin
    message, 'host ID must be passed as ULONG'
  endif

  if (n_params() eq 0L) then begin
    name = mg_net_host2name()
  endif else begin
    name = mg_net_host2name(hostID)
  endelse

  if (strcmp(name, '')) then begin
    message, 'unable to resolve hostname from host ID', /continue
  endif

  return, name
end


;+
; Return the number of bytes waiting in the socket buffer.
;
; :Returns:
;    long
;-
function mgnetsocket::check
  compile_opt strictarr

  err = mg_net_query(self.sockId, available_bytes=nBytes)
  if (err lt 0L) then nBytes = 0L

  return, nBytes
end


;+
; Close a socket.
;-
pro mgnetsocket::close
  compile_opt strictarr

  ;  close UDP port if open
  if (self.sockId ge 0L) then err = mg_net_close(self.sockId)

  ;  reset porperties
  self.destPort = 0L
  self.hostId = 0UL
  self.locPort = 0L
  self.sockId = -1L
  *self.buffer = 0B
end


;+
; Set properties of the socket.
;-
pro mgnetsocket::setProperty
  compile_opt strictarr

  ; There aren't any properties that are settable by the user at this point.
  ; The network endianess prop is one that would be.
end


;+
; Get properties of the socket.
;-
pro mgnetsocket::getProperty, localhost=locHost, $
                              localport=locPort, $
                              open=open, $
                              remotehost=destHost, $
                              remoteport=destPort, $
                              type=type
  compile_opt strictarr

  destPort = self.destPort
  locPort = self.locPort

  case self.type of
    0: type = 'LISTEN_TCP'
    1: type = 'UDP'
    2: type = 'IO_TCP'
    3: type = 'PEERED_UDP'
  endcase

  if (arg_present(locHost)) then begin
    err = mg_net_query(self.sockId, local_host=lh)
    locHost = mg_net_host2name(lh)
  endif

  if (arg_present(destHost)) then begin
    err = mg_net_query(self.sockID, remote_host=rh)
    destHost = mg_net_host2name(rh)
  endif

  open = self.sockId ge 0L ? 1L : 0L
end


;+
; Free resources held by the socket object.
;-
pro mgnetsocket::cleanup
  compile_opt strictarr

  ; close the socket if open
  if (self.sockId ge 0) then self->close

  ; free the lone pointer
  ptr_free, self.buffer
end


;+
; Create a socket object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Params:
;    sockId : in, optional, type=long
;       socket identifier
;-
function mgnetsocket::init, sockId
  compile_opt strictarr

  if (n_params() gt 0) then begin
    ; internal call from MGnetSocket::accept
    err = mg_net_query(sockId, $
                       local_port=self.locPort, $
                       remote_host=self.hostID, $
                       remote_port=self.destPort)
    if (err lt 0L) then return, 0
    self.sockId = sockId
    self.type = 2B
  endif else begin
    self.sockId = -1L
  endelse

  self.buffer = ptr_new(0B)

  return, 1
end


;+
; Defines instance variables.
;
; :Fields:
;    buffer
;       buffer of read data
;    bsize
;       size of buffer in bytes
;    sockId
;       socket identififer
;    type
;       type code: 0 => 'LISTEN_TCP', 1 => 'UDP', 2 => 'IO_TCP', 3 =>
;       'PEERED_UDP'
;    hostId
;       host identifier
;    locPort
;       local port
;    destPort
;       destination port
;-
pro mgnetsocket__define
  compile_opt strictarr

  define = { MGnetSocket, $
             buffer: ptr_new(), $
             bsize: 0L, $
             sockId: 0L, $
             type: 0B, $
             hostId: 0UL, $
             locPort: 0L, $
             destPort: 0L $
           }
end


; main-level example

; This is a simple example that requests time via TCP port 37 taken from a
; recent thread on comp.lang.idl-pvwave.
;
; Note that time-a.nist.gov doesn't always return data so it may time out on
; you. Just try again.
;
; The point is not to actually get the actual time, just an example of how to
; do this using MGnetSocket. This also illustrates a problem that is probably
; best handled via IDL's built in client side socket support.

timeServer = 'time-a.nist.gov'
timePort = 37

; connect to the time server
timeSock = obj_new('MGnetSocket')
ok = timeSock->connect(timeServer, timePort, /tcp)
timeSock->getProperty, localport=locPort, localhost=locHost
print, locHost, locPort, format='(%"Local TCP socket created on %s port %d")'

; wait for the time - MGnetSocket performs non-blocking reads
timeout = 0
while (timeSock->check() eq 0L) do begin
  wait, 0.1
  timeout += 0.1
  if (timeout gt 5.) then break
endwhile

; receive the time - store in MGnetSocket's buffer
nBytes = timeSock->receive(/tobuffer)
print, nBytes, timeServer, format='(%"Received %d bytes from %s")'

if (nBytes gt 0L) then begin
  ;  time is sent as an unsigned 32bit integer - need to byteswap
  time = timeSock->readBuffer(/byteswap, nels=1, type='ulong')

  print, time / 60. / 60. / 24. / 365.26, $
         format='(%"Approximate number of years since Midnight Jan 1, 1900: %f")'
endif

timeSock->close

end


