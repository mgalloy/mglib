; docformat = 'rst'

;+
; Widget program to browse the contents of a FITS file and load the contents
; of variables into IDL variables a the main-level. Similar to `H5_BROWSER`.
;
; :Categories:
;    file i/o, fits, sdf
;-


;= helper routines

;+
; Thin procedural wrapper to call `::handle_events` event handler.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_fits_browser_handleevents, event
  compile_opt strictarr

  widget_control, event.top, get_uvalue=browser
  browser->handle_events, event
end


;+
; Thin procedural wrapper to call `::cleanup_widgets` cleanup routine.
;
; :Params:
;    tlb : in, required, type=long
;       top-level base widget identifier
;-
pro mg_fits_browser_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=browser
  if (obj_valid(browser)) then browser->cleanup_widgets
end


;+
; Wrapper for `STREGEX` to catch errors.
;-
function mg_fits_browser_stregex, text, re, boolean=boolean, _ref_extra=e
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, keyword_set(boolean) ? bytarr(n_elements(text)) : -1L
  endif

  return, stregex(text, re, boolean=boolean, _extra=e)
end


;= data specific to be overridden by subclass


;+
; Return title to display for extension.
;
; :Returns:
;   string
;
; :Params:
;   filename : in, required, type=string
;     filename of FITS file
;   header : in, required, type=strarr
;     primary header of FITS file
;-
function mg_fits_browser::file_title, filename, header
  compile_opt strictarr

  return, file_basename(filename)
end


;+
; Return bitmap of icon to display next to the file.
;
; :Returns:
;   `bytarr(m, n, 3)` or `bytarr(m, n, 4)` or `0` if default is to be used
;
; :Params:
;   filename : in, required, type=string
;     filename of FITS file
;   header : in, required, type=strarr
;     primary header of FITS file
;-
function mg_fits_browser::file_bitmap, filename, header
  compile_opt strictarr

  return, 0
end


;+
; Return title to display for extension.
;
; :Returns:
;   string
;
; :Params:
;   n_exts : in, required, type=long
;     number of extensions
;   ext_names : in, required, type=strarr
;     extension names
;
; :Keywords:
;   filename : in, required, type=string
;     filename of file
;-
function mg_fits_browser::extension_title, n_exts, ext_names, $
                                           filename=filename
  compile_opt strictarr

  if (n_exts eq 0L) then return, []

  titles = strarr(n_exts)
  for e = 1L, n_exts do begin
    titles[e - 1L] = ext_names[e] eq '' ? ('ext ' + strtrim(e, 2)) : ext_names[e]
  endfor

  return, titles
end


;+
; Return bitmap of icon to display next to the extension.
;
; :Returns:
;   `bytarr(m, n, 3)` or `bytarr(m, n, 4)` or `0` if default is to be used
;
; :Params:
;   ext_number : in, required, type=long
;     extension number
;   ext_name : in, required, type=long
;     extension name
;   ext_header : in, required, type=strarr
;     header for extension
;
; :Keywords:
;   filename : in, required, type=string
;     filename of file
;-
function mg_fits_browser::extension_bitmap, ext_number, ext_name, ext_header, $
                                            filename=filename
  compile_opt strictarr

  return, 0
end


;+
; Returns valid file extensions.
;
; :Returns:
;   strarr
;-
function mg_fits_browser::file_extensions
  compile_opt strictarr

  return, [['*.fits;*.fts;*.fts.gz;*.FTS', '*.*'], $
           ['FITS files', 'All files']]
end


;+
; Display the given data as an image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   dimensions : in, required, type=fltarr(2)
;     dimensions of target window
;   filename : in, optional, type=string
;     filename of file containing image
;-
pro mg_fits_browser::display_image, data, header, filename=filename, dimensions=dimensions
  compile_opt strictarr

  ndims = size(data, /n_dimensions)
  if (ndims ne 2) then begin
    self->erase
    return
  endif

  dims = size(data, /dimensions)

  data_aspect_ratio = float(dims[1]) / float(dims[0])
  draw_aspect_ratio = float(dimensions[1]) / float(dimensions[0])

  if (data_aspect_ratio gt draw_aspect_ratio) then begin
    ; use y as limiting factor for new dimensions
    dims *= dimensions[1] / float(dims[1])
  endif else begin
    ; use x as limiting factor for new dimensions
    dims *= dimensions[0] / float(dims[0])
  endelse

  _data = congrid(data, dims[0], dims[1], /interp)

  if (dims[0] gt dimensions[0] || dims[1] gt dimensions[1]) then begin
    xoffset = 0
    yoffset = 0
  endif else begin
    xoffset = (dimensions[0] - dims[0]) / 2
    yoffset = (dimensions[1] - dims[1]) / 2
  endelse

  tvscl, _data, xoffset, yoffset
end


;+
; Overlay information on the image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   dimensions : in, required, type=fltarr(2)
;     dimensions of target window
;   filename : in, optional, type=string
;     filename of file containing image
;-
pro mg_fits_browser::annotate_image, data, header, filename=filename, dimensions=dimensions
  compile_opt strictarr

  ; by default nothing is done
end


;+
; Determine if annotation is available for a given image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   filename : in, optional, type=string
;     filename of file containing image
;-
function mg_fits_browser::annotate_available, data, header, filename=filename
  compile_opt strictarr

  return, 0B
end



;= API

