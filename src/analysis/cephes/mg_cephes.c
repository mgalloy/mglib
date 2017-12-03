#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "mg_idl_export.h"
#include "protos.h"

static IDL_VPTR IDL_CDECL IDL_mg_fdtr(int argc, IDL_VPTR *argv) {
  double a, b, x;
  a = IDL_DoubleScalar(argv[0]);
  b = IDL_DoubleScalar(argv[1]);
  x = IDL_DoubleScalar(argv[2]);
  return IDL_GettmpDouble(cephes_fdtr(a, b, x));
}

static IDL_VPTR IDL_CDECL IDL_mg_fdtrc(int argc, IDL_VPTR *argv) {
  double a, b, x;
  a = IDL_DoubleScalar(argv[0]);
  b = IDL_DoubleScalar(argv[1]);
  x = IDL_DoubleScalar(argv[2]);
  return IDL_GettmpDouble(cephes_fdtrc(a, b, x));
}

static IDL_VPTR IDL_CDECL IDL_mg_fdtri(int argc, IDL_VPTR *argv) {
  double a, b, x;
  a = IDL_DoubleScalar(argv[0]);
  b = IDL_DoubleScalar(argv[1]);
  x = IDL_DoubleScalar(argv[2]);
  return IDL_GettmpDouble(cephes_fdtri(a, b, x));
}

int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the analysis DLM. The information contained in these
   * tables must be identical to that contained in mg_analysis.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_fdtrc,       "MG_FDTR",        3, 3, 0, 0 },
    { IDL_mg_fdtrc,       "MG_FDTRC",       3, 3, 0, 0 },
    { IDL_mg_fdtrc,       "MG_FDTRI",       3, 3, 0, 0 },
  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in mg_analysis.dlm.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
