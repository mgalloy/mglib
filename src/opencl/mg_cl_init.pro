; docformat = 'rst'

;+
; Initialize OpenCL. Note that it is required to use `MG_CL_INIT` before
; calling any routine that uses any OpenCL kernel.
;
; :Keywords:
;   platform : in, optional, type=long, default=0
;     set index of platform to use; default is to use the value of the
;     `CL_DEFAULT_PLATFORM` environment variable, if present, 0 otherwise
;   device : in, optional, type=long, default=0
;     set index of device to use; default is to use the value of the
;     `CL_DEFAULT_DEVICE` environment variable, if present, 0 otherwise
;   gpu : in, optional, type=boolean
;     set to use the first GPU device found
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status of initializing
;     OpenCL; use `MG_CL_ERROR_MESSAGE` to convert to a string message
;-
pro mg_cl_init, device=device, $
                error=error, $
                gpu=gpu, $
                platform=platform
  compile_opt strictarr

  mg_cl_initialize, device=device, error=error, gpu=gpu, platform=platform, $
                    kernel_location=mg_src_root()
end
