; docformat = 'rst'

;= API

function mg_normal_dist::select, n
  compile_opt strictarr

  if (n_elements(*self.seed) gt 0L) then seed = *self.seed
  values = self.standard_deviation * randomn(seed, n) + self.mean
  *self.seed = seed

  if (mg_isinteger(self.type, /type)) then begin
    values = fix(round(values), type=self.type)
  endif

  return, values
end


;= property cycle

;= lifecycle

pro mg_normal_dist::cleanup
  compile_opt strictarr

  self->mg_distribution::cleanup
end


function mg_normal_dist::init, mean, standard_deviation, type=type, _extra=e
  compile_opt strictarr

  if (self->mg_distribution::init(_extra=e) eq 0L) then return, 0L

  self.mean = mg_default(mean, 0.0)
  self.standard_deviation = mg_default(standard_deviation, 1.0)

  self.type = mg_default(type, 4L)

  return, 1
end


pro mg_normal_dist__define
  compile_opt strictarr

  !null = {mg_normal_dist, inherits mg_distribution, $
           mean: 0.0, $
           standard_deviation: 0.0, $
           type: 0L}
end


; main-level example

d = mg_normal_dist(100.0, 20.0)
x = d->select(20)
print, mean(x)
print, stddev(x)

end
