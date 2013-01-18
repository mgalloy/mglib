#include <stdio.h>
#include "idl_export.h"


static IDL_VPTR get_IDL_long(int l) {
  IDL_VPTR idl_l;
  if ((idl_l = IDL_Gettmp()) == (IDL_VPTR) NULL) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "Could not create temporary variable");
  }

  idl_l->type = IDL_TYP_LONG;
  idl_l->value.l = (IDL_LONG) l;

  return idl_l;
}


IDL_VPTR IDL_mg_sizeof(int argc, IDL_VPTR *argv) {
  IDL_ARRAY arr;
  int s;
  IDL_VPTR v = argv[0];

  s = sizeof(*v);

  if ((*v).flags & IDL_V_ARR) {
    arr = *((*v).value).arr;
    s += sizeof(arr) + arr.elt_len * arr.n_elts;
  }

  if ((*v).flags & IDL_V_STRUCT) {
    s += sizeof((*v).value.s);
  }

  return get_IDL_long(s);
}





int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the cmdline_tools DLM. The information contained in these
   * tables must be identical to that contained in mg_introspection.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_sizeof,     "MG_SIZEOF",     1, 1, 0, 0 },
  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in mg_introspection.dlm.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
