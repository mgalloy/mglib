; docformat = 'rst'

;+
; This makes MGffTemplate_ut a template object.
;
; :Params:
;    name : in, required, type=string
;       name of the variable to find
;
; :Keywords:
;    found : out, optional, type=boolean
;       true if variable found
;-
function mgfftemplate_ut::getVariable, name, found=found
  compile_opt strictarr

  found = 1B
  case strlowcase(name) of
    'a' : return, self.a
    'arr' : return, self.arr
    'objects' : return, self.objects
    'filename' : return, self.filename
    else : begin
        found = 0B
        return, -1L
      end
  endcase
end


function mgfftemplate_ut::_runTest, templateBasename, variables, answer, $
                                    line=line
  compile_opt strictarr
  on_error, 2

  root = mg_src_root()
  templateFilename = filepath(templateBasename + '.tt', root=root)
  outputFilename = filepath(templateBasename + '.out', root=root)

  template = obj_new('MGffTemplate', templateFilename)
  template->process, variables, outputFilename
  obj_destroy, template

  openr, lun, outputFilename, /get_lun
  line = ''
  readf, lun, line
  free_lun, lun

  file_delete, outputFilename

  return, line eq answer
end


;+
; Process an INCLUDE_TEMPLATE with an object template.
;-
function mgfftemplate_ut::test_include_template_object
  compile_opt strictarr

  self.filename = filepath('simple.tt', root=mg_src_root())
  self.a = 5S
  result = self->_runTest('include_template', $
                          self, $
                          '15')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an INCLUDE with an object template.
;-
function mgfftemplate_ut::test_include_object
  compile_opt strictarr

  self.filename = filepath('simple.tt', root=mg_src_root())
  result = self->_runTest('include', $
                          self, $
                          '[% 3 * a %]')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an INSERT with an object template.
;-
function mgfftemplate_ut::test_insert_object
  compile_opt strictarr

  result = self->_runTest('insert', $
                          self, $
                          '[% 3 * a %]')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process a SCOPE directive with an object template.
;-
function mgfftemplate_ut::test_scope
  compile_opt strictarr

  for i = 0L, 9L do begin
    o = obj_new('MGffTemplate_ut', test_runner=self.testRunner)
    o.a = i
    self.objects[i] = o
  endfor

  answer = '0123456789'
  result = self->_runTest('scope', $
                          self, $
                          answer, $
                          line=line)

  obj_destroy, self.objects
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process two SCOPE directives with an object template.
;-
function mgfftemplate_ut::test_double_scope
  compile_opt strictarr

  for i = 0L, 9L do begin
    o = obj_new('MGffTemplate_ut', test_runner=self.testRunner)
    o.a = i
    self.objects[i] = o
  endfor

  answer = '01234567890123456789'
  result = self->_runTest('double-scope', $
                          self, $
                          answer, $
                          line=line)

  obj_destroy, self.objects
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process a FOR loop with an object template.
;-
function mgfftemplate_ut::test_for_object
  compile_opt strictarr

  self.arr = bindgen(10)
  result = self->_runTest('for', $
                          self, $
                          '0123456789')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process two FOR loops with an object template.
;-
function mgfftemplate_ut::test_double_for_object
  compile_opt strictarr

  self.arr = bindgen(10)
  result = self->_runTest('double-for', $
                          self, $
                          '01234567890123456789', line=line)
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an IF/ELSE (using object template).
;-
function mgfftemplate_ut::test_if_object
  compile_opt strictarr

  self.a = 7S
  result = self->_runTest('if', self, 'True', line=line)
  assert, result, 'not true'

  self.a = 4S
  result = self->_runTest('if', self, 'False', line=line)
  assert, result, 'not false'

  return, 1
end


;+
; Process a simple expression with an object template.
;-
function mgfftemplate_ut::test_simple_object
  compile_opt strictarr


  self.a = 5S
  result = self->_runTest('simple', self, '15')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an INCLUDE_TEMPLATE.
;-
function mgfftemplate_ut::test_include_template
  compile_opt strictarr

  simpleFilename = filepath('simple.tt', root=mg_src_root())
  result = self->_runTest('include_template', $
                          { filename: simpleFilename, a: 5 }, $
                          '15')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an INCLUDE.
;-
function mgfftemplate_ut::test_include
  compile_opt strictarr

  simpleFilename = filepath('simple.tt', root=mg_src_root())
  result = self->_runTest('include', $
                          { filename: simpleFilename }, $
                          '[% 3 * a %]')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an INSERT.
;-
function mgfftemplate_ut::test_insert
  compile_opt strictarr

  result = self->_runTest('insert', $
                          { a: 5 }, $
                          '[% 3 * a %]')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process a FOR loop.
;-
function mgfftemplate_ut::test_for
  compile_opt strictarr

  result = self->_runTest('for', $
                          { arr:bindgen(10) }, $
                          '0123456789')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process an IF/ELSE.
;-
function mgfftemplate_ut::test_if
  compile_opt strictarr

  result = self->_runTest('if', $
                          { a: 7 }, $
                          'True')
  assert, result, 'incorrect result'

  result = self->_runTest('if', $
                          { a: 4 }, $
                          'False')
  assert, result, 'incorrect result'

  return, 1
end


;+
; Process a simple expression.
;-
function mgfftemplate_ut::test_simple
  compile_opt strictarr

  result = self->_runTest('simple', $
                          { a: 5 }, $
                          '15')
  assert, result, 'incorrect result'

  return, 1
end


function mgfftemplate_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgfftemplate__define', $
                            'mgfftemplate::cleanup', $
                            'mgfftemplate::reset', $
                            'mgfftemplate::process', $
                            'mgfftemplate::_process_tokens', $
                            'mgfftemplate::_process_variable', $
                            'mgfftemplate::_process_scope', $
                            'mgfftemplate::_process_insert', $
                            'mgfftemplate::_process_include_template', $
                            'mgfftemplate::_process_include', $
                            'mgfftemplate::_copyFile', $
                            'mgfftemplate::_process_foreach', $
                            'mgfftemplate::_process_if', $
                            'mgfftemplate::_printf', $
                            'mgffcompoundtemplate__define', $
                            'mgffcompoundtemplate::cleanup', $
                            'mgfffortemplate__define', $
                            'mgfffortemplate::cleanup', $
                            'mgfffortemplate::setVariable']
  self->addTestingRoutine, ['mgfftemplate::init', $
                            'mgfftemplate::_getVariable', $
                            'mgfftemplate_makespace', $
                            'mgffcompoundtemplate::init', $
                            'mgffcompoundtemplate::getVariable', $
                            'mgfffortemplate::init', $
                            'mgfffortemplate::getVariable'], $
                           /is_function

  return, 1
end


;+
; Unit tests fo MGffTemplate.
;-
pro mgfftemplate_ut__define
  compile_opt strictarr

  define = { mgfftemplate_ut, inherits MGutLibTestCase, $
             a: 0S, $
             arr: bytarr(10), $
             objects: objarr(10), $
             filename: '' $
           }
end
