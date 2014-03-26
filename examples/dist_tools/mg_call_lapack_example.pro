; docformat = 'rst'

;+
; Example of calling a LAPACK routine from the library provided by the IDL
; distribution.
;-
pro mg_call_lapack_example
  compile_opt strictarr
  
  ext = !version.os_family eq 'unix' ? '.so' : '.dll'
  lapack = filepath('idl_lapack' + ext, $
                    root=expand_path('<IDL_DEFAULT>', /dlm))

  prefix = ''
  suffix = '_'

  routine_name = prefix + 'sgeqrf' + suffix

  m = 20L
  n = 10L
  x = randomu(seed, m, n)
  
  info = 0L
  tau = fltarr(m < n)
  lwork = -1L
  work = fltarr(1)
  status = call_external(lapack, routine_name, $
                         m, n, x, m, tau, work, lwork, info, $
                         value=[0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L], $
                         /auto_glue, /verbose, /show_all_output)
  lwork = long(work[0])
  work2 = fltarr(lwork)
  status = call_external(lapack, routine_name, $
                         m, n, x, m, tau, work2, lwork, info, $
                         value=[0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L], $
                         /auto_glue)
end
