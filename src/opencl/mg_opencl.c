#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>

#include "mg_idl_export.h"

#if defined(__APPLE__) && defined(__MACH__)
#include <OpenCL/cl.h>
#else
#include <CL/cl.h>
#endif

#include "mg_hashtable.h"
#include "mg_cl_kernels.h"


#pragma mark --- header definitions ---


// CL_INIT macro needs to know IDL_cl_init definition
static void IDL_cl_init(int argc, IDL_VPTR *argv, char *argk);


char *CL_TypeNames[] = { "",
                         "uchar",
                         "short",
                         "int",
                         "float",
                         "double",
                         "float2",
                         "char *",
                         "",
                         "double2",
                         "",
                         "",
                         "ushort",
                         "uint",
                         "long",
                         "ulong" };

char *CL_ArrayIndexCommands[] = { "",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i].x=i;result[i].y=0.0f;",
                                  "",
                                  "",
                                  "result[i].x=i;result[i].y=0.0;",
                                  "",
                                  "",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i]=i;",
                                  "result[i]=i;" };

char *CL_ArrayZeroCommands[] = { "",
                                 "result[i]=0;",
                                 "result[i]=0;",
                                 "result[i]=0;",
                                 "result[i]=0.0f;",
                                 "result[i]=0.0;",
                                 "result[i].x=0.0f;result[i].y=0.0f;",
                                 "",
                                 "",
                                 "result[i].x=0.0;result[i].y=0.0;",
                                 "",
                                 "",
                                 "result[i]=0;",
                                 "result[i]=0;",
                                 "result[i]=0;",
                                 "result[i]=0;" };

// CL_VARIABLE flags
#define CL_V_VIEW 128

typedef struct {
  UCHAR type;
  UCHAR flags;
  IDL_MEMINT n_elts;
  UCHAR n_dim;
  IDL_ARRAY_DIM dim;
  cl_mem buffer;
} CL_VARIABLE;
typedef CL_VARIABLE *CL_VPTR;

typedef struct {
  UCHAR simple;
  char *expr;
  cl_kernel kernel;
} CL_KERNEL;


static cl_context current_context      = NULL;
static cl_command_queue current_queue  = NULL;
static cl_platform_id current_platform = NULL;
static cl_device_id current_device     = NULL;

MG_Table kernel_table;


IDL_MSG_BLOCK msg_block;

static IDL_MSG_DEF msg_arr[] = {
#define OPENCL_ERROR 0
  { "OPENCL_ERROR",                  "%NError: %s." },
#define OPENCL_NO_PLATFORMS -1
  { "OPENCL_NO_PLATFORMS",           "%NNo valid platforms found." },
#define OPENCL_NO_DEVICES -2
  { "OPENCL_NO_DEVICES",             "%NNo valid devices found." },
#define OPENCL_MISSING_KEYWORD -3
  { "OPENCL_MISSING_KEYWORD",        "%NMissing required keyword: %s." },
#define OPENCL_INCORRECT_N_PARAMS -4
  { "OPENCL_INCORRECT_N_PARAMS",     "%NIncorrect number of parameters." },
#define OPENCL_INCORRECT_PARAM_TYPE -5
  { "OPENCL_INCORRECT_PARAM_TYPE",   "%NIncorrect parameter type." },
#define OPENCL_INCORRECT_PARAM_LENGTH -6
  { "OPENCL_INCORRECT_PARAM_LENGTH",   "%NMismatched parameter lengths." },
#define OPENCL_INVALID_PLATFORM_INDEX -7
  { "OPENCL_INVALID_PLATFORM_INDEX", "%NInvalid platform index: %d." },
};


// ===

void mg_cl_release_kernel(void *k) {
  cl_kernel kernel = (cl_kernel) k;
  cl_program program;
  cl_int err = 0;

  if (kernel == NULL) return;

  // get program from the kernel
  err = clGetKernelInfo(kernel, CL_KERNEL_PROGRAM, sizeof(cl_program), &program, NULL);
  if (err < 0 || program == NULL) return;

  err = clReleaseKernel(kernel);
  if (err < 0) return;

  err = clReleaseProgram(program);
}


static char *mg_cl_read_program(char *filename, size_t *program_size) {
  FILE *program_handle;
  char *program_buffer;
  int err = 0;

  if ((program_handle = fopen(filename, "r"))) {
    err = fseek(program_handle, 0, SEEK_END);
    *program_size = ftell(program_handle);
    rewind(program_handle);

    program_buffer = (char *) malloc(*program_size + 1);
    fread(program_buffer, sizeof(char), *program_size, program_handle);
    program_buffer[*program_size] = '\0';

    fclose(program_handle);
  } else {
    *program_size = 0;
  }

  free(filename);

  return program_buffer;
}


// ===

#pragma mark --- helper macros ---

#define STRINGIFY(text) #text

#define CL_INIT                   \
  if (!current_context) {         \
    IDL_cl_init(0, NULL, NULL);   \
  }

cl_int IDL_cl_check_build(cl_program program) {
  size_t log_size;
  char *program_log;
  cl_int err;

  // query to get program build log size first
  err = clGetProgramBuildInfo(program,
                              current_device,
                              CL_PROGRAM_BUILD_LOG,
                              0,
                              NULL,
                              &log_size);
  program_log = (char *) calloc(log_size + 1, sizeof(char));
  err = clGetProgramBuildInfo(program,
                              current_device,
                              CL_PROGRAM_BUILD_LOG,
                              log_size + 1,
                              program_log,
                              NULL);
  printf("%s\n", program_log);
  free(program_log);

  return(err);
}

#define CL_CHECK_BUILD                                                       \
  size_t log_size;                                                           \
  char *program_log;                                                         \
  err = clGetProgramBuildInfo(program, current_device, CL_PROGRAM_BUILD_LOG, \
                              0, NULL, &log_size);                           \
  program_log = (char *) calloc(log_size + 1, sizeof(char));                 \
  err = clGetProgramBuildInfo(program, current_device, CL_PROGRAM_BUILD_LOG, \
                              log_size + 1, program_log, NULL);              \
  printf("%s\n", program_log);                                               \
  free(program_log);

#define CL_SET_ERROR(err)                      \
  if (kw.error_present) {                      \
    kw.error->type = IDL_TYP_LONG;             \
    kw.error->value.l = err;                   \
  }


// ===

#pragma mark --- query ---

static IDL_VPTR IDL_cl_platforms(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;

  cl_int err = 0;

  cl_platform_id *platform_ids;
  cl_uint num_platforms;
  int p;

  char *info_data;
  size_t info_size;

  IDL_MEMINT nplatforms = 1;
  void *idl_platforms_data;
  IDL_VPTR platform_result;

  static IDL_STRUCT_TAG_DEF platform_tags[] = {
    {"NAME",       0, (void *) IDL_TYP_STRING},
    {"VENDOR",     0, (void *) IDL_TYP_STRING},
    {"VERSION",    0, (void *) IDL_TYP_STRING},
    {"PROFILE",    0, (void *) IDL_TYP_STRING},
    {"EXTENSIONS", 0, (void *) IDL_TYP_STRING},
    { 0 }
  };

  typedef struct platform {
    IDL_STRING name;
    IDL_STRING vendor;
    IDL_STRING version;
    IDL_STRING profile;
    IDL_STRING extensions;
  } Platform;

  Platform *platform_data;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR count;
    int count_present;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "COUNT", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(count_present), IDL_KW_OFFSETOF(count) },
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  // query for number of platforms
  err = clGetPlatformIDs(0, NULL, &num_platforms);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  nplatforms = num_platforms;

  if (kw.count_present) {
    kw.count->type = IDL_TYP_LONG;
    kw.count->value.l = nplatforms;
  }

  platform_data = (Platform *) calloc(num_platforms, sizeof(Platform));

  platform_ids = (cl_platform_id *) calloc(num_platforms,
                                           sizeof(cl_platform_id));
  clGetPlatformIDs(num_platforms, platform_ids, NULL);

  for (p = 0; p < num_platforms; p++) {
#define GET_PLATFORM_STR_PROP(PROP, FIELD)                        \
    err = clGetPlatformInfo(platform_ids[p], PROP,                \
                            0, NULL, &info_size);                 \
    info_data = (char *) malloc(info_size);                       \
    err = clGetPlatformInfo(platform_ids[p], PROP,                \
                            info_size, info_data, NULL);          \
    IDL_StrStore(&platform_data[p].FIELD, info_data);             \
    free(info_data);                                              \

    GET_PLATFORM_STR_PROP(CL_PLATFORM_NAME, name)
    GET_PLATFORM_STR_PROP(CL_PLATFORM_VENDOR, vendor)
    GET_PLATFORM_STR_PROP(CL_PLATFORM_VERSION, version)
    GET_PLATFORM_STR_PROP(CL_PLATFORM_PROFILE, profile)
    GET_PLATFORM_STR_PROP(CL_PLATFORM_EXTENSIONS, extensions)
  }

  IDL_KW_FREE;

  free(platform_ids);

  idl_platforms_data = IDL_MakeStruct("CL_PLATFORM", platform_tags);

  platform_result = IDL_ImportArray(1,
                                    &nplatforms,
                                    IDL_TYP_STRUCT,
                                    (UCHAR *) platform_data,
                                    0,
                                    idl_platforms_data);

  return(platform_result);
}


