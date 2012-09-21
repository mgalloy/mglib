; docformat = 'rst'


                  

; main-level example program

updater = obj_new('MGnetUpdate', url=url, current_version='3.1', $
                  relative_root='.')
needsUpdating = updater->checkForUpdates(releases=releases)

if (needsUpdating) then begin
  ; get listing of possibly multiple versions with release notes
  for r = 0L, n_elements(releases) do begin
    print, releases[r].title
    print, strjoin(strarr(strlen(releases[r].title)) + '-')
    print, releases[r].description
    print
  endfor
  
  ; get most recent update
  updater->update(version=releases[0].version)
endif 

obj_destroy, updater

end