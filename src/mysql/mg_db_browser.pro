; docformat = 'rst'

;+
; Browse databases and their tables.
;-


;= helper routines

;+
; Thin procedural wrapper to call `::handle_events` event handler.
;
; :Params:
;   event : in, required, type=structure
;     event structure for event handler to handle
;-
pro mg_db_browser_handleevents, event
  compile_opt strictarr

  widget_control, event.top, get_uvalue=browser
  browser->handle_events, event
end


;+
; Thin procedural wrapper to call `::cleanup_widgets` cleanup routine.
;
; :Params:
;   tlb : in, required, type=long
;     top-level base widget identifier
;-
pro mg_db_browser_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=browser
  browser->cleanup_widgets
end


;= API

;+
; Set the window title based on the current filename. Set the filename
; to the empty string if there is no title to display.
;
; :Params:
;   filename : in, required, type=string                                                    
;       filename to display in title
;-
pro mg_db_browser::set_title, filename
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
pro mg_db_browser::set_status, msg, clear=clear
  compile_opt strictarr

  _msg = keyword_set(clear) || n_elements(msg) eq 0L ? '' : msg
  widget_control, self.statusbar, set_value=_msg
end


pro mg_db_browser::_update_table
  compile_opt strictarr

  db_values = self.db->query('select * from %s limit 500', self.current_table, $
                             status=status, error_message=error_message)

  if (n_elements(db_values) eq 0L) then begin
    n_blank = 10
    widget_control, self.table, set_value=strarr(n_blank), $
                    xsize=n_blank, $
                    column_labels=strarr(n_blank)
  endif else begin
    widget_control, self.table, $
                    set_value=db_values, $
                    xsize=n_tags(db_values), $
                    column_labels=tag_names(db_values)
  endelse
end


;= widget events

pro mg_db_browser::handle_events, event
  compile_opt strictarr

  uname = widget_info(event.id, /uname)
  case uname of
    'tlb': begin
        tlb_geometry = widget_info(self.tlb, /geometry)
        table_geometry = widget_info(self.table, /geometry)
        statusbar_geometry = widget_info(self.statusbar, /geometry)

        table_width = event.x $
                        - 2 * tlb_geometry.xpad $
                        - 3
        statusbar_width = table_width
        height = event.y - 3 * tlb_geometry.ypad $
                   - statusbar_geometry.scr_ysize $
                   - 2 * statusbar_geometry.margin

        widget_control, self.tlb, update=0

        widget_control, self.table, scr_xsize=table_width, scr_ysize=height
        widget_control, self.statusbar, scr_xsize=statusbar_width

        widget_control, self.tlb, update=1
      end
    'databases': begin
        self->setProperty, database=event.str
        table_list = widget_info(self.tlb, find_by_uname='tables')
        tables = self.db->list_tables()
        self->setProperty, table=tables[0]
        widget_control, table_list, set_value=tables

        self->_update_table
      end
    'tables': begin
        self->setProperty, table=event.str

        self->_update_table
      end
    else:
  endcase
end


;= widget lifecycle methods

;+
; Handle cleanup when the widget program is destroyed.
;-
pro mg_db_browser::cleanup_widgets
  compile_opt strictarr

  obj_destroy, self
end


pro mg_db_browser::create_widgets
  compile_opt strictarr

  table_xsize = 800
  table_ysize = 600
  xpad = 0

  dbs = self.db->list_dbs()
  self->setProperty, database=dbs[0]
  tables = self.db->list_tables()
  self->setProperty, table=tables[0]
  db_values = self.db->query('select * from %s limit 500', tables[0])

  self.tlb = widget_base(title=self.title, /column, /tlb_size_events, $
                         uvalue=self, uname='tlb')

  ; toolbar
  toolbar = widget_base(self.tlb, /row, uname='toolbar')
  database_list = widget_combobox(toolbar, value=dbs, uname='databases')
  table_list = widget_combobox(toolbar, value=tables, uname='tables')

  self.table = widget_table(self.tlb, $
                            /no_row_headers, $
                            column_labels=tag_names(db_values[0]), $
                            value=db_values, $
                            xsize=n_tags(db_values[0]), $
                            scr_xsize=table_xsize, $
                            scr_ysize=table_ysize, $
                            uname='table', $
                            /resizeable_columns, $
                            /all_events, $
                            /context_events)
  self.statusbar = widget_label(self.tlb, $
                                scr_xsize=table_xsize + 2 * xpad, $
                                /align_left, /sunken_frame)
end


;+
; Draw the widget hierarchy.
;-
pro mg_db_browser::realize_widgets
  compile_opt strictarr

  widget_control, self.tlb, /realize
end


;+
; Start `XMANAGER`.
;-
pro mg_db_browser::start_xmanager
  compile_opt strictarr

  xmanager, 'mg_db_browser', self.tlb, /no_block, $
            event_handler='mg_db_browser_handleevents', $
            cleanup='mg_db_browser_cleanup'
end


;= property access

pro mg_db_browser::setProperty, database=database, table=table
  compile_opt strictarr

  if (n_elements(database) gt 0L) then begin
    self.current_database = database
    self.db->setProperty, database=database
  endif

  if (n_elements(table) gt 0L) then begin
    self.current_table = table
  endif
end



;= lifecycle methods

pro mg_db_browser::cleanup
  compile_opt strictarr

  obj_destroy, self.db
end


function mg_db_browser::init, config_filename, section=section
  compile_opt strictarr

  self.title = 'Database browser'

  _config_filename = n_elements(config_filename) eq 0L $
                       ? filepath('.mysqldb', root=getenv('HOME')) $
                       : config_filename

  config = mg_read_config(_config_filename)

  config->getProperty, sections=sections

  _section = n_elements(section) eq 0L ? sections[0] : section

  obj_destroy, config

  self.db = mgdbmysql()
  self.db->setProperty, mysql_secure_auth=0
  self.db->connect, config_filename=_config_filename, $
                    config_section=_section, $
                    error_message=error_message
  self.db->getProperty, host_name=host

  self->create_widgets
  self->realize_widgets
  self->start_xmanager

  self->set_status, string(host, format='(%"Connected to %s...\n")')

  return, 1
end


pro mg_db_browser__define
  compile_opt strictarr

  define = { mg_db_browser, $
             title: '', $
             tlb: 0L, $
             db: obj_new(), $
             table: 0L, $
             statusbar: 0L, $
             current_database: '', $
             current_table: '' $
           }
end


;+
; Browse databases and their tables.
;
; :Params:
;   config_filename : in, optional, type=string, default=~/.mysqldb
;     configuration file with login information for database
;   section : in, optional, type=string
;     section of the configuration file to use; defaults to the first
;     section
;-
pro mg_db_browser, config_filename, section=section
  compile_opt strictarr
  on_error, 2

  browser = obj_new('mg_db_browser', config_filename, section=section)
end
