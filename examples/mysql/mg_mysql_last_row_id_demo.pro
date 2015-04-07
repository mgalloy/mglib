; docformat = 'rst'

;+
; Simple demo to show inserting some values into a database table.
; `MG_MYSQL_CREATEDB_DEMO` must be run before this demo.
;
; Output of the program is::
;
;   IDL> mg_mysql_last_row_id_demo
;   The last inserted row id is: 3
;
; Results can be verified from the `mysql` command line::
;
;   mysql> select * from Writers;
;   +----+------------------+
;   | Id | Name             |
;   +----+------------------+
;   |  1 | Leo Tolstoy      |
;   |  2 | Jack London      |
;   |  3 | Honore de Balzac |
;   +----+------------------+
;   3 rows in set (0.00 sec)
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, optional, type=string, default=mgalloy
;     user to connect as
;   password : in, optional, type=string, default=passwd
;     password for user
;-
pro mg_mysql_last_row_id_demo, host=host, user=user, password=password
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

  cmds = ['DROP TABLE IF EXISTS Writers', $
          'CREATE TABLE Writers(Id INT PRIMARY KEY AUTO_INCREMENT, Name TEXT)', $
          'INSERT INTO Writers(Name) VALUES(''Leo Tolstoy'')', $
          'INSERT INTO Writers(Name) VALUES(''Jack London'')', $
          'INSERT INTO Writers(Name) VALUES(''Honore de Balzac'')']

  for c = 0L, n_elements(cmds) - 1L do begin
    if (mg_mysql_query(con, cmds[c]) ne 0) then begin
      error_msg = mg_mysql_error(con)
      mg_mysql_close, con
      message, 'CMD ' + cmds[c] + ': ' + error_msg
    endif
  endfor

  id = mg_mysql_insert_id(con)
  print, id, format='(%"The last inserted row id is: %d")'

  mg_mysql_close, con
end
