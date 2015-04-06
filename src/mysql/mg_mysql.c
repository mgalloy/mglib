#include <stdio.h>
#include <stdlib.h>

#include <my_global.h>
#include <mysql.h>

#include "mg_idl_export.h"


// const char * STDCALL mysql_get_client_info(void);
static IDL_VPTR IDL_mg_mysql_get_client_info(int argc, IDL_VPTR *argv) {
  const char *output = mysql_get_client_info();

  return IDL_StrToSTRING(output);
}

// unsigned long   STDCALL mysql_get_client_version(void);
static IDL_VPTR IDL_mg_mysql_get_client_version(int argc, IDL_VPTR *argv) {
  unsigned long version = mysql_get_client_version();

  return IDL_GettmpULong64(version);
}


int IDL_Load(void) {
  /*
     These tables contain information on the functions and procedures
     that make up the cmdline_tools DLM. The information contained in these
     tables must be identical to that contained in cmdline_tools.dlm.
  */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_mysql_get_client_info,    "MG_MYSQL_GET_CLIENT_INFO",    0, 0, 0, 0 },
    { IDL_mg_mysql_get_client_version, "MG_MYSQL_GET_CLIENT_VERSION", 0, 0, 0, 0 },
  };

  /*
     Register our routines. The routines must be specified exactly the same
     as in mg_mysql.dlm.
  */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