;+
; Erase the draw window.
;-
pro mg_fits_browser::erase
  compile_opt strictarr

  erase
end


;+
; Display the image and its annotations (if desired).
;-
pro mg_fits_browser::display
  compile_opt strictarr

  if (n_elements(*self.current_data) eq 0L) then return

  draw_wid = widget_info(self.tlb, find_by_uname='draw')
  geo_info = widget_info(draw_wid, /geometry)

  ; get current graphics status to be able to reset afterwards
  old_win_id = !d.window
  device, get_decomposed=odec
  tvlct, rgb, /get

  dimensions = [geo_info.draw_xsize, geo_info.draw_ysize]

  if (self.currently_selected[0] gt 0L) then begin
    wset, self.pixmaps[0]
    self->display_image, *self.current_data, *self.current_header, $
                         filename=self.current_filename, dimensions=dimensions
    if (self.annotate) then begin
      self->annotate_image, *self.current_data, *self.current_header, $
                            filename=self.current_filename, dimensions=dimensions
    endif
  endif

  if (self.currently_selected[1] gt 0L) then begin
    wset, self.pixmaps[1]
    self->display_image, *self.compare_data, *self.compare_header, $
                         filename=self.compare_filename, dimensions=dimensions
    if (self.annotate) then begin
      self->annotate_image, *self.compare_data, *self.compare_header, $
                            filename=self.compare_filename, dimensions=dimensions
    endif
  endif

  ; create backing_store
  if (self.currently_selected[0] gt 0L) then begin
    wset, self.backing_store
    device, copy=[0, 0, dimensions, 0, 0, self.pixmaps[0]]

    wset, self.draw_id
    device, copy=[0, 0, dimensions, 0, 0, self.backing_store]
  endif

  ; reset graphics status
  wset, old_win_id
  tvlct, rgb
  device, decomposed=odec
end


;+
; Convert device coordinates of draw widget to pixel location of image.
;
; :Params:
;   screen_x : in, required, type=long
;     x location on screen
;   screen_y : in, required, type=long
;     y location on screen
;
; :Keywords:
;   x : out, optional, type=long
;     set to a named variable to retrieve the corresponding x pixel location in
;     image
;   y : out, optional, type=long
;     set to a named variable to retrieve the corresponding y pixel location in
;     image
;-
pro mg_fits_browser::datacoords_for_screen, screen_x, screen_y, x=x, y=y
  compile_opt strictarr

  if (n_elements(*self.current_data) eq 0L) then return

  dims = size(*self.current_data, /dimensions)
  image_draw = widget_info(self.tlb, find_by_uname='draw')
  draw_geometry = widget_info(image_draw, /geometry)
  x = long(screen_x / draw_geometry.scr_xsize * dims[0])
  y = long(screen_y / draw_geometry.scr_ysize * dims[1])
end


;+
; Set the window title based on the current filename. Set the filename to the
; empty string if there is no title to display.
;
; :Params:
;    filename : in, required, type=string
;       filename to display in title
;-
pro mg_fits_browser::set_title, filename
  compile_opt strictarr

  title = string(self.title, $
                 filename eq '' ? '' : ' - ', $
                 filename, $
                 format='(%"%s%s%s")')
  widget_control, self.tlb, base_set_title=title
end


;+
; Set the text in the status bar.
;
; :Params:
;   msg : in, optional, type=string
;     message to display in the status bar
;
; :Keywords:
;   clear : in, optional, type=boolean
;     set to clear the current status bar message
;   secondary : in, optional, type=boolean
;     set to indicate the message should be display on the secondary status line
;-
pro mg_fits_browser::set_status, msg, clear=clear, secondary=secondary
  compile_opt strictarr

  _msg = keyword_set(clear) || n_elements(msg) eq 0L ? '' : msg
  if (keyword_set(secondary)) then begin
    widget_control, self.secondary_statusbar, set_value=_msg
  endif else begin
    widget_control, self.statusbar, set_value=_msg
  endelse
end


;+
; Load FITS files corresponding to filenames.
;
; :Params:
;   filenames : in, optional, type=string/strarr
;     filenames (or glob expressions) of files to load
;-
pro mg_fits_browser::load_files, filenames
  compile_opt strictarr

  n_files = n_elements(filenames)
  self.nfiles += n_elements(filenames)

  self->set_title, self.nfiles eq 1L ? file_basename(filenames[0]) : 'many files'

  self->set_status, string(n_files, n_files eq 1 ? '' : 's', $
                           format='(%"Loading %d FITS file%s...")')

  foreach f, filenames do begin
    files = file_search(f, count=files_found)

    skip = 1
    case files_found of
      0: self->set_status, 'file not found or not regular: ' + f
      1: skip = 0
      else: self->load_files, files
    endcase
    if (skip) then continue

    fits_open, f, fcb
    fits_read, fcb, data, header, exten_no=0, /header_only

    extension_titles = self->extension_title(fcb.nextend, fcb.extname, $
                                             filename=f)

    widget_control, self.tlb, update=0

    file_node = widget_tree(self.tree, /folder, /expanded, $
                            value=self->file_title(f, header), $
                            bitmap=self->file_bitmap(f, header), $
                            uname='fits:file', uvalue=file_expand_path(f))

    for i = 1L, fcb.nextend do begin
      fits_read, fcb, ext_data, ext_header, exten_no=i, /header_only
      ext_node = widget_tree(file_node, $
                             bitmap=self->extension_bitmap(i, $
                                                           fcb.extname[i], $
                                                           ext_header, $
                                                           filename=f), $
                             value=extension_titles[i - 1], $
                             uname='fits:extension', uvalue=i)
    endfor
    fits_close, fcb

    widget_control, self.tlb, update=1
  endforeach

  self->set_status, /clear
