; docformat = 'rst'

;+
; `MG_XML_BROWSER` is a widget program to browse the contents of an XML file
; (either a local file or an URL).
;
; :Examples:
;   Both local files and URLs can be accessed. For example, to load an example
;   XML file that comes with IDL, do::
;
;     planets = filepath('planets.xml', subdir=['examples', 'data'])
;     mg_xml_browser, planets
;
;   This should result in something like:
;
;   .. image:: xml_browser.png
;
;   To browse an XML file from the Internet, try::
;
;     url = 'http://michaelgalloy.com/feed'
;     mg_xml_browser, url, /url
;
;   This should result in something like:
;
;   .. image:: xml_browser_url.png
;
; :Categories:
;    xml, fileio
;
; :Author:
;    Michael Galloy
;-


;= IDLffXMLSAX parser methods

;+
; Called to process the opening of a tag.
;
; :Private:
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   name : in, required, type=string
;     element name
;   attName : in, optional, type=strarr
;     names of attributes
;   attValue : in, optional, type=strarr
;     attribute values
;-
pro mg_xml_browser_parser::startElement, uri, local, name, attName, attValue
  compile_opt strictarr

  atts = n_elements(attName) gt 0L $
           ? ': ' + strjoin(attName + '=' + attValue, ', ') $
           : ''

  node = widget_tree((*self.currentNode)[0], value=name + atts, /folder)
  *self.currentNode = [node, *self.currentNode]
end


;+
; Called to process the closing of a tag.
;
; :Private:
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   name : in, required, type=string
;     element name
;-
pro mg_xml_browser_parser::endElement, uri, local, name
  compile_opt strictarr

  *self.currentNode = (*self.currentNode)[1:*]
end


;+
; Called to process character data in an XML file.
;
; :Private:
;
; :Params:
;   chars : in, required, type=string
;     characters detected by parser
;-
pro mg_xml_browser_parser::characters, chars
  compile_opt strictarr

  if (stregex(chars, '^[[:space:]]*$', /boolean)) then return

  node = widget_tree((*self.currentNode)[0], value=chars)
end


;+
; Create an XML browser parser.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   root : in, required, type=long
;     `WIDGET_TREE` widget identifier
;-
function mg_xml_browser_parser::init, root=root
  compile_opt strictarr

  self.root = root
  self.currentNode = ptr_new([root])

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_xml_browser_parser__define
  compile_opt strictarr

  define = { mg_xml_browser_parser, inherits IDLffXMLSAX, $
             root: 0L, $
             currentNode: ptr_new() $
           }
end


;= widget helper routines

;+
; Resize the browser to the given size.
;
; :Private:
;
; :Params:
;   tlb : in, required, type=long
;     widget identifier of top-level base
;   x : in, required, type=long
;     new xsize of the tlb
;   y : in, required, type=long
;     new ysize of the tlb
;-
pro mg_xml_browser_resize, tlb, x, y
  compile_opt strictarr

  controls = widget_info(tlb, find_by_uname='controls')
  treeRoot = widget_info(tlb, find_by_uname='root')

  tlbG = widget_info(tlb, /geometry)
  controlsG = widget_info(controls, /geometry)
  treeRootG = widget_info(treeRoot, /geometry)

  xsize = x - 2 * tlbG.xpad
  ysize = y - 2 * tlbG.ypad - tlbG.space $
            - controlsG.scr_ysize - 2 * controlsG.ypad

  widget_control, treeRoot, scr_xsize=xsize, scr_ysize=ysize
end


;+
; Expand or contract the widget tree.
;
; :Private:
;
; :Params:
;   tlb : in, required, type=long
;     widget identifier of top-level base
;
; :Keywords:
;   expand : in, optional, type=boolean
;     set to 1 to expand widget tree, 0 to contract it
;-
pro mg_xml_browser_expand, tlb, expand=expand
  compile_opt strictarr

  treeRoot = widget_info(tlb, find_by_uname='root')
  widget_control, widget_info(treeRoot, /child), set_tree_expanded=expand
end


;+
; Handle all events.
;
; :Private:
;
; :Params:
;   event : in, required, type=structure
;     events from any of the widgets in the browser
;-
pro mg_xml_browser_event, event
  compile_opt strictarr
  on_error, 2

  uname = widget_info(event.id, /uname)
  case uname of
    'tlb': mg_xml_browser_resize, event.top, event.x, event.y
    'expand': mg_xml_browser_expand, event.top, expand=1B
    'contract': mg_xml_browser_expand, event.top, expand=0B
    else: begin
        if (strcmp(tag_names(event, /structure_name), 'WIDGET_TREE', 11)) then break

        message, 'unknown widget event'
      end
  endcase
end


;+
; Cleanup resources claimed by the widget program.
;
; :Private:
;
; :Params:
;   tlb : in, required, type=long
;      top-level base widget identifier
;-
pro mg_xml_browser_cleanup, tlb
  compile_opt strictarr

end


;= main routine

;+
; Start a widget program to browse an XML file.
;
; :Params:
;   filename : in, required, type=string
;     filename or URL to browse
;
; :Keywords:
;   url : in, optional, type=boolean
;     set to specify an URL instead of a local filename for the filename
;     positional parameter
;-
pro mg_xml_browser, filename, url=url
  compile_opt strictarr
  on_error, 2

  if (n_elements(filename) eq 0L) then message, 'filename parameter required'

  if (keyword_set(url)) then begin
    tokens = parse_url(filename)
    basename = tokens.path
  endif else begin
    basename = file_basename(filename)
  endelse

  tlb = widget_base(title='XML browser - ' + basename, /column, $
                    /tlb_size_events, uname='tlb')

  controls = widget_base(tlb, uname='controls', $
                         /row, /toolbar, space=0, xpad=0, ypad=0)
  expandButton = widget_button(controls, $
                               value=filepath('switch_down.bmp', $
                                              subdir=['resource', 'bitmaps']), $
                               /bitmap, $
                               uname='expand', $
                               tooltip='Expand tree')
  contractButton = widget_button(controls, $
                                 value=filepath('switch_up.bmp', $
                                                subdir=['resource', 'bitmaps']), $
                                 /bitmap, $
                                 uname='contract', $
                                 tooltip='Contract tree')

  treeRoot = widget_tree(tlb, uname='root', scr_xsize=400, scr_ysize=600)

  oxml = obj_new('mg_xml_browser_parser', root=treeRoot)
  oxml->parseFile, filename, url=keyword_set(url)
  obj_destroy, oxml

  widget_control, tlb, /realize

  xmanager, 'mg_xml_browser', tlb, /no_block, $
            event_handler='mg_xml_browser_event', $
            cleanup='mg_xml_browser_cleanup'
end


; main-level program as an example of using MG_XML_BROWSER

planets = filepath('planets.xml', subdir=['examples', 'data'])
mg_xml_browser, planets

url = 'http://michaelgalloy.com/feed'
mg_xml_browser, url, /url

end
