; docformat = 'rst'


;= API

pro mg_minmaxscaler::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, x, y, _extra=e

  dims = size(x, /dimensions)
  n_features = dims[0]

  *self._ranges = make_array(dimension=[n_features, 2], type=size(x, /type))
  x_min = min(x, dimension=2, max=x_max)
  (*self._ranges)[*, 0] = x_min
  (*self._ranges)[*, 1] = x_max
end


function mg_minmaxscaler::transform, x
  compile_opt strictarr

  dims = size(x, /dimensions)
  new_x = make_array(dimension=dims, type=size(x, /type), /nozero)
  n_features = dims[0]

  slopes = 1.0 / ((*self._ranges)[*, 1] - (*self._ranges)[*, 0])
  for f = 0L, n_features - 1L do begin
    new_x[f, *] = slopes[f] * (x[f, *] - (*self._ranges)[f, 0])
  endfor

  return, new_x
end


;= overload methods

function mg_minmaxscaler::_overloadHelp, varname
  compile_opt strictarr

  _type = 'MINMAXSCL'
  if (n_elements(*self.feature_names) gt 0L) then begin
    _specs = string(n_elements(*self.feature_names), $
                    format='(%"<fit to %d features>")')
  endif else begin
    _specs = '<not fit>'
  endelse
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_minmaxscaler::getProperty, fit_parameters=fit_parameters, _ref_extra=e
  compile_opt strictarr

  if (arg_present(fit_parameters)) then fit_parameters = *self._ranges

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_minmaxscaler::setProperty, fit_parameters=fit_parameters, _extra=e
  compile_opt strictarr

  if (n_elements(fit_parameters) gt 0L) then begin
    *self._ranges = fit_parameters
  endif

  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecycle methods

pro mg_minmaxscaler::cleanup
  compile_opt strictarr

  ptr_free, self._ranges
  self->mg_transformer::cleanup
end


function mg_minmaxscaler::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self._ranges = ptr_new(/allocate_heap)

  return, 1
end


pro mg_minmaxscaler__define
  compile_opt strictarr

  !null = {mg_minmaxscaler, inherits mg_transformer, $
           _ranges: ptr_new()}
end


; main-level example program

n_features = 2L
n_samples = 1000L
x_train = randomu(seed, n_features, n_samples)
x_train[0, *] = 3.0 * x_train[0, *] - 1
x_train[1, *] = 2.0 * x_train[1, *] + 1
minmax = mg_minmaxscaler()
help, minmax
new_x_train = minmax->fit_transform(x_train)
help, minmax

window, xsize=800, ysize=400, title='min-max transform', /free
!p.multi = [0, 2, 1]
plot, x_train[0, *], x_train[1, *], psym=3, $
      xrange=[-3, 3], yrange=[-3, 3], xstyle=1, ystyle=1
plot, new_x_train[0, *], new_x_train[1, *], psym=3, $
      xrange=[-3, 3], yrange=[-3, 3], xstyle=1, ystyle=1
!p.multi = 0

obj_destroy, minmax

end
