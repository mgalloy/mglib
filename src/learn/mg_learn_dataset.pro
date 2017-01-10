; docformat = 'rst'

;+
; Loads the Boston house prices dataset.
;
; The Boston house prices dataset has 506 samples and 13 features
;
; :Returns:
;   structure with fields `data`, `target`, `target_names`, and `feature_names`
;-
function mg_load_boston
  compile_opt strictarr

  filename = filepath('boston_house_prices.csv', root=mg_src_root())
  openr, lun, filename, /get_lun

  line = ''
  readf, lun, line
  tokens = strsplit(line, ',', /extract)
  n_samples = long(tokens[0])
  n_features = long(tokens[1])
  readf, lun, line
  feature_names = strsplit(line, ',', /extract)
  n_feature_names = n_elements(feature_names)
  feature_names = strmid(feature_names, 1, reform(strlen(feature_names) - 2, 1, n_feature_names))
  feature_names = feature_names[0:-2]   ; remove last one, it's target

  data_row = {features:fltarr(n_features), target:fltarr(1)}
  data = replicate(data_row, n_samples)

  readf, lun, data
  free_lun, lun

  return, {data: data.features, $
           target: reform(data.target), $
           target_names: '', $
           feature_names: feature_names}
end


;+
; Loads the breast cancer dataset.
;
; The breast cancer dataset has 569 samples and 30 features.
;
; :Returns:
;   structure with fields `data`, `target`, `target_names`, and `feature_names`
;-
function mg_load_breast_cancer
  compile_opt strictarr

  filename = filepath('breast_cancer.csv', root=mg_src_root())
  openr, lun, filename, /get_lun

  line = ''
  readf, lun, line
  tokens = strsplit(line, ',', /extract)
  n_samples = long(tokens[0])
  n_features = long(tokens[1])
  target_names = tokens[2:3]

  data_row = {features:fltarr(n_features), target:lonarr(1)}
  data = replicate(data_row, n_samples)

  readf, lun, data
  free_lun, lun

  feature_names = ['mean radius', 'mean texture', $
                   'mean perimeter', 'mean area', $
                   'mean smoothness', 'mean compactness', $
                   'mean concavity', 'mean concave points', $
                   'mean symmetry', 'mean fractal dimension', $
                   'radius error', 'texture error', $
                   'perimeter error', 'area error', $
                   'smoothness error', 'compactness error', $
                   'concavity error', 'concave points error', $
                   'symmetry error', 'fractal dimension error', $
                   'worst radius', 'worst texture', $
                   'worst perimeter', 'worst area', $
                   'worst smoothness', 'worst compactness', $
                   'worst concavity', 'worst concave points', $
                   'worst symmetry', 'worst fractal dimension']

  return, {data: data.features, $
           target: reform(data.target), $
           target_names: target_names, $
           feature_names: feature_names}
end


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
;   structure with fields `data`, `target`, `target_names`, and `feature_names`
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


;+
; Load one of the example machine learning datasets.
;
; :Returns:
;
; :Params:
;   name : in, required, type=string
;     name of dataset to load: boston, breast_cancer, iris, wave
;-
function mg_learn_dataset, name
  compile_opt strictarr

  case name of
    'iris': return, mg_load_iris()
    'breast_cancer': return, mg_load_breast_cancer()
    'boston': return, mg_load_boston()
    'wave': begin
        n = 100
        x = 6.0 * randomu(42, n) - 3.0
        y = (sin(4 * x) + x + randomn(seed, n)) / 2.0
        return, {data: x, target: y, target_names: ['y'], feature_names: ['x']}
      end
    else: message, 'unknown dataset ' + name
  endcase
end


; main-level example program

if (n_elements(ps) eq 0L) then ps = 0
if (n_elements(demo) eq 0L) then demo = 0

mg_constants

dims = [800, 800]
size = [8, 8]
symsize = 0.75
if (keyword_set(ps)) then begin
  mg_psbegin, /color, bits_per_pixel=8, filename='breastcancer-dataset.ps'
  if (keyword_set(demo)) then begin
    size = [5.0, 5.0]
    dims = [400, 400]
    symsize = 0.5
  endif
  font = 1
endif else font = -1

mg_window, xsize=size[0], ysize=size[1], /inches, /free, $
           title='Breast cancer data set'

device, get_decomposed=odec
tvlct, rgb, /get

device, decomposed=0
loadct, 5

; there are 30 features in this dataset, too many to plot easily -- pick a
; subset of them below
features = [0, 1, 2, 3, 4, 5]

target_colors = [55, 89]

cancer = mg_load_breast_cancer()
mg_scatterplot_matrix, cancer.data[features, *], nbins=20, $
                       column_names=cancer.feature_names[features], $
                       color=target_colors[cancer.target], $
                       bar_color=150, $
                       charsize=1.0, $
                       psym=mg_usersym(/circle), symsize=symsize, font=font

device, decomposed=odec
tvlct, rgb

if (keyword_set(ps)) then begin
  mg_psend
  mg_convert, 'breastcancer-dataset', max_dimension=dims, output=im, keep_output=demo
  mg_image, im, /new_window
endif


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

mg_window, xsize=size[0], ysize=size[1], /inches, /free, title='Iris data set'

device, get_decomposed=odec
tvlct, rgb, /get

device, decomposed=0
loadct, 5

target_colors = [55, 89, 173]

iris = mg_learn_dataset('iris')
mg_scatterplot_matrix, iris.data, nbins=20, $
                       column_names=iris.feature_names, $
                       color=target_colors[iris.target], $
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

mg_window, xsize=4, ysize=4, /inches, /free, title='Wave'
wave = mg_learn_dataset('wave')
plot, wave.data, wave.target, psym=4

end

