/*
  DLM for visualization of flow in IDL.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "idl_export.h"

#define N_SEGMENTS 20
#define STEP_SIZE 0.5

// forward/backward streamlines
int nfwd, nbwd;
float fwd_float[2][N_SEGMENTS], bwd_float[2][N_SEGMENTS];
double fwd_double[2][N_SEGMENTS], bwd_double[2][N_SEGMENTS];

// vector field
IDL_VPTR u, v;


/*
  Perform the Runge-Kutta method from the given x, y point and stepping the
  given step size. The step argument is set negative to get the backwards
  streamline.

  Returns the status of finding the new point in the streamline and places
  the new point in the seg parameter.

  Uses the u and v file variables to lookup vector field values.
*/
#define MG_LIC_RK(TYPE) \
static int mg_lic_rk_ ## TYPE(TYPE x, TYPE y, TYPE step, TYPE seg[]) { \
  TYPE *udata = (TYPE *)u->value.arr->data, *vdata = (TYPE *)v->value.arr->data; \
  TYPE k[2][4], coef[] = { 0.0, 0.5, 0.5, 1.0 }; \
  int c; \
  TYPE mag; \
  TYPE uv[2], xy[2] = { x, y }; \
  int ind; \
  int size = u->value.arr->dim[0] * u->value.arr->dim[1]; \
 \
  for (c = 0; c < 4; c++) { \
    xy[0] = x + k[0][0] * coef[c]; \
    xy[1] = y + k[1][0] * coef[c]; \
 \
    ind = (int) xy[0] + (int) xy[1] * u->value.arr->dim[0]; \
    if (ind < 0 || ind >= size) return 0; \
    uv[0] = udata[ind]; \
    uv[1] = vdata[ind]; \
 \
    mag = sqrt(uv[0] * uv[0] + uv[1] * uv[1]); \
    if (mag != 0) { \
      uv[0] /= mag; \
      uv[1] /= mag; \
    } \
 \
    k[0][c] = uv[0] * step; \
    k[1][c] = uv[1] * step; \
  } \
 \
  seg[0] = x + k[0][0] / 6.0 + k[0][1] / 3.0 + k[0][2] / 3.0 + k[0][3] / 6.0; \
  seg[1] = y + k[1][0] / 6.0 + k[1][1] / 3.0 + k[1][2] / 3.0 + k[1][3] / 6.0; \
 \
  return 1; \
}

MG_LIC_RK(float);
MG_LIC_RK(double);


/*
  Compute streamline forward and backward for the element at the given row
  and column.
*/
#define MG_LIC_STREAMLINE(TYPE) \
static void mg_lic_streamline_ ## TYPE(TYPE row, TYPE col, int nrows, int ncols) { \
  int fwdValid = 1; \
  int bwdValid = 1; \
  int k; \
  TYPE seg[2]; \
 \
  nfwd = 0; \
  nbwd = 0; \
 \
  fwdValid = mg_lic_rk_ ## TYPE(col + 0.5, row + 0.5, STEP_SIZE, seg); \
  if (seg[0] < 0 || seg[0] >= ncols) fwdValid = 0; \
  if (seg[1] < 0 || seg[1] >= nrows) fwdValid = 0; \
  fwd_ ## TYPE[0][0] = seg[0]; \
  fwd_ ## TYPE[1][0] = seg[1]; \
  if (fwdValid) nfwd++; \
 \
  bwdValid = mg_lic_rk_ ## TYPE(col + 0.5, row + 0.5, - STEP_SIZE, seg); \
  if (seg[0] < 0 || seg[0] >= ncols) bwdValid = 0; \
  if (seg[1] < 0 || seg[1] >= nrows) bwdValid = 0; \
  bwd_ ## TYPE[0][0] = seg[0]; \
  bwd_ ## TYPE[1][0] = seg[1]; \
  if (bwdValid) nbwd++; \
 \
  for (k = 1; k < N_SEGMENTS; k++) { \
    if (fwdValid) { \
      fwdValid = mg_lic_rk_ ## TYPE(fwd_ ## TYPE[0][k-1], fwd_ ## TYPE[1][k-1], STEP_SIZE, seg); \
      if (seg[0] < 0 || seg[0] >= ncols) fwdValid = 0; \
      if (seg[1] < 0 || seg[1] >= nrows) fwdValid = 0; \
      fwd_ ## TYPE[0][k] = seg[0]; \
      fwd_ ## TYPE[1][k] = seg[1]; \
      if (fwdValid) nfwd++; \
    } \
 \
    if (bwdValid) { \
      bwdValid = mg_lic_rk_ ## TYPE(bwd_ ## TYPE[0][k-1], bwd_ ## TYPE[1][k-1], - STEP_SIZE, seg); \
      if (seg[0] < 0 || seg[0] >= ncols) bwdValid = 0; \
      if (seg[1] < 0 || seg[1] >= nrows) bwdValid = 0; \
      bwd_ ## TYPE[0][k] = seg[0]; \
      bwd_ ## TYPE[1][k] = seg[1]; \
      if (bwdValid) nbwd++; \
    } \
  } \
}

MG_LIC_STREAMLINE(float);
MG_LIC_STREAMLINE(double);


