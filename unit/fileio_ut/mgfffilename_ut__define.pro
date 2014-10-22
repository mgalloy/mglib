; docformat = 'rst'

function mgfffilename_ut::test_compose_allParts
  compile_opt strictarr

  f = obj_new('MGffFilename', 'a', subdir=['b', 'c'], root='d')
  filename = f->toString()
  obj_destroy, f

  assert, filename eq strjoin(['d', 'b', 'c', 'a'], path_sep()), $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_compose_fullFilename
  compile_opt strictarr

  f = obj_new('MGffFilename', filepath(''))
  filename = f->toString()
  obj_destroy, f

  assert, filename eq filepath(''), $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_compose_noBasename
  compile_opt strictarr

  f = obj_new('MGffFilename', subdir=['b', 'c'])
  filename = f->toString()
  obj_destroy, f

  assert, filename eq strjoin(['b', 'c'], path_sep()) + path_sep(), $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_compose_tmp
  compile_opt strictarr

  f = obj_new('MGffFilename', 'a', subdir=['b', 'c'], /tmp)
  filename = f->toString()
  obj_destroy, f

  tail = strjoin(['b', 'c', 'a'], path_sep())
  assert, strmid(filename, strlen(tail) - 1L, /reverse_offset) eq tail, $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_setExtension_replace
  compile_opt strictarr

  f = obj_new('MGffFilename', 'a.dat', subdir=['b', 'c'])
  f->setProperty, extension='html'
  filename = f->toString()
  obj_destroy, f

  assert, filename eq strjoin(['b', 'c', 'a'], path_sep()) + '.html', $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_setExtension_add
  compile_opt strictarr

  f = obj_new('MGffFilename', subdir=['b', 'c'])
  f->setProperty, extension='html'
  filename = f->toString()
  obj_destroy, f

  assert, filename eq strjoin(['b', 'c'], path_sep()) + path_sep() + '.html', $
          'incorrect filename: ' + filename

  return, 1
end


function mgfffilename_ut::test_decompose_withSubdirs
  compile_opt strictarr

  subdirs = ['b', 'c']
  f = obj_new('MGffFilename', 'a.dat', subdir=subdirs)
  f->getProperty, extension=ext, basename=basename, dirname=dirname, directories=directories
  obj_destroy, f

  assert, ext eq 'dat', $
          'incorrect extension: ' + ext
  assert, basename eq 'a.dat', $
          'incorrect basename: ' + basename
  assert, dirname eq strjoin(subdirs, path_sep()) + path_sep(), $
          'incorrect dirname: ' + dirname
  assert, array_equal(directories, subdirs), $
          'incorrect directories: ' + strjoin(directories, ', ')

  return, 1
end


function mgfffilename_ut::test_decompose_noSubdirs
  compile_opt strictarr

  f = obj_new('MGffFilename', 'a.dat')
  f->getProperty, extension=ext, basename=basename, dirname=dirname, directories=directories
  obj_destroy, f

  assert, ext eq 'dat', $
          'incorrect extension: ' + ext
  assert, basename eq 'a.dat', $
          'incorrect basename: ' + basename
  assert, dirname eq '.' + path_sep(), $
          'incorrect dirname: ' + dirname
  assert, array_equal(directories, ['.']), $
          'incorrect directories: ' + strjoin(directories, ', ')

  return, 1
end


function mgfffilename_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgfffilename__define', $
                            'mgfffilename::cleanup', $
                            'mgfffilename::compose', $
                            'mgfffilename::getProperty', $
                            'mgfffilename::setProperty']
  self->addTestingRoutine, ['mgfffilename::init', $
                            'mgfffilename::toString'], $
                           /is_function

  return, 1
end


;+
; Test array list.
;-
pro mgfffilename_ut__define
  compile_opt strictarr

  define = { MGffFilename_ut, inherits MGutLibTestCase }
end
