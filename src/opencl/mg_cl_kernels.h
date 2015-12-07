char *array_zero =
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void array_zero(__global TYPE *result, const unsigned int n) {\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) { COMMAND }\n"
  "}\n";

char *array_index =
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void array_index(__global TYPE *result, const unsigned int n) {\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) { COMMAND }\n"
  "}\n";

char *custom_simple = 
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void custom_simple(%s\n"
  "                            const unsigned int n) {\n"
  "\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) %s;\n"
  "}\n";

char *unary_op =
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void unary_op(__global TYPE *x,\n"
  "                       __global TYPE *result,\n"
  "                       const unsigned int n) {\n"
  "\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) result[i] = OP(x[i]);\n"
  "}\n";

char *unary_z_op =
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void unary_op(__global TYPE *z,\n"
  "                       __global TYPE *result,\n"
  "                       const unsigned int n) {\n"
  "\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) { result[i].x = RE_EXPR; result[i].y = IM_EXPR; }\n"
  "}\n";

char *binary_op =
  "#ifdef cl_khr_fp64\n"
  "    #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "    #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void binary_op(__global TYPE *x,\n"
  "                        __global TYPE *y,\n"
  "                        __global TYPE *result,\n"
  "                        const unsigned int n) {\n"
  "\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) result[i] = x[i] OP y[i];\n"
  "}\n";

char *binary_z_op =
  "#ifdef cl_khr_fp64\n"
  "    #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "    #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void binary_op(__global TYPE *z,\n"
  "                        __global TYPE *w,\n"
  "                        __global TYPE *result,\n"
  "                        const unsigned int n) {\n"
  "\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) { result[i].x = RE_EXPR; result[i].y = IM_EXPR; }\n"
  "}\n";