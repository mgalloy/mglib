/*
  IDL_NET.H

  TCP and UDP socket support for IDL based on idl_sock.c by Randall Frank
  from his IDL_TOOLS collection. I have added UDP support to Randall's
  original code and broken it out from the IDL_TOOLS collection.

  Rick Towler
  NOAA Alaska Fisheries Science Center
  rick.towler@noaa.gov

*/

#ifndef MG_NET_H
#define MG_NET_H

/* message numbers */
#define MG_NET_ERROR	0
#define MG_NET_BADTYPE	-1

/* Handy macro */
#define ARRLEN(arr) (sizeof(arr) / sizeof(arr[0]))

extern IDL_MSG_BLOCK msg_block;

/* variable encapsulation and manipulation */
/*
 * Define the token value which leads up the var header.  Its form
 * on a read determines if byteswapping is necessary on the
 * read data.  ('IDLV')
 */
#define	TOKEN	0x49444C56
#define SWAPTOKEN	0x564C4449

/* IDL variable packet header */
typedef struct {
	IDL_LONG token;
	IDL_LONG type;
	IDL_LONG ndims;
	IDL_LONG len;
	IDL_LONG nelts;
	IDL_LONG dims[IDL_MAX_ARRAY_DIM];
} i_var;

extern void byteswap(void *buffer, int len, int swapsize);
extern void mg_net_exit_handler(void);

#endif

