; docformat = 'rst'


pro visgrtreemaplayout::getProperty, name=name, description=description
  compile_opt strictarr
  
end


;+
; :Abstract:
;
; :Params:
;    model : in, required, type=VISgrTreemapModel
;    bounds : in, required, type=VISgrRect
;-
pro visgrtreemaplayout::layout, model, bounds
  compile_opt strictarr
  
end


pro visgrtreemaplayout__define
  compile_opt strictarr
  
  define = { VISgrTreemapLayout, $
             name: '', $
             description: '' $
           }
end