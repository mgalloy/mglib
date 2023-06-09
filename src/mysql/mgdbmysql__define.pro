; docformat = 'rst'

;+
; Higher-level wrapper for direct MySQL bindings.
;
; :Examples:
;   An example MySQL database would need to first create the database object::
;
;     db = MGdbMySQL()
;
;   Before connecting, it might be needed to set some options on the
;   connections, for example to change the authentication method::
;
;     db->setProperty, mysql_secure_auth=0
;
;   Next, we connect to the database::
;
;     db->connect, user='mgalloy', password='passwd', database='testdb'
;
;   At this point, it is possible to query properties of the connection::
;
;     db->getProperty, proto_info=proto_info, $
;                      host_info=host_info, $
;                      server_info=server_info, $
;                      server_version=server_version
;     help, proto_info, host_info, server_info, server_version
;
;   We can list the databases available::
;
;     database_query = '%'
;     databases = db->list_dbs(database_query, n_databases=n_databases)
;     print, database_query, n_databases eq 0 ? '' : strjoin(databases, ', '), $
;            format='(%"Databases matching ''%s'': %s\n")'
;
;   As well as the tables available in the current database::
;
;     table_query = 'C%'
;     tables = db->list_tables(table_query, n_tables=n_tables)
;     print, table_query, n_tables eq 0 ? '' : strjoin(tables, ', '), $
;            format='(%"Tables matching ''%s'': %s\n")'
;
;   The `::query` method returns an array of structures containing the data::
;
;     car_results = db->query('select * from Cars', fields=fields)
;     print, fields.name, format='(%"%-3s %-10s %-6s")'
;     print, car_results, format='(%"%3d %10s %6d")'
;
;   Blobs are returned as pointers to a byte data array (which will have to be
;   `REFORM`-ed to the correct size and converted to the correct data type)::
;
;     image_results = db->query('select * from Images', fields=fields)
;     mg_image, reform(*image_results[0].data, 288, 216), /new_window
;
;   Cleanup the array of structures containing a pointer and the database
;   object::
;
;     heap_free, image_results
;     obj_destroy, db
;
;   Note: it is often necessary to restore a byte vector to another data type.
;   Here is an example of doing the conversion both ways::
;
;     IDL> d = dist(5)
;     IDL> b = byte(d, 0, 25 * 4)
;     IDL> f = reform(float(b, 0, 25), 5, 5)
;     IDL> print, array_equal(d, f, /no_typeconv)
;        1
;     IDL> print, array_equal(size(d, /dimensions), size(f, /dimensions))
;        1
;
; :Properties:
;   quiet
;     indicates whether error messages should be printed
;   client_info : type=string
;     version string
;   client_version : type=ulong64
;     version
;   host_name : type=string
;     host, must be retrieved after connecting
;   database : type=string
;     current database name
;   connected : type=byte
;     whether the database is connected
;   mysql_secure_auth : type=byte
;     whether to use secure authentication, must be set before connecting
;   mysql_opt_protocol : type=int
;     which protocol to use, must be set before connecting
;   proto_info : type=ulong
;     protocol information, must be retrieved after conecting
;   host_info : type=string
;     host infomration, must be retrieved after conecting
;   server_info : type=string
;     server information, must be retrieved after conecting
;   server_version : type=ulong64
;     server version, must be retrieved after conecting
;   last_command_info : type=string
;     information about the last SQL command issued
;-


;= reporting methods to be implemented by superclasses

;+
; Hook for superclasses.
;
; :Params:
;   sql_statement : in, required, type=string
;     SQL statement to report
;-
pro mgdbmysql::report_statement, sql_statement
  compile_opt strictarr
end


;+
; Hook for superclasses.
;
; :Keywords:
;   sql_statement : in, required, type=string
;     SQL statement
;   status : in, required, type=long
;      status code from the statement, 0 for success
;   error_message : in, required, type=string
;      MySQL error message; "Success" if not error
;-
pro mgdbmysql::report_error, sql_statement=sql_cmd, $
                             status=status, $
                             error_message=error_message
  compile_opt strictarr
end


