; docformat = 'rst'

;+
; Split a data set into a training set and a test set.
;
; :Params:
;   data : in, required, type="fltarr(n_features, n_samples)"
;     data to split
;   target : in, required, type=fltarr(n_samples)
;     target to split
;
; :Keywords:
;   x_test : out, optional, type="fltarr(n_features, test_size)"
;     testing data set
;   y_test : out, optional, type="fltarr(test_size)"
;     test target set
;   x_train : out, optional, type="fltarr(n_features, train_size)"
;     training data set
;   y_train : out, optional, type="fltarr(train_size)"
;     training target set
;   test_size : in, optional, type=float/long, default=0.25
;     set to a fraction between 0.0 and 1.0 to represent a fraction of
;     `n_samples` or to a integer value; if not set, uses complement of
;     `train_size`; if `train_size` not set, uses 0.25
;   train_size : in, optional, type=float/long, default=0.75
;     set to a fraction between 0.0 and 1.0 to represent a fraction of
;     `n_samples` or to a integer value; if not set, uses complement of
;     `test_size`; if `test_size` not set, uses 0.75
;   stratify_by : in, optional, type=integer/string array
;     class labels to make sure split matches
;   seed : in, out, optional, type=long/lonarr
;     random number seed to pass to `RANDOMU`
;-
pro mg_train_test_split, data, target, $
                         x_test=x_test, y_test=y_test, $
                         x_train=x_train, y_train=y_train, $
                         test_size=test_size, $
                         train_size=train_size, $
                         stratify_by=stratify_by, $
                         seed=seed
  compile_opt strictarr

  dims = size(data, /dimensions)
  n_features = dims[0]
  n_samples = dims[1]

  if (n_elements(test_size) eq 0L) then begin
    if (n_elements(train_size) eq 0L) then begin
      _train_size = n_samples - ceil(0.25 * n_samples)
    endif else if (train_size gt 0.0 && train_size lt 1.0) then begin
      _train_size = floor(train_size * n_samples)
    endif else begin
      _train_size = test_size
    endelse
  endif else if (test_size gt 0.0 && test_size lt 1.0) then begin
    _train_size = n_samples - ceil(test_size * n_samples)
  endif else begin
    _train_size = n_samples - test_size
  endelse

  if (n_elements(stratify_by) gt 0L) then begin
    counts = mg_frequency(stratify_by)
    n_classes = n_elements(counts)
    train_indices = lonarr(_train_size)
    class_sizes = counts.count * _train_size / n_samples
    n_extra = _train_size - total(class_sizes, /preserve_type)
    if (n_extra gt 0L) then begin
      extra_ind = mg_sample(n_classes, n_extra, seed=seed)
      class_sizes[extra_ind] += 1
    endif
    cc_sizes = [0L, total(class_sizes, /cumulative, /preserve_type)]
    for c = 0L, n_classes - 1L do begin
      ind1 = where(stratify_by eq counts[c].value)
      ind2 = mg_sample(counts[c].count, class_sizes[c], seed=seed)
      train_indices[cc_sizes[c]:cc_sizes[c + 1] - 1] = ind1[ind2]
    endfor
  endif else begin
    train_indices = mg_sample(n_samples, _train_size, seed=seed)
  endelse

  test_indices = mg_complement(train_indices, n_samples)

  ; randomize order of sampling indices
  train_indices = train_indices[sort(randomu(seed, _train_size))]
  test_indices = test_indices[sort(randomu(seed, n_elements(test_indices)))]

  if (arg_present(x_train)) then x_train = data[*, train_indices]
  if (arg_present(y_train)) then y_train = target[train_indices]
  if (arg_present(x_test)) then x_test = data[*, test_indices]
  if (arg_present(y_test)) then y_test = target[test_indices]
end


; main-level example program

iris = mg_learn_dataset('iris')

;seed = 0L
mg_train_test_split, iris.data, iris.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     seed=seed

help, x_train, y_train, x_test, y_test

cnames = ['Target', '#']
print, 'Targets for entire dataset'
print, mg_table(mg_frequency(iris.target), column_names=cnames)
print
print, 'Test targets'
print, mg_table(mg_frequency(y_test), column_names=cnames)

mg_train_test_split, iris.data, iris.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     stratify_by=iris.target, $
                     seed=seed
print
print, 'Test targets stratified by target'
print, mg_table(mg_frequency(y_test), column_names=cnames)

end
