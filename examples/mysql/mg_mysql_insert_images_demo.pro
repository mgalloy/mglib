; docformat = 'rst'

;+
; Simple demo to show inserting some values into a database table.
; `MG_MYSQL_CREATEDB_DEMO` must be run before this demo.
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, optional, type=string, default=mgalloy
;     user to connect as
;   password : in, optional, type=string, default=passwd
;     password for user
;-
pro mg_mysql_insert_images_demo, host=host, user=user, password=password
  compile_opt strictarr
  on_error, 2

  _host = n_elements(host) eq 0 ? 'localhost' : host
  _user = n_elements(user) eq 0 ? 'mgalloy' : user
  _password = n_elements(password) eq 0 ? 'passwd' : password

  con = mg_mysql_init()
  if (con eq 0) then begin
    message, 'INIT: ' + mg_mysql_error(con)
  endif

  con = mg_mysql_real_connect(con, _host, _user, _password, 'testdb', 0UL, $
                              '', 0ULL)
  if (con eq 0) then begin
    error_msg = mg_mysql_error(con)
    mg_mysql_close, con
    message, 'CONNECT: ' + error_msg
  endif

  cmds = ['DROP TABLE IF EXISTS Images', $
          'CREATE TABLE Images(Id INT PRIMARY KEY, Data MEDIUMBLOB)']
  for c = 0L, n_elements(cmds) - 1L do begin
    if (mg_mysql_query(con, cmds[c]) ne 0) then begin
      error_msg = mg_mysql_error(con)
      mg_mysql_close, con
      message, 'CMD ' + cmds[c] + ': ' + error_msg
    endif
  endfor

  im = 255B - read_image(file_which('mineral.png'), r, g, b)
  im = mg_flatten(im)
  chunk = bytarr(2L * n_elements(im) +1L)
  chunk_length = mg_mysql_real_escape_string(con, chunk, im, ulong64(n_elements(im)))
  chunk = string(chunk)
  query = string(chunk, format='(%"INSERT INTO Images(Id, Data) VALUES(1, ''%s'')")')
  if (mg_mysql_real_query(con, query, strlen(query)) ne 0) then begin
    error_msg = mg_mysql_error(con)
    mg_mysql_close, con
    message, 'QUERY: ' + error_msg
  endif

  mg_mysql_close, con
end
