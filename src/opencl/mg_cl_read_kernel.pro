; docformat = 'rst'

;+
; Read a kernel definition from a file in a single string appropriate
; for passing to `MG_CL_COMPILE`.
;
; :Returns:
;   string
;
; :Params:
;   filename : in, required, type=string
;     file containing code for an OpenCL kernel
;-
function mg_cl_read_kernel, filename
  compile_opt strictarr

  n_lines = file_lines(filename)
  lines = strarr(n_lines)

  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun

  return, mg_strmerge(lines)
end

