; docformat = 'rst'


;+
; Helper routine to strip out text from `MGtmText` tags and add them to the
; `firstline` tree.
;
; :Params:
;    firstline : in, required, type=`MGtmTag` object
;       parent to add text nodes to
;    tree : in, required, type=`MGtmNode` object
;       the current tree to examine
;
; :Keywords:
;    done : out, optional, type=boolean
;       set to a named variable to determine if the first sentence is complete
;-
pro mg_tm_firstline_gettext, firstline, tree, done=done
  compile_opt strictarr

  if (obj_isa(tree, 'MGtmText')) then begin
    ; if it's an MGtmText node, then add it (until the .)
    tree->getProperty, text=text
    dotpos = stregex(text, '\.([[:space:]]|$)')
    new_text = dotpos eq -1L ? text : strmid(text, 0, dotpos + 1L)
    text_node = obj_new('MGtmText', text=new_text)
    firstline->addChild, text_node

    done = dotpos ne -1L
  endif else if (obj_isa(tree, 'MGtmTag')) then begin
    tree->getProperty, n_children=nChildren
    for c = 0L, nChildren - 1L do begin
      child = tree->getChild(c)
      mg_tm_firstline_gettext, firstline, child, done=done
      if (done) then break
    endfor
  endif
end


;+
; Get the first line of text given a markup tree and return it as another
; markup tree (copying nodes in the original tree where necessary).
;
; :Returns:
;    another markup tree
;
; :Params:
;    tree : in, required, type=object
;       markup tree
;-
function mg_tm_firstline, tree
  compile_opt strictarr

  firstline = obj_new('MGtmTag', type='paragraph')

  ; depth first search to find the first paragraph
  firstpara = tree
  firstpara->getProperty, type=type
  nchildren = 1
  while (obj_class(firstpara) eq 'MGTMTAG' $
           && type ne 'paragraph' $
           && nChildren gt 0) do begin
    firstpara->getProperty, n_children=nChildren
    if (nChildren gt 0) then begin
      firstpara = firstpara->getChild(0)
      firstpara->getProperty, type=type
    endif
  endwhile

  ; add children of the first paragraph to firstline
  if (type eq 'paragraph') then begin
    mg_tm_firstline_gettext, firstline, firstpara, done=done
  endif

  ; return our contructed firstline
  return, firstline
end
