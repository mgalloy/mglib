; docformat = 'rst'

pro mg_run_unittests
  compile_opt strictarr

  filename = filepath('mglib-test-results.html', root='.')
  mgunit, 'mglib_uts', filename=filename, /html
end
