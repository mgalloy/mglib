/*
  DLM for visualization of line plots in IDL.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "idl_export.h"


// Try to implement Bresenham's line algorithm from:
//
//   http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

//
// generate x,y coordinates to draw a line from
// x0,y0 to x1,y1 and output the coordinates in
// the same direction that they are drawn.
// any coordinates which overlap other coordinates
// are duplicates and are removed from the output
// because they are redundant.
//

//int idx, dupe; // declared external 

//void line(int x0, int y0, int x1, int y1) {
//    int x, cx, deltax, xstep,
//        y, cy, deltay, ystep,
//        n, error, st;
//
//    // find largest delta for pixel steps
//    st = (abs(y1 - y0) > abs(x1 - x0));
//
//    // if deltay > deltax then swap x,y
//    if (st) {
//        swap(x0, y0);
//        swap(x1, y1);
//    }
//
//    deltax = abs(x1 - x0);
//    deltay = abs(y1 - y0);
//    error  = (deltax / 2);
//    y = y0;
//
//    if (x0 > x1) { xstep = -1; }
//    else         { xstep =  1; }
//
//    if (y0 > y1) { ystep = -1; }
//    else         { ystep =  1; }
//
//    for ((x = x0); (x != (x1 + xstep)); (x += xstep))
//    {
//        (cx = x); (cy = y); // copy of x, copy of y
//
//        // if x,y swapped above, swap them back now
//        if (st) { swap(cx,cy);  }
//
//        (dupe = 0); // initialize no dupe
//
//        for ((n = 0); (n < idx); (n++)) {
//            if((cx == accx[n]) && (cy == accy[n])) {
//                (dupe = 1); // found a dupe - flag it
//                break;
//            }
//        }
//
//        // record current x,y for later dupe check
//        (accx[idx] = cx); (accy[idx] = cy); (idx++);
//
//        if(!dupe) { // if not a dupe, write it out
//            fprintf(stdout, "X=%2d, Y=%2d\n", cx, cy);
//            fflush(stdout); }
//        else {
////            fprintf(stdout, "; Duplicate: X=%2d, Y=%2d\n", cx, cy); // debug
////            fflush(stdout);
//        }
//
//        (error -= deltay); // converge toward end of line
//
//        if (error < 0) { // not done yet
//            (y += ystep);
//            (error += deltax);
//        }
//    }
//}


static IDL_VPTR IDL_vis_rasterpolyline_(int argc, IDL_VPTR *argv) {
  IDL_VPTR x, y, polylines, dims, xrange, yrange, result;
  int *result_data;
  
  x = argv[0];
  y = argv[1];
  polylines = argv[2];
  dims = argv[3];
  xrange = argv[4];
  yrange = argv[5];
  
  printf("dims[0] = %d\n", x->value.arr->dim[0]);
  printf("dims[1] = %d\n", x->value.arr->dim[1]);
  printf("dims[2] = %d\n", x->value.arr->dim[2]);
  
  // variable to return result in
  result_data = (int *) IDL_MakeTempArray(IDL_TYP_LONG, 
                                          x->value.arr->n_dim,
                                          x->value.arr->dim,
                                          IDL_ARR_INI_ZERO, 
                                          &result);
  return result;                                                      
}


/*
  Register the routines available for IDL; they must be specified exactly as 
  in vis_lineplots.dlm.
*/

int IDL_Load(void) {
  
  // functions to register
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_vis_rasterpolyline_,     "VIS_RASTERPOLYLINE_",     6, 6, 0, 0 },
  };
  
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));  
}
