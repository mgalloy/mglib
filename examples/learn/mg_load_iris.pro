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

window, xsize=800, ysize=800, /free, title='Iris data set'

device, decomposed=0
mg_loadct, 28, /brewer
tvlct, 0, 0, 0, 0
;tvlct, 255, 0, 0, 1
;tvlct, 0, 255, 0, 2
;tvlct, 0, 0, 255, 3
tvlct, 255, 255, 255, 255

iris_data = mg_load_iris()
mg_scatterplot_matrix, iris_data.data, nbins=20, $
                       column_names=iris_data.feature_names, $
                       color=iris_data.target + 1, $
                       bar_color=1, $
                       axis_color=255, charsize=1.0, $
                       psym=mg_usersym(/circle), symsize=0.5

end
