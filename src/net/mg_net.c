/*
  TCP and UDP socket support for IDL based on idl_sock.c by Randall Frank
  from his IDL_TOOLS collection.I have added UDP support to Randall's
  original code and broken it out from the IDL_TOOLS collection.

  Rick Towler
  NOAA Alaska Fisheries Science Center
  rick.towler@noaa.gov
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "idl_export.h"
#include "mg_net.h"

#define MAX_SOCKETS 256
#define NET_UNUSED 0
#define NET_LISTEN 1
#define NET_IO 2
#define NET_UDP 0
#define NET_TCP 1
#define NET_UDP_PEER 2

#ifndef WIN32
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <sys/ioctl.h>
#define SOCKET int
#define IOCTL ioctl
#define CLOSE close
#else
#include <winsock2.h>
#define IOCTL ioctlsocket
#define CLOSE closesocket
#endif

typedef struct _sock {
	IDL_LONG iState;
	IDL_LONG iType;
	SOCKET socket;
} sock;

/* local prototypes */
static int mg_recv_packet(SOCKET s, void *buffer, int len);
static void mg_rebuffer_socket(SOCKET s, int len);
static void mg_nodelay_socket(SOCKET s, int flag);

/* global list of sockets */
sock net_list[MAX_SOCKETS];

