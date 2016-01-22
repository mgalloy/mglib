#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "netcdf.h"

#include "mg_idl_export.h"

static IDL_VPTR IDL_CDECL IDL_mg_nc_isncdf(int argc, IDL_VPTR *argv) {
  IDL_VPTR cptr_filename = argv[0];
  int status, ncidp;
  IDL_ENSURE_STRING(cptr_filename);
  status = nc_open(IDL_VarGetString(cptr_filename), 0, &ncidp);
  return IDL_GettmpByte(status == NC_ENOTNC ? 0 : 1);
}

int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the analysis DLM. The information contained in these
   * tables must be identical to that contained in mg_analysis.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_nc_isncdf, "MG_NC_ISNCDF", 1, 1, 0, 0 },
  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in mg_netcdf.dlm.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
