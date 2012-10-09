; docformat = 'rst'

pro mg_cula_demo
  compile_opt strictarr

  status = culaInitialize()
  help, status

  print, culaGetVersion(), format='(%"CULA version: %d")'
  e = culaGetLastStatus()
  print, culaGetStatusString(e)

  nDevices = 0L
  status = culaGetDeviceCount(ndevices)

  print, nDevices, format='(%"%d devices available")'

  ; int culaSgemm(char transa, char transb,
  ;               int m, int n, int k,
  ;               float alpha,
  ;               float a[], int lda,
  ;               float b[], int ldb,
  ;               float beta,
  ;               float c[], int ldc);

  noTrans = (byte('N'))[0]
  a = randomu(seed, 3, 3)
  b = randomu(seed, 3, 3)
  c = fltarr(3, 3)

  status = culaSgemm(noTrans, noTrans, 3L, 3L, 3L, 1.0, a, 3L, b, 3L, 1.0, c, 3L)
  e = culaGetLastStatus()
  print, culaGetStatusString(e), format='(%"Error from culaSgemm: %s")'

  print, c

  print, a ## b

  culaShutdown
end