;+
; Hook for superclasses.
;
; :Keywords:
;   n_warnings : in, required, type=long
;     number of warnings
;-
pro mgdbmysql::report_warnings, sql_statement=sql_cmd, n_warnings=n_warnings
  compile_opt strictarr
end


;= helper methods

;+
; Does the `mysql_init` call, returning whether the the MySQL API is found.
;
; :Private:
;
; :Returns:
;   1 for success, 0 for failure
;-
function mgdbmysql::_init
  compile_opt strictarr

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    return, 0
  endif

  self.connection = mg_mysql_init()
  return, 1
end

;+
; Gives the name of an `enum_field_type` value.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   code : in, required, type=integer
;     `enum_field_type`
;-
function mgdbmysql::_lookup_field_type, code
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
    1: return, 0B     ; MYSQL_TYPE_TINY1
    2: return, 0S     ; MYSQL_TYPE_SHORT
    3: return, 0L     ; MYSQL_TYPE_LONG
    4: return, 0.0    ; MYSQL_TYPE_FLOAT
    5: return, 0.0D   ; MYSQL_TYPE_DOUBLE
    7: return, ''     ; MYSQL_TYPE_TIMESTAMP
    8: return, 0ULL   ; MYSQL_TYPE_LONGLONG
    9: return, 0L     ; MYSQL_TYPE_INT24
    10: return, ''    ; MYSQL_TYPE_DATE
    12: return, ''    ; MYSQL_TYPE_DATETIME
    252: begin        ; MYSQL_TYPE_BLOB
        if (field.charsetnr eq 33) then begin
          return, ''
        endif else begin
          return, ptr_new()
        endelse
      end
    253: return, ''   ; MYSQL_TYPE_VARSTRING
    254: return, ''   ; MYSQL_TYPE_STRING
    else: message, 'unsupported type: ' + strtrim(field.type, 2)
  endcase
end


;+
; Helper method to return a result set.
;
; :Private:
;
; :Returns:
;   array of structures
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

  field = {}
  n_rows = 0ULL

  if (result eq 0) then return, {}

  n_rows = mg_mysql_num_rows(result)
  n_fields = mg_mysql_num_fields(result)

  if (n_rows eq 0) then return, {}

  fields = replicate({ mg_mysql_field }, n_fields)
  for f = 0L, n_fields - 1L do begin
    fields[f] = mg_mysql_fetch_field(result)
  endfor

  row_result = create_struct(idl_validname(fields[0].name, /convert_all), $
                             self->_get_type(fields[0]))
  for f = 1L, n_fields - 1L do begin
    field_name = strupcase(fields[f].name)
    while (total(tag_names(row_result) eq field_name, /integer) gt 0L) do begin
      field_name = '_' + field_name
    endwhile
    row_result = create_struct(row_result, $
                               field_name, self->_get_type(fields[f]))
  endfor

  query_result = replicate(row_result, n_rows)

  ; must allocate ptr columns
  for f = 0L, n_fields - 1L do begin
    if (size(self->_get_type(fields[f]), /type) eq 10) then begin
      query_result.(f) = ptrarr(n_rows, /allocate_heap)
    endif
  endfor

  ; populate result
  for r = 0L, n_rows - 1L do begin
    row = mg_mysql_fetch_row(result)
    lengths = mg_mysql_fetch_lengths(result)
    for f = 0L, n_fields - 1L do begin
      _result = mg_mysql_get_field(row, f)
      case size(row_result.(f), /type) of
        1: query_result[r].(f) = byte(fix(_result))
        2: query_result[r].(f) = fix(_result)
        3: query_result[r].(f) = long(_result)
        4: query_result[r].(f) = _result eq '' ? !values.f_nan : float(_result)
        5: query_result[r].(f) = _result eq '' ? !values.d_nan : double(_result)
        7: query_result[r].(f) = _result
        10: begin
            if (lengths[f] gt 0) then begin
              *query_result[r].(f) = mg_mysql_get_blobfield(row, f, lengths[f])
            endif
          end
        15: query_result[r].(f) = ulong64(_result)
      endcase
    endfor
  endfor

  return, query_result
end


;= API

