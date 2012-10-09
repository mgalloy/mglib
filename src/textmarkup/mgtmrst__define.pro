; docformat = 'rst'

;+
; Destination class to output reStructuredText.
;-


;+
; Text to include afer a markup node of the given type.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    type : in, required, type=string
;       type of `MGtmNode`
;
; :Keywords:
;    newline : out, optional, type=boolean, default=0
;       set to a named variable to get whether a newline should be added
;       at the given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmrst::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, '**'
    'code': return, '`'
    'emphasis': return, '*'
    'newline': begin
        newline = 1
        return, ''
      end
    'paragraph': return, ''
    'preformatted': return, ''
    else: return, ''
  endcase
end


;+
; Text to include after a markup node of the given type.
;
; :Private:
;
; :Returns:
;    string
;
; :Params:
;    type : in, required, type=string
;       type of `MGtmNode`
;
; :Keywords:
;    newline : out, optional, type=boolean, default=0
;       set to a named variable to get whether a newline should be added
;       at the given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmrst::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, '**'
    'code': return, '`'
    'emphasis': return, '*'
    'newline': return, ''
    'paragraph': begin
        newline = 1
        return, ''
      end
    'preformatted': begin
        newline = 1
        return, ''
      end
    else: return, ''
  endcase
end


;+
; Define `MGtmRST` class for processing restructured text.
;-
pro mgtmrst__define
  compile_opt strictarr

  define = { mgtmrst, inherits mgtmlanguage }
end
