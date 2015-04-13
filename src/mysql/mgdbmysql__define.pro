; docformat = 'rst'

;+
; Wrapper for direct MySQL bindings.
;
; :Properties:
;   quiet
;     indicates whether error messages should be printed
;   client_info : type=string
;     version string
;   client_version : type=ulong64
;     version
;-


;+
; :Private:
;-
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
; Return the correct variable type to hold data for a given field.
;
; :Private:
;
; :Returns:
;   variable of given type
;
; :Params:
;   field : in, required, type=structure
;     structure describing the field
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
    253: return, ''
    else: message, 'unsupported type'
  endcase
end



;+
; Helper method to return a result set.
;
; :Private:
;
; :Params:
;   result : in, required, type=ulong64
;     result set
;
; :Keywords:
;   fields : out, optional, type=array of structures
;     set to a named variable to retrieve an array of structures describing
;     describing the fields of the results
;   n_rows : out, optional, type=integer
;     set to a named variable to retrieve the number of rows in the result
;-
function mgdbmysql::_get_results, result, fields=fields, n_rows=n_rows
  compile_opt strictarr

  n_fields = mg_mysql_num_fields(result)
  n_rows = mg_mysql_num_rows(result)

  if (n_rows eq 0) then return, {}

  fields = replicate({ mg_mysql_field }, n_fields)
  for f = 0L, n_fields - 1L do begin
    fields[f] = mg_mysql_fetch_field(result)
  endfor

  row_result = create_struct(idl_validname(fields[0].name, /convert_all), $
                             self->_get_type(fields[0]))
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
  
  return, query_result
end


;= API

;+
; Returns the error message for the last failed MySQL API routine.
;
; :Returns:
;   string of error message
;-
function mgdbmysql::last_error_message
  compile_opt strictarr

  error_message = mg_mysql_error(self.connection)
  return, error_message eq '' ? 'unknown error' : error_message
end


