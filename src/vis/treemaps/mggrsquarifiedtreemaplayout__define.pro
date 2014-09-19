; docformat = 'rst'

;+
; Squarified treemap layout.
;
; :Properties:
;   name
;     name of layout
;   description
;     description of layout
;-


;+
; Layout.
;
; :Params:
;   items : in, required, type=list
;     list of objects with a `SIZE` property
;   startPos : in, required, type=integer
;     start index of `items`
;   endPos : in, required, type=integer
;     end index of `items`
;   bounds : in, required, type=`MGgrRect`
;     rectangle to slice layout with
;-
pro mggrsquarifiedtreemaplayout::layout, items, startPos, endPos, bounds
  compile_opt strictarr

  ; done
  if (startPos gt endPos) then return

  ; use slice layout if only 2 or fewer items
  if (endPos - startPos lt 2L) then begin
    mggrslicetreemaplayout__layoutBest, items, startPos, endPos, bounds
    return
  endif

  bounds->getProperty, x=x, y=y, width=w, height=h
  totalsize = self->sum(items, startPos, endPos)
  midPos = startPos
  (items->get(position=startPos))->getProperty, size=itemSize
  a = itemSize / totalSize
  b = a

  if (w lt h) then begin
    while (midPos le endPos) do begin
      aspect = self->normAspect(h, w, a, b)
      (items->get(position=midPos))->getProperty, size=itemSize
      q = itemSize / totalSize
      if (self->normAspect(h, w, a, b + q) gt aspect) then break
      midPos++
      b += q
    endwhile

    mggrslicetreemaplayout__layoutBest, items, startPos, midPos, $
                                        obj_new('MGgrRect', x=x, y=y, width=w, height=h * b)
    self->layout, items, midPos + 1L, endPos, $
                  obj_new('MGgrRect', x=x, y=y + h * b, width=w, height=h * (1 - b))
  endif else begin
    while (midPos le endPos) do begin
      aspect = self->normAspect(h, w, a, b)
      (items->get(position=midPos))->getProperty, size=itemSize
      q = itemSize / totalSize
      if (self->normAspect(h, w, a, b + q) gt aspect) then break
      midPos++
      b += q
    endwhile

    mggrslicetreemaplayout__layoutBest, items, startPos, midPos, $
                                        obj_new('MGgrRect', x=x, y=y, width=w * b, height=h)
    self->layout, items, midPos + 1L, endPos, $
                  obj_new('MGgrRect', x=x + w * b, y=y, width=w * (1 - b), height=h)
  endelse
end


;+
; Calculate aspect ratio.
;
; :Returns:
;   float
;
; :Params:
;   big : in, required, type=float
;   small : in, required, type=float
;   a : in, required, type=float
;   b : in, required, type=float
;-
function mggrsquarifiedtreemaplayout::aspect, big, small, a, b
  compile_opt strictarr

  return, (big * b) / (small * a / b)
end


;+
; Calculate value which normalizes aspect ratios less than 1, or aspect ratio
; itself if bigger than 1.
;
; :Returns:
;   float
;
; :Params:
;   big : in, required, type=float
;   small : in, required, type=float
;   a : in, required, type=float
;   b : in, required, type=float
;-
function mggrsquarifiedtreemaplayout::normAspect, big, small, a, b
  compile_opt strictarr

  x = self->aspect(big, small, a, b)
  return, x lt 1 ? 1 / x : x
end


;+
; Find total size of items.
;
; :Returns:
;   float
;
; :Params:
;   items : in, required, type=list
;     list of objects with a `SIZE` property
;   startPos : in, required, type=integer
;     start index of `items`
;   endPos : in, required, type=integer
;     end index of `items`
;-
function mggrsquarifiedtreemaplayout::sum, items, startPos, endPos
  compile_opt strictarr

  totalSize = 0.0
  for i = startPos, endPos do begin
    (items->get(position=i))->getProperty, size=itemSize
    totalSize += itemSize
  endfor

  return, totalSize
end


;= property access

;+
; Get properties.
;-
pro mggrsquarifiedtreemaplayout::getProperty, name=name, description=description
  compile_opt strictarr

  if (arg_present(name)) then name = 'Squarified'
  if (arg_present(description)) then description = 'Algorithm used by J.J. van Wijk'
end


;+
; Set properties.
;-
pro mggrsquarifiedtreemaplayout::setProperty
  compile_opt strictarr

end


;= lifecycle methods

;+
; Free resources.
;-
pro mggrsquarifiedtreemaplayout::cleanup
  compile_opt strictarr

  self->mggrabstracttreemaplayout::cleanup
end


;+
; Create squarified treemap layout object.
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mggrsquarifiedtreemaplayout::init
  compile_opt strictarr

  return, 1
end


;+
; Define instance variables.
;-
pro mggrsquarifiedtreemaplayout__define
  compile_opt strictarr

  define = { MGgrSquarifiedTreemapLayout, $
             inherits MGgrAbstractTreemapLayout $
           }
end
