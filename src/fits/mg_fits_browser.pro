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
  browser->cleanup_widgets
end


;= data specific

;+
; Returns valid file extensions.
;
; :Returns:
;   strarr
;-
function mg_fits_browser::file_extensions
  compile_opt strictarr

  return, ['*.fits', '*.fts', '*.FTS']
end


;+
; Display the given data as an image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;-
pro mg_fits_browser::display_image, data, header
  compile_opt strictarr

  ndims = size(data, /n_dimensions)
  if (ndims ne 2) then begin
    self->erase
    return
  endif

  draw_wid = widget_info(self.tlb, find_by_uname='draw')
  geo_info = widget_info(draw_wid, /geometry)

  dims = size(data, /dimensions)

  data_aspect_ratio = float(dims[1]) / float(dims[0])
  draw_aspect_ratio = float(geo_info.draw_ysize) / float(geo_info.draw_xsize)

  if (data_aspect_ratio gt draw_aspect_ratio) then begin
    ; use y as limiting factor for new dimensions
    dims *= geo_info.draw_ysize / float(dims[1])
  endif else begin
    ; use x as limiting factor for new dimensions
    dims *= geo_info.draw_xsize / float(dims[0])
  endelse

  data = congrid(data, dims[0], dims[1])

  if (dims[0] gt geo_info.draw_xsize || dims[1] gt geo_info.draw_ysize) then begin
    xoffset = 0
    yoffset = 0
  endif else begin
    xoffset = (geo_info.draw_xsize - dims[0]) / 2
    yoffset = (geo_info.draw_ysize - dims[1]) / 2
  endelse

  old_win_id = !d.window
  wset, self.draw_id
  tvscl, data, xoffset, yoffset
  wset, old_win_id
end


;= API

;+
; Erase the draw window.
;-
pro mg_fits_browser::erase
  compile_opt strictarr

  old_win_id = !d.window
  wset, self.draw_id
  erase
  wset, old_win_id
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
;-
pro mg_fits_browser::set_status, msg, clear=clear
  compile_opt strictarr

  _msg = keyword_set(clear) || n_elements(msg) eq 0L ? '' : msg
  widget_control, self.statusbar, set_value=_msg
end


;+
; Load FITS files corresponding to filenames.
;
; :Params:
;   filenames : in, optional, type=string/strarr
;     filenames of files to load
;-
pro mg_fits_browser::load_files, filenames
  compile_opt strictarr

  self.nfiles += n_elements(filenames)

  self->set_title, self.nfiles eq 1L ? file_basename(filenames[0]) : 'many files'

  ncbmp = read_bmp(filepath('image.bmp', subdir=['resource', 'bitmaps']), r, g, b)
  ncbmp = [[[r[ncbmp]]], [[g[ncbmp]]], [[b[ncbmp]]]]

  self->set_status, string(self.nfiles, self.nfiles eq 1 ? '' : 's', $
                           format='(%"Loading %d FITS file%s...")')

  widget_control, self.tree, update=0
  foreach f, filenames do begin
    file_node = widget_tree(self.tree, /folder, $
                            value=file_basename(f), $
                            bitmap=ncbmp, $
                            uname='fits:file', uvalue=f)
    fits_open, f, fcb
    fits_read, fcb, data, header
    for i = 0L, fcb.nextend - 1L do begin
      ext_node = widget_tree(file_node, $
                             value='extension ' + strtrim(i, 2), $
                             uname='fits:extension', uvalue=i)
    endfor
    fits_close, fcb
  endforeach
  widget_control, self.tree, update=1

  self->set_status, /clear
end


;+
; Bring up pick file dialog to choose a file and load it.
;
; :Private:
;-
pro mg_fits_browser::open_files
  compile_opt strictarr

  filenames = dialog_pickfile(group=self.tlb, /read, /multiple_files, $
                              filter=self->file_extensions(), $
                              title='Select FITS files to open')
  if (filenames[0] ne '') then self->load_files, filenames
end


