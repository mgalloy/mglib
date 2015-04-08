; docformat = 'rst'

pro mgdbmysql::setProperty, quiet=quiet
  compile_opt strictarr

  if (n_elements(quiet)) then self.quiet = quiet
end


pro mgdbmysql::getProperty, client_info=client_info, $
                            client_version=client_version
  compile_opt strictarr

  if (arg_present(client_info)) then client_info = mg_mysql_get_client_info()
  if (arg_present(client_version)) then version = mg_mysql_get_client_version()
end


function mgdbmysql::lookup, code
  compile_opt strictarr

  if (~obj_valid(self.enum_field_types)) then begin
    self.enum_field_types = hash()
    self.enum_field_types[0] = 'MYSQL_TYPE_DECIMAL'
    self.enum_field_types[1] = 'MYSQL_TYPE_TINY'
    self.enum_field_types[2] = 'MYSQL_TYPE_SHORT'
    self.enum_field_types[3] = 'MYSQL_TYPE_LONG'
    self.enum_field_types[4] = 'MYSQL_TYPE_FLOAT'
    self.enum_field_types[5] = 'MYSQL_TYPE_DOUBLE'
    self.enum_field_types[6] = 'MYSQL_TYPE_NULL'
    self.enum_field_types[7] = 'MYSQL_TYPE_TIMESTAMP'
    self.enum_field_types[8] = 'MYSQL_TYPE_LONGLONG'
    self.enum_field_types[9] = 'MYSQL_TYPE_INT24'
    self.enum_field_types[10] = 'MYSQL_TYPE_DATE'
    self.enum_field_types[11] = 'MYSQL_TYPE_TIME'
    self.enum_field_types[12] = 'MYSQL_TYPE_DATETIME'
    self.enum_field_types[13] = 'MYSQL_TYPE_YEAR'
    self.enum_field_types[14] = 'MYSQL_TYPE_NEWDATE'
    self.enum_field_types[15] = 'MYSQL_TYPE_VARCHAR'
    self.enum_field_types[16] = 'MYSQL_TYPE_BIT'
    self.enum_field_types[17] = 'MYSQL_TYPE_TIMESTAMP2'
    self.enum_field_types[18] = 'MYSQL_TYPE_DATETIME2'
    self.enum_field_types[19] = 'MYSQL_TYPE_TIME2'
    self.enum_field_types[246] = 'MYSQL_TYPE_NEWDECIMAL'
    self.enum_field_types[247] = 'MYSQL_TYPE_ENUM'
    self.enum_field_types[248] = 'MYSQL_TYPE_SET'
    self.enum_field_types[249] = 'MYSQL_TYPE_TINY_BLOB'
    self.enum_field_types[250] = 'MYSQL_TYPE_MEDIUM_BLOB'
    self.enum_field_types[251] = 'MYSQL_TYPE_LONG_BLOB'
    self.enum_field_types[252] = 'MYSQL_TYPE_BLOB'
    self.enum_field_types[253] = 'MYSQL_TYPE_VAR_STRING'
    self.enum_field_types[254] = 'MYSQL_TYPE_STRING'
    self.enum_field_types[255] = 'MYSQL_TYPE_GEOMETRY'
  endif

  return, self.enum_field_types[code]
end


;+
; if type is 3 -> long
; if charsetnr is 33 and type is 252 -> string
; otherwise binary
;-
function mgdbmysql::_get_type, field
  compile_opt strictarr
  on_error, 2

  case field.type of
    3: return, 0L
    252: begin
        if (field.charsetnr eq 33) then begin
          return, ''
        endif else begin
          return, ptr_new(/allocate_heap)
        endelse
      end
    else: message, 'unsupported type'
  endcase
end


function mgdbmysql::query, sql_query, $
                           fields=fields, $
                           error_message=error_message
  compile_opt strictarr
  on_error, 2

  if (mg_mysql_query(self.connection, sql_query) ne 0) then begin
    error_message = mg_mysql_error(self.connection)
    if (self.quiet || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

  result = mg_mysql_store_result(self.connection)
  if (result eq 0) then begin
    error_message = mg_mysql_error(self.connection)
    if (self.quiet || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

  n_fields = mg_mysql_num_fields(result)
  n_rows = mg_mysql_num_rows(result)

  fields = replicate({ mg_mysql_field }, n_fields)
  for f = 0L, n_fields - 1L do begin
    fields[f] = mg_mysql_fetch_field(result)
  endfor

  row_result = create_struct(fields[0].name, self->_get_type(fields[0]))
  for f = 1L, n_fields - 1L do begin
    row_result = create_struct(row_result, $
                               fields[f].name, self->_get_type(fields[f]))
  endfor

  query_result = replicate(row_result, n_rows)
  for r = 0L, n_rows - 1L do begin
    row = mg_mysql_fetch_row(result)
    lengths = mg_mysql_fetch_lengths(result)
    for f = 0L, n_fields - 1L do begin
      case size(row_result.(f), /type) of
        3: query_result[r].(f) = long(mg_mysql_get_field(row, f))
        7: query_result[r].(f) = mg_mysql_get_field(row, f)
        10: *query_result[r].(f) = mg_mysql_get_blobfield(row, f, lengths[f])
      endcase
    endfor
  endfor

  mg_mysql_free_result, result

  return, query_result
end


;+
; Connect to a database.
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, required, type=string
;     user to connect as
;   password : in, required, type=string
;     password for user
;   database : in, required, type=string
;     database to connect to
;   port : in, optional, type=ulong, default=0UL
;     port to use
;   socket : in, optional, type=string
;     socket or named pipe to use
;-
pro mgdbmysql::connect, host=host, $
                        user=user, $
                        password=password, $
                        database=database, $
                        port=port, $
                        socket=socket, $
                        error_message=error_message
  compile_opt strictarr
  on_error, 2

  _host = n_elements(host) eq 0 ? 'localhost' : host
  _port = n_elements(port) eq 0 ? 0UL : port
  _socket = n_elements(socket) eq 0 ? '' : socket

  flags = 0ULL

  self.connection = mg_mysql_init()
  if (self.connection eq 0) then begin
    error_message = mg_mysql_error(self.connection)
    if (self.quiet || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif

  self.connection = mg_mysql_real_connect(self.connection, $
                                          _host, user, password, database, $
                                          _port, _socket, flags)
  if (self.connection eq 0) then begin
    error_message = mg_mysql_error(self.connection)
    mg_mysql_close, self.connection
    if (self.quiet || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif
end


pro mg_dbmysql::cleanup
  compile_opt strictarr

  if (self.connection ne 0) then begin
    mg_mysql_close, self.connection
    self.connection = 0UL
  endif
end


function mgdbmysql::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e

  return, 1
end


pro mgdbmysql__define
  compile_opt strictarr

  define = { MGdbMySQL, $
             connection: 0ULL, $
             quiet: 0B, $
             enum_field_types: obj_new() $
           }
end


; main-level example

db = MGdbMySQL()
db->connect, user='mgalloy', password='passwd', database='testdb'

car_results = db->query('select * from Cars', fields=fields)
print, fields.name, format='(%"%-3s %-10s %-6s")'
print, car_results, format='(%"%3d %10s %6d")'

image_results = db->query('select * from Images', fields=fields)

mg_image, reform(*image_results[0].data, 288, 216), /new_window

ptr_free, image_results[0].data

obj_destroy, db

end
