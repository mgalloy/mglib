; docformat = 'rst'

;+
; Simple demo to show inserting some values into a database table.
; `MG_MYSQL_INSERT_DEMO` must be run before this demo.
;
; The output of the program is::
;
;   IDL> mg_mysql_retrieve_demo
;     1 Audi              52642
;     2 Mercedes          57127
;     3 Skoda              9000
;     4 Volvo             29000
;     5 Bentley          350000
;     6 Citroen           21000
;     7 Hummer            41400
;     8 Volkswagen        21600
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
pro mg_mysql_retrieve_demo, host=host, user=user, password=password
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

  if (mg_mysql_query(con, 'select * from Cars') ne 0) then begin
    error_msg = mg_mysql_error(con)
    mg_mysql_close, con
    message, 'SELECT: ' + error_msg
  endif

  result = mg_mysql_store_result(con)
  if (result eq 0) then begin
    error_msg = mg_mysql_error(con)
    mg_mysql_close, con
    message, 'STORE: ' + error_msg
  endif

  n_fields = mg_mysql_num_fields(result)

  fields = replicate({ mg_mysql_field }, n_fields)
  for f = 0L, n_fields - 1L do begin
    fields[f] = mg_mysql_fetch_field(result)
  endfor
  print, fields.name, format='(%"%-3s %-15s %-7s")'

  row = mg_mysql_fetch_row(result)
  row_str = strarr(3)
  while (row ne 0) do begin
    for i = 0, n_fields - 1 do begin
      row_str[i] = mg_mysql_get_field(row, i)
    endfor
    print, row_str, format='(%"%3s %-15s %7s")'
    row = mg_mysql_fetch_row(result)
  endwhile

  mg_mysql_free_result, result
  mg_mysql_close, con
end
