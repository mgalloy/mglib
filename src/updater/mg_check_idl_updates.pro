; docformat = 'rst'

;+
; Check versions of IDL released since a given version of IDL. Starts with IDL
; 8.6.1.
;-

;+
; Return the width of the current terminal in number of columns. Defaults to 80
; if unable to find `MG_TERMCOLUMNS`.
;
; :Returns:
;   long
;-
function mg_check_idl_updates_termcolumns
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 80L
  endif

  return, mg_termcolumns()
end


;+
; Check versions of IDL released since a given version.
;
; :Keywords:
;   version : in, optional, type=string, default="current version"
;     version to check from in the form "8.7.1"
;   verbose : in, optional, type=boolean
;     set to display descriptions of the versions instead of just version
;     numbers and release dates
;-
pro mg_check_idl_updates, version=version, verbose=verbose
  compile_opt strictarr

  base_url = 'http://updates.harrisgeospatial.com/checkupdate.php'

  _version = n_elements(version) eq 0L ? !version.release : version
  url = string(base_url, !version.os, !version.arch, _version, $
               format='%s?platform=%s_%s&idl=%s')

  json_text = mg_get_url_content(url)
  response = json_parse(json_text)

  if (keyword_set(verbose)) then termcolumns = mg_check_idl_updates_termcolumns()

  for r = n_elements(response) - 1L, 0L, -1L do begin
    release = response[r]

    title = string(release["version"], release["date"], format='%-6s [%s]')
    print, title

    if (keyword_set(verbose)) then begin
      underline = string(bytarr(strlen(title)) + (byte('-'))[0])
      print, underline
      description = mg_strunmerge(release["description"])
      for d = 0L, n_elements(description) - 1L do begin
        description_line = mg_strwrap(description[d], $
                                      width=termcolumns, $
                                      indent=2, $
                                      first_indent=0)
        for i = 0L, n_elements(description_line) - 1L do begin
          print, description_line[i]
        endfor
      endfor
      if (r ne 0L) then print
    endif
  endfor
end

