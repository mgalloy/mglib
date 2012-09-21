; docformat = 'rst'

pro visgrsquarifiedtreemaplayout::getProperty, name=name, description=description
  compile_opt strictarr
  
  if (arg_present(name)) then name = 'Squarified'
  if (arg_present(description)) then description = 'Algorithm used by J.J. van Wijk'
end


pro visgrsquarifiedtreemaplayout::setProperty
  compile_opt strictarr
  
end


pro visgrsquarifiedtreemaplayout::layout, items, startPos, endPos, bounds
  compile_opt strictarr
  
  ; done
  if (startPos gt endPos) then return
  
  ; use slice layout if only 2 or fewer items
  if (endPos - startPos lt 2L) then begin
    visgrslicetreemaplayout__layoutBest, items, startPos, endPos, bounds
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

    visgrslicetreemaplayout__layoutBest, items, startPos, midPos, $
                                         obj_new('VISgrRect', x=x, y=y, width=w, height=h * b)
    self->layout, items, midPos + 1L, endPos, $
                  obj_new('VISgrRect', x=x, y=y + h * b, width=w, height=h * (1 - b))
  endif else begin
    while (midPos le endPos) do begin
      aspect = self->normAspect(h, w, a, b)
      (items->get(position=midPos))->getProperty, size=itemSize
      q = itemSize / totalSize
      if (self->normAspect(h, w, a, b + q) gt aspect) then break
      midPos++
      b += q
    endwhile    

    visgrslicetreemaplayout__layoutBest, items, startPos, midPos, $
                                         obj_new('VISgrRect', x=x, y=y, width=w * b, height=h)
    self->layout, items, midPos + 1L, endPos, $
                  obj_new('VISgrRect', x=x + w * b, y=y, width=w * (1 - b), height=h)
  endelse
end


function visgrsquarifiedtreemaplayout::aspect, big, small, a, b
  compile_opt strictarr
  
  return, (big * b) / (small * a / b)
end


function visgrsquarifiedtreemaplayout::normAspect, big, small, a, b
  compile_opt strictarr

  x = self->aspect(big, small, a, b)
  return, x lt 1 ? 1 / x : x
end


function visgrsquarifiedtreemaplayout::sum, items, startPos, endPos
  compile_opt strictarr

  totalSize = 0.0
  for i = startPos, endPos do begin
    (items->get(position=i))->getProperty, size=itemSize
    totalSize += itemSize
  endfor
  
  return, totalSize  
end


pro visgrsquarifiedtreemaplayout::cleanup
  compile_opt strictarr
  
  self->visgrabstracttreemaplayout::cleanup
end


function visgrsquarifiedtreemaplayout::init
  compile_opt strictarr
  
  return, 1
end


pro visgrsquarifiedtreemaplayout__define
  compile_opt strictarr
  
  define = { visgrsquarifiedtreemaplayout, $
             inherits VISgrAbstractTreemapLayout $
           }
end