end


;+
; Bring up pick file dialog to choose a file and load it.
;
; :Private:
;-
pro mg_fits_browser::open_files
  compile_opt strictarr

  filenames = dialog_pickfile(path=self.path, $
                              group=self.tlb, /read, /multiple_files, $
                              filter=self->file_extensions(), $
                              title='Select FITS files to open')
  if (filenames[0] ne '') then begin
    self.path = file_dirname(filenames[0])
    self->load_files, filenames
  endif
end


;+
; Resize to the given dimensions.
;
; :Params:
;   x : in, required, type=float
;     width of browser in pixels
;   y : in, required, type=float
;     height of browser in pixels
;-
pro mg_fits_browser::resize, x, y
  compile_opt strictarr

  draw = widget_info(self.tlb, find_by_uname='draw')
  content_base = widget_info(self.tlb, find_by_uname='content_base')
  details_base = widget_info(self.tlb, find_by_uname='details')
  search_text = widget_info(self.tlb, find_by_uname='search')
  fits_header = widget_info(self.tlb, find_by_uname='fits_header')
  file_toolbar = widget_info(self.tlb, find_by_uname='file_toolbar')
  button_toolbar = widget_info(self.tlb, find_by_uname='button_toolbar')
  spacer = widget_info(self.tlb, find_by_uname='spacer')

  tlb_geometry = widget_info(self.tlb, /geometry)
  tree_geometry = widget_info(self.tree, /geometry)
  draw_geometry = widget_info(draw, /geometry)
  statusbar_geometry = widget_info(self.statusbar, /geometry)
  content_base_geometry = widget_info(content_base, /geometry)
  file_toolbar_geometry = widget_info(file_toolbar, /geometry)
  button_toolbar_geometry = widget_info(button_toolbar, /geometry)
  details_geometry = widget_info(details_base, /geometry)
  search_geometry = widget_info(search_text, /geometry)

  tree_height = y $
                  - statusbar_geometry.scr_ysize $
                  - file_toolbar_geometry.scr_ysize $
                  - 2 * tlb_geometry.ypad $
                  - 2 * tlb_geometry.margin
  draw_size = draw_geometry.scr_ysize $
                + tree_height - tree_geometry.scr_ysize

  tree_width = x $
                 - draw_size $
                 - 2 * tlb_geometry.xpad $
                 - tlb_geometry.space $
                 - 2 * content_base_geometry.xpad $
                 - 2 * content_base_geometry.margin

  tree_width >= 100.0
  fits_header_ysize = draw_size $
                      - search_geometry.scr_ysize $
                      - details_geometry.space

  statusbar_width = tree_width + draw_size + 2 * tlb_geometry.xpad + tlb_geometry.space
  spacer_width = tree_width - button_toolbar_geometry.xsize

  widget_control, self.tlb, update=0

  widget_control, draw, scr_xsize=draw_size, scr_ysize=draw_size
  widget_control, search_text, scr_xsize=draw_size
  widget_control, fits_header, scr_xsize=draw_size, scr_ysize=fits_header_ysize
  widget_control, self.statusbar, scr_xsize=statusbar_width
  widget_control, spacer, scr_xsize=spacer_width
  widget_control, self.secondary_statusbar, scr_xsize=draw_size
  widget_control, self.tree, scr_xsize=tree_width, scr_ysize=tree_height

  widget_control, self.tlb, update=1

  self->set_status, string(draw_size, draw_size, $
                           format='(%"Resized to %dx%d graphics window")')

  ; update pixmaps
  old_window = !d.window

  wdelete, self.backing_store, self.pixmaps[0], self.pixmaps[1]
  window, /free, /pixmap, xsize=draw_size, ysize=draw_size
  self.backing_store = !d.window
  window, /free, /pixmap, xsize=draw_size, ysize=draw_size
  self.pixmaps[0] = !d.window
  window, /free, /pixmap, xsize=draw_size, ysize=draw_size
  self.pixmaps[1] = !d.window

  wset, old_window

  self->display
end


