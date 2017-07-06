; docformat = 'rst'


;= API

pro mg_standardscaler::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, x, y, _extra=e

  dims = size(x, /dimensions)
  n_features = dims[0]

  *self._means = mean(x, dimension=2)
  *self._stddevs = stddev(x, dimension=2)
end


function mg_standardscaler::transform, x
  compile_opt strictarr

  dims = size(x, /dimensions)
  new_x = make_array(dimension=dims, type=size(x, /type), /nozero)
  n_features = dims[0]

  for f = 0L, n_features - 1L do begin
    new_x[f, *] = (x[f, *] - (*self._means)[f]) / (*self._stddevs)[f]
  endfor

  return, new_x
end


;= overload methods

function mg_standardscaler::_overloadHelp, varname
  compile_opt strictarr

  _type = 'STDSCL'
  if (n_elements(*self.feature_names) gt 0L) then begin
    _specs = string(n_elements(*self.feature_names), $
                    format='(%"<fit to %d features>")')
  endif else begin
    _specs = '<not fit>'
  endelse
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_standardscaler::getProperty, _means=_means, _stddevs=_stddevs, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e

  if (arg_present(_means)) then _means = *self._means
  if (arg_present(_stddevs)) then _stddevs = *self._stddevs
end


pro mg_standardscaler::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecycle methods

pro mg_standardscaler::cleanup
  compile_opt strictarr

  ptr_free, self._means, self._stddevs
  self->mg_transformer::cleanup
end


function mg_standardscaler::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self._means = ptr_new(/allocate_heap)
  self._stddevs = ptr_new(/allocate_heap)

  return, 1
end


pro mg_standardscaler__define
  compile_opt strictarr

  !null = {mg_standardscaler, inherits mg_transformer, $
           _means: ptr_new(), $
           _stddevs: ptr_new()}
end


; main-level example program

n_features = 2
n_samples = 100

x_train = randomu(seed, n_features, n_samples)
x_train[0, *] = 3 * x_train[0, *] + 1
x_train[1, *] = 5 * x_train[1, *] - 1

std = mg_standardscaler()
help, std
std_x_train = std->fit_transform(x_train)
help, std

window, xsize=800, ysize=400, title='Standard scaled data', /free
!p.multi = [0, 2, 1]
plot, x_train[0, *], x_train[1, *], psym=3, $
      xrange=[-5, 5], yrange=[-5, 5], xstyle=1, ystyle=1
plot, std_x_train[0, *], std_x_train[1, *], psym=3, $
      xrange=[-5, 5], yrange=[-5, 5], xstyle=1, ystyle=1
!p.multi = 0
obj_destroy, std

end