static IDL_VPTR IDL_cl_devices(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;

  cl_int err = 0;

  cl_platform_id *platform_ids;
  cl_uint num_platforms;
  int platform_index;

  cl_device_id *device_ids;
  cl_uint num_devices;
  int d = 0;

  char *info_data;
  size_t info_size;

  IDL_MEMINT ndevices = 1;
  void *idl_devices_data;
  IDL_VPTR device_result;

  cl_ulong ulong_info;
  cl_uint uint_info;
  cl_bool bool_info;

  static IDL_STRUCT_TAG_DEF device_tags[] = {
    { "NAME",                      0, (void *) IDL_TYP_STRING  },
    { "VENDOR",                    0, (void *) IDL_TYP_STRING  },
    { "VENDOR_ID",                 0, (void *) IDL_TYP_ULONG   },
    { "TYPE",                      0, (void *) IDL_TYP_STRING  },
    { "EXTENSIONS",                0, (void *) IDL_TYP_STRING  },
    { "PROFILE",                   0, (void *) IDL_TYP_STRING  },
    { "GLOBAL_MEM_SIZE",           0, (void *) IDL_TYP_ULONG64 },
    { "GLOBAL_MEM_CACHE_SIZE",     0, (void *) IDL_TYP_ULONG64 },
    { "ADDRESS_BITS",              0, (void *) IDL_TYP_ULONG   },
    { "AVAILABLE",                 0, (void *) IDL_TYP_BYTE    },
    { "COMPILER_AVAILABLE",        0, (void *) IDL_TYP_BYTE    },
    { "ENDIAN_LITTLE",             0, (void *) IDL_TYP_BYTE    },
    { "ERROR_CORRECTION_SUPPORT",  0, (void *) IDL_TYP_BYTE    },
    { "DEVICE_VERSION",            0, (void *) IDL_TYP_STRING  },
    { "DRIVER_VERSION",            0, (void *) IDL_TYP_STRING  },
    { 0 }
  };

  typedef struct device {
    IDL_STRING name;
    IDL_STRING vendor;
    IDL_ULONG vendor_id;
    IDL_STRING type;
    IDL_STRING extensions;
    IDL_STRING profile;
    IDL_ULONG64 global_mem_size;
    IDL_ULONG64 global_mem_cache_size;
    IDL_ULONG address_bits;
    UCHAR available;
    UCHAR compiler_available;
    UCHAR endian_little;
    UCHAR error_correction_support;
    IDL_STRING device_version;
    IDL_STRING driver_version;
  } Device;

  Device *device_data;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR count;
    int count_present;
    IDL_LONG current;
    IDL_VPTR error;
    int error_present;
    IDL_LONG gpu;
    IDL_VPTR platform;
    int platform_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "COUNT", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(count_present), IDL_KW_OFFSETOF(count) },
    { "CURRENT", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(current) },
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "GPU", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(gpu) },
    { "PLATFORM", IDL_TYP_UNDEF, 1, IDL_KW_VIN,
      IDL_KW_OFFSETOF(platform_present), IDL_KW_OFFSETOF(platform) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  if (kw.count_present) {
    kw.count->type = IDL_TYP_LONG;
    kw.count->value.l = 0;
  }

  if (kw.current && !current_device) {
    IDL_KW_FREE;

    return(IDL_GettmpLong(-1));
  }

  // query for number of platforms
  err = clGetPlatformIDs(0, NULL, &num_platforms);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  if (num_platforms == 0) {
    IDL_KW_FREE;

    IDL_MessageFromBlock(msg_block, OPENCL_NO_PLATFORMS, IDL_MSG_RET);
    return(IDL_GettmpLong(-1));
  }

  if (!kw.platform_present) {
    platform_index = 0;
  } else {
    platform_index = kw.platform->value.l;
  }

  if (platform_index >= num_platforms) {
    IDL_KW_FREE;

    IDL_MessageFromBlock(msg_block, OPENCL_INVALID_PLATFORM_INDEX, IDL_MSG_RET, platform_index);
    return(IDL_GettmpLong(-1));
  }

  platform_ids = (cl_platform_id *) calloc(num_platforms,
                                           sizeof(cl_platform_id));
  err = clGetPlatformIDs(num_platforms, platform_ids, NULL);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  err = clGetDeviceIDs(platform_ids[platform_index],
                       kw.gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_ALL,
                       0, NULL, &num_devices);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  if (kw.current) num_devices = 1;
  ndevices = num_devices;

  if (kw.count_present) {
    kw.count->type = IDL_TYP_LONG;
    kw.count->value.l = ndevices;
  }

  if (num_devices == 0) {
    return(IDL_GettmpLong(-1));
  }

  device_data = (Device *) calloc(num_devices, sizeof(Device));

  device_ids = (cl_device_id *) calloc(num_devices, sizeof(cl_device_id));
  clGetDeviceIDs(platform_ids[platform_index],
                 kw.gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_ALL,
                 num_devices, device_ids, NULL);

  if (kw.current) {
#define GET_DEVICE_STR_PROP(DEVICE, PROP, FIELD)          \
    err = clGetDeviceInfo(DEVICE, PROP,                   \
                          0, NULL, &info_size);           \
    info_data = (char *) malloc(info_size);               \
    err = clGetDeviceInfo(DEVICE, PROP,                   \
                          info_size, info_data, NULL);    \
    IDL_StrStore(&device_data[d].FIELD, info_data);       \
    free(info_data);

#define GET_DEVICE_PROP(DEVICE, PROP, FIELD, VAR)         \
    err = clGetDeviceInfo(DEVICE, PROP,                   \
                          sizeof(VAR), &VAR, NULL);       \
    device_data[d].FIELD = VAR;

    GET_DEVICE_STR_PROP(current_device, CL_DEVICE_NAME, name)
    GET_DEVICE_STR_PROP(current_device, CL_DEVICE_VENDOR, vendor)
    GET_DEVICE_STR_PROP(current_device, CL_DEVICE_EXTENSIONS, extensions)
    GET_DEVICE_STR_PROP(current_device, CL_DEVICE_PROFILE, profile)

    GET_DEVICE_PROP(current_device, CL_DEVICE_VENDOR_ID, vendor_id, uint_info)
    err = clGetDeviceInfo(current_device,
                          CL_DEVICE_VENDOR_ID,
                          sizeof(uint_info),
                          &uint_info, NULL);
    if (uint_info == CL_DEVICE_TYPE_CPU) {
      IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_CPU");
    } else if (uint_info == CL_DEVICE_TYPE_GPU) {
      IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_GPU");
    } else if (uint_info == CL_DEVICE_TYPE_GPU) {
      IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_ACCELERATOR");
    } else if (uint_info == CL_DEVICE_TYPE_GPU) {
      IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_DEFAULT");
    } else if (uint_info == CL_DEVICE_TYPE_ALL) {
      IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_ALL");
    }

    GET_DEVICE_PROP(current_device, CL_DEVICE_GLOBAL_MEM_SIZE, global_mem_size, ulong_info)
    GET_DEVICE_PROP(current_device, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, global_mem_cache_size, ulong_info)
    GET_DEVICE_PROP(current_device, CL_DEVICE_ADDRESS_BITS, address_bits, uint_info)
    GET_DEVICE_PROP(current_device, CL_DEVICE_AVAILABLE, available, bool_info)
    GET_DEVICE_PROP(current_device, CL_DEVICE_COMPILER_AVAILABLE, compiler_available, bool_info)

    GET_DEVICE_PROP(current_device, CL_DEVICE_ENDIAN_LITTLE, endian_little, bool_info)
    GET_DEVICE_PROP(current_device, CL_DEVICE_ERROR_CORRECTION_SUPPORT, error_correction_support, bool_info)

    GET_DEVICE_STR_PROP(current_device, CL_DEVICE_VERSION, device_version)
    GET_DEVICE_STR_PROP(current_device, CL_DRIVER_VERSION, driver_version)
  } else {
    for (d = 0; d < num_devices; d++) {
      GET_DEVICE_STR_PROP(device_ids[d], CL_DEVICE_NAME, name)
      GET_DEVICE_STR_PROP(device_ids[d], CL_DEVICE_VENDOR, vendor)
      GET_DEVICE_STR_PROP(device_ids[d], CL_DEVICE_EXTENSIONS, extensions)
      GET_DEVICE_STR_PROP(device_ids[d], CL_DEVICE_PROFILE, profile)

      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_VENDOR_ID, vendor_id, uint_info)
      err = clGetDeviceInfo(device_ids[d],
                            CL_DEVICE_VENDOR_ID,
                            sizeof(uint_info),
                            &uint_info, NULL);
      if (uint_info == CL_DEVICE_TYPE_CPU) {
        IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_CPU");
      } else if (uint_info == CL_DEVICE_TYPE_GPU) {
        IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_GPU");
      } else if (uint_info == CL_DEVICE_TYPE_GPU) {
        IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_ACCELERATOR");
      } else if (uint_info == CL_DEVICE_TYPE_GPU) {
        IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_DEFAULT");
      } else if (uint_info == CL_DEVICE_TYPE_ALL) {
        IDL_StrStore(&device_data[d].type, "CL_DEVICE_TYPE_ALL");
      }

      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_GLOBAL_MEM_SIZE, global_mem_size, ulong_info)
      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, global_mem_cache_size, ulong_info)
      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_ADDRESS_BITS, address_bits, uint_info)
      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_AVAILABLE, available, bool_info)
      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_COMPILER_AVAILABLE, compiler_available, bool_info)

      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_ENDIAN_LITTLE, endian_little, bool_info)
      GET_DEVICE_PROP(device_ids[d], CL_DEVICE_ERROR_CORRECTION_SUPPORT, error_correction_support, bool_info)

      GET_DEVICE_STR_PROP(device_ids[d], CL_DEVICE_VERSION, device_version)
      GET_DEVICE_STR_PROP(device_ids[d], CL_DRIVER_VERSION, driver_version)

      // TODO: there are more properties to check, * add soon
      /*
        CL_DEVICE_DOUBLE_FP_CONFIG,
        CL_DEVICE_EXECUTION_CAPABILITIES,
        CL_DEVICE_GLOBAL_MEM_CACHE_TYPE,
        CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE,
        CL_DEVICE_HALF_FP_CONFIG,
        CL_DEVICE_IMAGE_SUPPORT,
        CL_DEVICE_IMAGE2D_MAX_HEIGHT,
        CL_DEVICE_IMAGE2D_MAX_WIDTH,
        CL_DEVICE_IMAGE3D_MAX_DEPTH,
        CL_DEVICE_IMAGE3D_MAX_HEIGHT,
        CL_DEVICE_IMAGE3D_MAX_WIDTH,
        CL_DEVICE_LOCAL_MEM_SIZE,
        CL_DEVICE_LOCAL_MEM_TYPE,
        CL_DEVICE_MAX_CLOCK_FREQUENCY, *
        CL_DEVICE_MAX_COMPUTE_UNITS, *
        CL_DEVICE_MAX_CONSTANT_ARGS, *
        CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, *
        CL_DEVICE_MAX_MEM_ALLOC_SIZE, *
        CL_DEVICE_MAX_PARAMETER_SIZE, *
        CL_DEVICE_MAX_READ_IMAGE_ARGS,
        CL_DEVICE_MAX_SAMPLERS,
        CL_DEVICE_MAX_WORK_GROUP_SIZE, *
        CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, *
        CL_DEVICE_MAX_WORK_ITEM_SIZES, *
        CL_DEVICE_MAX_WRITE_IMAGE_ARGS,
        CL_DEVICE_MEM_BASE_ADDR_ALIGN,
        CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT,
        CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE,
        CL_DEVICE_PROFILING_TIMER_RESOLUTION,
        CL_DEVICE_QUEUE_PROPERTIES,
        CL_DEVICE_SINGLE_FP_CONFIG
      */
    }
  }

  IDL_KW_FREE;

  free(device_ids);

  idl_devices_data = IDL_MakeStruct("CL_DEVICE", device_tags);

  device_result = IDL_ImportArray(1,
                                  &ndevices,
                                  IDL_TYP_STRUCT,
                                  (UCHAR *) device_data,
                                  0,
                                  idl_devices_data);

  return(device_result);
}