pro mg_fits_browser::select_header_text, event
  compile_opt strictarr

  search_text = widget_info(self.tlb, find_by_uname='search')

  if (strmatch(tag_names(event, /structure_name), 'WIDGET_TEXT*')) then begin
    ; TODO: maybe should filter on all unprintable characters here
    if (event.type eq 0 && (event.ch eq 7B || event.ch eq 16B)) then begin
      widget_control, search_text, get_value=search_term
      text_select = widget_info(search_text, /text_select)
      case event.offset of
        0L: search_term = strmid(search_term, 1)
        strlen(search_term) - 1: search_term = strmid(search_term, 0, event.offset) + strmid(search_term, event.offset + 1)
        else: search_term = strmid(search_term, 0, strlen(search_term) - 1)
      endcase
      widget_control, search_text, set_value=search_term
      widget_control, search_text, set_text_select=text_select
      if (event.ch eq 7B) then self.search_index++ else self.search_index--
    endif
  endif

  fits_header = widget_info(self.tlb, find_by_uname='fits_header')

  ; get contents of text box
  widget_control, search_text, get_value=search_term
  search_term = search_term[0]
  if (search_term eq '') then begin
    widget_control, fits_header, set_text_select=[0, 0]
    return
  endif

  ; search header text for search text
  widget_control, fits_header, get_value=header_text
  hits = mg_fits_browser_stregex(header_text, search_term, /fold_case, /boolean)
  hit_lines = where(hits, n_hit_lines)

  self.search_index = 0 > self.search_index < (n_hit_lines - 1L)
  self->set_status, string(search_term, self.search_index + 1L, n_hit_lines, $
                           format='(%"Found ''%s'': %d of %d lines (ctrl-g/ctrl-p to move through hits)")')

  if (n_hit_lines eq 0L) then return

  ; highlight search text in header text
  hit_line = header_text[hit_lines[self.search_index]]
  pos = mg_fits_browser_stregex(hit_line, search_term, length=len, /fold_case)
  xy = [pos[0], hit_lines[self.search_index]]
  offset = widget_info(fits_header, text_xy_to_offset=xy)
  widget_control, fits_header, set_text_select=[offset, len]
end


;= event handling


;+
; Filter the primary header out of an extension header and remove END.
;
; :Returns:
;   `strarr`
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;-
function mg_fits_browser::_filter_header, header
  compile_opt strictarr

  ; return just the extension header
  pos = strpos(header, 'BEGIN EXTENSION HEADER')
  ind = where(pos ge 0, count)
  if (count gt 0L) then new_header = header[ind[0] + 1:*] else new_header = header

  new_header = new_header[0:-2]   ; remove END

  return, new_header
end


;+
; Retrieves the data corresponding to a tree identifier.
;
; :Private:
;
; :Params:
;   id : in, required, type=long
;     widget identifier for tree widget
;
; :Keywords:
;   header : out, optional, type=strarr
;     set to a named variable to retrieve the FITS header for the `id` as well
;   filename : out, optional, type=string
;     set to a named variable to retrieve the filename corresponding to the `id`
;-
function mg_fits_browser::_data_for_tree_id, id, header=header, filename=filename
  compile_opt strictarr

  uname = widget_info(id, /uname)
  case uname of
    'fits:file': begin
        widget_control, id, get_uvalue=filename

        fits_open, filename, fcb
        fits_read, fcb, data, header, exten_no=0
        fits_close, fcb
      end
    'fits:extension': begin
        widget_control, id, get_uvalue=e

        parent_id = widget_info(id, /parent)
        widget_control, parent_id, get_uvalue=filename

        fits_open, filename, fcb
        fits_read, fcb, data, header, exten_no=e
        fits_close, fcb
      end
  endcase
  return, data
end


;+
; Handle events for tree widgets.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_fits_browser::_handle_tree_event, event
  compile_opt strictarr

  ; only handle selection
  if (event.type ne 0) then return

  uname = widget_info(event.id, /uname)
  ids = widget_info(self.tree, /tree_select)

  nids = n_elements(ids)
  if (ids[0] lt 0L) then begin
    self.currently_selected = lonarr(2) - 1L
  endif else if (nids eq 1) then begin
    self.currently_selected = [event.id, -1L]
    data = self->_data_for_tree_id(event.id, header=header, filename=filename)
    *self.current_data = data
    *self.current_header = header
    self.current_filename = filename

    ; set header
    header_widget = widget_info(self.tlb, find_by_uname='fits_header')
    widget_control, header_widget, set_value=self->_filter_header(header)
    self->select_header_text, event
  endif else if (nids eq 2) then begin
    data = self->_data_for_tree_id(event.id, header=header, filename=filename)
    self.currently_selected[1] = event.id
    ; TODO: compare dims of data to *self.current_data
    *self.compare_data = data
    *self.compare_header = header
    self.compare_filename = filename
  endif else begin
    self.currently_selected[1] = event.id
    for i = 0L, nids - 1L do begin
      if (total(ids[i] eq self.currently_selected) lt 1) then begin
        widget_control, ids[i], set_tree_select=0
      endif
    endfor
    data = self->_data_for_tree_id(event.id, header=header, filename=filename)
    self.currently_selected[1] = event.id
    ; TODO: compare dims of data to *self.current_data
    *self.compare_data = data
    *self.compare_header = header
    self.compare_filename = filename
  endelse

  ; set status
  self->_set_status_for_tree_selection

  ; set annotation button sensitivity
  annotate_button = widget_info(self.tlb, find_by_uname='annotate')
  widget_control, annotate_button, sensitive=self->annotate_available(data, header, filename=self.current_filename)

  self->display
end


;+
; Determine the name for a tree widget.
;
; :Returns:
;   string
;
; :Params:
;   id : in, required, type=long
;     widget identifier for the tree widget
;-
function mg_fits_browser::_name_for_tree_id, id
  compile_opt strictarr

  uname = widget_info(id, /uname)
  case uname of
    'fits:file' : begin
        widget_control, id, get_uvalue=f
        return, file_basename(f)
      end
    'fits:extension': begin
        widget_control, id, get_uvalue=e
        parent_id = widget_info(id, /parent)
        widget_control, parent_id, get_uvalue=f
        return, string(file_basename(f), e, format='(%"%s ext %d")')
      end
  endcase
  return, ''
end


