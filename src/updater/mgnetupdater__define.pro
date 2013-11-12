; docformat = 'rst'


function mgnetupdater::check_for_updates, releases=releases
  compile_opt strictarr

  ; get releases from URL
  ; parse string
  ; return
end


pro mgnetupdater::cleanup
  compile_opt strictarr

end


function mgnetupdater::init, url=url, current_version=current_version, beta_releases=beta_releases
  compile_opt strictarr

  self.url = url
  self.current_version = current_version

  return, 1
end


pro mgnetupdater__define
  compile_opt strictarr

  define = { mgnetupdater, $
             url: '', $
             current_version: '' $
           }
end


; main-level example program

url = 'https://raw.github.com/mgalloy/idldoc/master/RELEASE.rst'
updater = obj_new('MGnetUpdater', url=url, current_version='3.1')
needs_updating = updater->check_for_updates(releases=releases)

if (needs_updating) then begin
  ; get listing of possibly multiple versions with release notes
  for r = 0L, n_elements(releases) do begin
    print, releases[r].title
    print, strjoin(strarr(strlen(releases[r].title)) + '-')
    print, releases[r].date
    print
    print, releases[r].description
    print
  endfor
endif

obj_destroy, updater

end
