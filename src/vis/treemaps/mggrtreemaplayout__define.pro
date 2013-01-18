; docformat = 'rst'


pro mggrtreemaplayout::getProperty, name=name, description=description
  compile_opt strictarr

end


;+
; :Abstract:
;
; :Params:
;    model : in, required, type=MGgrTreemapModel
;    bounds : in, required, type=MGgrRect
;-
pro mggrtreemaplayout::layout, model, bounds
  compile_opt strictarr

end


pro mggrtreemaplayout__define
  compile_opt strictarr

  define = { MGgrTreemapLayout, $
             name: '', $
             description: '' $
           }
end