static void IDL_cl_help(int argc, IDL_VPTR *argv, char *argk) {
  int nargs, d;
  cl_int err = 0;

  CL_VPTR cl_var;
  CL_KERNEL *kernel;
  char *varname = IDL_VarName(argv[0]);

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
    IDL_LONG kernel;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "KERNEL", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(kernel) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  CL_INIT;

  if (nargs == 0) {
    size_t info_size;
    char *info_data;

    err = clGetDeviceInfo(current_device, CL_DEVICE_NAME, 0, NULL, &info_size);
    info_data = (char *) malloc(info_size);
    err = clGetDeviceInfo(current_device, CL_DEVICE_NAME, info_size, info_data, NULL);
    printf("Current device: %s\n", info_data);
    free(info_data);
  } else {
    if (kw.kernel) {
      kernel = (CL_KERNEL *) argv[0]->value.ptrint;
      printf("%-16.16s%-9.9s = '%s'\n", varname[0] == '<' ? "<Expression>" : varname, "CL_KERNEL", kernel->expr);
    } else {
      cl_var = (CL_VPTR) argv[0]->value.ptrint;
      printf("%-16.16sCL_%-6.6s = Array[", varname[0] == '<' ? "<Expression>" : varname, IDL_TypeName[cl_var->type]);
      for (d = 0; d < cl_var->n_dim; d++) {
        printf("%s%lld", d == 0 ? "" : ", ", cl_var->dim[d]);
      }
      printf("]\n");
    }
  }

  IDL_KW_FREE;
}

static IDL_VPTR IDL_cl_size(int argc, IDL_VPTR *argv, char *argk) {
  int nargs, r;
  cl_int err = 0;
  IDL_LONG *result;
  IDL_MEMINT result_dims;
  IDL_VPTR result_vptr;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_LONG dimensions;
    IDL_VPTR error;
    int error_present;
    IDL_LONG n_dimensions;
    IDL_LONG n_elements;
    IDL_LONG tname;
    IDL_LONG type;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "DIMENSIONS", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(dimensions) },
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "N_DIMENSIONS", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(n_dimensions) },
    { "N_ELEMENTS", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(n_elements) },
    { "TNAME", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(tname) },
    { "TYPE", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(type) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  CL_INIT;

  CL_VPTR cl_var = (CL_VPTR) argv[0]->value.ptrint;

  if (kw.dimensions) {
    IDL_KW_FREE;

    result = (IDL_LONG *) malloc(sizeof(IDL_LONG) * (cl_var->n_dim));
    for (r = 0; r < cl_var->n_dim; r++) result[r] = cl_var->dim[r];
    result_dims = cl_var->n_dim;
    result_vptr = IDL_ImportArray(1,
                                  &result_dims,
                                  IDL_TYP_LONG,
                                  (UCHAR *) result,
                                  NULL,
                                  NULL);
    return result_vptr;
  }

  if (kw.n_dimensions) {
    IDL_KW_FREE;

    return IDL_GettmpLong(cl_var->n_dim);
  }

  if (kw.n_elements) {
    IDL_KW_FREE;

    return IDL_GettmpLong(cl_var->n_elts);
  }

  if (kw.tname) {
    IDL_KW_FREE;

    return IDL_StrToSTRING(IDL_TypeName[cl_var->type]);
  }

  if (kw.type) {
    IDL_KW_FREE;

    return IDL_GettmpLong(cl_var->type);
  }

  IDL_KW_FREE;

  // full result is [n_dimensions, dimensions, type, n_elements]

  result = (IDL_LONG *) malloc(sizeof(IDL_LONG) * (cl_var->n_dim + 3));
  result[0] = cl_var->n_dim;
  for (r = 0; r < cl_var->n_dim; r++) result[r + 1] = cl_var->dim[r];
  result[cl_var->n_dim + 1] = cl_var->type;
  result[cl_var->n_dim + 2] = cl_var->n_elts;
  result_dims = cl_var->n_dim + 3;
  result_vptr = IDL_ImportArray(1,
                                &result_dims,
                                IDL_TYP_LONG,
                                (UCHAR *) result,
                                NULL,
                                NULL);

  return result_vptr;
}


// ===

#pragma mark --- initialization ---

static void IDL_cl_init(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;
  cl_int err = 0;

  cl_platform_id *platform_ids;
  cl_uint num_platforms;
  int p, platform_index = 0;

  cl_device_id *device_ids;
  cl_uint num_devices;
  int device_index = 0;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR device;
    int device_present;
    IDL_VPTR error;
    int error_present;
    IDL_LONG gpu;
    IDL_VPTR kernel_loc;
    int kernel_loc_present;
    IDL_VPTR platform;
    int platform_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "DEVICE", IDL_TYP_UNDEF, 1, IDL_KW_VIN,
      IDL_KW_OFFSETOF(device_present), IDL_KW_OFFSETOF(device) },
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "GPU", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(gpu) },
    { "PLATFORM", IDL_TYP_UNDEF, 1, IDL_KW_VIN,
      IDL_KW_OFFSETOF(platform_present), IDL_KW_OFFSETOF(platform) },
    { NULL }
  };

  KW_RESULT kw;
  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  if (kw.platform_present) {
    platform_index = kw.platform->value.l;
  } else {
    char *platform_index_env;
    platform_index_env = getenv("MG_CL_DEFAULT_PLATFORM");
    if (platform_index_env != NULL) {
      platform_index = atoi(platform_index_env);
    }
  }
  if (kw.device_present) {
    device_index = kw.device->value.l;
  } else {
    char *device_index_env;
    device_index_env = getenv("MG_CL_DEFAULT_DEVICE");
    if (device_index_env != NULL) {
      device_index = atoi(device_index_env);
    }
  }

  // query for number of platforms
  err = clGetPlatformIDs(0, NULL, &num_platforms);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return;
  }

  if (num_platforms == 0) {
    IDL_KW_FREE;
    IDL_MessageFromBlock(msg_block, OPENCL_NO_PLATFORMS, IDL_MSG_RET);
    CL_SET_ERROR(-1);
    return;
  }

  platform_ids = (cl_platform_id *) calloc(num_platforms,
                                           sizeof(cl_platform_id));
  clGetPlatformIDs(num_platforms, platform_ids, NULL);

  // if a platform is specified and looking for a GPU, search all platforms
  // for first available GPU
  if (!kw.platform_present && kw.gpu) {
    for (p = 0; p < num_platforms; p++) {
      err = clGetDeviceIDs(platform_ids[p],
                           CL_DEVICE_TYPE_GPU,
                           0, NULL, &num_devices);

      // num_devices only valid if err is 0
      if (err == 0 && num_devices > 0) {
        platform_index = p;
        break;
      }
    }
  } else {
    err = clGetDeviceIDs(platform_ids[platform_index],
                         kw.gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_ALL,
                         0, NULL, &num_devices);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return;
    }
  }

  // failed to find any devices
  if (err != 0 || num_devices == 0) {
    free(platform_ids);
    IDL_KW_FREE;
    IDL_MessageFromBlock(msg_block, OPENCL_NO_DEVICES, IDL_MSG_RET);
    CL_SET_ERROR(-1);
    return;
  }

  device_ids = (cl_device_id *) calloc(num_devices, sizeof(cl_device_id));
  err = clGetDeviceIDs(platform_ids[platform_index],
                       kw.gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_ALL,
                       num_devices, device_ids, NULL);
  if (err < 0) {
    free(platform_ids);
    IDL_KW_FREE;
    IDL_MessageFromBlock(msg_block, OPENCL_NO_DEVICES, IDL_MSG_RET);
    CL_SET_ERROR(-1);
    return;
  }

  if (current_queue != NULL) {
    clReleaseCommandQueue(current_queue);
    clReleaseContext(current_context);

    // kernels in table are associated with old context
    mg_table_free(&kernel_table, mg_cl_release_kernel);
    kernel_table = mg_table_new(0);
  }

  current_platform = platform_ids[platform_index];
  current_device = device_ids[device_index];
  current_context = clCreateContext(NULL, 1, &current_device,
                                    NULL, NULL, &err);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return;
  }
  current_queue = clCreateCommandQueue(current_context, current_device, 0, &err);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return;
  }

  free(platform_ids);
  free(device_ids);

  IDL_KW_FREE;
}


// ===

#pragma mark --- memory ---

static IDL_VPTR IDL_cl_putvar(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;
  cl_int err = 0;
  cl_mem buffer;
  IDL_VPTR result;
  CL_VPTR cl_var;

  IDL_ENSURE_ARRAY(argv[0]);

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  // initialize OpenCL, if needed
  CL_INIT;

  buffer = clCreateBuffer(current_context,
                          CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                          IDL_TypeSizeFunc(argv[0]->type) * argv[0]->value.arr->n_elts,
                          argv[0]->value.arr->data,
                          &err);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  cl_var = (CL_VPTR) malloc(sizeof(CL_VARIABLE));
  cl_var->type = argv[0]->type;
  cl_var->flags = argv[0]->flags;
  cl_var->n_elts = argv[0]->value.arr->n_elts;
  cl_var->n_dim = argv[0]->value.arr->n_dim;
  memcpy(cl_var->dim, argv[0]->value.arr->dim, sizeof(IDL_ARRAY_DIM));
  cl_var->buffer = buffer;

  result = IDL_Gettmp();
  result->type = IDL_TYP_PTRINT;
  result->value.ptrint = (IDL_PTRINT) cl_var;

  IDL_KW_FREE;

  return result;
}