/* function protos */
extern IDL_VPTR IDL_CDECL mg_net_createport(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_close(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_connect(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_accept(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_send(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_sendto(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_recv(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_query(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_sendvar(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_recvvar(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_select(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_name2host(int argc, IDL_VPTR argv[], char *argk);
extern IDL_VPTR IDL_CDECL mg_net_host2name(int argc, IDL_VPTR argv[], char *argk);


/* define the NET functions */
static IDL_SYSFUN_DEF2 net_functions[] = {
    { mg_net_createport, "MG_NET_CREATEPORT", 1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { mg_net_close,      "MG_NET_CLOSE",      1, 1, 0, 0 },
    { mg_net_connect,    "MG_NET_CONNECT",    2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { mg_net_accept,     "MG_NET_ACCEPT",     1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { mg_net_send,       "MG_NET_SEND",       2, 2, 0, 0 },
    { mg_net_recv,       "MG_NET_RECV",       2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { mg_net_query,      "MG_NET_QUERY",      1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { mg_net_sendto,     "MG_NET_SENDTO",     4, 4, 0, 0 },
    { mg_net_sendvar,    "MG_NET_SENDVAR",    2, 4, 0, 0 },
    { mg_net_recvvar,    "MG_NET_RECVVAR",    2, 2, 0, 0 },
    { mg_net_select,     "MG_NET_SELECT",     2, 2, 0, 0 },
    { mg_net_name2host,  "MG_NET_NAME2HOST",  0, 1, 0, 0 },
    { mg_net_host2name,  "MG_NET_HOST2NAME",  0, 1, 0, 0 },
};

/*
  Define message codes and their corresponding printf(3) format strings. Note
  that message codes start at zero and each one is one less that the previous
  one. Codes must be monotonic and contiguous.
 */
static IDL_MSG_DEF msg_arr[] = {
  { "MG_NET_ERROR",	  "%NError: %s." },
  { "MG_NET_BADTYPE",	"%NUnsupproted data type: %s." },
};


#ifdef WIN32
static int	iInitW2 = 0;
#endif


/*
  Clean up all the open sockets on IDL shutdown.
*/
void mg_net_exit_handler(void) {
	IDL_LONG i;

	for(i = 0; i < MAX_SOCKETS; i++) {
		if (net_list[i].iState != NET_UNUSED) {
			shutdown(net_list[i].socket, 2);
			CLOSE(net_list[i].socket);
		}
	}

#ifdef WIN32
	if (iInitW2) WSACleanup();
#endif

}


/*
  The load function fills in this message block handle with the opaque handle
  to the message block used for this module. The other routines can then use
  it to throw errors from this block.
*/
IDL_MSG_BLOCK msg_block;


int IDL_Load(void) {
#ifdef WIN32
	WORD wVersionRequested;
	WSADATA wsaData;
	int err;

	wVersionRequested = MAKEWORD(2, 0);
	err = WSAStartup(wVersionRequested, &wsaData);
	if (!err) iInitW2 = 1;
#endif

    if (!(msg_block = IDL_MessageDefineBlock("mg_net", IDL_CARRAY_ELTS(msg_arr), msg_arr))) {
      return IDL_FALSE;
    }

    if (!IDL_SysRtnAdd(net_functions, TRUE, IDL_CARRAY_ELTS(net_functions))) {
      IDL_Message(IDL_M_GENERIC, IDL_MSG_RET, "Error adding MG_NET system routines");
		return IDL_FALSE;
	}

	IDL_ExitRegister(mg_net_exit_handler);

  return IDL_TRUE;
}


/*
  General notes:
     * All error codes return -1 on failure.
     * The socket identifier is NOT the actual underlying OS socket number, it
       is an IDL abstraction.
     * Ports are 16bit integers.
     * Hosts are unsigned 32bit integers.
*/


/*
  socket = MG_NET_CREATEPORT(portnum [, /TCP] [, /UDP])

  Creates a socket listening on the specified port for a new connection. Set
  the TCP keyword to create a TCP/IP port, or set the UDP keyword to create a
  UDP/IP port. By default a TCP port is created.

  For TCP sockets, MG_NET_SELECT returns true for this socket if there is an
  attempt to connect to it (which should be serviced by MG_NET_ACCEPT).

  For UDP sockets, you can both send and receive from this socket.
*/
IDL_VPTR IDL_CDECL mg_net_createport(int argc, IDL_VPTR argv[], char *argk) {
	SOCKET s;
	struct sockaddr_in sin;
	short	port;
	int	err;
	IDL_LONG i;

	static IDL_LONG	iUDP,iTCP;
	static IDL_KW_PAR kw_pars[] = { IDL_KW_FAST_SCAN,
		{ "TCP", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iTCP) },
		{ "UDP", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iUDP) },
    { NULL }
  };

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, argv, argk, kw_pars, argv, 1);
	port = (short) IDL_LongScalar(argv[0]);
	IDL_KWCleanup(IDL_KW_CLEAN);

	for(i = 0; i < MAX_SOCKETS; i++) {
		if (net_list[i].iState == NET_UNUSED) break;
	}
	if (i == MAX_SOCKETS) return (IDL_GettmpLong(-2));

	if (iUDP) {
		s = socket(AF_INET, SOCK_DGRAM, 0);
		net_list[i].iType = NET_UDP;
	} else {
		s = socket(AF_INET, SOCK_STREAM, 0);
		net_list[i].iType = NET_TCP;
	}
	if (s == -1) return (IDL_GettmpLong(-1));

	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = htonl(INADDR_ANY);
	sin.sin_port = htons(port);
	err = bind(s,(struct sockaddr *) &sin, sizeof(sin));
	if (err == -1) {
		CLOSE(s);
		return(IDL_GettmpLong(-1));
	}
	if (!iUDP) {
		err = listen(s, 5);
		if (err == -1) {
            CLOSE(s);
	        return (IDL_GettmpLong(-1));
		}
		net_list[i].iState = NET_LISTEN;
	} else {
		net_list[i].iState = NET_IO;
  }

	net_list[i].socket = s;

	return(IDL_GettmpLong(i));
}


/*
  err = MG_NET_CLOSE(socket)

  Close and free the socket in question.
*/
IDL_VPTR IDL_CDECL mg_net_close(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i;

	i = IDL_LongScalar(argv[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[i].iState == NET_UNUSED) return (IDL_GettmpLong(-1));

	shutdown(net_list[i].socket,2);
	CLOSE(net_list[i].socket);

	net_list[i].iState = NET_UNUSED;

	return (IDL_GettmpLong(0));
}


/*
  socket = MG_NET_CONNECT(host, port [, BUFFER=size] [, LOCAL_PORT=lp]
                          [, /NODELAY] [, /TCP] [, /UDP])

  Connect to a TCP socket listener on some specified host and port. The
  returned socket can be used for I/O after the server "accepts" the
  connection.

	The BUFFER keyword can be used to set the socket buffer size. For
	high-performance TCP/IP networks (e.g. gigE), higher bandwidth can be
	achieved by setting the buffer size to several megabytes. Setting the
	NODELAY keyword disables the Nagle algorithm for the socket (appropriate for
	applications with large numbers of small packets).

  Set the UDP keyword to create a UDP port with the peer address set to the
  provided host and port value. Data can then be sent using the MG_NET_SEND
  function which is somehwhat more efficient than the MG_NET_SENDTO function.
  This is useful if you will be sending data to primarily one host/port.

  MG_NET_CONNECT only creates TCP based sockets.
*/
IDL_VPTR IDL_CDECL mg_net_connect(int argc, IDL_VPTR inargv[], char *argk) {
	SOCKET s;
	struct sockaddr_in sin;
	int	addr_len,err;
	short	port;
	int	host;
	IDL_LONG i;
	IDL_VPTR argv[2];

	static IDL_LONG	iBuffer,iNoDelay,iUDP,iTCP, iLocPort;
	static IDL_KW_PAR kw_pars[] = { IDL_KW_FAST_SCAN,
		{ "BUFFER", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iBuffer) },
    { "LOCAL_PORT", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iLocPort) },
		{ "NODELAY", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iNoDelay) },
    { "TCP", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iTCP) },
		{ "UDP", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iUDP) },
    { NULL }
  };

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc,inargv,argk,kw_pars,argv,1);
	host = IDL_ULongScalar(argv[0]);
	port = (short) IDL_LongScalar(argv[1]);
	IDL_KWCleanup(IDL_KW_CLEAN);

	for (i = 0; i < MAX_SOCKETS; i++) {
		if (net_list[i].iState == NET_UNUSED) break;
	}
	if (i == MAX_SOCKETS) return (IDL_GettmpLong(-2));

    if (iUDP) {
		s = socket(AF_INET,SOCK_DGRAM, 0);
		net_list[i].iType = NET_UDP_PEER;
	} else {
		s = socket(AF_INET, SOCK_STREAM, 0);
        if (iBuffer) rebuffer_socket(s, iBuffer);
        if (iNoDelay) nodelay_socket(s, 1);
		net_list[i].iType = NET_TCP;
	}
	if (s == -1) return (IDL_GettmpLong(-2));

    if (iLocPort) {
        sin.sin_family = AF_INET;
        sin.sin_addr.s_addr = htonl(INADDR_ANY);
        sin.sin_port = htons((short)iLocPort);
        err=bind(s,(struct sockaddr *)&sin, sizeof(sin));
        if (err == -1) {
            CLOSE(s);
            return(IDL_GettmpLong(-2));
        }
    }

	sin.sin_addr.s_addr = host;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);
	addr_len = sizeof(struct sockaddr_in);
	err = connect(s, (struct sockaddr *)&sin, addr_len);
	if (err == -1) {
		CLOSE(s);
		return (IDL_GettmpLong(-1));
	}

	net_list[i].iState = NET_IO;
	net_list[i].socket = s;

	return (IDL_GettmpLong(i));
}


/*
  socket = MG_NET_ACCEPT(socket [, BUFFER=size] [, /NODELAY])

  Accepts a requested TCP/IP connection and returns a socket on which I/O can
  be performed. The BUFFER keyword can be used to set the socket buffer size.
  For high-performance TCP/IP networks (e.g. gigE), higher bandwidth can be
  achived by setting the buffer size to several megabytes. Setting the NODELAY
  keyword disables the Nagle algorithm for the socket (appropriate for
  applications with large numbers of small packets).

	Only valid for TCP based sockets.  Will return -1 if called for a UDP
	socket.
*/
IDL_VPTR IDL_CDECL mg_net_accept(int argc, IDL_VPTR inargv[], char *argk) {
	IDL_LONG i, j;
	struct sockaddr_in peer_addr;
	int	addr_len;
	SOCKET s;
	IDL_VPTR argv[1];

	static IDL_LONG	iBuffer, iNoDelay;
	static IDL_KW_PAR kw_pars[] = { IDL_KW_FAST_SCAN,
		{ "BUFFER", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iBuffer) },
		{ "NODELAY", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iNoDelay) },
    { NULL }
  };

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, inargv, argk, kw_pars, argv, 1);
	j = IDL_LongScalar(argv[0]);
	IDL_KWCleanup(IDL_KW_CLEAN);

	if ((j < 0) || (j >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[j].iState != NET_LISTEN) return (IDL_GettmpLong(-1));

	for(i = 0; i < MAX_SOCKETS; i++) {
		if (net_list[i].iState == NET_UNUSED) break;
	}
	if (i == MAX_SOCKETS) return(IDL_GettmpLong(-2));

	addr_len = sizeof(struct sockaddr_in);
	s = accept(net_list[j].socket, (struct sockaddr *)&peer_addr, &addr_len);
	if (s == -1) return (IDL_GettmpLong(-1));

	if (iBuffer) rebuffer_socket(s, iBuffer);
	if (iNoDelay) nodelay_socket(s, 1);
	net_list[i].iState = NET_IO;
	net_list[i].socket = s;

	return(IDL_GettmpLong(i));
}


/*
  nbytes = MG_NET_SEND(socket, variable [, host] [, port])

  Sends the raw byte data from the IDL variable on the socket. Returns the
  number of bytes sent or -1 for error. Note: no byteswapping is performed.

	When sending data from a UDP socket, you must specify the remote host and
	port arguments where host is the value returned from the MG_NET_NAME2HOST
	function.
*/
IDL_VPTR IDL_CDECL mg_net_send(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i, iNum, iRet;
	IDL_VPTR vpTmp;
	char *pbuffer;

	i = IDL_LongScalar(argv[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return(IDL_GettmpLong(-1));
	if ((net_list[i].iState != NET_IO) || (net_list[i].iType != NET_UDP_PEER))
    return(IDL_GettmpLong(-1));
	IDL_ENSURE_SIMPLE(argv[1]);
	vpTmp = argv[1];

	if (vpTmp->type == IDL_TYP_STRING) {
		vpTmp  = IDL_CvtByte(1, &vpTmp);
	}

	IDL_VarGetData(vpTmp, &iNum, &pbuffer, 1);
	iNum = iNum * IDL_TypeSizeFunc(vpTmp->type);

	iRet = send(net_list[i].socket, pbuffer, iNum, 0);

	if (vpTmp != argv[1]) IDL_Deltmp(vpTmp);

	return(IDL_GettmpLong(iRet));
}


/*
  nbytes = MG_NET_SENDTO(socket, variable, host, port)

  Sends the raw byte data from the IDL variable on the socket. Returns the
  number of bytes sent or -1 for error. Note: no byteswapping is performed.
*/
IDL_VPTR IDL_CDECL mg_net_sendto(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i, iNum, iRet;
  struct sockaddr_in sin;
	IDL_VPTR vpTmp;
	char *pbuffer;
  short	port;
  int host, addr_len;

	i = IDL_LongScalar(argv[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[i].iState != NET_IO) return (IDL_GettmpLong(-1));
	IDL_ENSURE_SIMPLE(argv[1]);
	vpTmp = argv[1];
	port = (short) IDL_LongScalar(argv[3]);
  host = IDL_ULongScalar(argv[2]);

	if (vpTmp->type == IDL_TYP_STRING) {
		vpTmp  = IDL_CvtByte(1, &vpTmp);
	}

	IDL_VarGetData(vpTmp, &iNum, &pbuffer, 1);
	iNum = iNum * IDL_TypeSizeFunc(vpTmp->type);

  sin.sin_addr.s_addr = host;
	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);
	addr_len = sizeof(struct sockaddr_in);

	iRet = sendto(net_list[i].socket, pbuffer, iNum, 0, (struct sockaddr *) &sin, addr_len);

	if (vpTmp != argv[1]) IDL_Deltmp(vpTmp);

	return(IDL_GettmpLong(iRet));
}


/*
  nbytes = MG_NET_RECV(socket, variable [, MAXIMUM_BYTES=b])

  Reads the raw data available on the socket and returns a BYTE array in
  variable. The maximum number of bytes to read can be specified by the
  MAXIMUM_BYTES keyword. The default is to read all the data available on the
  socket. Note: no byteswapping is performed.
*/
IDL_VPTR IDL_CDECL mg_net_recv(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i, iRet, err;
	int len;
	IDL_VPTR vpPlainArgs[2], vpTmp;
	char *pbuffer;

	static IDL_LONG	iMax;
	static IDL_KW_PAR kw_pars[] = { IDL_KW_FAST_SCAN,
		{ "MAXIMUM_BYTES", IDL_TYP_LONG, 1, IDL_KW_ZERO, 0, IDL_CHARA(iMax) },
    { NULL }
  };

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, argv, argk, kw_pars, vpPlainArgs, 1);

	i = IDL_LongScalar(vpPlainArgs[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[i].iState != NET_IO) return (IDL_GettmpLong(-1));
	IDL_EXCLUDE_EXPR(vpPlainArgs[1]);

	err = IOCTL(net_list[i].socket, FIONREAD, &len);
	if (err != 0) {
		iRet = -1;
		goto err;
	}
	if (iMax) len = IDL_MIN(iMax, len);

	pbuffer = (char *) IDL_MakeTempVector(IDL_TYP_BYTE, len, IDL_ARR_INI_NOP, &vpTmp);
	IDL_VarCopy(vpTmp, vpPlainArgs[1]);

	iRet = recv(net_list[i].socket, pbuffer, len, 0);

err:
	IDL_KWCleanup(IDL_KW_CLEAN);

	return(IDL_GettmpLong(iRet));
}


/*
  err = MG_NET_QUERY(socket [, AVAILABLE_BYTES=a] [, IS_LISTENER=l]
                     [, LOCAL_HOST=lh] [, LOCAL_PORT=lp]
                     [, REMOTE_HOST=rh] [, REMOTE_PORT=rp])

  Returns various information about the socket in question.

  AVAILABLE_BYTES: number of bytes available for reading.
  REMOTE_HOST: host number of the remote host the socket is connected to.
  IS_LISTENER: true if the socket was created using MG_NET_CREATEPORT()
*/
IDL_VPTR IDL_CDECL mg_net_query(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i;
	IDL_VPTR vpPlainArgs[1],vpTmp;
	struct sockaddr_in peer_addr;
	int addr_len, err;
	IDL_LONG iRet = 0;

	static IDL_VPTR	vpRHost, vpAvail, vpListen, vpLPort, vpRPort, vpLHost;
	static IDL_KW_PAR kw_pars[] = { IDL_KW_FAST_SCAN,
		{ "AVAILABLE_BYTES", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpAvail) },
		{ "IS_LISTENER", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpListen) },
    { "LOCAL_HOST", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpLHost) },
    { "LOCAL_PORT", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpLPort) },
		{ "REMOTE_HOST", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpRHost) },
    { "REMOTE_PORT", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO, 0, IDL_CHARA(vpRPort) },
    { NULL}
  };

	IDL_KWCleanup(IDL_KW_MARK);
	IDL_KWGetParams(argc, argv, argk, kw_pars, vpPlainArgs, 1);

	i = IDL_LongScalar(vpPlainArgs[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) {
		IDL_KWCleanup(IDL_KW_CLEAN);
		return(IDL_GettmpLong(-1));
	}

	if (vpRHost || vpRPort) {
		addr_len = sizeof(struct sockaddr_in);
		err = getpeername(net_list[i].socket,
		                  (struct sockaddr *) &peer_addr, &addr_len);
		if (err != 0) {
			iRet = -1;
		} else {
      if (vpRHost) {
          vpTmp = IDL_GettmpULong(peer_addr.sin_addr.s_addr);
          IDL_VarCopy(vpTmp, vpRHost);
      }
      if (vpRPort) {
          vpTmp = IDL_GettmpLong((long) ntohs(peer_addr.sin_port));
          IDL_VarCopy(vpTmp, vpRPort);
      }
		}
	}
	if (vpAvail) {
		int len;
		err = IOCTL(net_list[i].socket, FIONREAD, &len);
		if (err != 0) {
			iRet = -1;
		} else {
			vpTmp = IDL_GettmpULong(len);
			IDL_VarCopy(vpTmp, vpAvail);
		}
	}
	if (vpListen) {
		vpTmp = IDL_GettmpLong(net_list[i].iState == NET_LISTEN);
		IDL_VarCopy(vpTmp, vpListen);
	}
    if (vpLPort || vpLHost) {
		addr_len = sizeof(struct  sockaddr_in);
		err = getsockname(net_list[i].socket,
		                  (struct sockaddr *) &peer_addr, &addr_len);
		if (err != 0) {
			iRet = -1;
    } else {
      if (vpLHost) {
        vpTmp = IDL_GettmpULong(peer_addr.sin_addr.s_addr);
        IDL_VarCopy(vpTmp, vpLHost);
      }
      if (vpLPort) {
        vpTmp = IDL_GettmpLong((long) ntohs(peer_addr.sin_port));
        IDL_VarCopy(vpTmp, vpLPort);
      }
		}
	}

	IDL_KWCleanup(IDL_KW_CLEAN);

	return(IDL_GettmpLong(iRet));
}

/*
  Internal function to read a (potentially fragmented) block from a socket.
*/
static int mg_recv_packet(SOCKET s, void *buffer, int len) {
	int	n;
	int	num = 0;
	char *pbuf = (char *) buffer;

	while(num < len) {
		n = recv(s, pbuf, len - num, 0);
		if (n == -1) return(n);
		pbuf += n;
		num += n;
#ifdef	INTERRUPTABLE_READ
		if (IDL_BailOut(IDL_FALSE)) return (-1);
#endif
	}

	return(len);
}


/*
  err = MG_NET_SENDVAR(socket, variable [, host] [, port])

  Sends a complete IDL variable to a socket for reading by MG_NET_RECVVAR. The
  variable must be one of the basic types, but strings and arrays are sent
  with array dimensions and lengths intact.

	When sending data from a UDP socket, you must specify the remote host and
	port arguments where host is the value returned from the MG_NET_NAME2HOST
	function.

  Note: This is the easiest way to send a complete variable from one IDL to
  another. The receiver will byteswap the data if necessary. One should be
  careful not to mix calls to MG_NET_SEND/RECV and MG_NET_SENDVAR/RECVVAR as
  the latter send formatted information. You can use the two calls on the same
  socket as long as they are paired.
*/
IDL_VPTR IDL_CDECL mg_net_sendvar(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i;
	i_var	var;
	int host, addr_len;
	short	port;
  IDL_LONG iRet;
  IDL_VPTR vpTmp;
  char *pbuffer;
	struct sockaddr_in sin;

	i = IDL_LongScalar(argv[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[i].iState != NET_IO) return (IDL_GettmpLong(-1));
	IDL_ENSURE_SIMPLE(argv[1]);
	vpTmp = argv[1];

	if (net_list[i].iType == NET_UDP) {
		if (argc == 4) {
			host = IDL_ULongScalar(argv[2]);
			port = (short) IDL_LongScalar(argv[3]);
		} else {
			IDL_MessageFromBlock(msg_block,
			                     MG_NET_ERROR,
				                   IDL_MSG_RET,
				                   "This UDP socket requires the destination HOST and PORT arguments.");
		}
	}

	var.token = TOKEN;
	var.type = vpTmp->type;
	if ((var.type == IDL_TYP_STRUCT) ||
	    (var.type == IDL_TYP_PTR) ||
	    (var.type == IDL_TYP_OBJREF) ||
	    (var.type == IDL_TYP_UNDEF)) {
		IDL_MessageFromBlock(msg_block,
		                     MG_NET_BADTYPE,
			                   IDL_MSG_LONGJMP,
			                   IDL_TypeNameFunc(var.type));
	}

	if (vpTmp->type == IDL_TYP_STRING) {
		if (vpTmp->flags & IDL_V_ARR) return (IDL_GettmpLong(-1));
		pbuffer = IDL_STRING_STR(&(vpTmp->value.str));
		var.ndims = 0;
		var.len = vpTmp->value.str.slen + 1;
		var.nelts = var.len;
	} else if (vpTmp->flags & IDL_V_ARR) {
		pbuffer = vpTmp->value.arr->data;
		var.ndims = vpTmp->value.arr->n_dim;
		var.len = vpTmp->value.arr->arr_len;
		var.nelts = vpTmp->value.arr->n_elts;
		memcpy(var.dims, vpTmp->value.arr->dim, IDL_MAX_ARRAY_DIM * sizeof(IDL_LONG));
	} else {
		pbuffer = &(vpTmp->value.c);
		var.ndims = 0;
		var.len = IDL_TypeSizeFunc(var.type);
		var.nelts = 1;
	}

	/* send native, recvvar swaps if needed */
	if (net_list[i].iType == NET_UDP) {
		sin.sin_addr.s_addr = host;
		sin.sin_family = AF_INET;
		sin.sin_port = htons(port);
		addr_len = sizeof(struct sockaddr_in);

		iRet = sendto(net_list[i].socket, (char *) &var, sizeof(i_var), 0,
		              (struct sockaddr *) &sin, addr_len);
		if (iRet == -1) return(IDL_GettmpLong(iRet));

		iRet = sendto(net_list[i].socket, pbuffer, var.len, 0,
		              (struct sockaddr *) &sin, addr_len);
	} else {
		iRet = send(net_list[i].socket,(char *) &var, sizeof(i_var), 0);
		if (iRet == -1) return (IDL_GettmpLong(iRet));

		iRet = send(net_list[i].socket, pbuffer, var.len, 0);
	}

	return(IDL_GettmpLong(1));
}


/*
  err = MG_NET_RECVVAR(socket, variable)

  Reads an IDL variable from the socket in the form written by MG_NET_SENDVAR.
  The complete variable is reconstructed. See MG_NET_SENDVAR for more details.
 */
IDL_VPTR IDL_CDECL mg_net_recvvar(int argc, IDL_VPTR argv[], char *argk) {
	IDL_LONG i, iRet;
	IDL_LONG swab = 0;
	i_var var;
	IDL_VPTR vpTmp;
	char *pbuffer;

	i = IDL_LongScalar(argv[0]);
	if ((i < 0) || (i >= MAX_SOCKETS)) return (IDL_GettmpLong(-1));
	if (net_list[i].iState != NET_IO) return (IDL_GettmpLong(-1));
	IDL_EXCLUDE_EXPR(argv[1]);

  /* read the header */
	iRet = recv_packet(net_list[i].socket, &var,sizeof(i_var));
	if (iRet == -1) return (IDL_GettmpLong(-1));
	if (var.token == SWAPTOKEN) {
		mg_byteswap(&var, sizeof(i_var), sizeof(IDL_LONG));
		swab = 1;
	}
	if (var.token != TOKEN) return (IDL_GettmpLong(-1));

  /* allocate the variable */
	if (var.type == IDL_TYP_STRING) {
		vpTmp = IDL_StrToSTRING("");
		IDL_StrEnsureLength(&(vpTmp->value.str), var.len);
		vpTmp->value.str.slen = var.len - 1;
		pbuffer = vpTmp->value.str.s;
		memset(pbuffer, 0x20, var.len-1);
		pbuffer[var.len] = '\0';
		IDL_VarCopy(vpTmp, argv[1]);
	} else if (var.ndims != 0) {
		pbuffer = IDL_MakeTempArray(var.type, var.ndims, var.dims, IDL_BARR_INI_NOP, &vpTmp);
		IDL_VarCopy(vpTmp, argv[1]);
	} else {
		vpTmp = IDL_GettmpLong(0);
		IDL_VarCopy(vpTmp, argv[1]);
		IDL_StoreScalarZero(argv[1], var.type);
		pbuffer = &(argv[1]->value.c);
	}

  /* read the data */
	iRet = recv_packet(net_list[i].socket, pbuffer, var.len);
	if (iRet == -1) return (IDL_GettmpLong(-1));
	if (swab) {
		int	swapsize = var.len / var.nelts;
		if ((var.type == IDL_TYP_COMPLEX)
		      || (var.type == IDL_TYP_DCOMPLEX)) {
			swapsize /= 2;
		}
		mg_byteswap(pbuffer, var.len, swapsize);
	}

	return (IDL_GettmpLong(1));
}


/*
  out = MG_NET_SELECT(sockets[], timeout)

  Checks to see if there is data waiting to be read or a connection has been
  requested for a list of sockets. The return value is -1 on error, scalar 0
  if no sockets are ready or returns a list of the sockets which are ready.
  The routine waits the number of seconds specified by the timeout argument
  for sockets to become ready. A timeout value of 0 results in a poll of the
  sockets.
*/
IDL_VPTR IDL_CDECL mg_net_select(int argc, IDL_VPTR argv[], char *argk) {
  struct timeval timeval;
  fd_set rfds;

	IDL_LONG i, j;
	IDL_LONG n, num;

	float	fWait;
	IDL_LONG *piSocks,iNum;
	IDL_VPTR vpSocks;

	vpSocks = IDL_CvtLng(1, &(argv[0]));
	IDL_VarGetData(vpSocks, &iNum, (char **) &piSocks, 1);
	fWait = (float) IDL_DoubleScalar(argv[1]);

	num = -1;
	FD_ZERO(&rfds);

	for (j = 0; j < iNum; j++) {
		i = piSocks[j];
		if ((i < 0) || (i >= MAX_SOCKETS)) {
			if (vpSocks != argv[0]) IDL_Deltmp(vpSocks);
			return (IDL_GettmpLong(-1));
		}
		if (net_list[i].iState != NET_UNUSED) {
			FD_SET(net_list[i].socket, &rfds);
			if (net_list[i].socket > (SOCKET) num) num = net_list[i].socket;
		}
	}
	while (fWait >= 0.0) {
		if (fWait >= 2.0) {
			timeval.tv_sec = 2;
			timeval.tv_usec = 0;
		} else {
			timeval.tv_sec = (long) fWait;
			fWait = fWait - timeval.tv_sec;
			timeval.tv_usec = (long) (fWait * 1000000);
		}
		n = select(num + 1, &rfds, NULL, NULL, &timeval);
		if (n == -1) fWait = -1.0;
		if (n > 0) fWait = -1.0;
		fWait -= 2.0;
		if (IDL_BailOut(IDL_FALSE)) {
			n = -1;
			fWait = -1.0;
		}
	}

	if (n > 0) {
		IDL_LONG *pOut;
		IDL_VPTR vpTmp;

		pOut = (IDL_LONG *) IDL_MakeTempVector(IDL_TYP_LONG,
			                                     n, IDL_ARR_INI_NOP, &vpTmp);
		for (j = 0; j < iNum; j++) {
			i = piSocks[j];
			if (net_list[i].iState != NET_UNUSED) {
				if (FD_ISSET(net_list[i].socket, &rfds)){
					*pOut++ = i;
				}
			}
		}
		if (vpSocks != argv[0]) IDL_Deltmp(vpSocks);
		return (vpTmp);
	}

	if (vpSocks != argv[0]) IDL_Deltmp(vpSocks);

	return (IDL_GettmpLong(n));
}


/*
  host = MG_NET_NAME2HOST(name)

  Converts the ASCII host name into an unsigned long host value. If name is
  not specified, the local host name is used.
*/
IDL_VPTR IDL_CDECL mg_net_name2host(int argc, IDL_VPTR argv[], char *argk) {
	struct hostent *hp;
	char *pName, host_name[256];

	if (argc == 0) {
		if (gethostname(host_name, 256) == -1) {
			host_name[0] = '\0';
		}
		pName = host_name;
	} else {
		IDL_ENSURE_STRING(argv[0]);
		IDL_ENSURE_SCALAR(argv[0]);
		pName = IDL_STRING_STR(&(argv[0]->value.str));
	}

	hp = gethostbyname(pName);
	if (!hp) return(IDL_GettmpLong(0));

	return(IDL_GettmpULong(((struct in_addr *) (hp->h_addr))->s_addr));
}


/*
  name = MG_NET_HOST2NAME([host])

  Converts the unsigned long host value into an string hostname. If [host]
  is not specified, the local hostname is returned.
*/
IDL_VPTR IDL_CDECL mg_net_host2name(int argc, IDL_VPTR argv[], char *argk) {
	struct in_addr addr;
	struct hostent *hp;
	char host_name[256];

	if (argc == 0) {
		if (gethostname(host_name, 256) == -1) {
			host_name[0] = '\0';
		}
		return (IDL_StrToSTRING(host_name));
	} else {
		addr.s_addr = IDL_ULongScalar(argv[0]);
		hp = gethostbyaddr((char *)&addr, sizeof(struct in_addr), AF_INET);
		if (!hp) return (IDL_StrToSTRING(""));
	}
	return (IDL_StrToSTRING(hp->h_name));
}


/*
  Internal function to adjust socket buffering for things like gigE
  performance (sometimes referred to as "flogging").
*/
void mg_rebuffer_socket(SOCKET s, int len) {
	if (len < 10000) return; /* why would you do this??? */

	setsockopt(s, SOL_SOCKET, SO_RCVBUF, (void *) &len, sizeof(int));
	setsockopt(s, SOL_SOCKET, SO_SNDBUF, (void *) &len, sizeof(int));

	return;
}


void mg_nodelay_socket(SOCKET s,int flag) {
	setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (void *) &flag, sizeof(int));
}


/*
  Internal function to perform general 2, 4 and 8 byte byteswapping.
*/
void mg_byteswap(void *buffer, int len, int swapsize) {
	int	num;
	char *p = (char *) buffer;
	char t;

	switch (swapsize) {
		case 2:
			num = len / swapsize;
			while (num--) {
				t = p[0];
				p[0] = p[1];
				p[1] = t;

				p += swapsize;
			}
			break;
		case 4:
			num = len / swapsize;
			while (num--) {
				t = p[0];
				p[0] = p[3];
				p[3] = t;

				t = p[1];
				p[1] = p[2];
				p[2] = t;

				p += swapsize;
			}
			break;
		case 8:
			num = len / swapsize;
			while (num--) {
				t = p[0];
				p[0] = p[7];
				p[7] = t;

				t = p[1];
				p[1] = p[6];
				p[6] = t;

				t = p[2];
				p[2] = p[5];
				p[5] = t;

				t = p[3];
				p[3] = p[4];
				p[4] = t;

				p += swapsize;
			}
			break;
		default:
			break;
	}
	return;
}
