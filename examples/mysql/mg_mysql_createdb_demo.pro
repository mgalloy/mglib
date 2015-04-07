; docformat = 'rst'

;+
; Simple example to create a MySQL database called "testdb".
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, optional, type=string, default=mgalloy
;     user to connect as
;   password : in, optional, type=string, default=passwd
;     password for user
;-
pro mg_mysql_createdb_demo, host=host, user=user, password=password
  compile_opt strictarr
  on_error, 2

  _host = n_elements(host) eq 0 ? 'localhost' : host
  _user = n_elements(user) eq 0 ? 'mgalloy' : user
  _password = n_elements(password) eq 0 ? 'passwd' : password

  con = mg_mysql_init()
  if (con eq 0) then begin
    message, 'INIT: ' + mg_mysql_error(con)
  endif

  con = mg_mysql_real_connect(con, _host, _user, _password, '', 0UL, '', 0ULL)
  if (con eq 0) then begin
    message, 'CONNECT: ' + mg_mysql_error(con)
  endif

  status = mg_mysql_query(con, 'CREATE DATABASE testdb')
  if (status ne 0) then begin
    message, 'QUERY: ' + mg_mysql_error(con)
  endif

  mg_mysql_close, con
end

