#ifdef cl_khr_fp64
  #pragma OPENCL EXTENSION cl_khr_fp64 : enable
#elif defined(cl_amd_fp64)
  #pragma OPENCL EXTENSION cl_amd_fp64 : enable
#endif

__kernel void array_init(__global TYPE *result, const unsigned int n) {
  size_t i = get_global_id(0);
  if (i < n) { COMMAND }
}
