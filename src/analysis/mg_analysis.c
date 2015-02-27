#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "mg_idl_export.h"

/**************************************************************************
  Helper routines
***************************************************************************/

#define MG_C_ABS(z) sqrt(z.r*z.r + z.i*z.i)

#define MG_ARRAY_EQUAL_ARR2ARR(TYPE, TOLERANCE_TYPE, DIFFERENCE_EXPR, ABS)  \
static int mg_array_equal_ ## TYPE ## _arr2arr(int n,                       \
                                        TYPE *arr1, TYPE *arr2,             \
                                        TOLERANCE_TYPE tolerance) {         \
  int i;                                                                    \
  for (i = 0; i < n; i++) {                                                 \
    TYPE d, a1 = arr1[i], a2 = arr2[i];                                     \
    DIFFERENCE_EXPR;                                                        \
    if (ABS(d) > tolerance) return 0;                                       \
  }                                                                         \
  return 1;                                                                 \
}

MG_ARRAY_EQUAL_ARR2ARR(UCHAR, UCHAR, d = a1 - a2, abs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_INT, IDL_INT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_LONG, IDL_LONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_ARR2ARR(float, float, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_ARR2ARR(double, double, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_COMPLEX, float, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_ARR2ARR(IDL_DCOMPLEX, double, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_ARR2ARR(IDL_UINT, IDL_UINT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_ULONG, IDL_ULONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_LONG64, IDL_LONG64, d = a1 - a2, labs)
MG_ARRAY_EQUAL_ARR2ARR(IDL_ULONG64, IDL_ULONG64, d = a1 - a2, labs)

#define MG_ARRAY_EQUAL_SCALAR2ARR(TYPE, TOLERANCE_TYPE, DIFFERENCE_EXPR, ABS) \
static int mg_array_equal_ ## TYPE ## _scalar2arr(int n,                      \
                                           TYPE scalar, TYPE *arr,            \
                                           TOLERANCE_TYPE tolerance) {        \
  int i;                                                                      \
  for (i = 0; i < n; i++) {                                                   \
    TYPE d, a1 = scalar, a2 = arr[i];                                         \
    DIFFERENCE_EXPR;                                                          \
    if (ABS(d) > tolerance) return 0;                                         \
  }                                                                           \
  return 1;                                                                   \
}

MG_ARRAY_EQUAL_SCALAR2ARR(UCHAR, UCHAR, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_INT, IDL_INT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_LONG, IDL_LONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2ARR(float, float, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_SCALAR2ARR(double, double, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_COMPLEX, float, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_DCOMPLEX, double, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_UINT, IDL_UINT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_ULONG, IDL_ULONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_LONG64, IDL_LONG64, d = a1 - a2, labs)
MG_ARRAY_EQUAL_SCALAR2ARR(IDL_ULONG64, IDL_ULONG64, d = a1 - a2, labs)

#define MG_ARRAY_EQUAL_SCALAR2SCALAR(TYPE, TOLERANCE_TYPE, DIFFERENCE_EXPR, ABS) \
static int mg_array_equal_ ## TYPE ## _scalar2scalar(TYPE scalar1, TYPE scalar2, \
                                              TOLERANCE_TYPE tolerance) {        \
  int i;                                                                         \
  TYPE d, a1 = scalar1, a2 = scalar2;                                            \
  DIFFERENCE_EXPR;                                                               \
  if (ABS(d) > tolerance) return 0;                                              \
  return 1;                                                                      \
}

MG_ARRAY_EQUAL_SCALAR2SCALAR(UCHAR, UCHAR, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_INT, IDL_INT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_LONG, IDL_LONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(float, float, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(double, double, d = a1 - a2, fabs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_COMPLEX, float, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_DCOMPLEX, double, d.r = a1.r - a2.r; d.i = a1.i - a2.i, MG_C_ABS)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_UINT, IDL_UINT, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_ULONG, IDL_ULONG, d = a1 - a2, abs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_LONG64, IDL_LONG64, d = a1 - a2, labs)
MG_ARRAY_EQUAL_SCALAR2SCALAR(IDL_ULONG64, IDL_ULONG64, d = a1 - a2, labs)


#define MG_ARRAY_EQUAL_ARR2ARR_CASE(TYPE_VALUE, TYPE, TOLERANCE_TYPE, IDL_MEMBER, ZERO)          \
    case TYPE_VALUE:                                                                             \
      is_equal = mg_array_equal_ ## TYPE ## _arr2arr(argv[0]->value.arr->n_elts,                 \
                                                     (TYPE *) argv[0]->value.arr->data,          \
                                                     (TYPE *) argv[1]->value.arr->data,          \
                                                     kw.tolerance_present ? kw.tolerance->value.IDL_MEMBER : ZERO); \
      break;

#define MG_ARRAY_EQUAL_SCALAR2ARR_CASE(TYPE_VALUE, TYPE, SCALAR_ARG, ARR_ARG, TOLERANCE_TYPE, IDL_ARGMEMBER, IDL_TOLMEMBER, ZERO) \
    case TYPE_VALUE:                                                                              \
      is_equal = mg_array_equal_ ## TYPE ## _scalar2arr(ARR_ARG->value.arr->n_elts,               \
                                                        (TYPE) SCALAR_ARG->value.IDL_ARGMEMBER,   \
                                                        (TYPE *) ARR_ARG->value.arr->data,        \
                                                        kw.tolerance_present ? kw.tolerance->value.IDL_TOLMEMBER : ZERO); \
      break;

#define MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(TYPE_VALUE, TYPE, TOLERANCE_TYPE, IDL_ARGMEMBER, IDL_TOLMEMBER, ZERO)    \
    case TYPE_VALUE:                                                                              \
      is_equal = mg_array_equal_ ## TYPE ## _scalar2scalar((TYPE) argv[0]->value.IDL_ARGMEMBER,   \
                                                           (TYPE) argv[1]->value.IDL_ARGMEMBER,   \
                                                           kw.tolerance_present ? kw.tolerance->value.IDL_TOLMEMBER : ZERO); \
      break;


static IDL_VPTR IDL_CDECL IDL_mg_array_equal(int argc, IDL_VPTR *argv, char *argk) {
  int is_equal, nargs;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_LONG no_typeconv;
    IDL_VPTR tolerance;
    int tolerance_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "NO_TYPECONV", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(no_typeconv) },
    { "TOLERANCE", IDL_TYP_UNDEF, 1, IDL_KW_VIN | IDL_KW_OUT,
      IDL_KW_OFFSETOF(tolerance_present), IDL_KW_OFFSETOF(tolerance) },
    { NULL }
  };

  KW_RESULT kw;

  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SIMPLE(argv[1]);

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  if (kw.no_typeconv && (argv[0]->type != argv[1]->type)) {
    IDL_KW_FREE;
    return IDL_GettmpByte(0);
  }

  if (argv[0]->type != argv[1]->type) {
    IDL_KW_FREE;
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "input parameters must be of the same type");
  }

  // tolerance must be the same type, but complex tolerance should be float
  // and double complex tolerance should be double
  if (kw.tolerance_present && (kw.tolerance->type != argv[0]->type)
        && (kw.tolerance->type != 4 || argv[0]->type != 6)
        && (kw.tolerance->type != 5 || argv[0]->type != 9)) {
    IDL_KW_FREE;
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "TOLERANCE and input parameters must be of the same type");
  }

  // TODO: conversion between two different types

  if (argv[0]->flags & IDL_V_ARR && argv[1]->flags & IDL_V_ARR) {
    if (argv[0]->value.arr->n_elts != argv[1]->value.arr->n_elts) {
      IDL_KW_FREE;
      return IDL_GettmpByte(0);
    }

    switch (argv[0]->type) {
      MG_ARRAY_EQUAL_ARR2ARR_CASE(1, UCHAR, UCHAR, c, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(2, IDL_INT, IDL_INT, i, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(3, IDL_LONG, IDL_LONG, l, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(4, float, float, f, 0.0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(5, double, double, d, 0.0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(6, IDL_COMPLEX, float, f, 0.0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(9, IDL_DCOMPLEX, double, d, 0.0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(12, IDL_UINT, IDL_UINT, ui, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(13, IDL_ULONG, IDL_ULONG, ul, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(14, IDL_LONG64, IDL_LONG64, l64, 0)
      MG_ARRAY_EQUAL_ARR2ARR_CASE(15, IDL_ULONG64, IDL_ULONG64, ul64, 0)
    }
  } else if (argv[0]->flags & IDL_V_ARR && !(argv[1]->flags & IDL_V_ARR)) {
    switch (argv[0]->type) {
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(1, UCHAR, argv[1], argv[0], UCHAR, c, c, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(2, IDL_INT, argv[1], argv[0], IDL_INT, i, i, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(3, IDL_LONG, argv[1], argv[0], IDL_LONG, l, l, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(4, float, argv[1], argv[0], float, f, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(5, double, argv[1], argv[0], double, d, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(6, IDL_COMPLEX, argv[1], argv[0], float, cmp, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(9, IDL_DCOMPLEX, argv[1], argv[0], double, dcmp, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(12, IDL_UINT, argv[1], argv[0], IDL_UINT, ui, ui, 0);
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(13, IDL_ULONG, argv[1], argv[0], IDL_ULONG, ul, ul, 0);
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(14, IDL_LONG64, argv[1], argv[0], IDL_LONG64, l64, l64, 0);
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(15, IDL_ULONG64, argv[1], argv[0], IDL_ULONG64, ul64, ul64, 0);
    }
  } else if (!(argv[0]->flags & IDL_V_ARR) && argv[1]->flags & IDL_V_ARR) {
    switch (argv[0]->type) {
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(1, UCHAR, argv[0], argv[1], UCHAR, c, c, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(2, IDL_INT, argv[0], argv[1], IDL_INT, i, i, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(3, IDL_LONG, argv[0], argv[1], IDL_LONG, l, l, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(4, float, argv[0], argv[1], float, f, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(5, double, argv[0], argv[1], double, d, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(6, IDL_COMPLEX, argv[0], argv[1], float, cmp, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(9, IDL_DCOMPLEX, argv[0], argv[1], double, dcmp, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(12, IDL_UINT, argv[0], argv[1], IDL_UINT, ui, ui, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(13, IDL_ULONG, argv[0], argv[1], IDL_ULONG, ul, ul, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(14, IDL_LONG64, argv[0], argv[1], IDL_LONG64, l64, l64, 0)
      MG_ARRAY_EQUAL_SCALAR2ARR_CASE(15, IDL_ULONG64, argv[0], argv[1], IDL_ULONG64, ul64, ul64, 0)
    }
  } else {
    switch (argv[0]->type) {
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(1, UCHAR, UCHAR, c, c, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(2, IDL_INT, IDL_INT, i, i, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(3, IDL_LONG, IDL_LONG, l, l, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(4, float, float, f, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(5, double, double, d, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(6, IDL_COMPLEX, float, cmp, f, 0.0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(9, IDL_DCOMPLEX, double, dcmp, d, 0.0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(12, IDL_UINT, IDL_UINT, ui, ui, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(13, IDL_ULONG, IDL_ULONG, ul, ul, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(14, IDL_LONG64, IDL_LONG64, l64, l64, 0)
      MG_ARRAY_EQUAL_SCALAR2SCALAR_CASE(15, IDL_ULONG64, IDL_ULONG64, ul64, ul64, 0)
    }
  }

  IDL_KW_FREE;

  return IDL_GettmpByte(is_equal);
}


// Uses the Kahan summation algorithm:
//
//    http://en.wikipedia.org/wiki/Kahan_summation_algorithm
#define IDL_MG_TOTAL_TYPE(TYPE, IDL_TYPE, INIT)                              \
static IDL_VPTR IDL_CDECL IDL_mg_total_ ## IDL_TYPE (IDL_VPTR arg) {         \
  TYPE sum = INIT, c = INIT, y = INIT, t = INIT;                             \
  int i;                                                                     \
                                                                             \
  TYPE *arr = (TYPE *)arg->value.arr->data;                                  \
                                                                             \
  for (i = 0; i < arg->value.arr->n_elts; i++) {                             \
    y = arr[i] - c;                                                          \
    t = sum + y;                                                             \
    c = (t - sum) - y;                                                       \
    sum = t;                                                                 \
  }                                                                          \
  return(IDL_Gettmp ## IDL_TYPE (sum));                                      \
}

#define IDL_MG_TOTAL_CTYPE(TYPE, IDL_TYPE, INIT, FIELD, TYPE_CODE)           \
static IDL_VPTR IDL_CDECL IDL_mg_total_ ## IDL_TYPE (IDL_VPTR arg) {         \
  IDL_VPTR result;                                                           \
  TYPE sum, c, y, t;                                                         \
                                                                             \
  int i;                                                                     \
                                                                             \
  TYPE *arr = (TYPE *)arg->value.arr->data;                                  \
                                                                             \
  sum.r = INIT;                                                              \
  sum.i = INIT;                                                              \
  c.r = INIT;                                                                \
  c.i = INIT;                                                                \
  y.r = INIT;                                                                \
  y.i = INIT;                                                                \
  t.r = INIT;                                                                \
  t.i = INIT;                                                                \
                                                                             \
  for (i = 0; i < arg->value.arr->n_elts; i++) {                             \
    y.r = arr[i].r - c.r;                                                    \
    y.i = arr[i].i - c.i;                                                    \
    t.r = sum.r + y.r;                                                       \
    t.i = sum.i + y.i;                                                       \
    c.r = (t.r - sum.r) - y.r;                                               \
    c.i = (t.i - sum.i) - y.i;                                               \
    sum.r = t.r;                                                             \
    sum.i = t.i;                                                             \
  }                                                                          \
                                                                             \
  result = IDL_Gettmp();                                                     \
  result->type = TYPE_CODE;                                                  \
  result->value.FIELD.r = sum.r;                                             \
  result->value.FIELD.i = sum.i;                                             \
                                                                             \
  return(result);                                                            \
}

IDL_MG_TOTAL_TYPE(UCHAR, Byte, 0)
IDL_MG_TOTAL_TYPE(short int, Int, 0)
IDL_MG_TOTAL_TYPE(int, Long, 0)
IDL_MG_TOTAL_TYPE(float, Float, 0.0)
IDL_MG_TOTAL_TYPE(double, Double, 0.0)
IDL_MG_TOTAL_CTYPE(IDL_COMPLEX, Complex, 0.0, cmp, IDL_TYP_COMPLEX)
IDL_MG_TOTAL_CTYPE(IDL_DCOMPLEX, DComplex, 0.0, dcmp, IDL_TYP_DCOMPLEX)
IDL_MG_TOTAL_TYPE(IDL_UINT, UInt, 0)
IDL_MG_TOTAL_TYPE(IDL_ULONG, ULong, 0)
IDL_MG_TOTAL_TYPE(IDL_LONG64, Long64, 0)
IDL_MG_TOTAL_TYPE(IDL_ULONG64, ULong64, 0)

static IDL_VPTR IDL_CDECL IDL_mg_total(int argc, IDL_VPTR *argv, char *argk) {
  IDL_ENSURE_ARRAY(argv[0]);
  switch (argv[0]->type) {
    case IDL_TYP_BYTE:
      return(IDL_mg_total_Byte(argv[0]));
    case IDL_TYP_INT:
      return(IDL_mg_total_Int(argv[0]));
    case IDL_TYP_LONG:
      return(IDL_mg_total_Long(argv[0]));
    case IDL_TYP_FLOAT:
      return(IDL_mg_total_Float(argv[0]));
    case IDL_TYP_DOUBLE:
      return(IDL_mg_total_Double(argv[0]));
    case IDL_TYP_COMPLEX:
      return(IDL_mg_total_Complex(argv[0]));
    case IDL_TYP_DCOMPLEX:
      return(IDL_mg_total_DComplex(argv[0]));
    case IDL_TYP_UINT:
      return(IDL_mg_total_UInt(argv[0]));
    case IDL_TYP_ULONG:
      return(IDL_mg_total_ULong(argv[0]));
    case IDL_TYP_LONG64:
      return(IDL_mg_total_Long64(argv[0]));
    case IDL_TYP_ULONG64:
      return(IDL_mg_total_ULong64(argv[0]));
    default:
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, "unknown type");
  }
  return(IDL_GettmpLong(0));  // needed to not get a compiler warning
}

#define IDL_MG_MATRIX_VECTOR_MULTIPLY(TYPE)                                  \
void IDL_mg_matrix_vector_multiply_ ## TYPE(TYPE *a_data, TYPE *b_data, TYPE *result_data, int n, int m) { \
  int row, col;                                                              \
  for (row = 0; row < m; row++) {                                            \
    for (col = 0; col < n; col++) {                                          \
      result_data[row] += a_data[row * n + col] * b_data[col];               \
    }                                                                        \
  }                                                                          \
}

IDL_MG_MATRIX_VECTOR_MULTIPLY(float)
IDL_MG_MATRIX_VECTOR_MULTIPLY(double)

#define IDL_MG_BATCH_MATRIX_VECTOR_MULTIPLY(TYPE, IDL_TYPE) \
IDL_VPTR IDL_mg_batch_matrix_vector_multiply_ ## TYPE(IDL_VPTR a, IDL_VPTR b, int n, int m, int n_multiplies) { \
  IDL_VPTR result; \
  int i; \
  IDL_MEMINT dims[] = { m, n_multiplies }; \
  TYPE *result_data = (TYPE *) IDL_MakeTempArray(IDL_TYPE, 2, dims, IDL_ARR_INI_ZERO, &result); \
  TYPE *a_data = (TYPE *)a->value.arr->data; \
  TYPE *b_data = (TYPE *)b->value.arr->data; \
  for (i = 0; i < n_multiplies; i++) { \
    IDL_mg_matrix_vector_multiply_ ## TYPE(a_data + n * m * i, \
                                           b_data + n * i, \
                                           result_data + m * i, \
                                           n, m); \
  } \
  return result; \
}

IDL_MG_BATCH_MATRIX_VECTOR_MULTIPLY(float, IDL_TYP_FLOAT)
IDL_MG_BATCH_MATRIX_VECTOR_MULTIPLY(double, IDL_TYP_DOUBLE)

static IDL_VPTR IDL_mg_batched_matrix_vector_multiply(int argc, IDL_VPTR *argv) {
  IDL_VPTR a = argv[0];
  IDL_VPTR b = argv[1];
  IDL_LONG n = IDL_LongScalar(argv[2]);
  IDL_LONG m = IDL_LongScalar(argv[3]);
  IDL_LONG n_multiplies = IDL_LongScalar(argv[4]);
  IDL_VPTR result;

  switch (a->type) {
    case IDL_TYP_FLOAT:
      result = IDL_mg_batch_matrix_vector_multiply_float(a, b, n, m, n_multiplies);
      break;
    case IDL_TYP_DOUBLE:
      result = IDL_mg_batch_matrix_vector_multiply_double(a, b, n, m, n_multiplies);
      break;
  }
  
  return result;
}


int IDL_Load(void) {
  /*
   * These tables contain information on the functions and procedures
   * that make up the cmdline_tools DLM. The information contained in these
   * tables must be identical to that contained in mg_introspection.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_array_equal, "MG_ARRAY_EQUAL", 2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_mg_total,       "MG_TOTAL",       1, 1, 0, 0 },
    { IDL_mg_batched_matrix_vector_multiply, "MG_BATCHED_MATRIX_VECTOR_MULTIPLY", 5, 5, 0, 0 },

  };

  /*
   * Register our routines. The routines must be specified exactly the same
   * as in mg_introspection.dlm.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
