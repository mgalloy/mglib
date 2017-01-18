; docformat = 'rst'

;= API

pro mg_pcatransformer::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, _extra=e

  dims = size(x, /dimensions)
  n_features = dims[0]

  in_double = size(x, /type) eq 5
  covariance = correlate(x, /covariance, double=in_double)

  ; eigenvalues returned in from largest to smallest
  eigenvalues = eigenql(covariance, eigenvectors=eigenvectors, double=in_double)

  explained_variance = eigenvalues / trace(temporary(covariance), double=in_double)

  ; find the number of components to use
  if (self.n_components lt 1L) then begin
    if (self.required_variance gt 0.0) then begin
      ; if self.required_variance has been set, then use enough components
      ; to add up to the required variance
      csum_variance = total(explained_variance, /preserve_type, /cumulative)
      ind = where(csum_variance gt self.required_variance, count)
      if (count gt 0L) then begin
        self.n_components = ind[0] + 1L
      endif else begin
        message, 'not able to use enough components to explain variance'
      endelse
    endif else begin
      ; if neither self.n_components or self.required_variance are set, then
      ; use all the features
      self.n_components = n_features
    endelse
  endif

  *self._variance = explained_variance[0:self.n_components - 1L]
  *self._eigenvectors = eigenvectors[0:self.n_components - 1L, *]

  *self.feature_names = 'pc' + strtrim(lindgen(self.n_components) + 1, 2)
end


function mg_pcatransformer::transform, x
  compile_opt strictarr

  return, x ## *self._eigenvectors
end


;= overload methods

function mg_pcatransformer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'PCA'

  if (self.n_components lt 1L) then begin
    if (self.required_variance gt 0.0) then begin
      _specs = string(self.required_variance * 100, format='(%"<required variance: %0.1f%%>")')
    endif else begin
      _specs = '<all components>'
    endelse
  endif else begin
    _specs = string(self.n_components, format='(%"<components: %d>")')
  endelse
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_pcatransformer::getProperty, n_components=n_components, $
                                    components=components, $
                                    variance=variance, $
                                    _ref_extra=e
  compile_opt strictarr

  if (arg_present(n_components)) then n_components = self.n_components
  if (arg_present(components)) then components = *self._eigenvectors
  if (arg_present(variance)) then variance = *self._variance
  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_pcatransformer::setProperty, n_components=n_components, _extra=e
  compile_opt strictarr

  if (n_elements(n_components) gt 0L) then begin
    type = size(n_components, /type)
    if ((type eq 4 || type eq 5) && n_components gt 0.0 && n_components le 1.0) then begin
      self.required_variance = n_components
    endif else begin
      self.n_components = n_components
    endelse
  endif
  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecycle methods

pro mg_pcatransformer::cleanup
  compile_opt strictarr

  ptr_free, self._eigenvectors, self._variance
  self->mg_transformer::cleanup
end


function mg_pcatransformer::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self.n_components = 0L
  self.required_variance = -1.0
  self._eigenvectors = ptr_new(/allocate_heap)
  self._variance = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_pcatransformer__define
  compile_opt strictarr

  !null = {mg_pcatransformer, inherits mg_transformer, $
           n_components: 0L, $
           required_variance: 0.0, $
           _eigenvectors: ptr_new(), $
           _variance: ptr_new()}
end


; main-level example program

seed = 0
n_features = 2L
n_samples = 200L
n_components = 0.5

x1 = (2.0 * randomn(seed, n_features, n_samples) - 1.0) ## randomu(seed, n_features, n_features)
x2 = (2.0 * randomn(seed, n_features, 20) - 1.0) ## randomu(seed, n_features, n_features)

pca = mg_pcatransformer(n_components=n_components)
help, pca

x1_pca = pca->fit_transform(x1, feature_names=['x', 'y'])
x2_pca = pca->transform(x2)

help, pca

for c = 0L, pca.n_components - 1L do begin
  print, c, strjoin(strtrim(reform(pca.components[c, *]), 2), ', '), $
         format='(%"component[%d] = [%s]")'
endfor
print, strjoin(strtrim(pca.variance, 2), ', '), format='(%"variance = [%s]")'

obj_destroy, pca

end
