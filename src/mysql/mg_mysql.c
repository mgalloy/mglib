#include <stdio.h>
#include <stdlib.h>

#include <my_global.h>
#include <mysql.h>

#include "mg_idl_export.h"


// const char * STDCALL mysql_get_client_info(void);
static IDL_VPTR IDL_mg_mysql_get_client_info(int argc, IDL_VPTR *argv) {
  const char *info = mysql_get_client_info();
  return IDL_StrToSTRING(info);
}


// unsigned long   STDCALL mysql_get_client_version(void);
static IDL_VPTR IDL_mg_mysql_get_client_version(int argc, IDL_VPTR *argv) {
  unsigned long version = mysql_get_client_version();
  return IDL_GettmpULong64(version);
}


// MYSQL * STDCALL mysql_init(MYSQL *mysql);
static IDL_VPTR IDL_mg_mysql_init(int argc, IDL_VPTR *argv) {
  MYSQL *mysql = mysql_init(NULL);
  return IDL_GettmpMEMINT((IDL_MEMINT) mysql);
}


// void STDCALL mysql_close(MYSQL *sock);
static void IDL_mg_mysql_close(int argc, IDL_VPTR *argv) {
  mysql_close((MYSQL *)argv[0]->value.ptrint);
}


// MYSQL * STDCALL mysql_real_connect(MYSQL *mysql, const char *host,
//                                    const char *user, const char *passwd,
//                                    const char *db, unsigned int port,
//                                    const char *unix_socket,
//                                    unsigned long clientflag);
static IDL_VPTR IDL_mg_mysql_real_connect(int argc, IDL_VPTR *argv) {
  MYSQL *mysql = mysql_real_connect((MYSQL *) argv[0]->value.ptrint,
                                    IDL_VarGetString(argv[1]),
                                    IDL_VarGetString(argv[2]),
                                    IDL_VarGetString(argv[3]),
                                    argv[4]->value.str.slen == 0 ? NULL : IDL_VarGetString(argv[4]),
                                    argv[5]->value.ul,
                                    argv[6]->value.str.slen == 0 ? NULL : IDL_VarGetString(argv[6]),
                                    argv[7]->value.ul64);
  return IDL_GettmpMEMINT((IDL_MEMINT) mysql);
}


// int STDCALL mysql_query(MYSQL *mysql, const char *q);
static IDL_VPTR IDL_mg_mysql_query(int argc, IDL_VPTR *argv) {
  int status = mysql_query((MYSQL *) argv[0]->value.ptrint,
                           IDL_VarGetString(argv[1]));
  return IDL_GettmpLong(status);
}


// const char * STDCALL mysql_error(MYSQL *mysql);
static IDL_VPTR IDL_mg_mysql_error(int argc, IDL_VPTR *argv) {
  const char *msg = mysql_error((MYSQL *)argv[0]->value.ptrint);
  return IDL_StrToSTRING(msg);
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
    { IDL_mg_mysql_init,               "MG_MYSQL_INIT",               0, 0, 0, 0 },
    { IDL_mg_mysql_real_connect,       "MG_MYSQL_REAL_CONNECT",       8, 8, 0, 0 },
    { IDL_mg_mysql_query,              "MG_MYSQL_QUERY",              2, 2, 0, 0 },
    { IDL_mg_mysql_error,              "MG_MYSQL_ERROR",              1, 1, 0, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_mysql_close, "MG_MYSQL_CLOSE",  1, 1, 0, 0 },
  };

  /*
     Register our routines. The routines must be specified exactly the same
     as in mg_mysql.dlm.
  */
  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
      && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
