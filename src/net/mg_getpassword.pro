; docformat = 'rst'

;+
; Get a password from the command line. Shows asterisks instead of the actual
; password.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_getpassword
;
;    This does the following::
;
;       IDL> password = mg_getpassword(prompt='Password:')
;       Password: *******************
;       IDL> print, password, format='(%"Password = \"%s\"")'
;       Password = "this is my password"
;
; :Returns:
;    string
;
; :Keywords:
;    prompt : in, optional, type=string
;       prompt to display before the password is typed
;-
function mg_getpassword, prompt=prompt
  compile_opt strictarr

  _prompt = n_elements(prompt) eq 0L ? '' : (prompt + ' ')
  print, _prompt, format='(A, $)'

  ch = ''
  result = ''
  while (1B) do begin
    ch = get_kbrd()
    if (byte(ch) eq 10B) then break
    print, '*', format='(A1, $)'
    result += ch
  endwhile

  print

  return, result
end


; main-level example program

password = mg_getpassword(prompt='Password:')
print, password, format='(%"Password = \"%s\"")'

end
