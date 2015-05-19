; docformat = 'rst'

;+
; Widget program to browse the contents of a FITS file and load the contents
; of variables into IDL variables a the main-level. Similar to `H5_BROWSER`.
;
; :Categories:
;    file i/o, fits, sdf
;-


;+
; Thin procedural wrapper to call `::handleEvents` event handler.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_fits_browser_handleevents, event
  compile_opt strictarr

  widget_control, event.top, get_uvalue=browser
  browser->handleEvents, event
end


;+
; Thin procedural wrapper to call `::_cleanupWidgets` cleanup routine.
;
; :Params:
;    tlb : in, required, type=long
;       top-level base widget identifier
;-
pro mg_fits_browser_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=browser
  browser->_cleanupWidgets
end


;+
; Set the window title based on the current filename. Set the filename to the
; empty string if there is no title to display.
;
; :Params:
;    filename : in, required, type=string
;       filename to display in title
;-
pro mg_fits_browser::setTitle, filename
  compile_opt strictarr

  title = string(self.title, $
                 filename eq '' ? '' : ' - ', $
                 filename, $
                 format='(%"%s%s%s")')
  widget_control, self.tlb, base_set_title=title
end


;+
; Load FITS files corresponding to filenames.
;
; :Params:
;   filenames : in, optional, type=string/strarr
;     filenames of files to load
;-
pro mg_fits_browser::loadFiles, filenames
  compile_opt strictarr

  self.nfiles += n_elements(filenames)

  self->setTitle, self.nfiles eq 1L ? file_basename(filenames[0]) : 'many files'

  ncbmp = read_bmp(filepath('image.bmp', subdir=['resource', 'bitmaps']), r, g, b)
  ncbmp = [[[r[ncbmp]]], [[g[ncbmp]]], [[b[ncbmp]]]]

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
end


;+
; Display the given data as an image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;-
pro mg_fits_browser::_display_image, data
  compile_opt strictarr

  ndims = size(data, /n_dimensions)
  if (ndims ne 2) then begin
    erase
    return
  endif

  dims = size(data, /dimensions)

  draw_id = widget_info(self.tlb, find_by_uname='draw')
  widget_control, draw_id, get_value=win_id

  geo_info = widget_info(draw_id, /geometry)
  if (dims[0] gt geo_info.draw_xsize || dims[1] gt geo_info.draw_ysize) then begin
    xoffset = 0
    yoffset = 0
  endif else begin
    xoffset = (geo_info.draw_xsize - dims[0]) / 2
    yoffset = (geo_info.draw_ysize - dims[1]) / 2
  endelse

  old_win_id = !d.window
  wset, win_id
  tvscl, data, xoffset, yoffset
  wset, old_win_id
end


;+
; Bring up pick file dialog to choose a file and load it.
;-
pro mg_fits_browser::_openFiles
  compile_opt strictarr

  filenames = dialog_pickfile(group=self.tlb, /read, /multiple_files, $
                              filter='*.fits', $
                              title='Select FITS files to open')
  if (filenames[0] ne '') then self->loadFiles, filenames
end


;+
; Handle all events from the widget program.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_fits_browser::handleEvents, event
  compile_opt strictarr

  uname = widget_info(event.id, /uname)
  case uname of
    'open': self->_openFiles
    'tlb':
    'export_data':
    'export_header':
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

        self->_display_image, data

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

        self->_display_image, data

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


;+
; Handle cleanup when the widget program is destroyed.
;-
pro mg_fits_browser::_cleanupWidgets
  compile_opt strictarr

  obj_destroy, self
end


;+
; Create the widget hierarchy.
;-
pro mg_fits_browser::_createWidgets
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

  scr_ysize = 512

  ; tree
  self.tree = widget_tree(content_base, uname='browser', $
                          scr_xsize=300, scr_ysize=scr_ysize)

  ; visualization
  image_display = widget_draw(content_base, xsize=scr_ysize, ysize=scr_ysize, $
                              uname='draw')

  ; details column
  details = widget_base(content_base, /column)

  ; metadata
  header = widget_text(details, value='', $
                       xsize=80, scr_ysize=scr_ysize, $
                       /scroll, $
                       uname='fits_header')

  ; variable name for import

  ; status basr
  status_bar = widget_label(self.tlb, scr_xsize=300 + 2 * scr_ysize, $
                            /sunken_frame)
end


;+
; Draw the widget hierarchy.
;-
pro mg_fits_browser::_realizeWidgets
  compile_opt strictarr

  widget_control, self.tlb, /realize
end


;+
; Start `XMANAGER`.
;-
pro mg_fits_browser::_startXManager
  compile_opt strictarr

  xmanager, 'mg_fits_browser', self.tlb, /no_block, $
            event_handler='mg_fits_browser_handleevents', $
            cleanup='mg_fits_browser_cleanup'
end


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

  self->_createWidgets
  self->_realizeWidgets
  self->_startXManager

  tlb = self.tlb

  if (n_elements(filenames) gt 0L) then self->loadFiles, filenames

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
;-
function mg_fits_browser, pfilenames, filenames=kfilenames, tlb=tlb
  compile_opt strictarr

  ; parameter filename takes precedence (it clobbers keyword filename, if
  ; both present)
  if (n_elements(kfilenames) gt 0L) then _filenames = kfilenames
  if (n_elements(pfilenames) gt 0L) then _filenames = pfilenames

  b = obj_new('mg_fits_browser', filenames=_filenames, tlb=tlb)

  return, b
end


dir = '/Users/mgalloy/Desktop/IRIS-4/data analysis/iris/20131226_171752_3840007146'
files = file_search(dir, '*.fits')
b = mg_fits_browser(files)

end