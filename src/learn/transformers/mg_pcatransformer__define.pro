; docformat = 'rst'

;= API

pro mg_pcatransformer::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, _extra=e

  dims = size(x, /dimensions)
  n_features = dims[0]

  n_components = self.n_components lt 1L ? n_features : self.n_components
  *self.feature_names = 'pc' + strtrim(lindgen(n_components) + 1, 2)

  in_double = size(x, /type) eq 5
  covariance = correlate(x, /covariance, double=in_double)

  ; eigenvalues returned in from largest to smallest
  eigenvalues = eigenql(covariance, eigenvectors=eigenvectors, double=in_double)
  *self._eigenvectors = eigenvectors[0:n_components - 1L, *]
  *self._variance = (eigenvalues / trace(temporary(covariance), double=in_double))[0:n_components - 1L]
end


function mg_pcatransformer::transform, x
  compile_opt strictarr

  return, x ## *self._eigenvectors
end


;= overload methods

function mg_pcatransformer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'PCA'
  _specs = string(self.n_components, format='(%"<components: %d>")')
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

  if (n_elements(n_components) gt 0L) then self.n_components = n_components
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
  self._eigenvectors = ptr_new(/allocate_heap)
  self._variance = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_pcatransformer__define
  compile_opt strictarr

  !null = {mg_pcatransformer, inherits mg_transformer, $
           n_components: 0L, $
           _eigenvectors: ptr_new(), $
           _variance: ptr_new()}
end


; main-level example program

seed = 0
n_features = 2L
n_samples = 200L
n_components = 1L

x1 = (2.0 * randomn(seed, n_features, n_samples) - 1.0) ## randomu(seed, n_features, n_features)
x2 = (2.0 * randomn(seed, n_features, 20) - 1.0) ## randomu(seed, n_features, n_features)

pca = mg_pcatransformer(n_components=n_components)
help, pca

x1_pca = pca->fit_transform(x1, feature_names=['x', 'y'])
x2_pca = pca->transform(x2)
for c = 0L, n_components - 1L do begin
  print, c, strjoin(strtrim(reform(pca.components[c, *]), 2), ', '), $
         format='(%"component[%d] = [%s]")'
endfor
print, strjoin(strtrim(pca.variance, 2), ', '), format='(%"variance = [%s]")'

;obj_destroy, pca

end
