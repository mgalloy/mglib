; docformat = 'rst'

; `x` must be 2-dimensional


;= API

pro mg_imputer::fit, x, y, _extra=e
  compile_opt strictarr
  on_error, 2

  self->mg_transformer::fit, x, y, _extra=e

  case strlowcase(self.strategy) of
    'mean': *self._replacement_values = mean(x, dimension=self.dimension, /nan)
    'median': *self._replacement_values = median(x, dimension=self.dimension)
    'mode': begin
        ; TODO: implement
      end
    else: message, string(self.strategy, format='(%"unknown strategy %s")')
  endcase
end


function mg_imputer::transform, x
  compile_opt strictarr

  dims = size(x, /dimensions)
  new_x = make_array(dimension=dims, type=size(x, /type), /nozero)
  n_features = dims[0]

  case self.dimension of
    1: begin
        for d = 0L, dims[1] - 1L do begin
          new_x[*, d] = self->_replace_missing(x[*, d], $
                                               replacement_value=(*self._replacement_values)[d])
        endfor
      end
    2: begin
        for d = 0L, dims[0] - 1L do begin
          new_x[d, *] = self->_replace_missing(x[d, *], $
                                               replacement_value=(*self._replacement_values)[d])
        endfor
      end
  endcase

  return, new_x
end


;= helper methods

function mg_imputer::_replace_missing, x, count=count, replacement_value=replacement_value
  compile_opt strictarr

  if (finite(*self.missing_value)) then begin
    ind = where(x eq *self.missing_value, count)
  endif else begin
    ind = where(finite(x) eq 0, count)
  endelse

  result = x
  if (count gt 0L) then result[ind] = replacement_value
  return, result
end


;= overload methods

function mg_imputer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'IMPUTER'
  if (n_elements(*self.feature_names) gt 0L) then begin
    _specs = string(n_elements(*self.feature_names), $
                    format='(%"<fit to %d features>")')
  endif else begin
    _specs = '<not fit>'
  endelse
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_imputer::getProperty, dimension=dimension, $
                             missing_value=missing_value, $
                             strategy=strategy, $
                             _replacement_values=_replacement_values, $
                             _ref_extra=e
  compile_opt strictarr

  if (arg_present(dimension)) then dimension = self.axis
  if (arg_present(missing_value)) then missing_value = *self.missing_value
  if (arg_present(strategy)) then strategy = self.strategy
  if (arg_present(_replacement_values)) then _replacement_values = *self._replacement_values

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


;= lifecycle methods

pro mg_imputer::cleanup
  compile_opt strictarr

  ptr_free, self.missing_value, self._replacement_values
end


function mg_imputer::init, dimension=dimension, $
                           missing_value=missing_value, $
                           strategy=strategy
  compile_opt strictarr

  if (~self->mg_transformer::init()) then return, 0

  self.dimension = mg_default(dimension, 2)
  self.missing_value = ptr_new(mg_default(missing_value, !values.f_nan))
  self.strategy = mg_default(strategy, 'mean')
  self._replacement_values = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_imputer__define
  compile_opt strictarr

  !null = {mg_imputer, inherits mg_transformer, $
           dimension: 0L, $
           missing_value: ptr_new(), $
           strategy: '', $
           _replacement_values: ptr_new()}
end


; main-level example program

; create some data with missing values
x = randomu(seed, 4, 20)
ind = mg_sample(n_elements(x), 10)
x[ind] = !values.f_nan
print, 'Original array with missing values:'
print, x

; fill in the missing values by column
imputer = mg_imputer(strategy='median', dimension=2)
imputer->fit, x
print, strjoin(strtrim(imputer._replacement_values, 2), ', '), format='(%"Replacement values: %s")'
print, imputer.missing_value, format='(%"Missing value: %f")'
new_x = imputer->transform(x)
print, 'Transformed array with imputed values:'
print, new_x

end