static IDL_VPTR IDL_cl_getvar(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;
  cl_int err = 0;

  CL_VPTR cl_var = (CL_VPTR) argv[0]->value.ptrint;
  cl_mem buffer;
  IDL_LONG type;
  size_t n_bytes;
  IDL_VPTR result;
  IDL_ARRAY_DIM dims;
  UCHAR *data;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  if (!cl_var) {
    CL_SET_ERROR(-101);
    IDL_KW_FREE;
    return IDL_GettmpLong(0);
  }

  buffer = cl_var->buffer;
  type = cl_var->type;
  n_bytes = cl_var->n_elts * IDL_TypeSizeFunc(type);

  CL_INIT;

  memcpy(dims, cl_var->dim, sizeof(IDL_ARRAY_DIM));
  data = malloc(n_bytes);

  err = clEnqueueReadBuffer(current_queue,
                            buffer,
                            CL_TRUE,         // blocking read?
                            0,               // offset
                            n_bytes,
                            data,
                            0,               // num_events_in_wait_list
                            NULL,            // event_wait_list
                            NULL);           // event
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  err = clFinish(current_queue);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(err);
  }

  result = IDL_ImportArray(cl_var->n_dim,
                           dims,
                           type,
                           data,
                           NULL,
                           NULL);

  IDL_KW_FREE;

  return result;
}

static void IDL_cl_free(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;
  cl_int err = 0;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);

  CL_INIT;

  if (argv[0]->flags & IDL_V_ARR) {
    int v;
    CL_VPTR *cl_var_arr = (CL_VPTR *) argv[0]->value.arr->data;
    for (v = 0; v < argv[0]->value.arr->n_elts; v++) {
      cl_mem buffer = (cl_mem) cl_var_arr[v]->buffer;
      if (cl_var_arr[v]->flags & CL_V_VIEW) {
        err = 0;
      } else {
        err = clReleaseMemObject(buffer);
      }
      cl_var_arr[v]->type = IDL_TYP_UNDEF;
      cl_var_arr[v]->n_dim = 0;
      cl_var_arr[v]->n_elts = 0;
      free(cl_var_arr[v]);
    }
  } else {
    CL_VPTR cl_var = (CL_VPTR) argv[0]->value.ptrint;
    cl_mem buffer = (cl_mem) cl_var->buffer;

    if (cl_var->flags & CL_V_VIEW) {
      err = 0;
    } else {
      err = clReleaseMemObject(buffer);
    }
    cl_var->type = IDL_TYP_UNDEF;
    cl_var->n_dim = 0;
    cl_var->n_elts = 0;
    free(cl_var);
  }

  CL_SET_ERROR(err);

  IDL_KW_FREE;
}

static IDL_VPTR IDL_cl_reform(int argc, IDL_VPTR *argv, char *argk) {
  int nargs, i, n_dims;

  IDL_VPTR dimsize;
  unsigned int total_n_elts = 1;
  IDL_ARRAY_DIM dim = { 0, 0, 0, 0, 0, 0, 0, 0 };

  cl_int err;
  CL_VPTR x = (CL_VPTR) argv[0]->value.ptrint;
  CL_VPTR cl_var;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
    IDL_LONG overwrite;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "OVERWRITE", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(overwrite) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // the second argument could actually be an array of dimensions
  n_dims = nargs - 1;
  for (i = 1; i < nargs; i++) {
    dimsize = IDL_CvtULng(1, &argv[i]);

    if (i == 1 && (dimsize->flags & IDL_V_ARR)) {
      for (i = 0; i < dimsize->value.arr->n_elts; i++) {
        dim[i] = ((IDL_ULONG *) dimsize->value.arr->data)[i];
        total_n_elts *= dim[i];
      }
      IDL_Deltmp(dimsize);
      n_dims = dimsize->value.arr->n_elts;
      break;
    }

    dim[i - 1] = dimsize->value.ul;
    total_n_elts *= dim[i - 1];
    IDL_Deltmp(dimsize);
  }

  // make sure total number of elements does not change
  if (total_n_elts != x->n_elts) {
    IDL_Message(IDL_M_NAMED_GENERIC,
                IDL_MSG_LONGJMP,
                "New subscripts must not change the number elements in input");
  }

  if (kw.overwrite) {
    cl_var = x;
  } else {
    // allocate result to return
    cl_var = (CL_VPTR) malloc(sizeof(CL_VARIABLE));
    cl_var->type = x->type;
    cl_var->flags = x->flags;
    cl_var->n_elts = x->n_elts;

    cl_var->buffer = clCreateBuffer(current_context,
                                    CL_MEM_READ_WRITE,
                                    x->n_elts * IDL_TypeSizeFunc(x->type),
                                    NULL,
                                    &err);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(0);
    }

    err = clFinish(current_queue);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(0);
    }

    err = clEnqueueCopyBuffer(current_queue,
                              x->buffer, cl_var->buffer,
                              0, 0,  // offsets
                              x->n_elts * IDL_TypeSizeFunc(x->type), // data_size
                              0, NULL, NULL);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(0);
    }

    err = clFinish(current_queue);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(0);
    }
  }

  cl_var->n_dim = n_dims;
  memcpy(cl_var->dim, dim, sizeof(IDL_ARRAY_DIM));

  IDL_KW_FREE;

  return(IDL_GettmpMEMINT((IDL_PTRINT) cl_var));
}


static IDL_VPTR IDL_cl_view(int argc, IDL_VPTR *argv, char *argk) {
  int n_args;
  cl_int err = 0;

  CL_VPTR x = (CL_VPTR) argv[0]->value.ptrint;
  IDL_VPTR offset;
  IDL_VPTR n_elements;
  IDL_ARRAY_DIM dim = { 0, 0, 0, 0, 0, 0, 0, 0 };

  CL_VPTR result;
  cl_buffer_region buffer_info;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  n_args = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // initialize error
  CL_SET_ERROR(err);
  CL_INIT;

  offset = IDL_CvtULng(1, &argv[1]);
  n_elements = IDL_CvtULng(1, &argv[2]);

  result = (CL_VPTR) malloc(sizeof(CL_VARIABLE));
  result->type = x->type;
  result->flags = x->flags | CL_V_VIEW;
  result->n_elts = n_elements->value.ul;
  result->n_dim = 1;
  dim[0] = n_elements->value.ul;
  memcpy(result->dim, dim, sizeof(IDL_ARRAY_DIM));

  buffer_info.origin = offset->value.ul * IDL_TypeSizeFunc(x->type);
  buffer_info.size = n_elements->value.ul * IDL_TypeSizeFunc(x->type);
  result->buffer = clCreateSubBuffer(x->buffer,
                                     CL_MEM_READ_WRITE,
                                     CL_BUFFER_CREATE_TYPE_REGION,
                                     &buffer_info,
                                     &err);
  if (err < 0) {
    CL_SET_ERROR(err);
    IDL_KW_FREE;
    return IDL_GettmpLong(0);
  }

  IDL_Deltmp(offset);
  IDL_Deltmp(n_elements);

  IDL_KW_FREE;

  return IDL_GettmpMEMINT((IDL_PTRINT) result);
}


// ===

#pragma mark --- array initialization ---

// init can be IDL_ARR_INI_INDEX, IDL_ARR_INI_NOP, IDL_ARR_INI_ZERO
static IDL_VPTR IDL_cl_array_init(int n_dims, IDL_MEMINT dims[], UCHAR type, int init, cl_int *err) {
  CL_VPTR cl_var;
  size_t program_size, global_size, local_size;

  cl_kernel kernel;
  cl_mem buffer;
  cl_program program;

  char *kernel_name;
  char *command;
  char *kernel_basename;
  char *program_buffer;
  char options[80];
  int i, slen, n_elts = 1;

  for (i = 0; i < n_dims; i++) {
    n_elts *= dims[i];
  }

  local_size = 64;
  global_size = ceil(n_elts / (float) local_size) * local_size;

  buffer = clCreateBuffer(current_context,
                          CL_MEM_READ_WRITE,
                          IDL_TypeSizeFunc(type) * n_elts,
                          NULL,
                          err);
  if (*err < 0) {
    return IDL_GettmpLong(0);
  }

  // initialize
  if (init != IDL_ARR_INI_NOP) {
    if (init == IDL_ARR_INI_ZERO) {
      program_buffer = array_zero;
      kernel_basename = "array_zero";
      command = CL_ArrayZeroCommands[type];
    } else if (init == IDL_ARR_INI_INDEX) {
      program_buffer = array_index;
      kernel_basename = "array_index";
      command = CL_ArrayIndexCommands[type];
    }

    program_size = strlen(program_buffer);
    slen = 11 + strlen(CL_TypeNames[type]);
    kernel_name = (char *) malloc(slen + 1);
    sprintf(kernel_name, "%s_%s", kernel_basename, CL_TypeNames[type]);
    kernel_name[slen] = '\0';

    kernel = (cl_kernel) mg_table_get(kernel_table, kernel_name);

    if (!kernel) {
      program = clCreateProgramWithSource(current_context,
                                          1,
                                          (const char**) &program_buffer,
                                          &program_size,
                                          err);
      if (*err < 0) {
        return IDL_GettmpLong(0);
      }

      sprintf(options,
              "-DTYPE=\"%s\" -DCOMMAND=\"%s\"",
              CL_TypeNames[type],
              command);

      *err = clBuildProgram(program, 1, &current_device, options, NULL, NULL);
      if (*err < 0) {
        *err = IDL_cl_check_build(program);
        return IDL_GettmpLong(0);
      }

      kernel = clCreateKernel(program, kernel_basename, err);
      if (*err < 0) {
        return IDL_GettmpLong(0);
      }

      mg_table_put(kernel_table, kernel_name, (void *) kernel);
    }

    *err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &buffer);
    if (*err < 0) {
      return IDL_GettmpLong(0);
    }

    *err = clSetKernelArg(kernel, 1, sizeof(unsigned int), &n_elts);
    if (*err < 0) {
      return IDL_GettmpLong(0);
    }

    *err = clEnqueueNDRangeKernel(current_queue,
                                  kernel,
                                  1,
                                  NULL,
                                  &global_size,
                                  &local_size,
                                  0,
                                  NULL,
                                  NULL);
    if (*err < 0) {
      return IDL_GettmpLong(0);
    }

    *err = clFinish(current_queue);
    if (*err < 0) {
      return IDL_GettmpLong(0);
    }
  }

  cl_var = (CL_VPTR) malloc(sizeof(CL_VARIABLE));
  cl_var->type = type;
  cl_var->flags = IDL_V_ARR | IDL_V_DYNAMIC;
  cl_var->n_dim = n_dims;
  for (i = 0; i < n_dims; i++) {
    cl_var->dim[i] = dims[i];
  }
  cl_var->n_elts = n_elts;
  cl_var->buffer = buffer;

  return(IDL_GettmpMEMINT((IDL_PTRINT) cl_var));
}