;+
; Sets status bar for the current tree widget selection.
;-
pro mg_fits_browser::_set_status_for_tree_selection
  compile_opt strictarr

  if (self.currently_selected[0] lt 0) then begin
    self->set_status, /clear
  endif else if (self.currently_selected[1] lt 0) then begin
    self->set_status, self->_name_for_tree_id(self.currently_selected[0])
  endif else begin
    msg = string(self->_name_for_tree_id(self.currently_selected[0]), $
                 self->_name_for_tree_id(self.currently_selected[1]), $
                 format='(%"%s and %s")')
    self->set_status, msg
  endelse
end


function mg_fits_browser::_format_code_for_data
  compile_opt strictarr

  type = size(*self.current_data, /type)
  if (type eq 4 || type eq 5) then begin
    return, '%0.1f'
  endif else begin
    return, '%d'
  endelse
end

pro mg_fits_browser::_set_status_for_draw, event
  compile_opt strictarr

  draw_wid = widget_info(self.tlb, find_by_uname='draw')
  self->datacoords_for_screen, event.x, event.y, x=x, y=y
  fc = self->_format_code_for_data()

  if (self.currently_selected[0] lt 0) then begin
    ; nothing
  endif else if (self.currently_selected[1] lt 1) then begin
    value = (*self.current_data)[x, y]
    self->set_status, string(x, y, value, $
                             format='(%"x: %d, y: %d, value: ' + fc + '")'), $
                      /secondary
  endif else begin
    self->set_status, string(x, y, $
                             (*self.current_data)[x, y], $
                             (*self.compare_data)[x, y], $
                             self->_name_for_tree_id(self.currently_selected[0]), $
                             self->_name_for_tree_id(self.currently_selected[1]), $
                             format='(%"x: %d, y: %d, value: ' + fc + ', ' + fc + ' (%s, %s)")'), $
                      /secondary
  endelse
end


;+
; Display the inset of the compare image.
;
; :Params:
;   event : in, required, type=structure
;     `WIDGET_DRAW` event
;-
pro mg_fits_browser::_show_compare_inset, event
  compile_opt strictarr

  draw_wid = widget_info(self.tlb, find_by_uname='draw')
  geo_info = widget_info(draw_wid, /geometry)
  dimensions = [geo_info.draw_xsize, geo_info.draw_ysize]

  inset_size = 80

  ; get current graphics status to be able to reset afterwards
  old_win_id = !d.window

  ; refresh backing store from pixmaps[0]
  wset, self.backing_store
  device, copy=[0, 0, dimensions, 0, 0, self.pixmaps[0]]

  ; copy inset from pixmaps[1]
  x_src = (event.x - inset_size / 2) > 0
  y_src = (event.y - inset_size / 2) > 0
  n_x = ((event.x + inset_size / 2) < dimensions[0]) - x_src
  n_y = ((event.y + inset_size / 2) < dimensions[1]) - y_src
  x_dst = x_src
  y_dst = y_src
  device, copy=[x_src, y_src, n_x, n_y, x_dst, y_dst, self.pixmaps[1]]

  ; refresh display
  wset, self.draw_id
  device, copy=[0, 0, dimensions, 0, 0, self.backing_store]

  wset, old_win_id
end


pro mg_fits_browser::_compute_box_stats, event
  compile_opt strictarr

  self->datacoords_for_screen, event.x, event.y, x=x1, y=y1
  self->datacoords_for_screen, self.rubberband_box_start[0], $
                               self.rubberband_box_start[1], $
                               x=x2, y=y2

  x = [x1 < x2, x1 > x2]
  y = [y1 < y2, y1 > y2]

  values = float((*self.current_data)[x[0]:x[1], y[0]:y[1]])
  n_values = n_elements(values)
  fc = self->_format_code_for_data()

  if (n_values eq 1) then begin
    msg = string(x[0], y[0], values[0], $
                 format='(%"x: %d, y: %d, value: ' + fc + '")')
  endif else begin
    msg = string(x, y, $
                 mean(values), median(values), stddev(values), $
                 min(values, max=max_value), max_value, $
                 n_values, $
                 format='(%"x: %d:%d, y: %d:%d, mean: %0.1f, median: %0.1f, std dev: %0.1f, range: [' + fc + ', ' + fc + '] (%d values)")')
  endelse
  self->set_status, msg
end


pro mg_fits_browser::_show_rubberband_box, event
  compile_opt strictarr

  draw_wid = widget_info(self.tlb, find_by_uname='draw')
  geo_info = widget_info(draw_wid, /geometry)
  dimensions = [geo_info.draw_xsize, geo_info.draw_ysize]

  inset_size = 80

  ; get current graphics status to be able to reset afterwards
  old_win_id = !d.window

  ; refresh backing store from pixmaps[0]
  wset, self.backing_store
  device, copy=[0, 0, dimensions, 0, 0, self.pixmaps[0]]

  ; draw rubberband box on backing store
  plots, [self.rubberband_box_start[0], $
          event.x, $
          event.x, $
          self.rubberband_box_start[0], $
          self.rubberband_box_start[0]], $
         [self.rubberband_box_start[1], $
          self.rubberband_box_start[1], $
          event.y, $
          event.y, $
          self.rubberband_box_start[1]], $
         /device

  ; refresh display
  wset, self.draw_id
  device, copy=[0, 0, dimensions, 0, 0, self.backing_store]

  wset, old_win_id
end


