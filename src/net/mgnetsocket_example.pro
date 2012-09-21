;:tabSize=4:indentSize=4:noTabs=true:
;:folding=explicit:collapseFolds=1:
;+
; NAME:  mgnetsocket_Example
;
;
; PURPOSE:  This program demonstrates the use of the mgnetsocket
;           class.
;
; AUTHOR:
;       Rick Towler
;       NOAA Alaska Fisheries Science Center
;       F/AKC1
;       7600 Sand Point Way NE
;       Seattle, WA 98115
;
;
; CATEGORY: Networking
;
;
; CALLING SEQUENCE:
;
;       mgnetsocket_Example
;
;
; MODIFICATION HISTORY:
;       Written by: Rick Towler, 20 July 2007
;
;-


;  Demonstrate UDP socket communications

;  You can create UDP sockets in one of two ways:
;
;  mgnetsocket::CreatePort will create a local socket and bind it
;  to an local adapter and port.  No default destination host and
;  port are defined so you must use mgnetsocket::SendTo to send
;  data from this type of UDP socket.
;
;  mgnetsocket::Connect creates a local socket, binds it to a
;  local adapter and port, and specifies a default destination host
;  and port.  This allows you to use mgnetsocket::Send to send
;  data to a remote machine.  mgnetsocket::Send is more efficient
;  than mgnetsocket::SendTo and this method is recommended if
;  most or all of the communication from this socket will be with
;  a single remote machine.  Note that these peered sockets can still
;  send data to other sockets using SendTo.
;
;  Note that if you do not specify a local port value, or specify
;  a local port value of 0, the OS will pick the local port for you.
;  This is the generally preferred method for client side sockets.
;  Use mgnetsocket::GetProperty to get the local port in these cases
;  (if you need know).
;

;  create a port using mgnetsocket::CreatePort
udpOne = OBJ_NEW('mgnetsocket')
ok = udpOne -> CreatePort(/UDP)
udpOne -> GetProperty, LOCALPORT=udpOnePort, LOCALHOST=lh
PRINT, 'Local UDP port opened on ' + lh + ' port ' + STRTRIM(udpOnePort,2)

;  create a port using mgnetsocket::Connect
;  "connect" to the port we just created above
udpTwo = OBJ_NEW('mgnetsocket')
ok = udpTwo -> Connect('127.0.0.1', udpOnePort, /UDP)
udpTwo -> GetProperty, LOCALPORT=udpTwoPort, LOCALHOST=lh
PRINT, 'Peered local UDP port opened on ' + lh + ' port ' + STRTRIM(udpTwoPort,2)
PRINT, ''


;  Simple send and receive - From Two to One
;  Since udpTwo is "connected" or rather peered to udpOne,
;  we can use mgnetsockets::Send to send the data w/o
;  specifying the destination host and port.  This is
;  a bit more efficient than using the SendTo method.
datSend = 'This is a test'
nbSent = udpTwo -> Send(datSend)
PRINT, 'Sent ' + STRTRIM(nbSent, 2) + ' bytes...'
WAIT, 0.5
nbrecv = udpOne -> Receive(data=datRecv)
PRINT, 'Received ' + STRTRIM(nbrecv, 2) + ' bytes: ' + STRING(datRecv)
PRINT, ''


;  Send something back the other way - From One to Two
;  Since udpOne is not peered, we need to use the SendTo method.
;  Note that you can pass a string that represents the host as
;  we do below, or you can use the Name2Host method to get the
;  ULONG host ID and pass that.  If making multiple calls to
;  SendTo, the latter method is preferred.
datSend = 'Going back the other way...'
nbSent = udpOne -> SendTo(datSend, '127.0.0.1', udpTwoPort)
PRINT, 'Sent ' + STRTRIM(nbSent, 2) + ' bytes...'
WAIT, 0.5
nbrecv = udpTwo -> Receive(data=datRecv)
PRINT, 'Received ' + STRTRIM(nbrecv, 2) + ' bytes: ' + STRING(datRecv)
PRINT, ''


;  You can also send and receive more complicated data packets.

;  construct the data packet...
d = FINDGEN(10) * 20
datSend = BYTE(d, 0, N_ELEMENTS(d) * 4)
d = DINDGEN(5)
datSend = [datSend, BYTE(d, 0, N_ELEMENTS(d) * 8)]
d = 'Here''s some data'
datSend = [datSend, BYTE(d)]

;  and send it
nbSent = udpTwo -> Send(datSend)
PRINT, 'Sent ' + STRTRIM(nbSent, 2) + ' bytes...'
WAIT, 0.5

;  receive the data and copy to the objects buffer
nbrecv = udpOne -> Receive(/TOBUFFER)
PRINT, 'Received ' + STRTRIM(nbrecv, 2) + ' bytes to buffer'

;  now extract our data from the buffer
;  read the 10 floats
data = udpOne -> ReadBuffer(nbytes, nels=10, type='FLOAT')
PRINT, 'Read ' + STRTRIM(nbytes, 2) + ' bytes from buffer'
help, data
print, data
;  read the 5 doubles
data = udpOne -> ReadBuffer(nbytes, nels=5, type='DOUBLE')
PRINT, 'Read ' + STRTRIM(nbytes, 2) + ' bytes from buffer'
help, data
print, data
;  read the rest of the data as BYTE
data = udpOne -> ReadBuffer(nbytes)
PRINT, 'Read ' + STRTRIM(nbytes, 2) + ' bytes from buffer'
help, data
print, STRING(data)
PRINT, ''

;  peered UDP sockets can send data to other sockets than
;  the one they are peered to:
udpThree = OBJ_NEW('mgnetsocket')
ok = udpThree -> CreatePort(/UDP)
udpThree -> GetProperty, LOCALPORT=udpThreePort, LOCALHOST=lh
PRINT, 'Local UDP port opened on ' + lh + ' port ' + STRTRIM(udpThreePort,2)
PRINT, ''


datSend = 'Peered UDP sockets can send data to other sockets too using mgnetsockets::SendTo'
hostID = udpThree -> Name2Host('127.0.0.1')
;  here we use the Name2Host method to get the HostID and pass that to SendTo
nbSent = udpTwo -> SendTo(datSend, hostID, udpThreePort)
PRINT, 'Sent ' + STRTRIM(nbSent, 2) + ' bytes...'
WAIT, 0.5
nbrecv = udpThree -> Receive(data=datRecv)
PRINT, 'Received ' + STRTRIM(nbrecv, 2) + ' bytes: ' + STRING(datRecv)
PRINT, ''

;  Clean up
OBJ_DESTROY, [udpOne, udpTwo, udpThree]

end
