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
