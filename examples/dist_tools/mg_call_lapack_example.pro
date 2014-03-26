; docformat = 'rst'

;+
; Example of calling a LAPACK routine from the library provided by the IDL
; distribution.
;-
pro mg_call_lapack_example
  compile_opt strictarr
  
  ext = !version.os_family eq 'unix' ? '.so' : '.dll'
  lapack = filepath('idl_lapack' + ext, root=expand_path('<IDL_DEFAULT>', /dlm))

  case !version.os_name of
    'linux': begin
        prefix = ''
        suffix = '_'
      end
    'Mac OS X': begin
        prefix = ''
        suffix = ''

        ; use Accelerate framework instead of library distributed with IDL
        lapack = '/System/Library/Frameworks/Accelerate.framework/' $
                   + 'Versions/Current/Frameworks/vecLib.framework/' $
                   + 'Versions/Current/libLAPACK.dylib'
      end
    'Microsoft Windows': begin
        prefix = ''
        suffix = ''
      end
    else: begin
        prefix = ''
        suffix = ''
      end
  endcase

  routine_name = prefix + 'sgeqrf' + suffix

  m = 20L
  n = 10L
  x = randomu(seed, m, n)
  original_x = x

  info = 0L
  tau = fltarr(m < n)
  lwork = -1L
  work = fltarr(1)
  status = call_external(lapack, routine_name, $
                         m, n, x, m, tau, work, lwork, info, $
                         value=[0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L], $
                         /auto_glue)
  lwork = long(work[0])
  work2 = fltarr(lwork)

  print, lwork, format='(%"Determined workspace required: %d bytes")'

  status = call_external(lapack, routine_name, $
                         m, n, x, m, tau, work2, lwork, info, $
                         value=[0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L], $
                         /auto_glue)

   q = identity(m)
   for i = 0L, n - 1L do begin
     v = fltarr(m)
     v[i] = 1.0
     v[i + 1:m - 1L] = x[i + 1:m - 1L, i]
     q_sub = (identity(m) - tau[i] * (v # v))
     q = q ## q_sub
   endfor

   r = fltarr(m, n)
   for i = 0L, n - 1L do r[0L:i, i] = x[0L:i, i]  ; fill in lower diag

   reconstructed_x = transpose(q) # r
   error = total(abs(original_x - reconstructed_x), /preserve_type)

   print, error, $
          format='(%"Total error in reconstruction of QR decomposition: %f")'
end