;+
; Handle all events from the widget program.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_fits_browser::handle_events, event
  compile_opt strictarr

  uname = widget_info(event.id, /uname)
  case uname of
    'open': self->open_files
    'tlb': begin
        case tag_names(event, /structure_name) of
          'WIDGET_TLB_MOVE': self.prefs->set, 'location', {x:event.x, y:event.y}
          'WIDGET_BASE': self->resize, event.x, event.y
          else:
        endcase
      end
    'export_data':
    'export_header':
    'tabs':
    'browser':
    'draw': begin
        case event.type of
          0: begin
            if ((event.press and 1) gt 0) then begin
              if (self.currently_selected[1] gt 0L) then begin
                self.show_inset = 1B
                self->_show_compare_inset, event
              endif else begin
                self.show_rubberband_box = 1B
                self.rubberband_box_start = [event.x, event.y]
                self->_show_rubberband_box, event
              endelse
            endif
            if ((event.press and 4) gt 0) then begin
              if (self.draw_contextmenu gt 0) then begin
                self.contextmenu_loc = [event.x, event.y]
                widget_displaycontextmenu, event.id, event.x, event.y, $
                                           self.draw_contextmenu
              endif
            endif
          end
          1: begin
            if ((event.release and 1) gt 0) then begin
              if (self.currently_selected[1] gt 0L) then begin
                self.show_inset = 0B
                self->display
              endif else begin
                self.show_rubberband_box = 0B
                self->_compute_box_stats, event
              endelse
            endif
          end
          2: begin
              draw_wid = widget_info(self.tlb, find_by_uname='draw')
              geo_info = widget_info(draw_wid, /geometry)
              if (event.x lt 0 || event.x ge geo_info.draw_xsize $
                    || event.y lt 0 || event.y ge geo_info.draw_ysize) then break
              n_dims = size(*self.current_data, /n_dimensions)
              if (n_dims eq 2) then begin
                self->_set_status_for_draw, event
              endif
              if (self.currently_selected[1] gt 0L && self.show_inset) then begin
                self->_show_compare_inset, event
              endif
              if (self.show_rubberband_box) then begin
                self->_show_rubberband_box, event
              endif
            end
          else:
        endcase
      end
    'cmdline': begin
        if (self.currently_selected[0] lt 0L) then return

        current_uname = widget_info(self.currently_selected[0], /uname)
        case current_uname of
          'fits:file': begin
              widget_control, self.currently_selected[0], get_uvalue=f
              exten_no = 0
            end
          'fits:extension': begin
              widget_control, self.currently_selected[0], get_uvalue=exten_no
              parent_id = widget_info(self.currently_selected[0], /parent)
              widget_control, parent_id, get_uvalue=f
            end
          else: begin
              ; this should never happen, but this message will make debugging
              ; easier if it does
              ok = dialog_message(string(current_uname, format='(%"unknown uname: %s")'), $
                                  dialog_parent=self.tlb)
              return
            end
        endcase

        fits_open, f, fcb
        fits_read, fcb, data, header, exten_no=exten_no
        fits_close, fcb

        tabs = widget_info(self.tlb, find_by_uname='tabs')
        tab_index = widget_info(tabs, /tab_current)
        case tab_index of
          0: begin
              (scope_varfetch('data', /enter, level=1)) = data
              self->set_status, string(exten_no, $
                                       format='(%"Data from extension %d exported to command line in variable ''data''")')
            end
          1: begin
              (scope_varfetch('header', /enter, level=1)) = header
              self->set_status, string(exten_no, $
                                       format='(%"Header from extension %d exported to command line in variable ''header''")')
            end
          else: begin
            ; this should never happen, but this message will make debugging easier
            ok = dialog_message(string(tab_index, format='(%"unknown tab: %d")'), $
                                dialog_parent=self.tlb)
          end
        endcase
      end
    'screenshot': begin
        if (self.currently_selected[0] lt 0L) then return

        basename = file_basename(file_basename(self.current_filename, '.gz'), '.fts')
        cd, current=cwd

        widget_control, self.currently_selected[0], get_uvalue=extension
        if (size(extension, /type) eq 7) then extension = 0L

        tabs = widget_info(self.tlb, find_by_uname='tabs')
        tab_index = widget_info(tabs, /tab_current)
        case tab_index of
          0: begin
              orig_window = !d.window
              wset, self.draw_id
              im = tvrd(true=1)
              wset, orig_window

              default_filename = string(basename, extension, $
                                        format='(%"%s-ext%d.png")')
              results = dialog_write_image(im, $
                                           dialog_parent=self.tlb, $
                                           filename=default_filename, $
                                           path=cwd, $
                                           options=options, $
                                           type='PNG')
              if (results) then self->set_status, 'Wrote image to ' + options.filename
            end
          1: begin
              header_text = widget_info(self.tlb, find_by_uname='fits_header')
              widget_control, header_text, get_value=text


              default_filename = string(basename, extension, $
                                        format='(%"%s-ext%d.txt")')
              full_filename = dialog_pickfile(dialog_parent=self.tlb, $
                                              file=default_filename, $
                                              path=cwd, $
                                              /write)
              if (full_filename ne '') then begin
                openw, lun, full_filename, /get_lun
                printf, lun, text
                free_lun, lun
                self->set_status, 'Wrote header to ' + full_filename
              endif
            end
          else: begin
            ; this should never happen, but this message will make debugging easier
            ok = dialog_message(string(tab_index, format='(%"unknown tab: %d")'), $
                                dialog_parent=self.tlb)
          end
        endcase
      end
    'annotate': begin
        self.annotate = event.select
        if (event.select) then begin
          widget_control, event.id, set_value=filepath('ellipse_active.bmp', $
                                                       subdir=['resource', 'bitmaps']), $
                                                       /bitmap
        endif else begin
          widget_control, event.id, set_value=filepath('ellipse.bmp', $
                                                       subdir=['resource', 'bitmaps']), $
                                                       /bitmap
        endelse

        if (self.currently_selected[0] le 0L) then return
        self->display
      end
    'fits:file': self->_handle_tree_event, event
    'fits:extension': self->_handle_tree_event, event
    'search': self->select_header_text, event
    else: self->handle_contextmenu_events, event
  endcase
