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

  return, {data:data, target_names:target_names, feature_names:feature_names}
end
