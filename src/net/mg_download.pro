; docformat = 'rst'

function mg_download_progress, status_info, progress_info, callback_data
  compile_opt strictarr

  total_kbytes = progress_info[1] / 1024L
  current_kbytes = progress_info[2] / 1024L

  if (obj_valid(callback_data) && obj_isa(callback_data, 'IDLnetURL')) then begin
    if (total_kbytes gt 0L) then begin
      p = mg_progress(lindgen(total_kbytes), /manual, title='Downloading (KB)')
      callback_data->setProperty, callback_data=p
    endif
  endif

  if (obj_valid(callback_data) && obj_isa(callback_data, 'mg_progress')) then begin
    callback_data->advance, work=curent_kbytes
  endif

  return, 1
end


pro mg_download, url, filename, interactive=interactive
  compile_opt strictarr

  ourl = IDLnetURL(callback_function='mg_download_progress')
  if (keyword_set(interactive)) then ourl->setProperty, callback_data=ourl
  filename = ourl->get(filename=filename, url=url)
  obj_destroy, ourl
end
