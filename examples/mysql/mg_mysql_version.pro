; docformat = 'rst'

;+
; Returns the MySQL version.
;-
pro mg_mysql_version
  compile_opt strictarr

  print, mg_mysql_get_client_info(), format='(%"MySQL client version: %s")'
end
