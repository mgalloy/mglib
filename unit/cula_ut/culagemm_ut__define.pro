; docformat = 'rst'

; function culagemm_ut::test_single_basic
;   compile_opt strictarr
;
;   seed = 1L
;   m = 5L
;   n = 10L
;   k = 20L
;   a = randomu(seed, m, k)
;   b = randomu(seed, k, n)
;   c = randomu(seed, m, n)
;   old_c = c
;   op = mg_char('N')
;
;   lda = m
;   ldb = k
;   ldc = m
;
;   status = culaSgemm(op, op, m, n, k, 1.0, a, lda, b, ldb, 1.0, c, ldc)
;
;   assert, status eq 0, 'invalid status: %d, %s', $
;           status, culaGetStatusString(status)
;
;   error = total(abs(a # b + old_c - c))
;   assert, error lt 1e-6, 'incorrect result; error = %f', error
;
;   return, 1
; end
;
;
; pro culagemm_ut::setup
;   compile_opt strictarr
;
;   self->MGutLibTestCase::setup
;
;   status = culaInitialize()
;   assert, status eq 0L, 'invalid initialization status: %d, %s', $
;           status, culaGetStatusString(status)
; end
;
;
; pro culagemm_ut::teardown
;   compile_opt strictarr
;
;   culaShutdown
;
;   self->MGutLibTestCase::teardown
; end


pro culagemm_ut__define
  compile_opt strictarr

  define = { culagemm_ut, inherits MGutLibTestCase }
end
