; docformat = 'rst'

;+
; Parent class for vis library test cases. All vis library unit tests should 
; inherit from this class. It provides vis library specific testing features.
;-

;+
; Initialize an vis library test case.
; 
; Returns: 1 for success, 0 for failure
;
; Keywords:
;    _ref_extra : in, out, optional, type=keyword
;       keywords to MGutTestCase::init
;-
function visuttestcase::init, _ref_extra=e
  compile_opt strictarr

  if (~self->mguttestcase::init(_strict_extra=e)) then return, 0
  
  self.root = file_dirname(vis_src_root(), /mark_directory)
  
  return, 1
end


;+
; Define instance variables.
; 
; Fields:
;    root
;       absolute path to the root of the IDLdoc project (with trailing slash)
;-
pro visuttestcase__define
  compile_opt strictarr
  
  define = { VISutTestCase, inherits MGutTestCase, $
             root: '' $
           }
end