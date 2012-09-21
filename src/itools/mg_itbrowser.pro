; docformat = 'rst'

;+
; Handle events.
;
; :Params:
;    event : in, required, type=structure
;       event structure
;-
pro mg_itbrowser_event, event
  compile_opt strictarr

  widget_control, event.top, get_uvalue=pstate
  uname = widget_info(event.id, /uname)

  case uname of
    'tlb' : begin ; resize event
        tree = widget_info(event.top, find_by_uname='tree_root')
        props = widget_info(event.top, find_by_uname='props')

        tlbG = widget_info(event.top, /geometry)

        newx = (event.x - 2 * tlbG.xpad - tlbG.space) / 2
        newy = event.y - 2 * tlbG.ypad

        widget_control, tree, scr_xsize=newx, scr_ysize=newy
        widget_control, props, scr_xsize=newx, scr_ysize=newy
      end
    'tree' : begin ; tree selection event
        widget_control, event.id, get_uvalue=ocomp
        props = widget_info(event.top, find_by_uname='props')
        widget_control, props, set_value=ocomp
      end
    'props' : ; don't need to do anything
  endcase
end


;+
; Cleanup resources.
;
; :Params:
;    tlb : in, required, type=long
;       widget ID of the top-level base
;-
pro mg_itbrowser_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=pstate
  ptr_free, pstate
end


;+
; Add a component to the component tree.
;
; :Params:
;    ids : in, required, type=strarr
;       string array of identifiers of components to process still
;    treeID : in, required, type=long
;       widget identifier of the parent of this component
;
; :Keywords:
;    path : in, required, type=string
;       path to prefix ids with to get full identifiers
;    tool : in, required, type=object
;       object reference for iTool
;-
pro mg_itbrowser_addids, ids, treeID, path=path, tool=otool
  compile_opt strictarr
  
  oItem = otool->getByIdentifier(path + ids[0])

  childIndices = where(strmatch(ids, ids[0] + '*'), nchildren, $ 
                       complement=siblingIndices, ncomplement=nsiblings)

  ; add yourself
  id = widget_tree(treeID, value=strmid(ids[0], 1), uvalue=oItem, $
                   uname='tree', folder=nchildren gt 1)

  ; add your children
  if (nchildren gt 1) then begin
    childIDs = (strmid(ids[childIndices], strlen(ids[0])))[1:*]
    mg_itbrowser_addids, childIDs, id, path=path + ids[0], tool=otool
  endif
  
  ; call again for siblings
  if (nsiblings gt 0) then begin
    mg_itbrowser_addids, ids[siblingIndices], treeID, path=path, tool=otool
  endif
end


;+
; Browse components and their properties of an iTool.
;
; :Params:
;    toolID : in, optional, type=string
;       identifier of the iTool to browse components of
;-
pro mg_itbrowser, toolID
  compile_opt strictarr
  on_error, 2

  ; get object reference of given ID or current tool
  if (n_elements(toolID) eq 0) then begin
      myToolID = itGetCurrent(tool=otool)
      if (myToolID eq '') then begin
          message, 'No current iTool'
      endif
  endif else begin
      oldToolID = itGetCurrent()
      itCurrent, toolID
      myToolID = itGetCurrent(tool=otool)
      itCurrent, oldToolID
  endelse

  ; create widget hierarchy
  tlb = widget_base(title='iTools browser', uname='tlb', /row, /tlb_size_events)

  tree = widget_tree(tlb, scr_xsize=400, scr_ysize=400, uname='tree_root')
  props = widget_propertysheet(tlb, scr_xsize=400, scr_ysize=400, $
                               value=otool, uname='props')

  ; find elements of the tree
  ids = otool->findIdentifiers('*')
  ids = strlowcase(ids)
  path = strsplit(ids[0], '/', /extract)
   
  toolsTree = widget_tree(tree, value=path[0], uname='tree', $
                          /expanded, /folder, uvalue=otool)  
  toolTree = widget_tree(toolsTree, value=path[1], uname='tree', $
                         /expanded, /folder, uvalue=otool)

  baseID = '/' + path[0] + '/' + path[1]
  mg_itbrowser_addids, strmid(ids, strlen(baseID)), toolTree, $
                      path=baseID, $
                      tool=otool

  widget_control, tlb, /realize

  state = { otool : otool $
          }
  pstate = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue=pstate

  xmanager, 'mg_itbrowser', tlb, /no_block, $
            event_handler='mg_itbrowser_event', $
            cleanup='mg_itbrowser_cleanup'
end
