#include <stdio.h>
#include <stdlib.h>

#include <mysql_version.h>
#include <my_global.h>
#include <mysql.h>

#include "mg_idl_export.h"

static IDL_STRUCT_TAG_DEF mg_mysql_field[] = {
  { "NAME",             0,    (void *) IDL_TYP_STRING,  0 },
  { "ORG_NAME",         0,    (void *) IDL_TYP_STRING,  0 },
  { "TABLE",            0,    (void *) IDL_TYP_STRING,  0 },
  { "ORG_TABLE",        0,    (void *) IDL_TYP_STRING,  0 },
  { "DB",               0,    (void *) IDL_TYP_STRING,  0 },
  { "CATALOG",          0,    (void *) IDL_TYP_STRING,  0 },
  { "DEF",              0,    (void *) IDL_TYP_STRING,  0 },
  { "LENGTH",           0,    (void *) IDL_TYP_ULONG64, 0 },
  { "MAX_LENGTH",       0,    (void *) IDL_TYP_ULONG64, 0 },
  { "NAME_LENGTH",      0,    (void *) IDL_TYP_ULONG,   0 },
  { "ORG_NAME_LENGTH",  0,    (void *) IDL_TYP_ULONG,   0 },
  { "TABLE_LENGTH",     0,    (void *) IDL_TYP_ULONG,   0 },
  { "ORG_TABLE_LENGTH", 0,    (void *) IDL_TYP_ULONG,   0 },
  { "DB_LENGTH",        0,    (void *) IDL_TYP_ULONG,   0 },
  { "CATALOG_LENGTH",   0,    (void *) IDL_TYP_ULONG,   0 },
  { "DEF_LENGTH",       0,    (void *) IDL_TYP_ULONG,   0 },
  { "FLAGS",            0,    (void *) IDL_TYP_ULONG,   0 },
  { "DECIMALS",         0,    (void *) IDL_TYP_ULONG,   0 },
  { "CHARSETNR",        0,    (void *) IDL_TYP_ULONG,   0 },
  { "TYPE",             0,    (void *) IDL_TYP_ULONG,   0 },
#if MYSQL_VERSION_ID >= 50100
  { "EXTENSION",        0,    (void *) IDL_TYP_PTRINT,  0 },
#endif
  { 0 }
};

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


// unsigned int mysql_get_proto_info(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_get_proto_info(int argc, IDL_VPTR *argv) {
  unsigned int info = mysql_get_proto_info((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpULong(info);
}


// const char *mysql_get_host_info(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_get_host_info(int argc, IDL_VPTR *argv) {
  const char *info = mysql_get_host_info((MYSQL *)argv[0]->value.ptrint);
  return IDL_StrToSTRING(info);
}


// const char *mysql_get_server_info(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_get_server_info(int argc, IDL_VPTR *argv) {
  const char *info = mysql_get_server_info((MYSQL *)argv[0]->value.ptrint);
  return IDL_StrToSTRING(info);
}


// unsigned long mysql_get_server_version(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_get_server_version(int argc, IDL_VPTR *argv) {
  unsigned long version = mysql_get_server_version((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpULong64(version);
}


// const char *mysql_info(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_info(int argc, IDL_VPTR *argv) {
  const char *info = mysql_info((MYSQL *)argv[0]->value.ptrint);
  return IDL_StrToSTRING(info);
}


// MYSQL * STDCALL mysql_init(MYSQL *mysql);
static IDL_VPTR IDL_mg_mysql_init(int argc, IDL_VPTR *argv) {
  MYSQL *mysql = mysql_init(NULL);
  return IDL_GettmpMEMINT((IDL_MEMINT) mysql);
}


// int mysql_options(MYSQL *mysql, enum mysql_option option, const char *arg)
static IDL_VPTR IDL_mg_mysql_options(int argc, IDL_VPTR *argv) {
  char *value;
  switch (argv[2]->type) {
    case IDL_TYP_BYTE:
      value = (char *) &argv[2]->value.c;
      break;
    case IDL_TYP_ULONG:
      value = (char *) &argv[2]->value.ul;
      break;
    case IDL_TYP_STRING:
      value = IDL_VarGetString(argv[2]);
      break;
  }
  int status = mysql_options((MYSQL *)argv[0]->value.ptrint,
                             IDL_ULongScalar(argv[1]),
                             value);
  return IDL_GettmpLong(status);
}


// MYSQL_RES *mysql_list_tables(MYSQL *mysql, const char *wild)
static IDL_VPTR IDL_mg_mysql_list_tables(int argc, IDL_VPTR *argv) {
  char *wildcard = NULL;
  if (argc > 1) {
    if (argv[1]->type == IDL_TYP_STRING) {
      wildcard = IDL_VarGetString(argv[1]);
    }
  }
  MYSQL_RES *result = mysql_list_tables((MYSQL *)argv[0]->value.ptrint,
                                        wildcard);
  return IDL_GettmpMEMINT((IDL_MEMINT) result);
}


