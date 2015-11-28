char *array_init =
  "#ifdef cl_khr_fp64\n"
  "  #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "  #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void array_init(__global TYPE *result, const unsigned int n) {\n"
  "  size_t i = get_global_id(0);\n"
  "  if (i < n) { COMMAND }\n"
  "}\n";
