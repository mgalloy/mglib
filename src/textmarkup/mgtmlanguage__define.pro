; docformat = 'rst'

;+
; Parent class for different output classes, i.e., HTML, LaTeX, rst.
;-


;+
; Add markup to specify prompts and output as opposed to input.
;
; :Returns:
;    string array
;
; :Params:
;    lines : in, required, type=strarr
;       lines to markup
;-
function mgtmlanguage::markup_listing, lines
  compile_opt strictarr

  return, lines
end


;+
; Text to include afer a markup node of the given type.
;
; :Abstract:
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
function mgtmlanguage::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  return, ''
end


;+
; Text to include after a markup node of the given type.
;
; :Abstract:
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
function mgtmlanguage::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  return, ''
end


;+
; Merges two string arrays into a single string array where the last line of
; the first and first line of the second are concatenated onto a single line
; in the middle of the result.
;
; :Returns:
;    strarr
;
; :Params:
;    str1 : in, required, type=strarr
;       first string array
;    str2 : in, required, type=strarr
;        second string array
;-
function mgtmlanguage::_textMerge, str1, str2
  compile_opt strictarr

  result = strarr(n_elements(str1) + n_elements(str2) - 1)
  result[0] = str1
  result[n_elements(str1) - 1L] += str2[0]

  if (n_elements(str2) gt 1) then begin
    result[n_elements(str1)] = str2[1:*]
  endif

  return, result
end


;+
; Process a `MGtmNode` tree of markup to produce a string array of the result.
;
; :Returns:
;    `strarr`
;
; :Params:
;    formatTree : in, required, type=objref
;       `MGtmNode` object containing possibly other `MGtmNode`s
;
; :Keywords:
;    _newline : in, optional, type=boolean
;       set if should start outputing to the next line of the result
;-
function mgtmlanguage::process, formatTree, _newline=newline
  compile_opt strictarr

  formatTree->getProperty, type=type

  result = self->_preTag(type, newline=newline, tag=formatTree)
  if (obj_isa(formatTree, 'MGtmTag')) then begin
    formatTree->getProperty, n_children=nchildren

    for c = 0L, nchildren - 1L do begin
      childNewline = 0
      child = formatTree->getChild(c)
      childResult = self->process(child, _newline=childNewline)
      if keyword_set(childNewline) then begin
        result = [result, childResult]
      endif else result = self->_textMerge(result, childResult)
    endfor
  endif else if (obj_isa(formatTree, 'MGtmText')) then begin
    formatTree->getProperty, text=text
    result += text
  endif

  postTag = self->_postTag(Type, newline=postNewline, tag=formatTree)
  result = self->_textMerge(result, postTag)
  if (keyword_set(postNewline)) then result = [result, replicate('', postNewline)]

  return, result
end


;+
; Parent class for all markup language definitions.
;
; :Fields:
;    name
;       name of the language
;-
pro mgtmlanguage__define
  compile_opt strictarr

  define = { mgtmlanguage, name: '' }
end
