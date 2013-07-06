; docformat = 'rst'

pro mg_run_unittests, filename
  compile_opt strictarr

  mgunit, 'mglib_uts', filename=filename, html=n_elements(filename) gt 0L, $
          ntest=ntest, npass=npass, nfail=nfail, nskip=nskip
  if (n_elements(filename) gt 0L) then begin
    print, ntest, npass, nfail, nskip, $
           format='(%"%d tests: %d passed, %d failed, %d skipped")'
    print, filename, format='(%"Full results in %s")'
  endif
end
