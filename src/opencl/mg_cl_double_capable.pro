; docformat = 'rst'

;+
; Determine if device(s) are capable of double-precision arithmetic.
;
; :Returns:
;   1B if double capable, 0B if not; returns an `bytarr` with the same number
;   of elements as devices if `PLATFORM` is set (or there is only one platform),
;   but `DEVICE` is not set
;
; :Keywords:
;   platform : in, optional, type=integer
;     index of platform to query
;   device : in, optional, type=integer
;     index of device to query
;   error : out, optional, type=integer
;     set to a named variable to retrieve the OpenCL error code; can be
;     converted to a string message with `MG_CL_ERROR_MESSAGE`
;-
function mg_cl_double_capable, platform=platform_index, $
                               device=device_index, $
                               error=error
  compile_opt strictarr
  on_error, 2

  if (n_elements(platform_index) gt 0L $
        && n_elements(device_index) eq 0L) then begin
    devices = mg_cl_devices(platform=platform_index, error=error)
    if (error ne 0L) then return, 0B

    return, strpos(devices.extensions, 'cl_khr_fp64') ge 0L
  endif

  if (n_elements(platform_index) eq 0L $
        && n_elements(device_index) eq 0L) then begin
    devices = mg_cl_devices(/current, error=err)
    if (size(devices, /type) ne 8L) then begin
      message, 'no current device'
    endif
    return, strpos(devices.extensions, 'cl_khr_fp64') ge 0L
  endif

  if (n_elements(platform_index) eq 0L $
        && n_elements(device_index) gt 0L) then begin
    platforms = mg_cl_platforms(count=n_platforms)
    if (n_platforms eq 1L) then begin
      _platform_index = 0L
    endif else begin
      message, 'DEVICE specified without PLATFORM'
    endelse
  endif else _platform_index = platform_index

  devices = mg_cl_devices(platform=_platform_index, error=error)
  if (error ne 0L) then return, 0B
  return, strpos(devices[device_index].extensions, 'cl_khr_fp64') ge 0L
end
