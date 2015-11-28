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

char *custom_simple = 
  "#ifdef cl_khr_fp64\n"
  "    #pragma OPENCL EXTENSION cl_khr_fp64 : enable\n"
  "#elif defined(cl_amd_fp64)\n"
  "    #pragma OPENCL EXTENSION cl_amd_fp64 : enable\n"
  "#endif\n"
  "\n"
  "__kernel void custom_simple(%s\n"
  "                            const unsigned int n) {\n"
  "\n"
  "  int i = get_global_id(0);\n"
  "  if (i < n) %s;\n"
  "}\n";
