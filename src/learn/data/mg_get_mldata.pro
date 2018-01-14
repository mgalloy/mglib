; docformat = 'rst'

;+
; Get a dataset from mldata.org.
;
; :Returns:
;   structure with fields `data`, `target`, `target_names`, and `feature_names`
;
; :Params:
;   name : in, required, type=string
;     name of the data set on mldata.org
;-
function mg_get_mldata, name, interactive=interactive
  compile_opt strictarr
  on_error, 2

  mldata_dir = filepath('', subdir=['mldata'], root=mg_src_root())
  if (~file_test(mldata_dir, /directory)) then file_mkdir, mldata_dir

  filename = filepath(name + '.h5', root=mldata_dir)
  if (~file_test(filename, /regular)) then begin
    mldata_base_url = mg_format('http://mldata.org/repository/data/download/%s/')
    url = string(name, format=mldata_base_url)
    mg_download, url, filename, interactive=interactive
  endif

  varnames= mg_h5_getdata(filename, '/data_descr/ordering')
  feature_names = mg_h5_getdata(filename, '/data_descr/names', error=error)
  if (error ne 0L) then feature_names = ''

  n_varnames = n_elements(varnames)

  var_format = mg_format('/data/%s')
  case n_varnames of
    1: begin
        var = mg_h5_getdata(filename, $
                            string(varnames[0], format=var_format))
        var = transpose(var)
        target = reform(var[0, *])
        data = var[1:*, *]
        if (n_elements(feature_names) gt 1L) then feature_names = feature_names[1:*]
      end
    else: begin
        target_ind = where(varnames eq 'label', n_target, $
                           complement=data_ind, ncomplement=n_data)
        if (n_target ne 1L) then message, 'multiple target variables'
        if (n_data ne 1L) then message, 'cannot handle multiple data variables'
        target = mg_h5_getdata(filename, $
                               string(varnames[target_ind[0]], format=var_format))
        target = reform(target)
        data = mg_h5_getdata(filename, $
                             string(varnames[data_ind[0]], format=var_format))
        data = transpose(data)
      end
  endcase

  if (n_elements(feature_names) eq 1L) then begin
    dims = size(data, /dimensions)
    n_features = dims[0]
    feature_names = strtrim(indgen(n_features), 2)
  endif

  return, {data: data, $
           target: target, $
           target_names: '', $
           feature_names: feature_names}
end


; main-level example program

; names = ['mnist-original', 'mhc-nips11-v2']
; for n = 0L, n_elements(names) - 1L do begin
;   data = mg_get_mldata(names[n])
;   print, names[n], format=mg_format('Name: %s')
;   help, data
; endfor

data = mg_get_mldata('mnist-original', /interactive)
scale = 4
n = 5
xsize = 28
ysize = 28
dims = size(data.data, /dimensions)
n_samples = dims[1]
samples = mg_sample(n_samples, n)
title = string(strjoin(strtrim(long(data.target[samples]), 2), ', '), $
               format='(%"MNIST digits: %s")')
window, xsize=xsize * scale * n, ysize=ysize * scale, /free, title=title
for i = 0L, n - 1L do begin
  im = reform(data.data[*, samples[i]], xsize, ysize)
  im = rotate(im, 7)
  tvscl, rebin(im, xsize * scale, ysize * scale), i
endfor

end
