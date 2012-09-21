; docformat = 'rst'

;+
; Destination class to output DocBook.
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
;       set to a named variable to get whether a newline should be added at 
;       the given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmdocbook::_preTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, '<bold>'
    'bullet_list': return, '<ul>'
    'code': return, '<code>'    
    'comments': return, '<span class="comments">'
    'emphasis': return, '<emphasis>'
    'image': begin
        src = tag->getAttribute('source')
        location = tag->getAttribute('location')
        extpos = strpos(src, '.', /reverse_search) + 1L
        ext = strmid(src, extpos)
        return, '<inlinemediaobject><imageobject>' $
                  + '<imagedata scale="75" fileref="' + location + src + '" format="' + ext + '"/>' $
                  + '</imageobject></inlinemediaobject>'
      end
    'embed': begin
        src = tag->getAttribute('source')
        location = tag->getAttribute('location')
        extpos = strpos(src, '.', /reverse_search) + 1L
        ext = strmid(src, extpos)
        return, '<inlinemediaobject><imageobject>' $
                  + '<imagedata scale="75" fileref="' + location + src + '" format="' + ext + '"/>' $
                  + '</imageobject></inlinemediaobject>'
      end      
    'link': begin
        href = tag->getAttribute('reference')
        return, '<a href="' + href + '">'
      end
    'listing': return, '<programlisting>'
    'list_item': return, '<listitem>'
    'newline': begin
        newline = 1
        return, ''
      end
    'numbered_list': return, '<orderedlist>'
    'paragraph': return, '<para>'
    'preformatted': return, '<para>'
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
;       set to a named variable to get whether a newline should be added at the 
;       given node
;    tag : in, required, type=object
;       tag's object reference
;-
function mgtmdocbook::_postTag, type, newline=newline, tag=tag
  compile_opt strictarr

  case type of
    '': return, ''
    'bold': return, '</bold>'
    'bullet_list': return, '</ul>'
    'code': return, '</code>'
    'comments': return, '</span>'
    'emphasis': return, '</emphasis>'
    'image': return, ''
    'embed': return, ''
    'link': return, '</a>'
    'listing': return, '</programlisting>'
    'list_item': return, '</listitem>'
    'newline': return, ''
    'numbered_list': return, '</orderedlist>'
    'paragraph': begin
        newline = 1
        return, '</para>'
      end
    'preformatted': begin
        newline = 1
        return, '</para>'
      end
    else: return, ''
  endcase
end


;+
; Define `MGtmDocbook` class for processing Docbook markup.
;-
pro mgtmdocbook__define
  compile_opt strictarr

  define = { mgtmdocbook, inherits mgtmlanguage }
end