static IDL_VPTR IDL_cl_make_array(int argc, IDL_VPTR *argv, char *argk) {
  int i, n_args, n_dims, type_code, init;
  cl_int err;
  IDL_ARRAY_DIM dims = { 0, 0, 0, 0, 0, 0, 0, 0 };
  IDL_VPTR dimsize, result;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
    IDL_LONG index;
    IDL_LONG nozero;
    IDL_LONG type;
    int type_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "INDEX", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(index) },
    { "NOZERO", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(nozero) },
    { "TYPE", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      IDL_KW_OFFSETOF(type_present), IDL_KW_OFFSETOF(type) },
    { NULL }
  };

  KW_RESULT kw;

  n_args = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  // the first argument could actually be an array of dimensions
  n_dims = n_args;
  for (i = 0; i < n_args; i++) {
    dimsize = IDL_CvtULng(1, &argv[i]);

    if (i == 0 && (dimsize->flags & IDL_V_ARR)) {
      for (i = 0; i < dimsize->value.arr->n_elts; i++) {
        dims[i] = ((IDL_ULONG *) dimsize->value.arr->data)[i];
      }
      IDL_Deltmp(dimsize);
      n_dims = dimsize->value.arr->n_elts;
      break;
    }

    dims[i] = dimsize->value.ul;
    IDL_Deltmp(dimsize);
  }

  type_code = kw.type_present ? kw.type : 4;
  init = kw.index ? IDL_ARR_INI_INDEX : (kw.nozero ? IDL_ARR_INI_NOP : IDL_ARR_INI_ZERO);

  result = IDL_cl_array_init(n_dims, dims, type_code, init, &err);

  CL_SET_ERROR(err)

  return(result);
}


#define CL_ARRAY_INIT(NAME, TYPE_CODE)                                                   \
static IDL_VPTR IDL_cl_##NAME(int argc, IDL_VPTR *argv, char *argk) {                    \
  int i, n_dims;                                                                         \
  IDL_ARRAY_DIM dims;                                                                    \
  IDL_VPTR dimsize;                                                                      \
  int init;                                                                              \
  cl_int err;                                                                            \
                                                                                         \
  typedef struct {                                                                       \
    IDL_KW_RESULT_FIRST_FIELD;                                                           \
    IDL_VPTR error;                                                                      \
    int error_present;                                                                   \
    IDL_LONG nozero;                                                                     \
  } KW_RESULT;                                                                           \
                                                                                         \
  static IDL_KW_PAR kw_pars[] = {                                                        \
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,                                              \
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },                          \
    { "NOZERO", IDL_TYP_LONG, 1, IDL_KW_ZERO,                                            \
      0, IDL_KW_OFFSETOF(nozero) },                                                      \
    { NULL }                                                                             \
  };                                                                                     \
                                                                                         \
  KW_RESULT kw;                                                                          \
                                                                                         \
  n_dims = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);  \
                                                                                         \
  for (i = 0; i < n_dims; i++) {                                                         \
    dimsize = IDL_CvtULng(1, &argv[i]);                                                  \
    dims[i] = dimsize->value.ul;                                                         \
    IDL_Deltmp(dimsize);                                                                 \
  }                                                                                      \
  init = kw.nozero ? IDL_ARR_INI_NOP : IDL_ARR_INI_ZERO;                                 \
  IDL_VPTR result = IDL_cl_array_init(n_dims, dims, TYPE_CODE, init, &err);              \
  CL_SET_ERROR(err)                                                                      \
  return(result);                                                                        \
}

CL_ARRAY_INIT(bytarr,        1);
CL_ARRAY_INIT(intarr,        2);
CL_ARRAY_INIT(lonarr,        3);
CL_ARRAY_INIT(fltarr,        4);
CL_ARRAY_INIT(dblarr,        5);
CL_ARRAY_INIT(complexarr,    6);
CL_ARRAY_INIT(dcomplexarr,   9);
CL_ARRAY_INIT(uintarr,      12);
CL_ARRAY_INIT(ulonarr,      13);
CL_ARRAY_INIT(lon64arr,     14);
CL_ARRAY_INIT(ulon64arr,    15);


#define CL_INDEX_GEN(NAME, TYPE_CODE)                                                    \
static IDL_VPTR IDL_cl_##NAME(int argc, IDL_VPTR *argv, char *argk) {                    \
  int i, n_dims;                                                                         \
  IDL_ARRAY_DIM dims;                                                                    \
  IDL_VPTR dimsize;                                                                      \
  int init;                                                                              \
  cl_int err;                                                                            \
                                                                                         \
  typedef struct {                                                                       \
    IDL_KW_RESULT_FIRST_FIELD;                                                           \
    IDL_VPTR error;                                                                      \
    int error_present;                                                                   \
    IDL_LONG nozero;                                                                     \
  } KW_RESULT;                                                                           \
                                                                                         \
  static IDL_KW_PAR kw_pars[] = {                                                        \
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,                                              \
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },                          \
    { NULL }                                                                             \
  };                                                                                     \
                                                                                         \
  KW_RESULT kw;                                                                          \
                                                                                         \
  n_dims = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);  \
                                                                                         \
  for (i = 0; i < n_dims; i++) {                                                         \
    dimsize = IDL_CvtULng(1, &argv[i]);                                                  \
    dims[i] = dimsize->value.ul;                                                         \
    IDL_Deltmp(dimsize);                                                                 \
  }                                                                                      \
  init = IDL_ARR_INI_INDEX;                                                              \
  IDL_VPTR result = IDL_cl_array_init(n_dims, dims, TYPE_CODE, init, &err);              \
  CL_SET_ERROR(err)                                                                      \
  return(result);                                                                        \
}

CL_INDEX_GEN(bindgen,        1);
CL_INDEX_GEN(indgen,         2);
CL_INDEX_GEN(lindgen,        3);
CL_INDEX_GEN(findgen,        4);
CL_INDEX_GEN(dindgen,        5);
CL_INDEX_GEN(cindgen,        6);
CL_INDEX_GEN(dcindgen,       9);
CL_INDEX_GEN(uindgen,       12);
CL_INDEX_GEN(ulindgen,      13);
CL_INDEX_GEN(l64indgen,     14);
CL_INDEX_GEN(ul64indgen,    15);


// ===

#pragma mark --- custom kernels ---

static IDL_VPTR IDL_cl_compile(int argc, IDL_VPTR *argv, char *argk) {
  int nargs, slen;
  cl_int err = 0;

  char *program_buffer;
  char *full_program_buffer;
  cl_program program;
  size_t program_size;
  cl_kernel kernel;
  char *kernel_name;
  char *vars;
  CL_KERNEL *kernel_struct;

  IDL_VPTR result;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
    IDL_LONG simple;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { "SIMPLE", IDL_TYP_LONG, 1, IDL_KW_ZERO,
      0, IDL_KW_OFFSETOF(simple) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  CL_INIT;

  // initialize error
  CL_SET_ERROR(err);

  IDL_ENSURE_STRING(argv[0]);
  IDL_ENSURE_ARRAY(argv[1]);
  IDL_ENSURE_STRING(argv[1]);
  IDL_ENSURE_ARRAY(argv[2]);

  if (argv[1]->value.arr->n_elts != argv[2]->value.arr->n_elts) {
    IDL_KW_FREE;
    CL_SET_ERROR(-102);
    IDL_MessageFromBlock(msg_block, OPENCL_INCORRECT_PARAM_LENGTH, IDL_MSG_LONGJMP);
    return IDL_GettmpLong(0);
  }

  if (!kw.simple) {
    IDL_ENSURE_STRING(argv[3]);
  }

  if (nargs < 3) {
    IDL_KW_FREE;
    IDL_MessageFromBlock(msg_block, OPENCL_INCORRECT_N_PARAMS, IDL_MSG_RET);
    return IDL_GettmpLong(err);
  }

  if (kw.simple) {
    int n_params = argv[2]->value.arr->n_elts;
    char *param_types = (char *) malloc(2 * n_params + 1);
    char type_code[3];
    param_types[2 * n_params] = '\0';

    for (int p = 0; p < n_params; p++) {
      sprintf(type_code,
              "%02d",
              ((IDL_LONG *) argv[2]->value.arr->data)[p]);
      param_types[2 * p] = type_code[0];
      param_types[2 * p + 1] = type_code[1];
    }

    slen = 14 + argv[0]->value.str.slen + 2 * n_params + 1;
    kernel_name = (char *) malloc(slen + 1);

    sprintf(kernel_name,
            "custom_simple_%s%s",
            param_types,
            IDL_VarGetString(argv[0]));

    kernel_name[slen] = '\0';
  } else {
    slen = 12 + argv[0]->value.str.slen + 1;
    kernel_name = (char *) malloc(slen + 1);
    sprintf(kernel_name,
            "custom_full_%s",
            IDL_VarGetString(argv[0]));
    kernel_name[slen] = '\0';
  }

  kernel = (cl_kernel) mg_table_get(kernel_table, kernel_name);
  if (!kernel) {
    if (kw.simple) {
      int n_params = argv[1]->value.arr->n_elts;
      int p, names_len = 0, types_len = 0, vars_pos = 0;
      for (p = 0; p < n_params; p++) {
        names_len += ((IDL_STRING *) argv[1]->value.arr->data)[p].slen;
        types_len += strlen(CL_TypeNames[((IDL_LONG *) argv[2]->value.arr->data)[p]]);
      }

      program_buffer = custom_simple;
      program_size = strlen(custom_simple);

      vars = (char *) malloc(13 * n_params + names_len + types_len + 1);
      vars[13 * n_params + names_len + types_len] = '\0';
      vars_pos = 0;
      for (p = 0; p < n_params; p++) {
        sprintf(vars + vars_pos,
                "__global %s *%s, ",
                CL_TypeNames[((IDL_LONG *) argv[2]->value.arr->data)[p]],
                ((IDL_STRING *) argv[1]->value.arr->data)[p].s);
        vars_pos += strlen(CL_TypeNames[((IDL_LONG *) argv[2]->value.arr->data)[p]])
          + ((IDL_STRING *) argv[1]->value.arr->data)[p].slen + 13;
      }

      program_size = strlen(program_buffer) - 4 + strlen(vars) + strlen(IDL_VarGetString(argv[0]));
      full_program_buffer = (char *) malloc(program_size + 1);
      sprintf(full_program_buffer, program_buffer, vars, IDL_VarGetString(argv[0]));
      full_program_buffer[program_size] = '\0';

      free(vars);
    } else {
      program_size = strlen(IDL_VarGetString(argv[0]));
      full_program_buffer = (char *) malloc(program_size + 1);
      sprintf(full_program_buffer, "%s", IDL_VarGetString(argv[0]));
      full_program_buffer[program_size] = '\0';
    }

    program = clCreateProgramWithSource(current_context,
                                        1,
                                        (const char**) &full_program_buffer,
                                        &program_size,
                                        &err);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }

    free(full_program_buffer);

    err = clBuildProgram(program, 0, NULL, "", NULL, NULL);
    if (err < 0) {
      CL_CHECK_BUILD;
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }

    kernel = clCreateKernel(program,
                            kw.simple ? "custom_simple" : IDL_VarGetString(argv[3]),
                            &err);
    if (err < 0) {
      printf("clCreateKernel error\n");
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }

    mg_table_put(kernel_table, kernel_name, (void *) kernel);
  }

  IDL_KW_FREE;

  kernel_struct = (CL_KERNEL *) malloc(sizeof(CL_KERNEL));
  kernel_struct->simple = kw.simple ? 1 : 0;
  kernel_struct->expr = (char *) malloc(strlen(IDL_VarGetString(argv[0])) + 1);
  sprintf(kernel_struct->expr, "%s", IDL_VarGetString(argv[0]));
  kernel_struct->expr[strlen(IDL_VarGetString(argv[0]))] = '\0';
  kernel_struct->kernel = kernel;

  result = IDL_Gettmp();
  result->type = IDL_TYP_PTRINT;
  result->value.ptrint = (IDL_PTRINT) kernel_struct;

  return result;
}


