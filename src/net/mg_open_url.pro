; docformat = 'rst'

;+
; Open an URL in the default web browser. On Windows and Mac there is a
; standard method for doing this. On UNIX platforms, the first time this
; routine is called it will ask for the location of your preferred web browser
; and save this location in the `APP_USER_DIR` for `MG_OPEN_URL`.
;
; :Examples:
;    For example to open the IDL page on Exelis VIS' website in the default web
;    browser, do::
;
;       IDL> mg_open_url, 'http://exelisvis.com/IDL'
;
; :Params:
;    url : in, required, type=string
;       url to open in the default web browser
;
; :Keywords:
;    help_browser : in, optional, type=boolean
;       set to open URL in `ONLINE_HELP` application instead of default web
;       browser
;
; :Requires:
;    IDL 6.1
;
; :Author:
;    Michael Galloy, 2006
;-
pro mg_open_url, url, help_browser=helpBrowser
  compile_opt strictarr

  ; open in online help browser
  if (keyword_set(helpBrowser)) then begin
    tmpfilename = mg_filename('link-%d.html', /clock_basename, /tmp)

    openw, lun, tmpfilename, /get_lun
    printf, lun, '<HTML><HEAD><META HTTP-EQUIV="refresh" CONTENT="0; URL=' + URL + '"></HEAD>If this page does not refresh, click <A HREF="' + URL + '">here</A>.</HTML>'
    free_lun, lun

    online_help, book=tmpfilename

    return
  endif

  ; launch the default web browser with the url, unfortunately, this is
  ; platform dependent
  case !version.os_family of
    'Windows' : spawn, 'start ' + url, /hide, /nowait
    else : begin
      ; Mac OS X has a nice way of doing this...
      if (!version.os_name eq 'Mac OS X') then begin
        spawn, 'open ' + url
        return
      endif

      ; ...but the other UNIX platforms don't
      app_readme_text = $
        ['This is the configuration directory for MG_OPEN_URL ', $
         'routine. It is used to save the location of the default ', $
         'web browser between MG_OPEN_URL invocations on UNIX ', $
         'platforms.', $
         '', $
         'It is safe to remove this directory, as it', $
         'will be recreated on demand. Note that all', $
         'settings will revert to their default settings.']

      prefdir = app_user_dir('mg', $
                             'Michael Galloy', $
                             'default-browser', $
                             'Default browser location', $
                             app_readme_text, 1)
      preffile = filepath('default-browser', root=prefdir)

      if (file_test(preffile)) then begin
        openr, lun, preffile, /get_lun
        browser = ''
        readf, lun, browser
        free_lun, lun
        spawn, browser + ' ' + url
      endif else begin
        title = 'Choose the path to your web browser application...'
        browser_location = dialog_pickfile(title=title)
        openw, lun, preffile, /get_lun
        printf, lun, browser_location
        free_lun, lun
        msg = ['Your browser location has been stored in:', '', $
               '    ' + preffile, '']
        ok = dialog_message(msg, /info)
        spawn, browser_location + ' ' + url
      endelse
    end
  endcase
end
