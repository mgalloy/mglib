; docformat = 'rst'


;+
; Send an email.
;
; Note: requires UNIX system with `mail` command in the `PATH`.
;
; :Params:
;   address : in, required, type=string
;     email address to send to
;   subject : in, required, type=string
;     subject of email
;   body : in, optional, type=string/strarr
;     text of body of email
;
; :Keywords:
;   filename : in, optional, type=boolean
;     set to indicate that `body` is a filename with contents to be used as the
;     body text, not that actual body text
;   error : out, optional, type=long
;     error status, 0 if no error
;-
pro mg_send_mail, address, subject, body, filename=filename, error=error
  compile_opt strictarr

  if (n_elements(body) eq 0L) then begin
    body_filename = '/dev/null'
  endif else begin
    if (keyword_set(filename)) then begin
      body_filename = body[0]
    endif else begin
      body_filename = mg_temp_filename('mg_send_mail-%s.txt')

      openw, lun, body_filename, /get_lun
      printf, lun, n_elements(body) gt 1L ? transpose(body) : body
      free_lun, lun
    endelse
  endelse

  cmd = string(subject, address, body_filename, $
               format='(%"mail -s ''%s'' %s < %s")')
  spawn, cmd, result, error_result, exit_status=error

  if (n_elements(body) gt 0L && ~keyword_set(filename)) then begin
    file_delete, body_filename
  endif
end
