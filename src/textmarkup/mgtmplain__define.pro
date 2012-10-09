; docformat = 'rst'

;+
; Destination class to output plain text.
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
;       set to a named variable to get whether a newline should be added at the
;       given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmplain::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, ''
    'code': return, ''
    'comments': return, ''
    'emphasis': return, ''
    'listing': return, ''
    'newline': begin
        newline = 1
        return, ''
      end
    'paragraph': return, ''
    else : return, ''
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
;       set to a named variable to get whether a newline should be added at
;       the given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmplain::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, ''
    'code': return, ''
    'comments': return, ''
    'emphasis': return, ''
    'listing': return, ''
    'newline': return, ''
    'paragraph': begin
        newline = 1
        return, ''
      end
    else: return, ''
  endcase
end


;+
; Define `MGtmPlain` class for producing plain output.
;-
pro mgtmplain__define
  compile_opt strictarr

  define = { MGtmPlain, inherits MGtmLanguage }
end
