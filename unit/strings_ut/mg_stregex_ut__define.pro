; docformat = 'rst'

; function mg_stregex_ut::testUrlsWithFindAll
;   compile_opt strictarr
;
;   s = 'www.michaelgalloy.com and http://www.espn.com are two of my favorite sites'
;   result = mg_stregex(s, /url, /extract, /find_all)
;
;   assert, result[0] eq 'www.michaelgalloy.com', $
;           'did not find www.michaelgalloy.com'
;   assert, result[1] eq 'http://www.espn.com', $
;           'did not find http://www.espn.com'
;
;   return, 1
; end
;
;
; function mg_stregex_ut::testUrls
;   compile_opt strictarr
;
;   urlsFilename = filepath('urls.txt', root=mg_src_root())
;   urlsFile = mg_file(urlsFilename)
;   urls = urlsFile->readf()
;   obj_destroy, urlsFile
;
;   positions = mg_stregex(urls, /url, length=length)
;
;   correctPositions = [0, 0, 16, 0, 16, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 7]
;   correctLength = [24, 25, 24, 36, 36, 24, 25, 24, 25, 24, 37, 19, 11, 10, 39, 25, 30, 34, 23, 70, 17, 14, 18, 15]
;
;   assert, array_equal(positions, correctPositions), 'incorrect positions'
;   assert, array_equal(length, correctLength), 'incorrect length'
;
;   return, 1
; end

function mg_stregex_ut::test_basic
  compile_opt strictarr

  assert, self->have_dlm('mg_strings'), 'MG_STRINGS DLM not found', /skip

  urlRe = '(([[:alnum:]_-]+://?|www[.])[^[:space:]()<>]+(\([[:alnum:]_[:digit:]]+\)|([^[:punct:][:space:]]|/)))'

  urlsFilename = filepath('urls.txt', root=mg_src_root())
  urlsFile = mg_file(urlsFilename)
  urls = urlsFile->readf()
  obj_destroy, urlsFile

  correctPositions = [0, 0, 16, 0, 16, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 7]
  correctLength = [24, 25, 24, 36, 36, 24, 25, 24, 25, 24, 37, 19, 11, 10, 39, 25, 30, 34, 23, 70, 17, 14, 18, 15]

  for i = 0L, n_elements(urls) - 1L do begin
    position = mg_stregex(urls[i], urlRe, length=length)

    assert, array_equal(position, correctPositions[i]), 'incorrect positions'
    assert, array_equal(length, correctLength[i]), 'incorrect length'
  endfor

  return, 1
end


function mg_stregex_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mg_stregex', /is_function

  return, 1
end


pro mg_stregex_ut__define
  compile_opt strictarr

  define = { mg_stregex_ut, inherits MGutLibTestCase }
end
