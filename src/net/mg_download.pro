; docformat = 'rst'

;+
; Callback on download progress.
;
; :Returns:
;   1 to continue, 0 to abort
;
; :Params:
;   status_info : in, required, type=strarr
;     status information
;   progress_info : in, required, type=lonarr(4)
;     progress information about the download
;   callback_data : in, required
;     `CALLBACK_DATA` property for `IDLnetURL` object
;-
function mg_download_progress, status_info, progress_info, callback_data
  compile_opt strictarr

  if (progress_info[0] eq 0L) then return, 1

  if (obj_valid(callback_data) && obj_isa(callback_data, 'IDLnetURL')) then begin
    total_bytes = progress_info[1]
    if (total_bytes gt 0L) then begin
      p = mg_progress(total=total_bytes / 1024, title='Downloading (KB)')
      callback_data->setProperty, callback_data=p
    endif
  endif

  if (obj_valid(callback_data) && obj_isa(callback_data, 'mg_progress')) then begin
    current_bytes = progress_info[2]
     callback_data->advance, current=current_bytes / 1024
  endif

  return, 1
end


;+
; Download a file.
;
; :Params:
;   url : in, required, type=string
;     URL to download
;   filename : in, required, type=string
;     filename of downloaded file
;
; :Keywords:
;   interactive : in, optional, type=boolean
;     display a progress bar on the command line
;   _ref_extra : out, optional, type=keywords
;     keywords that represent properties of `IDLnetURL`, e.g., `RESPONSE_CODE`
;     and `RESPONSE_HEADER`
;-
pro mg_download, url, filename, interactive=interactive, _ref_extra=e
  compile_opt strictarr

  ourl = IDLnetURL(callback_function='mg_download_progress')
  if (keyword_set(interactive)) then ourl->setProperty, callback_data=ourl
  filename = ourl->get(filename=filename, url=url)
  if (keyword_set(interactive)) then begin
    ourl->getProperty, callback_data=p
    p->done
    obj_destroy, p
  endif
  ourl->getProperty, _extra=e
  obj_destroy, ourl
end


; main-level example program
url = 'http://data.idldev.com/mnist-original.h5'
filename = 'mnist-original.h5'
mg_download, url, filename, /interactive

end