static IDL_VPTR IDL_cl_execute(int argc, IDL_VPTR *argv, char *argk, char *op) {
  int nargs, slen, n, i;
  cl_int err = 0;

  CL_KERNEL *kernel_struct;
  cl_kernel kernel;
  size_t local_size, global_size;
  IDL_VPTR param;
  IDL_VPTR result;
  IDL_MEMINT offset;
  CL_VPTR cl_param;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR error;
    int error_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  IDL_ENSURE_STRUCTURE(argv[1]);

  CL_INIT;

  // initialize error
  CL_SET_ERROR(err);

  kernel_struct = (CL_KERNEL *) argv[0]->value.ptrint;
  kernel = kernel_struct->kernel;

  if (kernel_struct->simple) {
    for (i = 0; i < IDL_StructNumTags(argv[1]->value.s.sdef); i++) {
      offset = IDL_StructTagInfoByIndex(argv[1]->value.s.sdef, i, i, &param);
      if (param->type != IDL_TYP_PTRINT) {
        CL_SET_ERROR(-1);
        IDL_MessageFromBlock(msg_block, OPENCL_INCORRECT_PARAM_TYPE, IDL_MSG_RET);
        return IDL_GettmpLong(-1);
      }

      cl_param = (CL_VPTR) (((IDL_PTRINT *) (argv[1]->value.s.arr->data + offset))[0]);
      n = cl_param->n_elts;
      err = clSetKernelArg(kernel, i, sizeof(cl_mem), &(cl_param->buffer));
      if (err < 0) {
        CL_SET_ERROR(err);
        IDL_KW_FREE;
        return IDL_GettmpLong(err);
      }

    }

    err = clSetKernelArg(kernel, i, sizeof(unsigned int), &n);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }

    local_size = 64;
    global_size = ceil(n / (float) local_size) * local_size;

    err = clEnqueueNDRangeKernel(current_queue,
                                 kernel,
                                 1,
                                 NULL,
                                 &global_size,
                                 &local_size,
                                 0,
                                 NULL,
                                 NULL);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }
  } else {
    for (i = 0; i < IDL_StructNumTags(argv[1]->value.s.sdef); i++) {
      offset = IDL_StructTagInfoByIndex(argv[1]->value.s.sdef, i, 0, &param);
      switch(param->type) {
        case IDL_TYP_PTRINT:
          cl_param = (CL_VPTR) (((IDL_PTRINT *) (argv[1]->value.s.arr->data + offset))[0]);
          n = cl_param->n_elts;
          err = clSetKernelArg(kernel, i, sizeof(cl_mem), &(cl_param->buffer));
          break;
        case IDL_TYP_BYTE:
          err = clSetKernelArg(kernel, i, sizeof(char), (char *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_INT:
          err = clSetKernelArg(kernel, i, sizeof(short int), (short int *) (argv[1]->value.s.arr->data + offset));
          break;
#if IDL_TYP_PTRINT != IDL_TYP_LONG
        case IDL_TYP_LONG:
          err = clSetKernelArg(kernel, i, sizeof(int), (int *) (argv[1]->value.s.arr->data + offset));
          break;
#endif
        case IDL_TYP_FLOAT:
          err = clSetKernelArg(kernel, i, sizeof(float), (float *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_DOUBLE:
          err = clSetKernelArg(kernel, i, sizeof(double), (double *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_COMPLEX:
          err = clSetKernelArg(kernel, i, sizeof(IDL_COMPLEX), (IDL_COMPLEX *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_DCOMPLEX:
          err = clSetKernelArg(kernel, i, sizeof(IDL_DCOMPLEX), (IDL_DCOMPLEX *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_UINT:
          err = clSetKernelArg(kernel, i, sizeof(unsigned short int), (unsigned short int *) (argv[1]->value.s.arr->data + offset));
          break;
        case IDL_TYP_ULONG:
          err = clSetKernelArg(kernel, i, sizeof(unsigned int), (unsigned int *) (argv[1]->value.s.arr->data + offset));
          break;
#if IDL_TYP_PTRINT != IDL_TYP_LONG64
        case IDL_TYP_LONG64:
          err = clSetKernelArg(kernel, i, sizeof(long), (long *) (argv[1]->value.s.arr->data + offset));
          break;
#endif
        case IDL_TYP_ULONG64:
          err = clSetKernelArg(kernel, i, sizeof(unsigned long), (unsigned long *) (argv[1]->value.s.arr->data + offset));
          break;
      }
      if (err < 0) {
        CL_SET_ERROR(err);
        IDL_KW_FREE;
        return IDL_GettmpLong(err);
      }
    }

    local_size = 64;
    global_size = ceil(n / (float) local_size) * local_size;

    err = clEnqueueNDRangeKernel(current_queue,
                                 kernel,
                                 1,
                                 NULL,
                                 &global_size,
                                 &local_size,
                                 0,
                                 NULL,
                                 NULL);
    if (err < 0) {
      CL_SET_ERROR(err);
      IDL_KW_FREE;
      return IDL_GettmpLong(err);
    }
  }

  IDL_KW_FREE;

  return(IDL_GettmpLong(0));
}


// ===

#pragma mark --- unary operations ---


static cl_int IDL_cl_unary_op(IDL_VPTR input, IDL_VPTR output, char *op, char *re_expr, char *im_expr) {
  cl_int err = 0;
  CL_VPTR x = (CL_VPTR) input->value.ptrint;
  unsigned int n_elts = x->n_elts;
  char is_complex = x->type == 6 || x->type == 9;

  size_t local_size = 64;
  size_t global_size = ceil(n_elts / (float) local_size) * local_size;

  CL_VPTR result = (CL_VPTR) output->value.ptrint;
  char *program_buffer;
  cl_program program;
  char options[500];
  size_t program_size;
  cl_kernel kernel;
  char *kernel_name;
  int slen;

  slen = 9 + strlen(op) + 1 + strlen(CL_TypeNames[x->type]) + 1;
  kernel_name = (char *) malloc(slen);
  sprintf(kernel_name, "unary_op_%s_%s", op, CL_TypeNames[x->type]);
  kernel_name[slen] = '\0';

  kernel = (cl_kernel) mg_table_get(kernel_table, kernel_name);
  if (!kernel) {
    program_buffer = is_complex ? unary_z_op : unary_op;
    program_size = strlen(program_buffer);
    program = clCreateProgramWithSource(current_context,
                                        1,
                                        (const char**) &program_buffer,
                                        &program_size,
                                        &err);
    if (err < 0) return(err);

    if (is_complex) {
      sprintf(options, "-DTYPE=%s -DRE_EXPR=%s -DIM_EXPR=%s",
              CL_TypeNames[x->type], re_expr, im_expr);
    } else {
      sprintf(options, "-DTYPE=%s -DOP=%s", CL_TypeNames[x->type], op);
    }

    err = clBuildProgram(program, 0, NULL, options, NULL, NULL);
    if (err < 0) {
      CL_CHECK_BUILD;
      return(err);
    }
  
    kernel = clCreateKernel(program, "unary_op", &err);
    if (err < 0) return(err);

    mg_table_put(kernel_table, kernel_name, (void *) kernel);
  }

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &x->buffer);
  if (err < 0) return(err);

  err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &result->buffer);
  if (err < 0) return(err);

  err = clSetKernelArg(kernel, 2, sizeof(unsigned int), &n_elts);
  if (err < 0) return(err);

  err = clEnqueueNDRangeKernel(current_queue,
                               kernel,
                               1,
                               NULL,
                               &global_size,
                               &local_size,
                               0,
                               NULL,
                               NULL);
  if (err < 0) return(err);

  err = clFinish(current_queue);
  if (err < 0) return(err);

  return(CL_SUCCESS);
}


#define CL_UNARY_OP(NAME, OP, RE_EXPR, IM_EXPR)                                         \
static IDL_VPTR IDL_cl_##NAME(int argc, IDL_VPTR *argv, char *argk) {                   \
  IDL_VPTR input = argv[0];                                                             \
  CL_VPTR cl_input = (CL_VPTR) input->value.ptrint;                                     \
  IDL_VPTR output;                                                                      \
  int n_args;                                                                           \
  cl_int err;                                                                           \
                                                                                        \
  typedef struct {                                                                      \
    IDL_KW_RESULT_FIRST_FIELD;                                                          \
    IDL_VPTR error;                                                                     \
    int error_present;                                                                  \
    IDL_VPTR lhs;                                                                       \
    int lhs_present;                                                                    \
  } KW_RESULT;                                                                          \
                                                                                        \
  static IDL_KW_PAR kw_pars[] = {                                                       \
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,                                             \
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },                         \
    { "LHS", IDL_TYP_UNDEF, 1, IDL_KW_VIN,                                              \
      IDL_KW_OFFSETOF(lhs_present), IDL_KW_OFFSETOF(lhs) },                             \
    { NULL }                                                                            \
  };                                                                                    \
                                                                                        \
  KW_RESULT kw;                                                                         \
                                                                                        \
  n_args = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw); \
                                                                                        \
  if (kw.lhs_present) {                                                                 \
    output = kw.lhs;                                                                    \
  } else {                                                                              \
    IDL_ARRAY_DIM dims = { 0, 0, 0, 0, 0, 0, 0, 0 };                                    \
    memcpy(dims, cl_input->dim, sizeof(IDL_ARRAY_DIM));                                 \
    output = IDL_cl_array_init(cl_input->n_dim,                                         \
                               dims,                                                    \
                               cl_input->type,                                          \
                               IDL_ARR_INI_NOP,                                         \
                               &err);                                                   \
  }                                                                                     \
  err = IDL_cl_unary_op(input, output, #OP, #RE_EXPR, #IM_EXPR);                        \
  return(output);                                                                       \
}

CL_UNARY_OP(not, ~, 0, 0)
CL_UNARY_OP(exp, exp, exp(z[i].x)*cos(z[i].y), exp(z[i].x)*sin(z[i].y))
CL_UNARY_OP(expm1, expm1, exp(z[i].x)*cos(z[i].y)-1, exp(z[i].x)*sin(z[i].y))
CL_UNARY_OP(exp2, exp2, exp2(z[i].x)*cos(log(2.0)*z[i].y), exp2(z[i].x)*sin(log(2.0)*z[i].y))
CL_UNARY_OP(exp10, exp10, exp10(z[i].x)*cos(log(10.0)*z[i].y), exp10(z[i].x)*sin(log(10.0)*z[i].y))
CL_UNARY_OP(sqrt, sqrt, sqrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*cos(atan2(z[i].y,z[i].x)/2), sqrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*sin(atan2(z[i].y,z[i].x)/2))
CL_UNARY_OP(cbrt, cbrt, cbrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*cos(atan2(z[i].y,z[i].x)/3), cbrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*sin(atan2(z[i].y,z[i].x)/3))
CL_UNARY_OP(rsqrt, rsqrt, sqrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*cos(atan2(z[i].y,z[i].x)/2)/sqrt(z[i].x*z[i].x+z[i].y*z[i].y), -sqrt(sqrt(z[i].x*z[i].x+z[i].y*z[i].y))*sin(atan2(z[i].y,z[i].x)/2)/sqrt(z[i].x*z[i].x+z[i].y*z[i].y))
CL_UNARY_OP(log, log, 0.5*log(z[i].x*z[i].x+z[i].y*z[i].y), (z[i].x!=0.)?atan2(z[i].y,z[i].x):acos(0.))
CL_UNARY_OP(log1p, log1p, 0.5*log((z[i].x+1.0)*(z[i].x+1.0)+z[i].y*z[i].y), (z[i].x!=-1.0)?atan2(z[i].y,z[i].x+1.0f):acos(0.))
CL_UNARY_OP(log2, log2, 0.5*log2(z[i].x*z[i].x+z[i].y*z[i].y), ((z[i].x!=0.)?atan2(z[i].y,z[i].x)/log(2.0):acos(0.)))
CL_UNARY_OP(log10, log10, 0.5*log10(z[i].x*z[i].x+z[i].y*z[i].y), (z[i].x!=0.)?atan2(z[i].y,z[i].x)/log(10.):acos(0.))
CL_UNARY_OP(logb, logb, 0, 0)
CL_UNARY_OP(erf, erf, 0, 0)
CL_UNARY_OP(erfc, erfc, 0, 0)
CL_UNARY_OP(tgamma, tgamma, 0, 0)
CL_UNARY_OP(lgamma, lgamma, 0, 0)
CL_UNARY_OP(sin, sin, sin(z[i].x)*cosh(z[i].y), cos(z[i].x)*sinh(z[i].y))
CL_UNARY_OP(cos, cos, cos(z[i].x)*cosh(z[i].y), -sin(z[i].x)*sinh(z[i].y))
CL_UNARY_OP(tan, tan, sin(2*z[i].x)/(cos(2*z[i].x)+cosh(2*z[i].y)), sinh(2*z[i].y)/(cos(2*z[i].x)+cosh(2*z[i].y)))
CL_UNARY_OP(asin, asin, asin(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)-0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)), -(log(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)+sqrt((0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))*(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))-1))))
CL_UNARY_OP(acos, acos, acos(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)-0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)), -log(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)+sqrt((0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))*(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))-1)))
CL_UNARY_OP(atan, atan, 0.5*atan2(2*z[i].x,(1-z[i].x*z[i].x-z[i].y*z[i].y)), 0.25*log((z[i].x*z[i].x+(z[i].y+1)*(z[i].y+1))/(z[i].x*z[i].x+(z[i].y-1)*(z[i].y-1))))
CL_UNARY_OP(sinh, sinh, sinh(z[i].x)*cos(z[i].y), cosh(z[i].x)*sin(z[i].y))
CL_UNARY_OP(cosh, cosh, cosh(z[i].x)*cos(z[i].y), sinh(z[i].x)*sin(z[i].y))
CL_UNARY_OP(tanh, tanh, sinh(2*z[i].x)/(cosh(2*z[i].x)+cos(2*z[i].y)), sin(2*z[i].y)/(cosh(2*z[i].x)+cos(2*z[i].y)))
CL_UNARY_OP(asinh, asinh, log(0.5*sqrt((-z[i].y+1)*(-z[i].y+1)+z[i].x*z[i].x)+0.5*sqrt((-z[i].y-1)*(-z[i].y-1)+z[i].x*z[i].x)+sqrt((0.5*sqrt((-z[i].y+1)*(-z[i].y+1)+z[i].x*z[i].x)+0.5*sqrt((-z[i].y-1)*(-z[i].y-1)+z[i].x*z[i].x))*(0.5*sqrt((-z[i].y+1)*(-z[i].y+1)+z[i].x*z[i].x)+0.5*sqrt((-z[i].y-1)*(-z[i].y-1)+z[i].x*z[i].x))-1)), -asin(0.5*sqrt((-z[i].y+1)*(-z[i].y+1)+z[i].x*z[i].x)-0.5*sqrt((-z[i].y-1)*(-z[i].y-1)+z[i].x*z[i].x)))
CL_UNARY_OP(acosh, acosh, log(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)+sqrt((0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))*(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)+0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y))-1)), acos(0.5*sqrt((z[i].x+1)*(z[i].x+1)+z[i].y*z[i].y)-0.5*sqrt((z[i].x-1)*(z[i].x-1)+z[i].y*z[i].y)))
CL_UNARY_OP(atanh, atanh, 0.25*log((z[i].y*z[i].y+(z[i].x+1)*(z[i].x+1))/(z[i].y*z[i].y+(z[i].x-1)*(z[i].x-1))), 0.5*atan2(-2*z[i].y,(1-z[i].y*z[i].y-z[i].x*z[i].x)))