// MYSQL_RES *mysql_list_dbs(MYSQL *mysql, const char *wild)
static IDL_VPTR IDL_mg_mysql_list_dbs(int argc, IDL_VPTR *argv) {
  char *wildcard = NULL;
  if (argc > 1) {
    if (argv[1]->type == IDL_TYP_STRING) {
      wildcard = IDL_VarGetString(argv[1]);
    }
  }
  MYSQL_RES *result = mysql_list_dbs((MYSQL *)argv[0]->value.ptrint,
                                     wildcard);
  return IDL_GettmpMEMINT((IDL_MEMINT) result);
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


// int mysql_select_db(MYSQL *mysql, const char *db)
static IDL_VPTR IDL_mg_mysql_select_db(int argc, IDL_VPTR *argv) {
  int status = mysql_select_db((MYSQL *) argv[0]->value.ptrint,
                               IDL_VarGetString(argv[1]));
  return IDL_GettmpLong(status);
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


// unsigned int mysql_errno(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_errno(int argc, IDL_VPTR *argv) {
  unsigned int err = mysql_errno((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpULong(err);
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


// my_ulonglong mysql_num_rows(MYSQL_RES *result);
static IDL_VPTR IDL_mg_mysql_num_rows(int argc, IDL_VPTR *argv) {
  unsigned long long num_rows = mysql_num_rows((MYSQL_RES *)argv[0]->value.ptrint);
  return IDL_GettmpULong64(num_rows);
}


// MYSQL_ROW STDCALL mysql_fetch_row(MYSQL_RES *result);
static IDL_VPTR IDL_mg_mysql_fetch_row(int argc, IDL_VPTR *argv) {
  MYSQL_ROW row = mysql_fetch_row((MYSQL_RES *)argv[0]->value.ptrint);
  return IDL_GettmpMEMINT((IDL_MEMINT) row);
}


// unsigned int mysql_field_count(MYSQL *mysql)
static IDL_VPTR IDL_mg_mysql_field_count(int argc, IDL_VPTR *argv) {
  unsigned int count = mysql_field_count((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpULong(count);
}


// not part of mysql.h, but needed to access the C fields
// typedef char **MYSQL_ROW;
static IDL_VPTR IDL_mg_mysql_get_field(int argc, IDL_VPTR *argv) {
  MYSQL_ROW row = (MYSQL_ROW) argv[0]->value.ptrint;
  IDL_ULONG field_index = IDL_ULongScalar(argv[1]);
  char *field = row[field_index];
  return IDL_StrToSTRING(field);
}


// not part of mysql.h, but needed to access the C fields
// typedef char **MYSQL_ROW;
static IDL_VPTR IDL_mg_mysql_get_blobfield(int argc, IDL_VPTR *argv) {
  MYSQL_ROW row = (MYSQL_ROW) argv[0]->value.ptrint;
  IDL_ULONG field_index = IDL_ULongScalar(argv[1]);
  unsigned long length = IDL_ULong64Scalar(argv[2]);

  char *field = row[field_index];

  IDL_ARRAY_DIM dims;
  IDL_VPTR blob;
  char *blob_data;
  int i;

  dims[0] = length;
  blob_data = (char *) IDL_MakeTempArray(IDL_TYP_BYTE,
                                         1,
                                         dims,
                                         IDL_ARR_INI_NOP,
                                         &blob);

  for (i = 0; i < length; i++) {
    blob_data[i] = field[i];
  }
  return blob;
}


// void STDCALL mysql_free_result(MYSQL_RES *result);
static void IDL_mg_mysql_free_result(int argc, IDL_VPTR *argv) {
  mysql_free_result((MYSQL_RES *)argv[0]->value.ptrint);
}


// my_ulonglong STDCALL mysql_insert_id(MYSQL *mysql);
static IDL_VPTR IDL_mg_mysql_insert_id(int argc, IDL_VPTR *argv) {
  my_ulonglong id = mysql_insert_id((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpULong64(id);
}


// MYSQL_FIELD * STDCALL mysql_fetch_fields(MYSQL_RES *res);
static IDL_VPTR IDL_mg_mysql_fetch_field(int argc, IDL_VPTR *argv) {
  static IDL_MEMINT nfields = 1;
  MYSQL_FIELD *field = mysql_fetch_field((MYSQL_RES *)argv[0]->value.ptrint);
  typedef struct field {
    IDL_STRING name;
    IDL_STRING org_name;
    IDL_STRING table;
    IDL_STRING org_table;
    IDL_STRING db;
    IDL_STRING catalog;
    IDL_STRING def;
    IDL_ULONG64 length;
    IDL_ULONG64 max_length;
    IDL_ULONG name_length;
    IDL_ULONG org_name_length;
    IDL_ULONG table_length;
    IDL_ULONG org_table_length;
    IDL_ULONG db_length;
    IDL_ULONG catalog_length;
    IDL_ULONG def_length;
    IDL_ULONG flags;
    IDL_ULONG decimals;
    IDL_ULONG charsetnr;
    IDL_ULONG type;
#if MYSQL_VERSION_ID >= 50100
    IDL_PTRINT extension;
#endif
  } MG_Field;
  MG_Field *mg_field_data = (MG_Field *) calloc(nfields, sizeof(MG_Field));
  void *idl_field_data;

  IDL_StrStore(&mg_field_data->name, field->name);
  IDL_StrStore(&mg_field_data->org_name, field->org_name);
  IDL_StrStore(&mg_field_data->table, field->table);
  IDL_StrStore(&mg_field_data->org_table, field->org_table);
  IDL_StrStore(&mg_field_data->db, field->db);
  IDL_StrStore(&mg_field_data->catalog, field->catalog);
  IDL_StrStore(&mg_field_data->def, field->def);

  mg_field_data->length = field->length;
  mg_field_data->max_length = field->max_length;

  mg_field_data->name_length = field->name_length;
  mg_field_data->org_name_length = field->org_name_length;
  mg_field_data->table_length = field->table_length;
  mg_field_data->org_table_length = field->org_table_length;
  mg_field_data->db_length = field->db_length;
  mg_field_data->catalog_length = field->catalog_length;
  mg_field_data->def_length = field->def_length;
  mg_field_data->flags = field->flags;
  mg_field_data->decimals = field->decimals;
  mg_field_data->charsetnr = field->charsetnr;
  mg_field_data->type = field->type;

#if MYSQL_VERSION_ID >= 50100
  mg_field_data->extension = (IDL_PTRINT)field->extension;
#endif

  idl_field_data = IDL_MakeStruct(0, mg_mysql_field);
  IDL_VPTR result = IDL_ImportArray(1,
                                    &nfields,
                                    IDL_TYP_STRUCT,
                                    (UCHAR *) mg_field_data,
                                    0,
                                    idl_field_data);
  return result;
}


// int STDCALL mysql_next_result(MYSQL *mysql);
// 0 successful and there are more results
// -1 successful and there are no more results
// >0 not successful
static IDL_VPTR IDL_mg_mysql_next_result(int argc, IDL_VPTR *argv) {
  int status = mysql_next_result((MYSQL *)argv[0]->value.ptrint);
  return IDL_GettmpLong(status);
}


// unsigned long STDCALL mysql_real_escape_string(MYSQL *mysql,
//                                                char *to, const char *from,
//                                                unsigned long length);
static IDL_VPTR IDL_mg_mysql_real_escape_string(int argc, IDL_VPTR *argv) {
  unsigned long length;
  IDL_ENSURE_ARRAY(argv[1])
  IDL_ENSURE_ARRAY(argv[2])
  length = mysql_real_escape_string((MYSQL *)argv[0]->value.ptrint,
                                    (char *) argv[1]->value.arr->data,
                                    (char *) argv[2]->value.arr->data,
                                    IDL_ULong64Scalar(argv[3]));
  return IDL_GettmpULong64(length);
}



// int STDCALL mysql_real_query(MYSQL *mysql, const char *q,
//                              unsigned long length);
static IDL_VPTR IDL_mg_mysql_real_query(int argc, IDL_VPTR *argv) {
  int status = mysql_real_query((MYSQL *)argv[0]->value.ptrint,
                                IDL_VarGetString(argv[1]),
                                IDL_ULong64Scalar(argv[2]));
  return IDL_GettmpLong(status);
}


// unsigned long * STDCALL mysql_fetch_lengths(MYSQL_RES *result);
static IDL_VPTR IDL_mg_mysql_fetch_lengths(int argc, IDL_VPTR *argv) {
  MYSQL_RES *result = (MYSQL_RES *)argv[0]->value.ptrint;
  unsigned int num_fields = mysql_num_fields(result);
  unsigned long *lengths = mysql_fetch_lengths(result);
  IDL_ARRAY_DIM dims;
  IDL_VPTR vptr_lengths;
  unsigned long *lengths_data;
  int i;

  dims[0] = num_fields;

  lengths_data = (unsigned long *) IDL_MakeTempArray(IDL_TYP_ULONG64,
                                                     1,
                                                     dims,
                                                     IDL_ARR_INI_NOP,
                                                     &vptr_lengths);
  for (i = 0; i < num_fields; i++) {
    lengths_data[i] = lengths[i];
  }
  return vptr_lengths;
}


#pragma mark --- lifecycle ---

// handle any cleanup required
static void mg_mysql_exit_handler(void) {
  mysql_library_end();
}

int IDL_Load(void) {
  IDL_StructDefPtr mg_mysql_field_sdef;

  /*
     These tables contain information on the functions and procedures
     that make up the MySQL DLM. The information contained in these
     tables must be identical to that contained in mg_mysql.dlm.
  */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_mysql_get_client_info,    "MG_MYSQL_GET_CLIENT_INFO",    0, 0, 0, 0 },
    { IDL_mg_mysql_get_client_version, "MG_MYSQL_GET_CLIENT_VERSION", 0, 0, 0, 0 },
    { IDL_mg_mysql_get_proto_info,     "MG_MYSQL_GET_PROTO_INFO",     1, 1, 0, 0 },
    { IDL_mg_mysql_get_host_info,      "MG_MYSQL_GET_HOST_INFO",      1, 1, 0, 0 },
    { IDL_mg_mysql_get_server_info,    "MG_MYSQL_GET_SERVER_INFO",    1, 1, 0, 0 },
    { IDL_mg_mysql_get_server_version, "MG_MYSQL_GET_SERVER_VERSION", 1, 1, 0, 0 },
    { IDL_mg_mysql_info,               "MG_MYSQL_INFO",               1, 1, 0, 0 },
    { IDL_mg_mysql_init,               "MG_MYSQL_INIT",               0, 0, 0, 0 },
    { IDL_mg_mysql_options,            "MG_MYSQL_OPTIONS",            3, 3, 0, 0 },
    { IDL_mg_mysql_list_tables,        "MG_MYSQL_LIST_TABLES",        1, 2, 0, 0 },
    { IDL_mg_mysql_list_dbs,           "MG_MYSQL_LIST_DBS",           1, 2, 0, 0 },
    { IDL_mg_mysql_real_connect,       "MG_MYSQL_REAL_CONNECT",       8, 8, 0, 0 },
    { IDL_mg_mysql_select_db,          "MG_MYSQL_SELECT_DB",          2, 2, 0, 0 },
    { IDL_mg_mysql_query,              "MG_MYSQL_QUERY",              2, 2, 0, 0 },
    { IDL_mg_mysql_error,              "MG_MYSQL_ERROR",              1, 1, 0, 0 },
    { IDL_mg_mysql_errno,              "MG_MYSQL_ERRNO",              1, 1, 0, 0 },
    { IDL_mg_mysql_store_result,       "MG_MYSQL_STORE_RESULT",       1, 1, 0, 0 },
    { IDL_mg_mysql_num_fields,         "MG_MYSQL_NUM_FIELDS",         1, 1, 0, 0 },
    { IDL_mg_mysql_num_rows,           "MG_MYSQL_NUM_ROWS",           1, 1, 0, 0 },
    { IDL_mg_mysql_fetch_row,          "MG_MYSQL_FETCH_ROW",          1, 1, 0, 0 },
    { IDL_mg_mysql_field_count,        "MG_MYSQL_FIELD_COUNT",        1, 1, 0, 0 },
    { IDL_mg_mysql_get_field,          "MG_MYSQL_GET_FIELD",          2, 2, 0, 0 },
    { IDL_mg_mysql_get_blobfield,      "MG_MYSQL_GET_BLOBFIELD",      3, 3, 0, 0 },
    { IDL_mg_mysql_insert_id,          "MG_MYSQL_INSERT_ID",          1, 1, 0, 0 },
    { IDL_mg_mysql_fetch_field,        "MG_MYSQL_FETCH_FIELD",        1, 1, 0, 0 },
    { IDL_mg_mysql_fetch_lengths,      "MG_MYSQL_FETCH_LENGTHS",      1, 1, 0, 0 },
    { IDL_mg_mysql_next_result,        "MG_MYSQL_NEXT_RESULT",        1, 1, 0, 0 },
    { IDL_mg_mysql_real_escape_string, "MG_MYSQL_REAL_ESCAPE_STRING", 4, 4, 0, 0 },
    { IDL_mg_mysql_real_query,         "MG_MYSQL_REAL_QUERY",         3, 3, 0, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_mysql_close,       "MG_MYSQL_CLOSE",        1, 1, 0, 0 },
    { (IDL_SYSRTN_GENERIC) IDL_mg_mysql_free_result, "MG_MYSQL_FREE_RESULT",  1, 1, 0, 0 },
  };

  mg_mysql_field_sdef = IDL_MakeStruct("MG_MYSQL_FIELD", mg_mysql_field);

  if (mysql_library_init(0, NULL, NULL)) {
    // initialization failed
    return 0;
  }

  IDL_ExitRegister(mg_mysql_exit_handler);

  /*
     Register our routines. The routines must be specified exactly the same
     as in mg_mysql.dlm.
  */
  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
      && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