;+
; Perform a query and retrieve the results.
;
; :Returns:
;   array of structures
;
; :Params:
;   sql_query : in, required, type=string
;     query string, may be C format string with `arg1`-`arg12` substituted into
;     it
;
; :Keywords:
;   fields : out, optional, type=array of structures
;     array of structures defining each field of the return value
;   error_message : out, optional, type=string
;     MySQL error message
;-
function mgdbmysql::query, sql_query, $
                           arg1, arg2, arg3, arg4, arg5, $
                           arg6, arg7, arg8, arg9, arg10, $
                           arg11, arg12, $
                           fields=fields, $
                           error_message=error_message
  compile_opt strictarr
  on_error, 2

  case n_params() of
     0: _sql_query = ''
     1: _sql_query = sql_query
     2: _sql_query = string(arg1, format='(%"' + sql_query + '")')
     3: _sql_query = string(arg1, arg2, format='(%"' + sql_query + '")')
     4: _sql_query = string(arg1, arg2, arg3, format='(%"' + sql_query + '")')
     5: _sql_query = string(arg1, arg2, arg3, arg4, format='(%"' + sql_query + '")')
     6: _sql_query = string(arg1, arg2, arg3, arg4, arg5, format='(%"' + sql_query + '")')
     7: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, format='(%"' + sql_query + '")')
     8: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, format='(%"' + sql_query + '")')
     9: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, format='(%"' + sql_query + '")')
    10: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, format='(%"' + sql_query + '")')
    11: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, format='(%"' + sql_query + '")')
    12: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, format='(%"' + sql_query + '")')
    13: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, format='(%"' + sql_query + '")')
  endcase

  if (mg_mysql_query(self.connection, _sql_query) ne 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

  result = mg_mysql_store_result(self.connection)
  if (result eq 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

  query_result = self->_get_results(result, fields=fields)

  mg_mysql_free_result, result

  return, query_result
end


;+
; Perform an SQL command that does not retrieve a result.
;
; :Returns:
;   array of structures
;
; :Params:
;   sql_query : in, required, type=string
;     query string, may be C format string with `arg1`-`arg12` substituted into
;     it
;
; :Keywords:
;   error_message : out, optional, type=string
;     MySQL error message
;-
pro mgdbmysql::execute, sql_query, $
                        arg1, arg2, arg3, arg4, arg5, $
                        arg6, arg7, arg8, arg9, arg10, $
                        arg11, arg12, $
                        error_message=error_message
  compile_opt strictarr
  on_error, 2

  case n_params() of
     0: _sql_query = ''
     1: _sql_query = sql_query
     2: _sql_query = string(arg1, format='(%"' + sql_query + '")')
     3: _sql_query = string(arg1, arg2, format='(%"' + sql_query + '")')
     4: _sql_query = string(arg1, arg2, arg3, format='(%"' + sql_query + '")')
     5: _sql_query = string(arg1, arg2, arg3, arg4, format='(%"' + sql_query + '")')
     6: _sql_query = string(arg1, arg2, arg3, arg4, arg5, format='(%"' + sql_query + '")')
     7: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, format='(%"' + sql_query + '")')
     8: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, format='(%"' + sql_query + '")')
     9: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, format='(%"' + sql_query + '")')
    10: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, format='(%"' + sql_query + '")')
    11: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, format='(%"' + sql_query + '")')
    12: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, format='(%"' + sql_query + '")')
    13: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, format='(%"' + sql_query + '")')
  endcase

  if (mg_mysql_query(self.connection, _sql_query) ne 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif
end


;+
; Return a list of tables available.
;
; :Returns:
;   array of structures or `[]` if no matching tables
;
; :Params:
;   wildcard : in, optional, type=string, default=%
;     wildcard matched against table names, containing `%` and/or `_`
;
; :Keywords:
;   n_tables : out, optional, type=long
;     set to a named variable to retrieve the number of matching tables
;-
function mgdbmysql::list_tables, wildcard, n_tables=n_tables
  compile_opt strictarr

  result = mg_mysql_list_tables(self.connection, wildcard)
  query_result = self->_get_results(result, n_rows=n_tables)
  mg_mysql_free_result, result
  return, n_tables eq 0 ? [] : query_result.(0)
end


;+
; Return a list of databases available.
;
; :Returns:
;   array of structures or `[]` if no matching tables
;
; :Params:
;   wildcard : in, optional, type=string, default=%
;     wildcard matched against databases, containing `%` and/or `_`
;
; :Keywords:
;   n_databases : out, optional, type=long
;     set to a named variable to retrieve the number of matching databases
;-
function mgdbmysql::list_dbs, wildcard, n_databases=n_databases
  compile_opt strictarr

  result = mg_mysql_list_dbs(self.connection, wildcard)
  query_result = self->_get_results(result, n_rows=n_databases)
  mg_mysql_free_result, result
  return, n_databases eq 0 ? [] : query_result.(0)
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
;   error_message : out, optional, type=string
;     MySQL error message
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

  self.host = n_elements(host) eq 0 ? 'localhost' : host
  _port = n_elements(port) eq 0 ? 0UL : port
  _socket = n_elements(socket) eq 0 ? '' : socket
  self.database = database

  flags = 0ULL

  self.connection = mg_mysql_init()
  if (self.connection eq 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif

  self.connection = mg_mysql_real_connect(self.connection, $
                                          self.host, user, password, $
                                          self.database, $
                                          _port, _socket, flags)
  if (self.connection eq 0) then begin
    error_message = self->last_error_message()
    mg_mysql_close, self.connection
    if (self.quiet || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif
end


;= overloaded operators

;+
; Returns a string describing the database.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     variable name
;-
function mgdbmysql::_overloadHelp, varname
  compile_opt strictarr

  if (self.connection ne 0L) then begin
    return, string(varname, self.host, self.database, format='(%"%-16s%s:%s")')
  endif else begin
    return, string(varname, format='(%"%-16snot connected")')
  endelse
end


;= property access

;+
; Set properties.
;-
pro mgdbmysql::setProperty, quiet=quiet
  compile_opt strictarr

  if (n_elements(quiet)) then self.quiet = quiet
end


;+
; Retrieve properties.
;-
pro mgdbmysql::getProperty, client_info=client_info, $
                            client_version=client_version, $
                            connected=connected
  compile_opt strictarr

  if (arg_present(client_info)) then client_info = mg_mysql_get_client_info()
  if (arg_present(client_version)) then version = mg_mysql_get_client_version()
  connected = self.connection ne 0ULL
end


;= lifecycle methods

;+
; Free resources, including closing database connection.
;-
pro mgdbmysql::cleanup
  compile_opt strictarr

  if (self.connection ne 0) then begin
    mg_mysql_close, self.connection
    self.connection = 0UL
  endif
end


;+
; Create database connection.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `setProperty`
;-
function mgdbmysql::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e

  return, 1
end


;+
; Define MySQL database class.
;
; :Fields:
;   connection
;     connection pointer
;   quiet
;     boolean whether to print error messages
;   enum_field_types
;     hash of codes to constant names
;-
pro mgdbmysql__define
  compile_opt strictarr

  define = { MGdbMySQL, inherits IDL_Object, $
             connection: 0ULL, $
             host: '', $
             database: '', $
             quiet: 0B, $
             enum_field_types: obj_new() $
           }
end


; main-level example

db = MGdbMySQL()
db->connect, user='mgalloy', password='passwd', database='testdb'

database_query = '%'
databases = db->list_dbs(database_query, n_databases=n_databases)
print, database_query, n_databases eq 0 ? '' : strjoin(databases, ', '), $
       format='(%"Databases matching ''%s'': %s\n")'

table_query = 'C%'
tables = db->list_tables(table_query, n_tables=n_tables)
print, table_query, n_tables eq 0 ? '' : strjoin(tables, ', '), $
       format='(%"Tables matching ''%s'': %s\n")'

car_results = db->query('select * from Cars', fields=fields)
print, fields.name, format='(%"%-3s %-10s %-6s")'
print, car_results, format='(%"%3d %10s %6d")'

image_results = db->query('select * from Images', fields=fields)

mg_image, reform(*image_results[0].data, 288, 216), /new_window

ptr_free, image_results[0].data

obj_destroy, db

end