;+
; Creates a properly escaped string from any numeric array.
;
; :Returns:
;   string
;
; :Params:
;   from : in, required, type=numeric/string
;     variable
;-
function mgdbmysql::escape_string, from
  compile_opt strictarr

  if (n_elements(from) eq 0L) then return, 'NULL'

  n_bytes = mg_typesize(size(from, /type)) * n_elements(from)
  to = bytarr(2 * n_bytes + 1)
  n_bytes_to = mg_mysql_real_escape_string(self.connection, to, from, n_bytes)
  return, string(to[0:n_bytes_to - 1])
end


;+
; Returns the error message for the last failed MySQL API routine.
;
; :Returns:
;   string of error message
;-
function mgdbmysql::last_error_message
  compile_opt strictarr

  return, mg_mysql_error(self.connection)
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
;   arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
;   arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18,
;   arg19, arg20 : in, optional, type=any
;     arguments to be substituted into `sql_query`
;
; :Keywords:
;   sql_statement : out, optional, type=string
;     set to a named variable to retrieve the statement that was used
;   fields : out, optional, type=array of structures
;     array of structures defining each field of the return value
;   status : out, optional, type=long
;     set to a named variable to retrieve the status code from the
;     query, 0 for success
;   error_message : out, optional, type=string
;     MySQL error message; "Success" if not error
;   n_affected_rows : out, optional, type=ulong64
;     set to a named variable to retrieve the number of rows affected by the
;     operation
;   n_warnings : out, optional, type=ulong
;     set to a named variable to retrieve the number of warnings generated
;     during the query
;-
function mgdbmysql::query, sql_query, $
                           arg1, arg2, arg3, arg4, arg5, $
                           arg6, arg7, arg8, arg9, arg10, $
                           arg11, arg12, arg13, arg14, arg15, $
                           arg16, arg17, arg18, arg19, arg20, $
                           sql_statement=_sql_query, $
                           fields=fields, $
                           status=status, $
                           error_message=error_message, $
                           n_affected_rows=n_affected_rows, $
                           n_warnings=n_warnings, $
                           count=count
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_fmt
  count = 0L

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
    14: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, format='(%"' + sql_query + '")')
    15: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, format='(%"' + sql_query + '")')
    16: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, format='(%"' + sql_query + '")')
    17: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, format='(%"' + sql_query + '")')
    18: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, format='(%"' + sql_query + '")')
    19: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, format='(%"' + sql_query + '")')
    20: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, format='(%"' + sql_query + '")')
    21: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, format='(%"' + sql_query + '")')
  endcase

  self->report_statement, _sql_query
  status = mg_mysql_query(self.connection, _sql_query)
  if (status ne 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      query_result = !null
      goto, reporting
    endif else begin
      message, error_message
    endelse
  endif else error_message = 'Success'

  result = mg_mysql_store_result(self.connection)
  if (result eq 0) then begin
    error_message = self->last_error_message()
    status = 1L
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

  query_result = self->_get_results(result, fields=fields, n_rows=count)

  mg_mysql_free_result, result

  if (arg_present(n_affected_rows)) then begin
    n_affected_rows = mg_mysql_affected_rows(self.connection)
  endif

  reporting:
  n_warnings = mg_mysql_warning_count(self.connection)

  self->report_error, sql_statement=_sql_query, $
                      status=status, $
                      error_message=error_message
  self->report_warnings, sql_statement=_sql_query, n_warnings=n_warnings

  return, query_result

  bad_fmt:
  status = 1
  error_message = !error_state.msg
  _sql_query = '<undefined>'
  fields = !null
  n_affected_rows = 0ULL
  n_warnings = 0UL
  return, !null
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
;   arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
;   arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 : in, optional, type=any
;     arguments to be substituted into `sql_query`
;
; :Keywords:
;   sql_statement : out, optional, type=string
;     set to a named variable to retrieve the statement that was used
;   status : out, optional, type=long
;     set to a named variable to retrieve the status code from the
;     query, 0 for success
;   error_message : out, optional, type=string
;     MySQL error message; "Success" if not error
;   n_affected_rows : out, optional, type=ulong64
;     set to a named variable to retrieve the number of rows affected by the
;     operation
;   n_warnings : out, optional, type=ulong
;     set to a named variable to retrieve the number of warnings generated
;     during the query
;-
pro mgdbmysql::execute, sql_query, $
                        arg1, arg2, arg3, arg4, arg5, $
                        arg6, arg7, arg8, arg9, arg10, $
                        arg11, arg12, arg13, arg14, arg15, $
                        arg16, arg17, arg18, arg19, arg20, $
                        arg21, arg22, arg23, arg24, arg25, $
                        arg26, arg27, arg28, arg29, arg30, $
                        arg31, arg32, arg33, arg34, arg35, $
                        arg36, arg37, arg38, arg39, arg40, $
                        arg41, arg42, arg43, arg44, arg45, $
                        arg46, arg47, arg48, arg49, arg50, $
                        arg51, arg52, arg53, arg54, arg55, $
                        arg56, arg57, arg58, arg59, arg60, $
                        arg61, arg62, arg63, arg64, arg65, $
                        arg66, arg67, arg68, arg69, arg70, $
                        arg71, arg72, arg73, arg74, arg75, $
                        sql_statement=_sql_query, $
                        status=status, $
                        error_message=error_message, $
                        n_affected_rows=n_affected_rows, $
                        n_warnings=n_warnings
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_fmt

  n_warnings = 0UL
  sql_query_fmt = '(%"' + sql_query + '")'
  case n_params() of
     0: _sql_query = ''
     1: _sql_query = sql_query
     2: _sql_query = string(arg1, format=sql_query_fmt)
     3: _sql_query = string(arg1, arg2, format=sql_query_fmt)
     4: _sql_query = string(arg1, arg2, arg3, format=sql_query_fmt)
     5: _sql_query = string(arg1, arg2, arg3, arg4, format=sql_query_fmt)
     6: _sql_query = string(arg1, arg2, arg3, arg4, arg5, format=sql_query_fmt)
     7: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, $
                            format=sql_query_fmt)
     8: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, $
                            format=sql_query_fmt)
     9: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            format=sql_query_fmt)
    10: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, $
                            format=sql_query_fmt)
    11: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, $
                            format=sql_query_fmt)
    12: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, $
                            format=sql_query_fmt)
    13: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, $
                            format=sql_query_fmt)
    14: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, $
                            format=sql_query_fmt)
    15: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, $
                            format=sql_query_fmt)
    16: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            format=sql_query_fmt)
    17: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, $
                            format=sql_query_fmt)
    18: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, $
                            format=sql_query_fmt)
    19: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, $
                            format=sql_query_fmt)
    20: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, $
                            format=sql_query_fmt)
    21: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, $
                            format=sql_query_fmt)
    22: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, $
                            format=sql_query_fmt)
    23: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            format=sql_query_fmt)
    24: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, $
                            format=sql_query_fmt)
    25: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, $
                            format=sql_query_fmt)
    26: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, $
                            format=sql_query_fmt)
    27: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, $
                            format=sql_query_fmt)
    28: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, $
                            format=sql_query_fmt)
    29: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, $
                            format=sql_query_fmt)
    30: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            format=sql_query_fmt)
    31: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, $
                            format=sql_query_fmt)
    32: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, $
                            format=sql_query_fmt)
    33: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, $
                            format=sql_query_fmt)
    34: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, $
                            format=sql_query_fmt)
    35: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, $
                            format=sql_query_fmt)
    36: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, $
                            format=sql_query_fmt)
    37: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            format=sql_query_fmt)
    38: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, $
                            format=sql_query_fmt)
    39: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, $
                            format=sql_query_fmt)
    40: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, $
                            format=sql_query_fmt)
    41: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, $
                            format=sql_query_fmt)
    42: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, $
                            format=sql_query_fmt)
    43: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, $
                            format=sql_query_fmt)
    44: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            format=sql_query_fmt)
    45: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, $
                            format=sql_query_fmt)
    46: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, $
                            format=sql_query_fmt)
    47: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, $
                            format=sql_query_fmt)
    48: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, $
                            format=sql_query_fmt)
    49: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, $
                            format=sql_query_fmt)
    50: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, $
                            format=sql_query_fmt)
    51: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            format=sql_query_fmt)
    52: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, $
                            format=sql_query_fmt)
    53: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, $
                            format=sql_query_fmt)
    54: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, $
                            format=sql_query_fmt)
    55: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, $
                            format=sql_query_fmt)
    56: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, $
                            format=sql_query_fmt)
    57: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, $
                            format=sql_query_fmt)
    58: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            format=sql_query_fmt)
    59: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, $
                            format=sql_query_fmt)
    60: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, $
                            format=sql_query_fmt)
    61: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, $
                            format=sql_query_fmt)
    62: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, $
                            format=sql_query_fmt)
    63: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, $
                            format=sql_query_fmt)
    64: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, $
                            format=sql_query_fmt)
    65: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            format=sql_query_fmt)
    66: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, $
                            format=sql_query_fmt)
    67: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, $
                            format=sql_query_fmt)
    68: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, $
                            format=sql_query_fmt)
    69: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, $
                            format=sql_query_fmt)
    70: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, $
                            format=sql_query_fmt)
    71: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, $
                            format=sql_query_fmt)
    72: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, arg71, $
                            format=sql_query_fmt)
    73: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, arg71, $
                            arg72, $
                            format=sql_query_fmt)
    74: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, arg71, $
                            arg72, arg73, $
                            format=sql_query_fmt)
    75: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, arg71, $
                            arg72, arg73, arg74, $
                            format=sql_query_fmt)
    76: _sql_query = string(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, $
                            arg9, arg10, arg11, arg12, arg13, arg14, arg15, $
                            arg16, arg17, arg18, arg19, arg20, arg21, arg22, $
                            arg23, arg24, arg25, arg26, arg27, arg28, arg29, $
                            arg30, arg31, arg32, arg33, arg34, arg35, arg36, $
                            arg37, arg38, arg39, arg40, arg41, arg42, arg43, $
                            arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
                            arg51, arg52, arg53, arg54, arg55, arg56, arg57, $
                            arg58, arg59, arg60, arg61, arg62, arg63, arg64, $
                            arg65, arg66, arg67, arg68, arg69, arg70, arg71, $
                            arg72, arg73, arg74, arg76, $
                            format=sql_query_fmt)
  endcase

  self->report_statement, _sql_query
  status = mg_mysql_query(self.connection, _sql_query)
  if (status ne 0) then begin
    error_message = self->last_error_message()
    if (~self.quiet && ~arg_present(status) && ~arg_present(error_message)) then begin
      message, error_message
    endif
  endif else begin
    error_message = 'Success'
  endelse

  if (status eq 0L && arg_present(n_affected_rows)) then begin
    n_affected_rows = mg_mysql_affected_rows(self.connection)
  endif

  n_warnings = mg_mysql_warning_count(self.connection)
  self->report_error, sql_statement=_sql_query, $
                      status=status, $
                      error_message=error_message
  self->report_warnings, sql_statement=_sql_query, n_warnings=n_warnings

  return

  bad_fmt:
  status = 1
  error_message = !error_state.msg
  _sql_query = '<undefined>'
  n_affected_rows = 0ULL
  n_warnings = 0UL
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
;   status : out, optional, type=long
;     set to a named variable to retrieve the status code from the
;     query, 0 for success
;   error_message : out, optional, type=string
;     MySQL error message; "Success" if not error
;-
function mgdbmysql::list_tables, wildcard, $
                                 n_tables=n_tables, $
                                 status=status, $
                                 error_message=error_message
  compile_opt strictarr

  status = 0L
  error_message = 'Success'

  result = mg_mysql_list_tables(self.connection, wildcard)
  if (result eq 0) then begin
    status = 1L
    error_message = self->last_error_message()
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

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
;   status : out, optional, type=long
;     set to a named variable to retrieve the status code from the
;     query, 0 for success
;   error_message : out, optional, type=string
;     MySQL error message; "Success" if not error
;-
function mgdbmysql::list_dbs, wildcard, $
                              n_databases=n_databases, $
                              status=status, $
                              error_message=error_message
  compile_opt strictarr

  status = 0L
  error_message = 'Success'

  result = mg_mysql_list_dbs(self.connection, wildcard)
  if (result eq 0) then begin
    status = 1L
    error_message = self->last_error_message()
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      return, !null
    endif else begin
      message, error_message
    endelse
  endif

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
;   database : in, optional, type=string
;     database to connect to
;   port : in, optional, type=ulong, default=0UL
;     port to use
;   socket : in, optional, type=string
;     socket or named pipe to use
;   config_filename : in, optional, type=string
;     filename of configuration file that contains connection information;
;     keywords to this routine override the values in the configuration file
;   config_section : in, optional, type=string, default=''
;     name of section in `config_filename` containing connection information;
;     this section must contain `user` and `password` with optional values
;     for `host`, `database`, `port`, and `socket`
;   multi_statements : in, optional, type=boolean
;     set to allow multiple statements separated by ";"
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the connection, 0 for
;     success; if not 0, `ERROR_MESSAGE` should be set to a non-empty message
;   error_message : out, optional, type=string
;     set to a named variable to retrieve an MySQL error message
;-
pro mgdbmysql::connect, host=host, $
                        user=user, $
                        password=password, $
                        database=database, $
                        port=port, $
                        socket=socket, $
                        config_filename=config_filename, $
                        config_section=config_section, $
                        multi_statements=multi_statements, $
                        status=status, $
                        error_message=error_message
  compile_opt strictarr
  on_error, 2

  status = 0L
  error_message = 'Success'
  self.connected = 0B

  if (n_elements(config_filename) gt 0) then begin
    c = mg_read_config(config_filename)
    if (n_elements(config_section) gt 0 && config_section ne '') then begin
      if (~c->has_section(config_section)) then begin
        msg = string(config_section, $
                     format='(%"CONFIG_SECTION %s not found")')
        if (arg_present(status) || arg_present(error_message)) then begin
          status = 1L
          error_message = msg
        endif else begin
          message, msg
        endelse
      endif
    endif

    self.host = n_elements(host) eq 0 $
                  ? c->get('host', section=config_section, default='localhost') $
                  : host
    _port = n_elements(port) eq 0 $
              ? ulong(c->get('port', section=config_section, default=0)) $
              : port
    _socket = n_elements(socket) eq 0 $
                ? c->get('socket', section=config_section, default='') $
                : socket
    self.database = n_elements(database) eq 0 $
                      ? c->get('database', section=config_section, default='') $
                      : database

    _user = c->get('user', section=config_section, found=user_found)
    _user = n_elements(user) gt 0 ? user : _user
    if (~user_found && n_elements(user) eq 0) then begin
      msg = 'USER required'
      if (arg_present(status) || arg_present(error_message)) then begin
        status = 1L
        error_message = msg
      endif else begin
        message, msg
      endelse
    endif

    _password = c->get('password', section=config_section, found=password_found)
    _password = n_elements(password) gt 0 ? password : _password
    if (~password_found && n_elements(password) eq 0) then begin
      msg = 'PASSWORD required'
      if (arg_present(status) || arg_present(error_message)) then begin
        status = 1L
        error_message = msg
      endif else begin
        message, msg
      endelse
    endif
  endif else begin
    self.host = n_elements(host) eq 0 ? 'localhost' : host
    _port = n_elements(port) eq 0 ? 0UL : port
    _socket = n_elements(socket) eq 0 ? '' : socket
    self.database = n_elements(database) eq 0 ? '' : database
    _user = user
    _password = password
  endelse

  flags = 0ULL
  if (keyword_set(multi_statements)) then flags or= ishft(1ULL, 16)

  tmp = mg_mysql_real_connect(self.connection, $
                              self.host, _user, _password, $
                              self.database, $
                              _port, _socket, flags)
  if (tmp eq 0UL) then begin
    error_message = self->last_error_message()
    mg_mysql_close, self.connection
    self.connection = 0UL
    status = 1L
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      return
    endif else begin
      message, error_message
    endelse
  endif

  self.connected = 1B
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


