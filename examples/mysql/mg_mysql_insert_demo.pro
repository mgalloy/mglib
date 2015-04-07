; docformat = 'rst'

;+
; Simple demo to show inserting some values into a database table.
;
; Results can be verified from the `mysql` command line::
;
;   mysql> use testdb;
;   Reading table information for completion of table and column names
;   You can turn off this feature to get a quicker startup with -A
;
;   Database changed
;   mysql> show tables;
;   +------------------+
;   | Tables_in_testdb |
;   +------------------+
;   | Cars             |
;   +------------------+
;   1 row in set (0.00 sec)
;
;   mysql> select * from cars;
;   +------+------------+--------+
;   | Id   | Name       | Price  |
;   +------+------------+--------+
;   |    1 | Audi       |  52642 |
;   |    2 | Mercedes   |  57127 |
;   |    3 | Skoda      |   9000 |
;   |    4 | Volvo      |  29000 |
;   |    5 | Bentley    | 350000 |
;   |    6 | Citroen    |  21000 |
;   |    7 | Hummer     |  41400 |
;   |    8 | Volkswagen |  21600 |
;   +------+------------+--------+
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, optional, type=string, default=mgalloy
;     user to connect as
;   password : in, optional, type=string, default=passwd
;     password for user
;-
pro mg_mysql_insert_demo, host=host, user=user, password=password
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
    mg_close, con
    message, 'CONNECT: ' + mg_mysql_error(con)
  endif

  cmds = ['DROP TABLE IF EXISTS Cars', $
          'CREATE TABLE Cars(Id INT, Name TEXT, Price INT)', $
          'INSERT INTO Cars VALUES(1,''Audi'',52642)', $
          'INSERT INTO Cars VALUES(2,''Mercedes'',57127)', $
          'INSERT INTO Cars VALUES(3,''Skoda'',9000)', $
          'INSERT INTO Cars VALUES(4,''Volvo'',29000)', $
          'INSERT INTO Cars VALUES(5,''Bentley'',350000)', $
          'INSERT INTO Cars VALUES(6,''Citroen'',21000)', $
          'INSERT INTO Cars VALUES(7,''Hummer'',41400)', $
          'INSERT INTO Cars VALUES(8,''Volkswagen'',21600)']

  for c = 0L, n_elements(cmds) - 1L do begin
    if (mg_mysql_query(con, cmds[c]) ne 0) then begin
      error_msg = mg_mysql_error(con)
      mg_mysql_close, con
      message, 'CMD ' + cmds[c] + ': ' + error_msg
    endif
  endfor

  mg_mysql_close, con
end
