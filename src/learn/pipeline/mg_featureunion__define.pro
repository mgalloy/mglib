; docformat = 'rst'

;+
; Combine the feature matrices of multiple pipelines.
;-

;= API

pro mg_featureunion::fit, x, y, feature_names=feature_names, _extra=e
  compile_opt strictarr

  for p = 0L, n_elements(*self.pipelines) - 1L do begin
    ((*self.pipeline)[s])->fit, x, y
  endfor
end


;+
; Apply the learned transform to `x`.
;
; :Returns:
;   `fltarr(n_new_features, n_samples)`
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to transform
;-
function mg_featureunion::transform, x
  compile_opt strictarr

  self->getProperty, feature_names=feature_names
  n_union_features = n_elements(feature_names)
  dims = size(x, /dimensions)
  n_samples = dims[1]

  union = make_array(dimension=[n_union_features, n_samples], $
                     type=size(x, /type))

  c = 0L
  for t = 0L, n_elements(*self.transformers) - 1L do begin
    transform = ((*self.transformers)[t])->transform(x)
    transform_dims = size(transform, /dimensions)
    union[c:c + transform_dims[0] - 1, *] = transform
    c += transform_dims[0]
  endfor

  return, union
end


;= property access

pro mg_featureunion::getProperty, transformers=transformers, $
                                  n_transformers=n_transformers, $
                                  feature_names=feature_names, $
                                  fit_parameters=fit_parameters, $
                                  _ref_extra=e
  compile_opt strictarr

  if (arg_present(transformers)) then transformers = *self.transformers
  if (arg_present(n_transformers)) then n_transformers = n_elements(*self.transformers)
  if (arg_present(feature_names)) then begin
    fnames = list()
    for p = 0L, n_elements(*self.transformers) - 1L do begin
      fnames->add, ((*self.transformers)[p]).feature_names, /extract
    endfor
    feature_names = fnames->toArray()
    obj_destroy, fnames
  endif

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


;= lifecycle

pro mg_featureunion::cleanup
  compile_opt strictarr

  obj_destroy, *self.transformers
  ptr_free, self.transformers
end


function mg_featureunion::init, transformers
  compile_opt strictarr

  self.transformers = ptr_new(transformers)

  return, 1
end


pro mg_featureunion__define
  compile_opt strictarr

  !null = {mgfeatureunion, inherits mg_estimator, $
           transformers: ptr_new()}
end
