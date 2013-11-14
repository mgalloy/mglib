; docformat = 'rst'

;+
; :Private:
;-
function mg_updater_getdate, line
  compile_opt strictarr

  re = '(\*)?(Released)?[[:space:]]+([^*]+)(\*)?'
  tokens = stregex(line, re, /subexpr, /extract)
  return, tokens[3]
end


;+
; :Private:
;-
function mg_updater_getversion, line, name=name
  compile_opt strictarr

  re = string(name, '(%"(%s)?[[:space:]]+(.+)")')
  tokens = stregex(line, re, /subexpr, /extract)
  return, tokens[2]
end


;+
; :Private:
;-
function mg_updater_parser, content, name=name
  compile_opt strictarr

  n_lines = n_elements(content)
  release_lines = stregex(content, '^--', /boolean)
  release_line_numbers = where(release_lines, n_releases)
  if (n_releases eq 0L) then return, !null

  release_line_numbers = [release_line_numbers, n_lines + 2L]

  releases = replicate({ version: '', date: '', description: '' }, n_releases)

  for r = 0L, n_releases - 1L do begin
    version_line = content[release_line_numbers[r] - 1L]
    releases[r].version = mg_updater_getversion(version_line, name=name)

    date_line = content[release_line_numbers[r] + 1L]
    releases[r].date = mg_updater_getdate(date_line)

    start_line = release_line_numbers[r] + 3L
    end_line = release_line_numbers[r + 1] - 3L
    releases[r].description = mg_strmerge(content[start_line:end_line])
  endfor

  return, releases
end


;+
; Reads release notes available via a URL to determine if there are new versions
; available.
;
; :Returns:
;   1 if needs to be updated, 0 if not
;
; :Params:
;   url : in, required, type=string
;     URL to check for releases notes
;
; :Keywords:
;   current_version : in, optional, type=string, default='0.0'
;     current version to check if there are later releases
;   name : in, optional, type=string, default=''
;     name of distribution
;   development_builds : in, optional, type=boolean
;     set to check for development builds as well as releases with versions
;   releases : out, optional, type=structure
;     array of available releases::
;
;       { version: '', date: '', description: '' }
;
;   error : out, optional, type=long
;     set to a named variable to retrieve error status: 0 if OK, 1 if not
;-
function mg_updater, url, $
                     current_version=current_version, $
                     name=name, $
                     development_builds=development_builds, $
                     releases=releases, $
                     error=error, $
                     response_code=response_code
  compile_opt strictarr
  on_error, 2

  if (n_elements(url) eq 0L) then message, 'URL parameter required'

  _current_version = n_elements(current_version) eq 0L ? '0.0' : current_version
  error = 0L

  response_code = 408L
  while (response_code eq 408L) do begin
    content = mg_get_url_content(url, $
                                 response_code=response_code, $
                                 connect_timeout=5.0)
    case response_code of
      200L:
      408L:
      else: begin
          error = 1L
          return, 0B
        end
    endcase
  endwhile

  releases = mg_updater_parser(content, name=name)
  new_releases = bytarr(n_elements(releases))

  for r = 0L, n_elements(releases) - 1L do begin
    new_releases[r] = mg_cmp_version(_current_version, releases[r].version) lt 0L
    if (~keyword_set(development_builds) && releases[r].date eq '') then begin
      new_releases[r] = 0B
    endif
  endfor

  ind = where(new_releases, count)
  if (count eq 0L) then begin
    releases = !null
    return, 0B
  endif
  releases = releases[ind]

  return, 1B
end


; main-level program

url = 'https://raw.github.com/mgalloy/idldoc/master/RELEASE.rst'
needs_updating = mg_updater(url, $
                            current_version='3.3.1', $
                            name='IDLdoc', $
                            releases=releases, $
                            error=error)

if (needs_updating) then begin
  ; get listing of possibly multiple versions with release notes
  for r = 0L, n_elements(releases) - 1L do begin
    print, releases[r].version, format='(%"IDLdoc %s")'
    print, strjoin(strarr(strlen(releases[r].version) + 7L) + '-')
    print, releases[r].date
    print
    print, releases[r].description
    print
  endfor

  print, strjoin(releases[*].version, ', '), $
         format='(%"Updates available: IDLdoc %s")'
endif


end

                