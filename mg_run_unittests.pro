; docformat = 'rst'

pro mg_run_unittests
  compile_opt strictarr

  filename = filepath('mglib-test-results.html', root='.')
  mgunit, 'mglib_uts', filename=filename, /html, $
          ntest=ntest, npass=npass, nfail=nfail, nskip=nskip
  print, ntest, npass, nfail, nskip, $
         format='(%"%d tests: %d passed, %d failed, %d skipped")'
end
