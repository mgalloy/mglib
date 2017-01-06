; docformat = 'rst'

;+
; Loads the iris dataset.
;
; The iris dataset has 4 features: sepal length (cm), sepal width (cm), petal
; length (cm), petal width (cm). It has 3 targets: setosa, versicolor, and
; virginica.
;
; .. image:: iris-dataset.png
;
; :Returns:
;   structure with fields `data`, `target`, `target_names`, and `feature_names`;
;   `data` has
;-
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

  data_row = {features:fltarr(n_features), target:lonarr(1)}
  data = replicate(data_row, n_samples)

  readf, lun, data
  free_lun, lun

  feature_names=['sepal length (cm)', $
                 'sepal width (cm)', $
                 'petal length (cm)', $
                 'petal width (cm)']

  return, {data: data.features, $
           target: reform(data.target), $
           target_names: target_names, $
           feature_names: feature_names}
end


; main-level example

if (n_elements(ps) eq 0L) then ps = 0
if (n_elements(demo) eq 0L) then demo = 0

mg_constants

dims = [800, 800]
size = [8, 8]
symsize = 0.75
if (keyword_set(ps)) then begin
  mg_psbegin, /color, bits_per_pixel=8, filename='iris-dataset.ps'
  if (keyword_set(demo)) then begin
    size = [5.0, 5.0]
    dims = [400, 400]
    symsize = 0.5
  endif
  font = 1
endif else font = -1

mg_window, xsize=size[0], ysize=size[1], /inches, title='Iris data set'

device, get_decomposed=odec
tvlct, rgb, /get

device, decomposed=0
loadct, 5

target_colors = [55, 89, 173]

iris_data = mg_load_iris()
mg_scatterplot_matrix, iris_data.data, nbins=20, $
                       column_names=iris_data.feature_names, $
                       color=target_colors[iris_data.target], $
                       bar_color=150, $
                       charsize=1.0, $
                       psym=mg_usersym(/circle), symsize=symsize, font=font

device, decomposed=odec
tvlct, rgb

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'iris-dataset', max_dimension=dims, output=im, keep_output=demo
  mg_image, im, /new_window
endif

end
