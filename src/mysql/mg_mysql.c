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
                                    IDL_ULongScalar(argv[5]),
                                    argv[6]->value.str.slen == 0 ? NULL : IDL_VarGetString(argv[6]),
                                    IDL_ULong64Scalar(argv[7]));
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


// MYSQL_RES * STDCALL mysql_store_result(MYSQL *mysql);
static IDL_VPTR IDL_mg_mysql_store_result(int argc, IDL_VPTR *argv) {
  MYSQL_RES *result = mysql_store_result((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpMEMINT((IDL_MEMINT) result);
}


// unsigned int STDCALL mysql_num_fields(MYSQL_RES *res);
static IDL_VPTR IDL_mg_mysql_num_fields(int argc, IDL_VPTR *argv) {
  unsigned int num_fields = mysql_num_fields((MYSQL_RES *)argv[0]->value.ptrint);
  return IDL_GettmpULong(num_fields);
}


// MYSQL_ROW STDCALL mysql_fetch_row(MYSQL_RES *result);
static IDL_VPTR IDL_mg_mysql_fetch_row(int argc, IDL_VPTR *argv) {
  MYSQL_ROW row = mysql_fetch_row((MYSQL_RES *)argv[0]->value.ptrint);
  return IDL_GettmpMEMINT((IDL_MEMINT) row);
}


// not part of mysql.h, but needed to access the C fields
// typedef char **MYSQL_ROW;
static IDL_VPTR IDL_mg_mysql_fetch_field(int argc, IDL_VPTR *argv) {
  MYSQL_ROW row = (MYSQL_ROW) argv[0]->value.ptrint;
  IDL_ULONG i = IDL_ULongScalar(argv[1]);
  char *field = row[i];
  return IDL_StrToSTRING(field);
}


// void STDCALL mysql_free_result(MYSQL_RES *result);
static void IDL_mg_mysql_free_result(int argc, IDL_VPTR *argv) {
  mysql_free_result((MYSQL_RES *)argv[0]->value.ptrint);
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
    { IDL_mg_mysql_store_result,       "MG_MYSQL_STORE_RESULT",       1, 1, 0, 0 },
    { IDL_mg_mysql_num_fields,         "MG_MYSQL_NUM_FIELDS",         1, 1, 0, 0 },
    { IDL_mg_mysql_fetch_row,          "MG_MYSQL_FETCH_ROW",          1, 1, 0, 0 },
    { IDL_mg_mysql_fetch_field,        "MG_MYSQL_FETCH_FIELD",        2, 2, 0, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_mysql_close,       "MG_MYSQL_CLOSE",        1, 1, 0, 0 },
    { (IDL_SYSRTN_GENERIC) IDL_mg_mysql_free_result, "MG_MYSQL_FREE_RESULT",  1, 1, 0, 0 },
  };

  /*
     Register our routines. The routines must be specified exactly the same
     as in mg_mysql.dlm.
  */
  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
      && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