;+
; Returns a string array giving either the available databases or tables,
; depending on whether the database is currently set.
;
; :Returns:
;   string
;-
function mgdbmysql::_overloadPrint
  compile_opt strictarr

  if (self.database eq '') then begin
    databases = transpose(['Available databases:', '  ' + self->list_dbs()])
    return, databases
  endif else begin
    tables = transpose([string(self.database, $
                               format='(%"Available tables for %s:")'), $
                        '  ' + self->list_tables()])
    return, tables
  endelse
end


;= property access

;+
; Set properties.
;-
pro mgdbmysql::setProperty, quiet=quiet, $
                            mysql_secure_auth=mysql_secure_auth, $
                            mysql_opt_protocol=mysql_opt_protocol, $
                            database=database
  compile_opt strictarr

  if (n_elements(quiet)) then self.quiet = quiet

  if (n_elements(mysql_opt_protocol) gt 0) then begin
    status = mg_mysql_options(self.connection, 9UL, ulong(mysql_opt_protocol[0]))
  endif

  if (n_elements(mysql_secure_auth) gt 0) then begin
    status = mg_mysql_options(self.connection, 18UL, byte(mysql_secure_auth[0]))
  endif

  if (n_elements(database) gt 0) then begin
    self.database = database
    status = mg_mysql_select_db(self.connection, self.database)
  endif