end


;+
; Handle context menu events.
;
; Override this method if your subclass creates context menus in
; `create_draw_contextmenu`.
;
; :Params:
;   event : in, required, type=structure
;     `WIDGET_CONTEXT` event
;-
pro mg_fits_browser::handle_contextmenu_events, event
  compile_opt strictarr

  ; this should never happen since we don't create context menus, but
  ; this message will make debugging easier
  uname = widget_info(event.id, /uname)
  ok = dialog_message(string(uname, format='(%"unknown uname: %s")'), $
                      dialog_parent=self.tlb)
end


;= widget lifecycle methods

;+
; Handle cleanup when the widget program is destroyed.
;-
pro mg_fits_browser::cleanup_widgets
  compile_opt strictarr

  obj_destroy, self
end


;+
; Create the context menu associated with the draw widget.
;
; :Returns:
;   long, widget identifier for context menu, 0L if no context menu
;
; :Params:
;   image_draw : in, required, type=long
;     widget identifier for draw widget
;-
function mg_fits_browser::create_draw_contextmenu, image_draw
  compile_opt strictarr

  ; no context menu by default, child classes can override
  return, 0L
end


;+
; Create the widget hierarchy.
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `WIDGET_BASE`
;-
pro mg_fits_browser::create_widgets, _extra=e
  compile_opt strictarr

  tree_xsize = 300
  scr_ysize = 512

  loc = self.prefs->get('location', default={x:0L, y:0L})
  self.tlb = widget_base(title=self.title, /column, uvalue=self, uname='tlb', $
                         /tlb_size_events, /tlb_move_events, _extra=e, $
                         xoffset=loc.x, yoffset=loc.y)

  ; toolbar
  bitmapdir = ['resource', 'bitmaps']
  toolbar = widget_base(self.tlb, /toolbar, /row, uname='toolbar')

  button_toolbar = widget_base(toolbar, /row, uname='button_toolbar', xpad=0, ypad=0)

  file_toolbar = widget_base(button_toolbar, /toolbar, /row, uname='file_toolbar')
  open_button = widget_button(file_toolbar, /bitmap, uname='open', $
                              tooltip='Open FITS file', $
                              value=filepath('open.bmp', subdir=bitmapdir))

  export_toolbar = widget_base(button_toolbar, /toolbar, /row)
  cmdline_button = widget_button(export_toolbar, /bitmap, uname='cmdline', $
                                 tooltip='Export to command line', $
                                 value=filepath('commandline.bmp', $
                                                subdir=bitmapdir))
  screenshot_button = widget_button(export_toolbar, $
                                    /bitmap, uname='screenshot', $
                                    tooltip='Save screenshot of image display', $
                                    value=filepath('export.bmp', $
                                                   subdir=bitmapdir))

  toggle_toolbar = widget_base(button_toolbar, /row, /nonexclusive)
  annotate_button = widget_button(toggle_toolbar, /bitmap, uname='annotate', $
                                  tooltip='Annotate image', $
                                  value=filepath('ellipse.bmp', $
                                                 subdir=bitmapdir), $
                                  sensitive=0)

  spacer = widget_label(toolbar, value=' ', scr_xsize=1, uname='spacer')

  self.secondary_statusbar = widget_label(toolbar, value=' ', $
                                          scr_xsize=scr_ysize, /align_center)

  ; content row
  content_base = widget_base(self.tlb, /row, uname='content_base')

  ; tree
  self.tree = widget_tree(content_base, uname='browser', $
                          scr_xsize=tree_xsize, scr_ysize=scr_ysize, $
                          /multiple)

  tabs = widget_tab(content_base, uname='tabs')

  ; visualization
  old_window = !d.window

  image_base = widget_base(tabs, xpad=0, ypad=0, title='Data', /column)
  image_draw = widget_draw(image_base, xsize=scr_ysize, ysize=scr_ysize, $
                           /motion_events, /button_events, $
                           uname='draw', retain=2)

  window, /free, /pixmap, xsize=scr_ysize, ysize=scr_ysize
  self.backing_store = !d.window
  window, /free, /pixmap, xsize=scr_ysize, ysize=scr_ysize
  self.pixmaps[0] = !d.window
  window, /free, /pixmap, xsize=scr_ysize, ysize=scr_ysize
  self.pixmaps[1] = !d.window

  wset, old_window

  self.draw_contextmenu = self->create_draw_contextmenu(image_draw)

  ; details column
  details_base = widget_base(tabs, xpad=0, ypad=0, title='Header', /column, $
                             uname='details')

  ; metadata
  search_text = widget_text(details_base, value='', xsize=80, ysize=1, $
                            /editable, /all_events, uname='search')
  header_text = widget_text(details_base, value='', $
                            xsize=80, scr_ysize=scr_ysize - 100.0, $
                            /scroll, $
                            uname='fits_header')

  ; variable name for import

  ; status bar
  self.statusbar = widget_label(self.tlb, $
                                value=' ', $
                                scr_xsize=tree_xsize + scr_ysize + 2 * 4.0, $
                                /align_left, $
                                /sunken_frame)