// ===

#pragma mark --- binary operations ---

static cl_int IDL_cl_binary_op(IDL_VPTR input1, IDL_VPTR input2, IDL_VPTR output, char *op, char *re_expr, char *im_expr, char is_comparison) {
  cl_int err = 0;
  CL_VPTR x = (CL_VPTR) input1->value.ptrint;
  CL_VPTR y = (CL_VPTR) input2->value.ptrint;
  unsigned int n_elts = x->n_elts;
  char is_complex = x->type == 6 || x->type == 9;

  size_t local_size = 64;
  size_t global_size = ceil(n_elts / (float) local_size) * local_size;

  CL_VPTR result = (CL_VPTR) output->value.ptrint;
  char *program_buffer;
  cl_program program;
  char options[500];
  size_t program_size;
  cl_kernel kernel;
  char *kernel_name;
  int slen;

  // check to make sure both operands are the same type and same length
  if (x->n_elts != y->n_elts) {
    IDL_Message(IDL_M_NAMED_GENERIC,
                IDL_MSG_LONGJMP,
                "Binary operands must have the same number of elements");
  }
  if (x->type != y->type) {
    IDL_Message(IDL_M_NAMED_GENERIC,
                IDL_MSG_LONGJMP,
                "Binary operands must match type");
  }

  slen = 9 + strlen(op) + 1 + strlen(CL_TypeNames[x->type]) + 1;
  kernel_name = (char *) malloc(slen);
  sprintf(kernel_name, "binary_op_%s_%s", op, CL_TypeNames[x->type]);
  kernel_name[slen] = '\0';

  kernel = (cl_kernel) mg_table_get(kernel_table, kernel_name);
  if (!kernel) {
    program_buffer = (is_complex && !is_comparison) ? binary_z_op : binary_op;
    program_size = strlen(program_buffer);
    program = clCreateProgramWithSource(current_context,
                                        1,
                                        (const char**) &program_buffer,
                                        &program_size,
                                        &err);
    if (err < 0) return(err);

    if (is_complex && !is_comparison) {
      sprintf(options, "-DTYPE=%s -DRE_EXPR=%s -DIM_EXPR=%s",
              CL_TypeNames[x->type], re_expr, im_expr);
    } else {
      sprintf(options, "-DTYPE=%s -DOP=%s", CL_TypeNames[x->type], op);
    }

    err = clBuildProgram(program, 0, NULL, options, NULL, NULL);
    if (err < 0) {
      CL_CHECK_BUILD;
      return(err);
    }
  
    kernel = clCreateKernel(program, "binary_op", &err);
    if (err < 0) return(err);

    mg_table_put(kernel_table, kernel_name, (void *) kernel);
  }

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &x->buffer);
  if (err < 0) return(err);

  err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &y->buffer);
  if (err < 0) return(err);

  err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &result->buffer);
  if (err < 0) return(err);

  err = clSetKernelArg(kernel, 3, sizeof(unsigned int), &n_elts);
  if (err < 0) return(err);

  err = clEnqueueNDRangeKernel(current_queue,
                               kernel,
                               1,
                               NULL,
                               &global_size,
                               &local_size,
                               0,
                               NULL,
                               NULL);
  if (err < 0) return(err);

  err = clFinish(current_queue);
  if (err < 0) return(err);

  return(CL_SUCCESS);
}