end


;+
; Retrieve properties.
;-
pro mgdbmysql::getProperty, quiet=quiet, $
                            client_info=client_info, $
                            client_version=client_version, $
                            connected=connected, $
                            proto_info=proto_info, $
                            host_info=host_info, $
                            server_info=server_info, $
                            server_version=server_version, $
                            last_command_info=last_command_info, $
                            database=database, $
                            host_name=host_name, $
                            connection=connection
  compile_opt strictarr

  quiet = self.quiet
  if (arg_present(client_info)) then client_info = mg_mysql_get_client_info()
  if (arg_present(client_version)) then client_version = mg_mysql_get_client_version()
  connected = self.connected
  if (arg_present(proto_info)) then proto_info = mg_mysql_get_proto_info(self.connection)
  if (arg_present(host_info)) then host_info = mg_mysql_get_host_info(self.connection)
  if (arg_present(server_info)) then server_info = mg_mysql_get_server_info(self.connection)
  if (arg_present(server_version)) then server_version = mg_mysql_get_server_version(self.connection)
  if (arg_present(last_command_info)) then last_command_info = mg_mysql_info(self.connection)
  database = self.database
  host_name = self.host
  connection = self.connection
end


;= lifecycle methods

;+
; Free resources, including closing database connection.
;-
pro mgdbmysql::cleanup
  compile_opt strictarr

  if (self.connection ne 0UL) then begin
    mg_mysql_close, self.connection
    self.connection = 0UL
    self.connected = 0B
  endif
