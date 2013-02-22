#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "idl_export.h"
#include "zlib.h"

#if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
#  include <fcntl.h>
#  include <io.h>
#  define SET_BINARY_MODE(file) setmode(fileno(file), O_BINARY)
#else
#  define SET_BINARY_MODE(file)
#endif

#define CHUNK 16384


static IDL_MSG_DEF msg_arr[] = {
#define M_MG_Z_ERRNO                0
  {  "M_MG_Z_ERRNO",           "%Nzlib error." },
#define M_MG_Z_STREAM_ERROR        -1
  {  "M_MG_Z_STREAM_ERROR",    "%NInvalid compression level." },
#define M_MG_DATA_ERROR            -2
  {  "M_MG_DATA_ERROR",        "%NInvalid or incomplete deflate data." },
#define M_MG_Z_MEM_ERROR           -3
  {  "M_MG_Z_MEM_ERROR",       "%NOut of memory." },
#define M_MG_Z_BUF_ERROR           -4
  {  "M_MG_Z_BUF_ERROR",       "%NBuffer error." },
#define M_MG_Z_VERSION_ERROR       -5
  {  "M_MG_Z_VERSION_ERROR",   "%Nzlib version mismatch!" },
};
static IDL_MSG_BLOCK msg_block;


static IDL_VPTR IDL_mg_zlib_version(int argc, IDL_VPTR *argv) {
  return(IDL_StrToSTRING(zlibVersion()));
}


static void IDL_mg_compress(int argc, IDL_VPTR *argv) {
}


static void IDL_mg_decompress(int argc, IDL_VPTR *argv) {
}


int IDL_Load(void) {
  /*
     These tables contain information on the functions and procedures
     that make up the cmdline_tools DLM. The information contained in these
     tables must be identical to that contained in cmdline_tools.dlm.
  */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_zlib_version,     "MG_ZLIB_VERSION",     0, 0, 0, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_compress,    "MG_COMPRESS",    2, 2, 0, 0 },
    { (IDL_SYSRTN_GENERIC) IDL_mg_decompress,  "MG_DECOMPRESS",    2, 2, 0, 0 },
  };

  if (!(msg_block = IDL_MessageDefineBlock("mg_zlib_dlm",
                                           IDL_CARRAY_ELTS(msg_arr),
                                           msg_arr))) return IDL_FALSE;

  /*
     Register our routines. The routines must be specified exactly the same
     as in cmdline_tools.dlm.
  */
  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
      && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
