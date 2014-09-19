; docformat = 'rst'

;+
; Layout interface.
;
; :Properties:
;   name
;     name of layout
;   description
;     description of layout
;-


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
pro mggrtreemaplayout::layout, model, bounds
  compile_opt strictarr

end


;= property access

;+
; Get properties.
;-
pro mggrtreemaplayout::getProperty, name=name, description=description
  compile_opt strictarr

end


;= lifecycle methods

;+
; Define instance variables.
;-
pro mggrtreemaplayout__define
  compile_opt strictarr

  define = { MGgrTreemapLayout, $
             name: '', $
             description: '' $
           }
end