#define CL_BINARY_OP(NAME, OP, RE_EXPR, IM_EXPR, IS_COMPARISON)                           \
static IDL_VPTR IDL_cl_##NAME(int argc, IDL_VPTR *argv, char *argk) {                     \
  IDL_VPTR input1 = argv[0];                                                              \
  IDL_VPTR input2 = argv[1];                                                              \
  CL_VPTR cl_input1 = (CL_VPTR) input1->value.ptrint;                                     \
  CL_VPTR cl_input2 = (CL_VPTR) input2->value.ptrint;                                     \
  IDL_VPTR output;                                                                        \
  int n_args;                                                                             \
  cl_int err;                                                                             \
                                                                                          \
  typedef struct {                                                                        \
    IDL_KW_RESULT_FIRST_FIELD;                                                            \
    IDL_VPTR error;                                                                       \
    int error_present;                                                                    \
    IDL_VPTR lhs;                                                                         \
    int lhs_present;                                                                      \
  } KW_RESULT;                                                                            \
                                                                                          \
  static IDL_KW_PAR kw_pars[] = {                                                         \
    { "ERROR", IDL_TYP_LONG, 1, IDL_KW_OUT,                                               \
      IDL_KW_OFFSETOF(error_present), IDL_KW_OFFSETOF(error) },                           \
    { "LHS", IDL_TYP_UNDEF, 1, IDL_KW_VIN,                                                \
      IDL_KW_OFFSETOF(lhs_present), IDL_KW_OFFSETOF(lhs) },                               \
    { NULL }                                                                              \
  };                                                                                      \
                                                                                          \
  KW_RESULT kw;                                                                           \
                                                                                          \
  n_args = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);   \
                                                                                          \
  if (kw.lhs_present) {                                                                   \
    output = kw.lhs;                                                                      \
  } else {                                                                                \
    IDL_ARRAY_DIM dims = { 0, 0, 0, 0, 0, 0, 0, 0 };                                      \
    memcpy(dims, cl_input1->dim, sizeof(IDL_ARRAY_DIM));                                  \
    output = IDL_cl_array_init(cl_input1->n_dim,                                          \
                               dims,                                                      \
                               IS_COMPARISON ? 1 : cl_input1->type,                       \
                               IDL_ARR_INI_NOP,                                           \
                               &err);                                                     \
  }                                                                                       \
  err = IDL_cl_binary_op(input1, input2, output, #OP, #RE_EXPR, #IM_EXPR, IS_COMPARISON); \
  return(output);                                                                         \
}

CL_BINARY_OP(add, x[i]+y[i], z[i].x+w[i].x, z[i].y+w[i].y, 0);
CL_BINARY_OP(sub, x[i]-y[i], z[i].x-w[i].x, z[i].y-w[i].y, 0);
CL_BINARY_OP(mult, x[i]*y[i], z[i].x*w[i].x-z[i].y*w[i].y, z[i].y*w[i].x+z[i].x*w[i].y, 0);
CL_BINARY_OP(div, x[i]/y[i], (z[i].x*w[i].x+z[i].y*w[i].y)/(w[i].x*w[i].x+w[i].y*w[i].y), (z[i].y*w[i].x-z[i].x*w[i].y)/(w[i].x*w[i].x+w[i].y*w[i].y), 0);

CL_BINARY_OP(and, x[i]&y[i], z[i].x&w[i].x, z[i].y&w[i].y, 0);
CL_BINARY_OP(or, x[i]|y[i], z[i].x|w[i].x, z[i].y|w[i].y, 0);
CL_BINARY_OP(xor, x[i]^y[i], z[i].x^w[i].x, z[i].y^w[i].y, 0);
CL_BINARY_OP(mod, fmod(x[i], y[i]), fmod(z[i].x, w[i].x), fmod(z[i].y, w[i].y), 0);

CL_BINARY_OP(eq, x[i]==y[i], (x[i].x==y[i].x)&&(x[i].y==y[i].y), 0, 1);
CL_BINARY_OP(ne, x[i]!=y[i], (x[i].x!=y[i].x)||(x[i].y!=y[i].y), 0, 1);
CL_BINARY_OP(gt, x[i]>y[i], (x[i].x*x[i].x+x[i].y*x[i].y)>(y[i].x*y[i].x+y[i].y*y[i].y), 0, 1);
CL_BINARY_OP(ge, x[i]>=y[i], (x[i].x*x[i].x+x[i].y*x[i].y)>=(y[i].x*y[i].x+y[i].y*y[i].y), 0, 1);
CL_BINARY_OP(lt, x[i]<y[i], (x[i].x*x[i].x+x[i].y*x[i].y)<(y[i].x*y[i].x+y[i].y*y[i].y), 0, 1);
CL_BINARY_OP(le, x[i]<=y[i], (x[i].x*x[i].x+x[i].y*x[i].y)<=(y[i].x*y[i].x+y[i].y*y[i].y), 0, 1);


// ===

#pragma mark --- lifecycle ---


// handle any cleanup required
static void mg_cl_exit_handler(void) {
  mg_table_free(&kernel_table, mg_cl_release_kernel);

  clReleaseCommandQueue(current_queue);
  clReleaseContext(current_context);
}


int IDL_Load(void) {
  char *kernel_location_env;
  static IDL_SYSFUN_DEF2 function_addr[] = {
    // query
    { IDL_cl_platforms,   "MG_CL_PLATFORMS",   0, 0, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_devices,     "MG_CL_DEVICES",     0, 0, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_size,        "MG_CL_SIZE",        1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // memory
    { IDL_cl_putvar,      "MG_CL_PUTVAR",      1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_getvar,      "MG_CL_GETVAR",      1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_reform,      "MG_CL_REFORM",      2, 9, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_view,        "MG_CL_VIEW",        3, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // array initialization
    { IDL_cl_make_array,  "MG_CL_MAKE_ARRAY",  1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_bytarr,      "MG_CL_BYTARR",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_intarr,      "MG_CL_INTARR",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_lonarr,      "MG_CL_LONARR",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_fltarr,      "MG_CL_FLTARR",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_dblarr,      "MG_CL_DBLARR",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_complexarr,  "MG_CL_COMPLEXARR",  1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_dcomplexarr, "MG_CL_DCOMPLEXARR", 1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_uintarr,     "MG_CL_UINTARR",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ulonarr,     "MG_CL_ULONARR",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_lon64arr,    "MG_CL_LON64ARR",    1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ulon64arr,   "MG_CL_ULON64ARR",   1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_bindgen,     "MG_CL_BINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_indgen,      "MG_CL_INDGEN",      1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_lindgen,     "MG_CL_LINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_findgen,     "MG_CL_FINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_dindgen,     "MG_CL_DINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_cindgen,     "MG_CL_CINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_dcindgen,    "MG_CL_DCINDGEN",    1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_uindgen,     "MG_CL_UINDGEN",     1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ulindgen,    "MG_CL_ULINDGEN",    1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_l64indgen,   "MG_CL_L64INDGEN",   1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ul64indgen,  "MG_CL_UL64INDGEN",  1, 8, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // custom kernels
    { IDL_cl_compile,     "MG_CL_COMPILE",     3, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_execute,     "MG_CL_EXECUTE",     2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // unary operations
    { IDL_cl_not,         "MG_CL_NOT",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_sqrt,        "MG_CL_SQRT",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_exp,         "MG_CL_EXP",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_expm1,       "MG_CL_EXPM1",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_exp2,        "MG_CL_EXP2",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_exp10,       "MG_CL_EXP10",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_sqrt,        "MG_CL_SQRT",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_cbrt,        "MG_CL_CBRT",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_rsqrt,       "MG_CL_RSQRT",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_log,         "MG_CL_LOG",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_log1p,       "MG_CL_LOG1P",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_log2,        "MG_CL_LOG2",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_log10,       "MG_CL_LOG10",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_logb,        "MG_CL_LOGB",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_erf,         "MG_CL_ERF",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_erfc,        "MG_CL_ERFC",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_tgamma,      "MG_CL_TGAMMA",      1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_lgamma,      "MG_CL_LGAMMA",      1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_sin,         "MG_CL_SIN",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_cos,         "MG_CL_COS",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_tan,         "MG_CL_TAN",         1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_asin,        "MG_CL_ASIN",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_acos,        "MG_CL_ACOS",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_atan,        "MG_CL_ATAN",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_sinh,        "MG_CL_SINH",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_cosh,        "MG_CL_COSH",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_tanh,        "MG_CL_TANH",        1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_asinh,       "MG_CL_ASINH",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_acosh,       "MG_CL_ACOSH",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_atanh,       "MG_CL_ATANH",       1, 3, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // binary operations
    { IDL_cl_add,         "MG_CL_ADD",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_sub,         "MG_CL_SUB",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_mult,        "MG_CL_MULT",        2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_div,         "MG_CL_DIV",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_and,         "MG_CL_AND",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_or,          "MG_CL_OR",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_xor,         "MG_CL_XOR",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_mod,         "MG_CL_MOD",         2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    { IDL_cl_eq,          "MG_CL_EQ",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ne,          "MG_CL_NE",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_gt,          "MG_CL_GT",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_ge,          "MG_CL_GE",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_lt,          "MG_CL_LT",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_cl_le,          "MG_CL_LE",          2, 4, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    // initialization
    { (IDL_SYSRTN_GENERIC) IDL_cl_init, "MG_CL_INIT", 0, 0, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // query
    { (IDL_SYSRTN_GENERIC) IDL_cl_help, "MG_CL_HELP", 0, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },

    // memory
    { (IDL_SYSRTN_GENERIC) IDL_cl_free, "MG_CL_FREE", 1, 1, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
  };

  if (!(msg_block = IDL_MessageDefineBlock("opencl", IDL_CARRAY_ELTS(msg_arr), msg_arr))) {
    return(IDL_FALSE);
  }

  IDL_ExitRegister(mg_cl_exit_handler);

  kernel_table = mg_table_new(0);

  // default initialization
  IDL_cl_init(0, NULL, NULL);

  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
         && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
