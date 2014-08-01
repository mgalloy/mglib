; docformat = 'rst'

;+
; Destination class to output LaTeX.
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
;-
function mgtmlatex::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '' : return, ''
    'code': return, '{\tt '
    'bold' : return, '\textbf{'
    'image': begin
        location = tag->getAttribute('location')
        src = tag->getAttribute('source')

        return, '\hspace{0.5em}' + string([13B, 10B, 13B, 10B]) + '\includegraphics[scale=0.6]{' + location + src + '}'
      end
    'embed': begin
        location = tag->getAttribute('location')
        src = tag->getAttribute('source')
        dotpos = strpos(src, '.', /reverse_search)
        ext = strmid(src, dotpos + 1L)
        if (strlowcase(ext) eq 'svg') then src = strmid(src, 0, dotpos) + '.pdf'
        return, '\hspace{0.5em}' + string([13B, 10B, 13B, 10B]) + '\includegraphics[scale=0.6]{' + location + src + '}'
      end
    'link': begin
        href = tag->getAttribute('reference')
        use_href = strmid(href, 0, 7) eq 'http://'
        return, use_href ? ('\href{' + mg_escape_latex(href) + '}{') : ''
      end
    'listing': return, '\begin{verbatim}'
    'heading1': return, '\subsection{'
    'paragraph': return, ''
    'newline' : begin
        newline = 1
        return, ''
      end
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
;       set to a named variable to get whether a newline should be added
;       at the given node
;-
function mgtmlatex::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '' : return, ''
    'bold' : return, '}'
    'code': return, '}'
    'image': return, string([13B, 10B, 13B, 10B]) + '\hspace{0.5em}'
    'embed': return, string([13B, 10B, 13B, 10B]) + '\hspace{0.5em}'
    'link': begin
        href = tag->getAttribute('reference')
        use_href = strmid(href, 0, 7) eq 'http://'
        return, use_href ? '}' : ''
      end
    'listing': return, '\end{verbatim}'
    'heading1': return, '}'
    'paragraph': begin
        newline = 1
        return, ''
      end
    'newline' : return, ''
    else : return, ''
  endcase
end


;+
; Define `MGtmLaTeX` class for processing LaTeX.
;-
pro mgtmlatex__define
  compile_opt strictarr

  define = { mgtmlatex, inherits mgtmlanguage }
end
