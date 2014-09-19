; docformat = 'rst'

;+
; Abstract parent class for treemap layout subclasses.
;-

;= helper routines

;+
; Find total size of items.
;
; :Private:
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
function mggrabstracttreemaplayout__totalSize, items, startPos, endPos
  compile_opt strictarr

  totalSize = 0.0
  for i = startPos, endPos do begin
    (items->get(position=i))->getProperty, size=itemSize
    totalSize += itemSize
  endfor

  return, totalSize
end


;+
; Slice layout.
;
; :Private:
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
;
; :Keywords:
;   vertical : in, optional, type=boolean
;     set to slice vertically
;   ascending : in, optional, type=boolean
;     set to slice in ascending order
;-
pro mggrabstracttreemaplayout__sliceLayout, items, startPos, endPos, bounds, vertical=vertical, ascending=ascending
  compile_opt strictarr

  totalSize = mggrabstracttreemaplayout__totalSize(items, startPos, endPos)
  a = 0.0

  for i = startPos, endPos do begin
    r = obj_new('Rect')
    item = items->get(position=i)
    item->getProperty, size=itemSize
    b = itemSize / totalSize
    bounds->getProperty, x=boundsX, y=boundsY, height=boundsHeight, width=boundsWidth
    if (keyword_set(vertical)) then begin
      r->setProperty, x=boundsX, width=boundsWidth, height=boundsHeight * b, $
                      y=keyword_set(ascending) $
                        ? boundsY + boundsHeight * a $
                        : boundsY + boundsHeight * (1 - a - b)

    endif else begin
      r->setProperty, y=boundsY, width=boundsWidth * b, height=boundsHeight, $
                      x=keyword_set(ascending) $
                        ? boundsX + boundsWidth * a $
                        : boundsX + boundsWidth * (1 - a - b)
    endelse
    item->setProperty, bounds=r
    a += b
  endfor
end


;+
; Sort items in descending order of size.
;
; :Returns:
;   list
;
; :Params:
;   items : in, required, type=list
;     items to sort
;-
function mggrabstracttreemaplayout::sortDescending, items
  compile_opt strictarr

  count = items->count()
  if (count eq 0L) then return, items

  itemArray = objarr(count)
  sizes = fltarr(count)
  for i = 0L, count - 1L do begin
    item  = items->get(position=i)
    item->getProperty, size=size
    sizes[i] = size
  endfor

  ind = sort(sizes)
  itemArray = itemArray[ind]

  items->remove, /all
  items->add, itemArray

  return, items
end


;+
; Layout items.
;
; :Abstract:
;
; :Params:
;   model : in, required, type=`MGgrTreemapModel`
;     model
;   bounds : in, required, type=`MGgrRect`
;     bounds
;-
pro mggrabstracttreemaplayout::layout, model, bounds
  compile_opt strictarr

end


; TODO: implement rest of methods

;= lifecycle methods

;+
; Define instance variables.
;-
pro mggrabstracttreemaplayout__define
  compile_opt strictarr

  define = { MGgrAbstractTreemapLayout, inherits MGgrTreemapLayout }
end
