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
;   y_testing : out, optional, type="fltarr(test_size)"
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
;   seed : in, out, optional, type=long/lonarr
;     random number seed to pass to `RANDOMU`
;-
pro mg_train_test_split, data, target, $
                         x_test=x_test, y_test=y_test, $
                         x_train=x_train, y_train=y_train, $
                         test_size=test_size, $
                         train_size=train_size, $
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

  train_indices = mg_sample(n_samples, _train_size, seed=seed)
  test_indices = mg_complement(train_indices, n_samples)

  if (arg_present(x_train)) then x_train = data[*, train_indices]
  if (arg_present(y_train)) then y_train = target[train_indices]
  if (arg_present(x_test)) then x_test = data[*, test_indices]
  if (arg_present(y_test)) then y_test = target[test_indices]
end


; main-level example program

iris = mg_load_iris()

mg_train_test_split, iris.data, iris.target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     seed=0L

help, x_train, y_train, x_test, y_test

end
