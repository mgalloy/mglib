; docformat = 'rst'

pro visgrslicetreemaplayout__layoutBest, items, startPos, endPos, bounds
  compile_opt strictarr
  
  bounds->getProperty, width=w, height=h
  visgrabstracttreemaplayout__sliceLayout, items, startPos, endPos, bounds, $
                                           vertical=w lt h, /ascending
end


pro visgrslicetreemaplayout__define
  compile_opt strictarr
  
  define = { visgrslicetreemaplayout, inherits VISgrAbstractTreemapLayout }
end