/*
  Line-integral convolution (LIC) for flow visualization based on "Imaging
  Vector Fields Using Line Integral Convolution" by Brian Cabral and Leith
  (Casey) Leedom.

  Arguments for the routine are passed from IDL. They are:

  :Params:
     u : in, required, type=fltarr(m, n)
        x-coordinates of vector field
     v : in, required, type=fltarr(m, n)
        y-coordinates of vector field

  :Keywords:
     texture : in, optional, type=bytarr(m, n)
        texture map i.e. random noise
*/
static IDL_VPTR IDL_mg_lic(int argc, IDL_VPTR *argv, char *argk) {
  IDL_VPTR result, tex, integral, hits, plain_args[2];
  int nargs;
  unsigned char *result_data, *tex_data;
  int *integral_data;
  int item, row, col, nrows, ncols, f, b, sum;
  int max;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR texture;
    int texture_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "TEXTURE", IDL_TYP_UNDEF, 1, IDL_KW_VIN | IDL_KW_OUT,
      IDL_KW_OFFSETOF(texture_present), IDL_KW_OFFSETOF(texture) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, plain_args, 1, &kw);
  u = plain_args[0];
  v = plain_args[1];
  ncols = u->value.arr->dim[0];
  nrows = u->value.arr->dim[1];

  // check inputs
  IDL_ENSURE_SIMPLE(u);
  IDL_ENSURE_ARRAY(u);

  IDL_ENSURE_SIMPLE(v);
  IDL_ENSURE_ARRAY(v);

  if (u->type != IDL_TYP_FLOAT && u->type != IDL_TYP_DOUBLE) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "u and v parameters must be float or double");
  }

  if (u->type != v->type) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "u and v parameters must be of the same type");
  }

  if (u->value.arr->n_dim !=2 || v->value.arr->n_dim != 2) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "u and v parameters must be 2 dimensional");
  }

  if (u->value.arr->dim[0] != v->value.arr->dim[0]
        || u->value.arr->dim[1] != v->value.arr->dim[1]) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "u and v parameters must have the same dimensions");
  }

  if (kw.texture_present) {
    IDL_ENSURE_SIMPLE(kw.texture);
    IDL_ENSURE_ARRAY(kw.texture);
    if (kw.texture->type != IDL_TYP_BYTE ) {
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                  "TEXTURE must be of type byte");
    }
    if (kw.texture->value.arr->n_dim !=2) {
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                  "TEXTURE must be 2 dimensional");
    }
    if (u->value.arr->dim[0] != kw.texture->value.arr->dim[0]
          || u->value.arr->dim[1] != kw.texture->value.arr->dim[1]) {
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                  "TEXTURE must have the same dimensions as parameters");
    }
  }

  // variable to return result in
  result_data = (unsigned char *) IDL_MakeTempArray(IDL_TYP_BYTE,
                                                    u->value.arr->n_dim,
                                                    u->value.arr->dim,
                                                    IDL_ARR_INI_NOP,
                                                    &result);

  // random texture
  if (kw.texture_present) {
    tex_data = (unsigned char *) &kw.texture->value.arr->data;
  } else {
    tex_data = (unsigned char *) IDL_MakeTempArray(IDL_TYP_BYTE,
                                                   u->value.arr->n_dim,
                                                   u->value.arr->dim,
                                                   IDL_ARR_INI_NOP,
                                                   &tex);
    // initialize texture array with random data
    for (item = 0; item < nrows * ncols; item++) {
      *(tex_data + item) = (unsigned char) rand();
    }
  }

  integral_data = (int *) IDL_MakeTempArray(IDL_TYP_LONG,
                                            u->value.arr->n_dim,
                                            u->value.arr->dim,
                                            IDL_ARR_INI_NOP,
                                            &integral);

  // calculate the line-intergral convolution (put in result_data)
  for (row = 0; row < nrows; row++) {
    for (col = 0; col < ncols; col++) {
      // compute streamline
      if (u->type == IDL_TYP_FLOAT) {
        mg_lic_streamline_float((float) row, (float) col, nrows, ncols);
      } else {
        mg_lic_streamline_double((double) row, (double) col, nrows, ncols);
      }

      // compute I: average of texture at fwd/bwd indices
      sum = (int) *(tex_data + col + row * ncols);
      for (f = 0; f < nfwd; f++) {
        sum += (int) *(tex_data
                        + (int) (u->type == IDL_TYP_FLOAT ? fwd_float[0][f] : fwd_double[0][f])
                        + (int) (u->type == IDL_TYP_FLOAT ? fwd_float[1][f] : fwd_double[1][f]) * ncols);
      }

      for (b = 0; b < nbwd; b++) {
        sum += (int) *(tex_data
                         + (int) (u->type == IDL_TYP_FLOAT ? bwd_float[0][b] : bwd_double[0][b])
                         + (int) (u->type == IDL_TYP_FLOAT ? bwd_float[1][b] : bwd_double[1][b]) * ncols);
      }

      *(integral_data + col + row * ncols) = sum / (nfwd + nbwd + 1);
    }
  }

  // normalize result

  // find max of integral_data
  max = 0;
  for (item = 0; item < nrows * ncols; item++) {
    if (*(integral_data + item) > max) {
      max = *(integral_data + item);
    }
  }

  if (max > 0) {
    for (item = 0; item < nrows * ncols; item++) {
      *(result_data + item) = (char) (255 * *(integral_data + item) / max);
    }
  }

  // free IDL temporary variables
  if (!kw.texture_present) IDL_Deltmp(tex);
  IDL_Deltmp(integral);
  IDL_KW_FREE;

  return result;
}


/*
  Register the routines available for IDL; they must be specified exactly as
  in mg_flow.dlm.
*/

// functions to register
static IDL_SYSFUN_DEF2 function_addr[] = {
  { IDL_mg_lic,     "MG_LIC",     2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
};

int IDL_Load(void) {
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
