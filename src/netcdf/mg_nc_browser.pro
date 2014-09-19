; docformat = 'rst'

;+
; Widget program to browse the contents of a netCDF file and load the contents
; of variables into IDL variables a the main-level. Similar to `H5_BROWSER`.
;
; :Categories:
;    file i/o, netcdf, sdf
;-


;+
; Thin procedural wrapper to call `::handleEvents` event handler.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_nc_browser_handleevents, event
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
pro mg_nc_browser_cleanup, tlb
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
pro mg_nc_browser::setTitle, filename
  compile_opt strictarr

  title = string(self.title, $
                 filename eq '' ? '' : ' - ', $
                 filename, $
                 format='(%"%s%s%s")')
  widget_control, self.tlb, base_set_title=title
end


;+
; Load netCDF files corresponding to filenames.
;
; :Params:
;   filenames : in, optional, type=string/strarr
;     filenames of files to load
;-
pro mg_nc_browser::loadFiles, filenames
  compile_opt strictarr

  self.nfiles += n_elements(filenames)

  self->setTitle, self.nfiles eq 1L ? file_basename(filenames[0]) : 'many files'

  ncbmp = read_bmp(filepath('netcdf.bmp', root=mg_src_root()), r, g, b)
  ncbmp = [[[r[ncbmp]]], [[g[ncbmp]]], [[b[ncbmp]]]]

  foreach f, filenames do begin
    file = obj_new('MGffNCFile', filename=f)
    file_node = widget_tree(self.tree, /folder, value=f, bitmap=ncbmp, $
                            uname='netcdf:file', uvalue=file)
  endforeach
end


;+
; Bring up pick file dialog to choose a file and load it.
;-
pro mg_nc_browser::_openFiles
  compile_opt strictarr

  filenames = dialog_pickfile(group=self.tlb, /read, /multiple_files, $
                              filter='*.nc', $
                              title='Select netCDF files to open')
  if (filenames[0] ne '') then self->loadFiles, filenames
end


;+
; Handle all events from the widget program.
;
; :Params:
;    event : in, required, type=structure
;       event structure for event handler to handle
;-
pro mg_nc_browser::handleEvents, event
  compile_opt strictarr

  uname = widget_info(event.id, /uname)
  case uname of
    'open': self->_openFiles
    'display':
    'fittowindow':
    'fliphoriz':
    'flipvert':
    'tlb':
    'import':
    'netcdf:file':
    'netcdf:group':
    'netcdf:variable':
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
pro mg_nc_browser::_cleanupWidgets
  compile_opt strictarr

  obj_destroy, self
end


;+
; Create the widget hierarchy.
;-
pro mg_nc_browser::_createWidgets
  compile_opt strictarr

  self.tlb = widget_base(title=self.title, /column, uvalue=self, uname='tlb')

  ; toolbar
  bitmapdir = ['resource', 'bitmaps']
  toolbar = widget_base(self.tlb, /toolbar, /row)

  file_toolbar = widget_base(toolbar, /toolbar, /row)
  open_button = widget_button(file_toolbar, /bitmap, uname='open', $
                              tooltip='Open netCDF file', $
                              value=filepath('open.bmp', subdir=bitmapdir))

  vis_toolbar = widget_base(toolbar, /toolbar, /nonexclusive, /row)
  display_button = widget_button(vis_toolbar, /bitmap, uname='display', $
                                 tooltip='Open netCDF file', $
                                 value=filepath('image.bmp', subdir=bitmapdir))
  fittowindow_button = widget_button(vis_toolbar, /bitmap, uname='fittowindow', $
                                     tooltip='Open netCDF file', $
                                     value=filepath('fitwindow.bmp', subdir=bitmapdir))
  fliphoriz_button = widget_button(vis_toolbar, /bitmap, uname='fliphoriz', $
                                   tooltip='Open netCDF file', $
                                   value=filepath('fliphoriz.bmp', subdir=bitmapdir))
  flipvert_button = widget_button(vis_toolbar, /bitmap, uname='flipvert', $
                                  tooltip='Open netCDF file', $
                                  value=filepath('flipvert.bmp', subdir=bitmapdir))

  ; content row
  content_base = widget_base(self.tlb, /row)

  ; tree
  self.tree = widget_tree(content_base, uname='browser', $
                          scr_xsize=300, scr_ysize=512)

  ; details column

  ; visualization

  ; metadata

  ; variable name for import

  ; import, done buttons
end


;+
; Draw the widget hierarchy.
;-
pro mg_nc_browser::_realizeWidgets
  compile_opt strictarr

  widget_control, self.tlb, /realize
end


;+
; Start `XMANAGER`.
;-
pro mg_nc_browser::_startXManager
  compile_opt strictarr

  xmanager, 'mg_nc_browser', self.tlb, /no_block, $
            event_handler='mg_nc_browser_handleevents', $
            cleanup='mg_nc_browser_cleanup'
end


;+
; Free resources
;-
pro mg_nc_browser::cleanup
  compile_opt strictarr

end


;+
; Browse the contents of an netCDF file with a GUI browser program.
;
; :Returns:
;    1 for successful initialization, 0 for failure
;
; :Keywords:
;    filenames : in, optional, type=string
;       filenames of netCDF files to view
;    tlb : out, optional, type=long
;       widget identifier for the top-level base
;-
function mg_nc_browser::init, filenames=filenames, tlb=tlb
  compile_opt strictarr

  self.title = 'netCDF Browser'

  self->_createWidgets
  tlb = self.tlb
  self->_realizeWidgets
  self->_startXManager

  if (n_elements(filenames) gt 0L) then self->loadFiles, filenames

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    tlb
;       top-level base widget identifier
;-
pro mg_nc_browser__define
  compile_opt strictarr

  define = { mg_nc_browser, $
             tlb: 0L, $
             tree: 0L, $
             filename: '', $
             title: '', $
             nfiles: 0L $
           }
end


;+
; Create the browser.
;
; :Returns:
;    widget identifier for the browser
;
;
; :Params:
;    pfilenames : in, optional, type=string
;       filenames of netCDF files to view
;
; :Keywords:
;    filenames : in, optional, type=string
;       filenames of netCDF files to view
;-
function mg_nc_browser, pfilenames, filenames=kfilenames
  compile_opt strictarr

  ; parameter filename takes precedence (it clobbers keyword filename, if
  ; both present)
  if (n_elements(kfilenames) gt 0L) then _filenames = kfilenames
  if (n_elements(pfilenames) gt 0L) then _filenames = pfilenames

  b = obj_new('mg_nc_browser', filenames=_filenames, tlb=tlb)

  return, tlb
end


; main-level example program

tlb = mg_nc_browser(filepath('ncgroup.nc', subdir=['examples', 'data']))
tlb = mg_nc_browser(filepath('sample.nc', subdir=['examples', 'data']))

end