end


;+
; Create database connection.
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status code from the
;     query, 0 for success
;   error_message : out, optional, type=string
;     MySQL error message
;   _extra : in, optional, type=keywords
;     keywords to `setProperty`
;-
function mgdbmysql::init, status=status, error_message=error_message, _extra=e
  compile_opt strictarr
  on_error, 2

  self.connected = 0B

  if (self->_init() ne 1) then begin
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      status = 1L
      error_message = !error_state.msg

      return, 0
    endif else begin
      message, !error_state.msg
    endelse
  endif

  if (self.connection eq 0) then begin
    error_message = self->last_error_message()
    if (self.quiet || arg_present(status) || arg_present(error_message)) then begin
      status = 1L
      return, 0
    endif else begin
      message, error_message
    endelse
  endif

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
             connected: 0B, $
             host: '', $
             database: '', $
             quiet: 0B, $
             enum_field_types: obj_new() $
           }
end


; main-level example

db = MGdbMySQL()
db->connect, user='mgalloy', password='passwd', database='testdb'
db->getProperty, proto_info=proto_info, $
                 host_info=host_info, $
                 server_info=server_info, $
                 server_version=server_version
print, proto_info, format='(%"Proto info: %d")'
print, host_info, format='(%"Host info: %s")'
print, server_info, format='(%"Server info: %s")'
print, server_version, format='(%"Server version: %d")'

print

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

heap_free, image_results
obj_destroy, db

end
