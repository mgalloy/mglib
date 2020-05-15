; docformat = 'rst'

;+
; Get information from a URL that represents a directory listing for websites
; that enable them. Note: the parser of the directory listing is very brittle,
; and may not work for all web servers.
;
; :Returns:
;   array of structures with fields `name`, `link`, `date`, and `size`
;
; :Params:
;   url : in, required, type=string
;     URL to retrieve
;-
function mg_url_dirlisting, url, _ref_extra=e
  compile_opt strictarr

  listing = mg_get_url_content(url, _extra=e)

  ; there are 8 header lines and 2 footer lines
  n_header_lines = 8L
  n_footer_lines = 2L
  n_entries = n_elements(listing) - n_header_lines - n_footer_lines

  s = replicate({name: '', link: '', date: '', size: ''}, n_entries)

  re = '<img .*> <a href="(.*)">(.*)</a>[[:space:]]*(....-..-.. ..:..)[[:space:]]*(.*)'
  for e = 0L, n_entries - 1L do begin
    r = stregex(listing[e + n_header_lines], re, /extract, /subexpr)
    s[e].link = r[1]
    s[e].name = r[2]
    s[e].date = r[3]
    s[e].size = r[4]
  endfor

  return, s
end


; main-level example

url = 'http://download.hao.ucar.edu/2020/05/14/'
listing = mg_url_dirlisting(url)
extavg_indices = where(strmatch(listing.name, '*_extavg_cropped.gif'), n_extavg, /null)
times = strmid((listing.name)[extavg_indices], 9, 6)
print, times

end
