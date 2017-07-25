; docformat = 'rst'

;= API

;+
; Generate indices to split data into a training and test set.
;-
pro mg_kfoldcv::split, x, y, $
                       training_indices=training_indices, $
                       test_indices=test_indices
  compile_opt strictarr
  on_error, 2

  if (self.i eq self.n_splits) then message, 'no more indices'

  dims = size(x, /dimensions)
  n_samples = dims[1]

  if (self.i eq 0L) then begin
    *self.indices = lindgen(n_samples)

    if (self.shuffle) then begin
      seed = *self.seed
      *self.indices = mg_shuffle(*self.indices, seed=seed)
      *self.seed = seed
    endif
  endif

  fold_sizes = lonarr(self.n_splits) + n_samples / self.n_splits
  fold_sizes[0:(n_samples mod self.n_splits) - 1] += 1
  c_fold_sizes = [0L, total(fold_sizes, /integer, /cumulative)]

  test_indices = (*self.indices)[c_fold_sizes[self.i]:c_fold_sizes[self.i + 1L] - 1L]
  training_indices = mg_complement(test_indices, n_samples)

  self.i += 1
end


;= property access

pro mg_kfoldcv::getProperty, n_splits=n_splits, $
                             shuffle=shuffle, $
                             seed=seed
  compile_opt strictarr

  if (arg_present(n_splits)) then n_splits = self.n_splits
  if (arg_present(shuffle)) then shuffle = self.shuffle
  if (arg_present(seed)) then seed = *self.seed
end


;= lifecycle

pro mg_kfoldcv::cleanup
  compile_opt strictarr

  ptr_free, self.seed, self.indices
end


function mg_kfoldcv::init, n_splits=n_splits, $
                           shuffle=shuffle, $
                           seed=seed
  compile_opt strictarr

  self.n_splits = mg_default(n_splits, 3)
  self.shuffle = mg_default(shuffle, 0B)
  self.seed = ptr_new(seed)
  self.indices = ptr_new(/allocate_heap)
  self.i = 0L

  return, 1
end


pro mg_kfoldcv__define
  compile_opt strictarr

  !null = {mg_kfoldcv, inherits IDL_Object, $
           n_splits:0L, $
           shuffle: 0L, $
           seed: ptr_new(), $
           indices: ptr_new(), $
           i: 0L}
end
