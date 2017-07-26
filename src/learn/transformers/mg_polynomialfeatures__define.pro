; docformat = 'rst'


;= helper methods

function mg_polynomialfeatures::_combine, combos, names
  compile_opt strictarr

  ones = combos eq 0
  if (mg_all(ones)) then begin
    return, names[combos[0]]
  endif else begin
    ind = where(combos ne 0, count)
    start_index = count eq 0L ? 0L : ind[0]
    indices = combos[start_index:*]

    name_array = []
    i_min = min(indices)
    h = histogram(indices, min=i_min)
    for i = 0L, n_elements(h) - 1L do begin
      if (h[i] gt 0L) then begin
        _name = names[i + i_min] + (h[i] eq 1L ? '' : ('^' + strtrim(h[i], 2)))
        name_array = [name_array, _name]
      endif
    endfor
    return, strjoin(name_array, ' ')
  endelse
end


function mg_polynomialfeatures::_find_feature_names, combinations, feature_names
  compile_opt strictarr

  dims = size(combinations, /dimensions)
  degree = dims[0]
  n_features = dims[1]

  new_feature_names = strarr(n_features)

  for f = 0L, n_features - 1L do begin
    new_feature_names[f] = self->_combine(combinations[*, f], feature_names)
  endfor

  return, new_feature_names
end


;= API

pro mg_polynomialfeatures::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, x, y, _extra=e

  dims = size(x, /dimensions)
  n_features = dims[0]

  *self._combinations = mg_find_combinations(n_features + 1, $
                                           self.degree, $
                                           /with_replacement, $
                                           count=n_combinations)

  *self.feature_names = self->_find_feature_names(*self._combinations, $
                                                  ['1', *self.feature_names])
end


function mg_polynomialfeatures::transform, x
  compile_opt strictarr

  dims = size(x, /dimensions)
  type = size(x, /type)
  n_features = dims[0]
  n_samples = dims[1]

  cdims = size(*self._combinations, /dimensions)
  new_x = make_array(dimension=[cdims[1], n_samples], type=type, value=fix(1, type=type))
  for i = 1L, cdims[1] - 1L do begin
    for d = 0L, self.degree - 1 do begin
      col = (*self._combinations)[d, i]
      if (col ne 0L) then new_x[i, *] *= x[col - 1, *]
    endfor
  endfor
  return, new_x
end


;= overload methods

function mg_polynomialfeatures::_overloadHelp, varname
  compile_opt strictarr

  _type = 'POLYF'
  _specs = string(self.degree, format='(%"<degree: %d>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_polynomialfeatures::getProperty, degree=degree, $
                                        fit_parameters=fit_parameters, $
                                        _ref_extra=e
  compile_opt strictarr

  if (arg_present(degree)) then degree = self.degree
  if (arg_present(fit_parameters)) then begin
    fit_parameters = {combinations: *self._combinations, $
                      feature_names: *self.feature_names}
  endif

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_polynomialfeatures::setProperty, degree=degree, $
                                        fit_parameters=fit_parameters, $
                                        _extra=e
  compile_opt strictarr

  if (n_elements(degree) gt 0L) then self.degree = degree
  if (n_elements(fit_parameters) gt 0L) then begin
    *self._combinations = fit_parameters.combinations
    *self.feature_names = fit_parameters.feature_names
  endif

  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecycle methods

pro mg_polynomialfeatures::cleanup
  compile_opt strictarr

  ptr_free, self._combinations
  self->mg_transformer::cleanup
end


function mg_polynomialfeatures::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self._combinations = ptr_new(/allocate_heap)

  self.degree = 2L
  self->setProperty, _extra=e

  return, 1
end


pro mg_polynomialfeatures__define
  compile_opt strictarr

  !null = {mg_polynomialfeatures, inherits mg_transformer, $
           degree: 0L, $
           _combinations: ptr_new()}
end


; main-level example program

x = findgen(2, 10)
poly = mg_polynomialfeatures(degree=2, feature_names=['x0', 'x1'])
poly->fit, x
new_x = poly->transform(x)
print, strjoin(poly.feature_names, ', ')
obj_destroy, poly

end
