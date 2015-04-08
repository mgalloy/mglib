; docformat = 'rst'

;+
; Simple demo to show inserting some values into a database table.
; `MG_MYSQL_INSERT_IMAGES_DEMO` must be run before this demo.
;
; :Keywords:
;   host : in, optional, type=string, default=localhost
;     host to connect to
;   user : in, optional, type=string, default=mgalloy
;     user to connect as
;   password : in, optional, type=string, default=passwd
;     password for user
;-
pro mg_mysql_retrieve_images_demo, host=host, user=user, password=password
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

  if (mg_mysql_query(con, 'select Data from Images WHERE Id=1') ne 0) then begin
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

  row = mg_mysql_fetch_row(result)
  lengths = mg_mysql_fetch_lengths(result)
  n_rows = mg_mysql_num_rows(result)

  print, n_rows, n_rows eq 1 ? '' : 's', lengths[0], $
         format='(%"found %d image%s with length %d bytes")'
  im = mg_mysql_get_blobfield(row, 0, lengths[0])
  im = reform(im, 288, 216)
  mg_image, im, /new_window, title='Image retrieved from DB...'

  mg_mysql_free_result, result
  mg_mysql_close, con
end