;= event handling

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
    'tlb':
    'export_data':
    'export_header':
    'tabs':
    'browser':
    'cmdline': begin
        if (self.currently_selected eq 0L) then return

        current_uname = widget_info(self.currently_selected, /uname)
        case current_uname of
          'fits:file': begin
              widget_control, self.currently_selected, get_uvalue=f
              exten_no = 0
            end
          'fits:extension': begin
              widget_control, self.currently_selected, get_uvalue=exten_no
              parent_id = widget_info(self.currently_selected, /parent)
              widget_control, parent_id, get_uvalue=f
            end
          else: begin
              ; this should never happen, but this message will make debugging easier
              ok = dialog_message(string(current_uname, format='(%"unknown uname: %s")'), $
                                  dialog_parent=self.tlb)
              return
            end
        endcase

        fits_open, f, fcb
        fits_read, fcb, data, header, exten_no=exten_no
        fits_close, fcb

        ; TODO: need to know if data or header and name for variable
        export_data_id = widget_info(self.tlb, find_by_uname='export_data')
        data_set = widget_info(export_data_id, /button_set)
        if (data_set eq 1) then begin
          (scope_varfetch('data', /enter, level=1)) = data
        endif else begin
          (scope_varfetch('header', /enter, level=1)) = header
        endelse
      end
    'fits:file': begin
        self.currently_selected = event.id

        widget_control, event.id, get_uvalue=f

        fits_open, f, fcb
        fits_read, fcb, data, header
        fits_close, fcb

        self->display_image, data, header

        header_widget = widget_info(self.tlb, find_by_uname='fits_header')
        widget_control, header_widget, set_value=header
      end
    'fits:extension': begin
        self.currently_selected = event.id

        widget_control, event.id, get_uvalue=e
        parent_id = widget_info(event.id, /parent)
        widget_control, parent_id, get_uvalue=f

        fits_open, f, fcb
        fits_read, fcb, data, header, exten_no=e
        fits_close, fcb

        self->display_image, data, header

        header_widget = widget_info(self.tlb, find_by_uname='fits_header')
        widget_control, header_widget, set_value=header
      end
    else: begin
      ; this should never happen, but this message will make debugging easier
      ok = dialog_message(string(uname, format='(%"unknown uname: %s")'), $
                          dialog_parent=self.tlb)
    end
  endcase
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
; Create the widget hierarchy.
;-
pro mg_fits_browser::create_widgets
  compile_opt strictarr

  self.tlb = widget_base(title=self.title, /column, uvalue=self, uname='tlb')

  ; toolbar
  bitmapdir = ['resource', 'bitmaps']
  toolbar = widget_base(self.tlb, /toolbar, /row)

  file_toolbar = widget_base(toolbar, /toolbar, /row)
  open_button = widget_button(file_toolbar, /bitmap, uname='open', $
                              tooltip='Open FITS file', $
                              value=filepath('open.bmp', subdir=bitmapdir))

  export_toolbar = widget_base(toolbar, /toolbar, /row)
  cmdline_button = widget_button(export_toolbar, /bitmap, uname='cmdline', $
                                 tooltip='Export to command line', $
                                 value=filepath('commandline.bmp', $
                                                subdir=bitmapdir))

  exporttype_toolbar = widget_base(export_toolbar, /toolbar, /exclusive, /row, $
                                   xpad=0, ypad=0)
  data_button = widget_button(exporttype_toolbar, /bitmap, $
                              uname='export_data', $
                              tooltip='Set export type to data', $
                              value=filepath('binary.bmp', subdir=bitmapdir))
  header_button = widget_button(exporttype_toolbar, /bitmap, $
                                uname='export_header', $
                                tooltip='Set export type to header', $
                                value=filepath('lft.bmp', subdir=bitmapdir))
  widget_control, data_button, set_button=1
  widget_control, header_button, set_button=0

  ; content row
  content_base = widget_base(self.tlb, /row)

  tree_xsize = 300
  scr_ysize = 512

  ; tree
  self.tree = widget_tree(content_base, uname='browser', $
                          scr_xsize=tree_xsize, scr_ysize=scr_ysize)

  tabs = widget_tab(content_base, uname='tabs')

  ; visualization
  image_base = widget_base(tabs, xpad=0, ypad=0, title='Data', /column)
  image_draw = widget_draw(image_base, xsize=scr_ysize, ysize=scr_ysize, $
                           uname='draw')

  ; details column
  details_base = widget_base(tabs, xpad=0, ypad=0, title='Header', /column)

  ; metadata
  header_text = widget_text(details_base, value='', $
                            xsize=80, scr_ysize=scr_ysize, $
                            /scroll, $
                            uname='fits_header')

  ; variable name for import

  ; status basr
  self.statusbar = widget_label(self.tlb, scr_xsize=tree_xsize + scr_ysize, $
                                /align_left, /sunken_frame)
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
;-
function mg_fits_browser::init, filenames=filenames, tlb=tlb
  compile_opt strictarr

  self.title = 'FITS Browser'

  self->create_widgets
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
             tlb: 0L, $
             tree: 0L, $
             draw_id: 0L, $
             statusbar: 0L, $
             filename: '', $
             title: '', $
             nfiles: 0L, $
             currently_selected: 0L $
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
;-
function mg_fits_browser, pfilenames, filenames=kfilenames, tlb=tlb, $
                          classname=classname
  compile_opt strictarr

  ; parameter filename takes precedence (it clobbers keyword filename, if
  ; both present)
  if (n_elements(kfilenames) gt 0L) then _filenames = kfilenames
  if (n_elements(pfilenames) gt 0L) then _filenames = pfilenames

  _classname = n_elements(classname) eq 0L ? 'mg_fits_browser' : classname
  b = obj_new(_classname, filenames=_filenames, tlb=tlb)

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
