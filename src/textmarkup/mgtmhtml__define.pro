; docformat = 'rst'

;+
; Destination class to output HTML.
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
function mgtmhtml::markup_listing, lines
  compile_opt strictarr

  _lines = n_elements(lines) eq 1 ? '' : strarr(n_elements(lines))

  for l = 0L, n_elements(lines) - 1L do begin
    pos = stregex(lines[l], '^([[:space:]]*)IDL&gt;', length=len, /subexpr)
    if (pos[0] eq 0L) then begin
      _lines[l] = string(strmid(lines[l], pos[1], len[1]), $
                         '<span class="code-prompt">IDL&gt;</span>', $
                         strmid(lines[l], pos[0] + len[0]), $
                         format='(%"%s%s%s")')
    endif else begin
      _lines[l] = string('<span class="code-output">', $
                         lines[l], $
                         '</span>', $
                         format='(%"%s%s%s")')
    endelse
  endfor

  return, _lines
end


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
function mgtmhtml::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'anchor': begin
        id = tag->getAttribute('identifier')
        return, '<a id="' + id + '"></a>'
      end
    'bold': return, '<bold>'
    'bullet_list': return, '<ul>'
    'code': return, '<code>'
    'comments': return, '<span class="comments">'
    'emphasis': return, '<em>'
    'heading1': return, '<h1>'
    'heading2': return, '<h2>'
    'heading3': return, '<h3>'
    'heading4': return, '<h4>'
    'heading5': return, '<h5>'
    'heading6': return, '<h6>'
    'html' : RETURN, tag->getAttribute('html')      
    'image': begin
        src = tag->getAttribute('source')
        loc = tag->getAttribute('html_location')
        return, '<img src="' + loc + src + '"/>'
      end
    'embed': begin
        src = tag->getAttribute('source')
        return, '<embed src="' + src + '"/>'
      end
    'link': begin
        href = tag->getAttribute('reference')
        if (href eq '') then return, ''
        return, '<a href="' + href + '">'
      end
    'listing': return, '<div><div><code class="listing">'
    'list_item': return, '<li>'
    'newline': begin
        newline = 1
        return, ''
      end
    'numbered_list': return, '<ol>'
    'paragraph': return, '<p>'
    'preformatted': return, '<p style="white-space: pre;">'
    'table': return, '<table>'
    'row': return, '<tr>'
    'column': return, '<td>'
    'column_header': return, '<th>'
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
function mgtmhtml::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, '</bold>'
    'bullet_list': return, '</ul>'
    'code': return, '</code>'
    'comments': return, '</span>'
    'emphasis': return, '</em>'
    'heading1': return, '</h1>'
    'heading2': return, '</h2>'
    'heading3': return, '</h3>'
    'heading4': return, '</h4>'
    'heading5': return, '</h5>'
    'heading6': return, '</h6>'
    'image': return, ''
    'embed': return, ''
    'link': begin
        href = tag->getAttribute('reference')
        if (href eq '') then return, ''
        return, '</a>'
      end
    'listing': return, '</code></div></div>'
    'list_item': return, '</li>'
    'newline': return, ''
    'numbered_list': return, '</ol>'
    'paragraph': begin
        newline = 2
        return, '</p>'
      end
    'preformatted': begin
        newline = 1
        return, '</p>'
      end
    'table': return, '</table>'
    'row': return, '</tr>'
    'column': return, '</td>'
    'column_header': return, '</th>'
    else: return, ''
  endcase
end


;+
; Define `MGtmHTML` class for processing HTML.
;-
pro mgtmhtml__define
  compile_opt strictarr

  define = { mgtmhtml, inherits mgtmlanguage }
end
