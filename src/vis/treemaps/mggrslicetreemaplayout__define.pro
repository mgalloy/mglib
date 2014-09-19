; docformat = 'rst'

;= helper routines

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
pro mggrslicetreemaplayout__layoutBest, items, startPos, endPos, bounds
  compile_opt strictarr

  bounds->getProperty, width=w, height=h
  mggrabstracttreemaplayout__sliceLayout, items, startPos, endPos, bounds, $
                                          vertical=w lt h, /ascending
end


;= lifecycle methods

;+
; Define instance variables.
;-
pro mggrslicetreemaplayout__define
  compile_opt strictarr

  define = { MGgrSliceTreemapLayout, inherits MGgrAbstractTreemapLayout }
end
