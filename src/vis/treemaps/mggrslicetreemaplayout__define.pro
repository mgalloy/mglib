; docformat = 'rst'

pro mggrslicetreemaplayout__layoutBest, items, startPos, endPos, bounds
  compile_opt strictarr

  bounds->getProperty, width=w, height=h
  mggrabstracttreemaplayout__sliceLayout, items, startPos, endPos, bounds, $
                                          vertical=w lt h, /ascending
end


pro mggrslicetreemaplayout__define
  compile_opt strictarr

  define = { MGgrSliceTreemapLayout, inherits MGgrAbstractTreemapLayout }
end
