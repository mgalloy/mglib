; docformat = 'rst'

;+
; Example of using GSL bindings to produce non-uniform random distributions.
;
; :Keywords:
;   n : optional, type=integer, default=1000
;     number of random numbers to generate
;-
pro mg_gsl_randist_example, n=n, sigma=sigma
  compile_opt strictarr

  _sigma = n_elements(sigma) eq 0L ? 1.0D : sigma
  _n = n_elements(n) eq 0L ? 10000L : n

  mg_gsl_rng_env_setup
  t = mg_gsl_rng_default()
  r = mg_gsl_rng_alloc(t)

  u = dblarr(_n)
  for i = 0L, _n - 1L do begin
    u[i] = mg_gsl_ran_gaussian(r, _sigma)
  endfor

  print, _n, mean(u), stddev(u), $
         format='(%"%d doubles generated; mean = %f, stddev = %f")'

  m = 3.0
  nbins = 40
  h = histogram(u, min=-m, max=m, nbins=nbins)
  mg_histplot, 2.0 * m * findgen(nbins) / (nbins - 1L) - m, h, $
               xstyle=9, xrange=[-m, m], $
               ystyle=9, yrange=[0, max(h)]
end
