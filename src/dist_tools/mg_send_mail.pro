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
;   html : in, optional, type=boolean
;     set to send an HTML email
;   from : in, optional, type=string
;     email address of sender; default is username at hostname
;   filename : in, optional, type=boolean
;     set to indicate that `body` is a filename with contents to be used as the
;     body text, not that actual body text
;   attachments : in, optional, type=strarr
;     filenames of attachments, not compatible with `/HTML`
;   error : out, optional, type=long
;     error status, 0 if no error
;-
pro mg_send_mail, address, subject, body, $
                  html=html, $
                  from=from, $
                  filename=filename, $
                  attachments=attachments, $
                  error=error
  compile_opt strictarr
  on_error, 2

  if ((n_elements(attachments) gt 0L) && keyword_set(html)) then begin
    message, 'ATTACHMENTS and HTML keywords are not compatible'
  endif

  _attachments = n_elements(attachments) eq 0L $
                   ? '' $
                   : (strjoin('-a ' + attachments, ' '))

  _from = n_elements(from) eq 0L ? '' : string(from, format='(%"-r %s")')

  if (keyword_set(html)) then begin
    _subject = string(subject, format='(%"%s\\nContent-Type: text/html")')
  endif else begin
    _subject = subject
  endelse

  mail_cmd = string(_subject, _attachments, _from, address, $
               format='(%"mail -s \"$(echo -e \"%s\")\" %s %s %s")')

  ; how to pipe to mail depends on whether a file or strarr
  if (keyword_set(filename)) then begin
    cmd = string(mail_cmd, body[0], format='(%"%s < %s")')
  endif else begin
    cmd = string(mg_strmerge(body), mail_cmd, format='(%"echo -e \"%s\" | %s")')
  endelse

  spawn, cmd, result, error_result, exit_status=error
end