end


;+
; Draw the widget hierarchy.
;-
pro mg_fits_browser::realize_widgets
  compile_opt strictarr

  widget_control, self.tlb, /realize
  image_draw = widget_info(self.tlb, find_by_uname='draw')
  widget_control, image_draw, get_value=draw_id
  self.draw_id = draw_id

  self->resize, 850, 600
end


;+
; Start `XMANAGER`.
;-
pro mg_fits_browser::start_xmanager
  compile_opt strictarr

  xmanager, 'mg_fits_browser', self.tlb, /no_block, $
            event_handler='mg_fits_browser_handleevents', $
            cleanup='mg_fits_browser_cleanup'
end


;= lifecycle methods

;+
; Free resources
;-
pro mg_fits_browser::cleanup
  compile_opt strictarr

  obj_destroy, self.prefs

  wdelete, self.backing_store, self.pixmaps[0], self.pixmaps[1]
  
  ptr_free, self.current_data, self.current_header, self.compare_data, self.compare_header
end


;+
; Browse the contents of an FITS file with a GUI browser program.
;
; :Returns:
;   1 for successful initialization, 0 for failure
;
; :Keywords:
;   filenames : in, optional, type=string
;     filenames of FITS files to view
;   tlb : out, optional, type=long
;     widget identifier for the top-level base
;   _extra : in, optional, type=keywords
;     keywords to `::create_widgets`
;-
function mg_fits_browser::init, filenames=filenames, tlb=tlb, _extra=e
  compile_opt strictarr

  self.prefs = obj_new('MGffPrefs', $
                       author_name='mgalloy', $
                       app_name='mg_fits_browser')

  self.title = 'FITS Browser'
  self.path = ''
  self.annotate = 0B
  self.currently_selected = lonarr(2) - 1L
  self.current_data = ptr_new(/allocate_heap)
  self.current_header = ptr_new(/allocate_heap)
  self.compare_data = ptr_new(/allocate_heap)
  self.compare_header = ptr_new(/allocate_heap)
  self.backing_store = -1L
  self.pixmaps = lonarr(2) - 1L

  self->create_widgets, _extra=e
  self->realize_widgets
  self->start_xmanager

  tlb = self.tlb

  if (n_elements(filenames) gt 0L) then self->load_files, filenames

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   tlb
;     top-level base widget identifier
;-
pro mg_fits_browser__define
  compile_opt strictarr

  define = { mg_fits_browser, $
             prefs: obj_new(), $
             tlb: 0L, $
             tree: 0L, $
             draw_id: 0L, $
             statusbar: 0L, $
             secondary_statusbar: 0L, $
             draw_contextmenu: 0L, $
             contextmenu_loc: lonarr(2), $
             filename: '', $
             title: '', $
             path: '', $
             nfiles: 0L, $
             currently_selected: lonarr(2), $
             show_inset: 0B, $
             show_rubberband_box: 0B, $
             rubberband_box_start: lonarr(2), $
             backing_store: 0L, $
             pixmaps: lonarr(2), $
             search_index: 0L, $
             annotate: 0B, $
             current_filename: '', $
             current_data: ptr_new(), $
             current_header: ptr_new(), $
             compare_filename: '', $
             compare_data: ptr_new(), $
             compare_header: ptr_new() $
           }
end


;+
; Create the browser.
;
; :Returns:
;   `mg_fits_browser` object
;
; :Params:
;   pfilenames : in, optional, type=string
;     filenames of FITS files to view
;
; :Keywords:
;   filenames : in, optional, type=string
;     filenames of netCDF files to view
;   tlb : out, optional, type=long
;     set to a named variable to retrieve the top-level base widget identifier
;     of the FITS browser
;   classname : in, optional, type=string, default='mg_fits_browser'
;     classname of subclass of `mg_fits_browser` class
;   _extra : in, optional, type=keywords
;     keywords to `::init` for `MG_FITS_BROWSER` or, if specified, the
;     class of `CLASSNAME`
;-
function mg_fits_browser, pfilenames, filenames=kfilenames, tlb=tlb, $
                          classname=classname, _extra=e
  compile_opt strictarr

  ; parameter filename takes precedence (it clobbers keyword filename, if
  ; both present)
  if (n_elements(kfilenames) gt 0L) then _filenames = kfilenames
  if (n_elements(pfilenames) gt 0L) then _filenames = pfilenames

  _classname = n_elements(classname) eq 0L ? 'mg_fits_browser' : classname
  b = obj_new(_classname, filenames=_filenames, tlb=tlb, _extra=e)

  return, b
end


;dir = '/Users/mgalloy/data/CoMP/raw/20150226'
;files = file_search(dir, '*.FTS')
;b = mg_fits_browser(files[0:4])

f = filepath('20150428_223017_kcor.fts', $
             subdir=['..', '..', 'unit', 'fits_ut'], $
             root=mg_src_root())
b = mg_fits_browser(f)

end
