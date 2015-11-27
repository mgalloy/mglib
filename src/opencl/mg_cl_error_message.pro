; docformat = 'rst'

;+
; Returns the string name for an OpenCL error code.
;
; :Examples:
;   For example::
;
;     IDL> print, mg_cl_error_message(-1)
;     CL_DEVICE_NOT_FOUND
;     IDL> print, mg_cl_error_message(0)
;     CL_SUCCESS
;
; :Returns:
;   string
;
; :Params:
;   code : in, required, type=int
;     OpenCL error code as returned from the `ERROR` keyword of a `MG_CL_*`
;     routine
;-
function mg_cl_error_message, code
  compile_opt strictarr
  on_error, 2

  if (n_elements(code) eq 0L) then message, 'code argument required'

  if (code le 0L && code ge - 14L) then begin
    return, (['CL_SUCCESS', $
              'CL_DEVICE_NOT_FOUND', $
              'CL_DEVICE_NOT_AVAILABLE', $
              'CL_COMPILER_NOT_AVAILABLE', $
              'CL_MEM_OBJECT_ALLOCATION_FAILURE', $
              'CL_OUT_OF_RESOURCES', $
              'CL_OUT_OF_HOST_MEMORY', $
              'CL_PROFILING_INFO_NOT_AVAILABLE', $
              'CL_MEM_COPY_OVERLAP', $
              'CL_IMAGE_FORMAT_MISMATCH', $
              'CL_IMAGE_FORMAT_NOT_SUPPORTED', $
              'CL_BUILD_PROGRAM_FAILURE', $
              'CL_MAP_FAILURE', $
              'CL_MISALIGNED_SUB_BUFFER_OFFSET', $
              'CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST'])[- code]
  endif

  if (code le - 30L && code ge - 64L) then begin
    code += 30L
    return, (['CL_INVALID_VALUE', $
              'CL_INVALID_DEVICE_TYPE', $
              'CL_INVALID_PLATFORM', $
              'CL_INVALID_DEVICE', $
              'CL_INVALID_CONTEXT', $
              'CL_INVALID_QUEUE_PROPERTIES', $
              'CL_INVALID_COMMAND_QUEUE', $
              'CL_INVALID_HOST_PTR', $
              'CL_INVALID_MEM_OBJECT', $
              'CL_INVALID_IMAGE_FORMAT_DESCRIPTOR', $
              'CL_INVALID_IMAGE_SIZE', $
              'CL_INVALID_SAMPLER', $
              'CL_INVALID_BINARY', $
              'CL_INVALID_BUILD_OPTIONS', $
              'CL_INVALID_PROGRAM', $
              'CL_INVALID_PROGRAM_EXECUTABLE', $
              'CL_INVALID_KERNEL_NAME', $
              'CL_INVALID_KERNEL_DEFINITION', $
              'CL_INVALID_KERNEL', $
              'CL_INVALID_ARG_INDEX', $
              'CL_INVALID_ARG_VALUE', $
              'CL_INVALID_ARG_SIZE', $
              'CL_INVALID_KERNEL_ARGS', $
              'CL_INVALID_WORK_DIMENSION', $
              'CL_INVALID_WORK_GROUP_SIZE', $
              'CL_INVALID_WORK_ITEM_SIZE', $
              'CL_INVALID_GLOBAL_OFFSET', $
              'CL_INVALID_EVENT_WAIT_LIST', $
              'CL_INVALID_EVENT', $
              'CL_INVALID_OPERATION', $
              'CL_INVALID_GL_OBJECT', $
              'CL_INVALID_BUFFER_SIZE', $
              'CL_INVALID_MIP_LEVEL', $
              'CL_INVALID_GLOBAL_WORK_SIZE', $
              'CL_INVALID_PROPERTY'])[- code]
  endif

  return, string(code, format='(%"unknown error code (%d)")')
end
