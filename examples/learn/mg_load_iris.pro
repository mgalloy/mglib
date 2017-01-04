; docformat = 'rst'

function mg_load_iris
  compile_opt strictarr

  filename = filepath('iris.csv', root=mg_src_root())
  openr, lun, filename, /get_lun
  line = ''
  readf, lun, line
  tokens = strsplit(line, ',', /extract)
  n_samples = long(tokens[0])
  n_features = long(tokens[1])
  target_names = tokens[2:*]
  data = fltarr(n_features + 1L, n_samples)
  readf, lun, data
  target = reform(data[n_features, *])
  data = data[0:n_features - 1L, *]
  free_lun, lun

  feature_names=['sepal length (cm)', 'sepal width (cm)', $
                 'petal length (cm)', 'petal width (cm)']

  return, {data: data, $
           target: target, $
           target_names: target_names, $
           feature_names: feature_names}
end


; main-level example

if (n_elements(ps) eq 0L) then ps = 0

mg_constants

if (keyword_set(ps)) then begin
  mg_psbegin, /image, /color, filename='iris-dataset.ps'
  font = 1
endif else font = -1

mg_window, xsize=8, ysize=8, /inches, title='Iris data set'

device, get_decomposed=odec
tvlct, rgb, /get

device, decomposed=0
mg_loadct, 28, /brewer
tvlct, 0, 0, 0, 0
tvlct, 255, 255, 255, 255

iris_data = mg_load_iris()
mg_scatterplot_matrix, iris_data.data, nbins=20, $
                       column_names=iris_data.feature_names, $
                       color=iris_data.target + 1, $
                       bar_color=1, $
                       axis_color=255, charsize=1.0, $
                       psym=mg_usersym(/circle), symsize=0.75, font=font

device, decomposed=odec
tvlct, rgb

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'iris-dataset', max_dimension=[800, 800], output=im
  mg_image, im, /new_window
endif

end
