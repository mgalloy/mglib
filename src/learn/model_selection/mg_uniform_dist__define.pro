; docformat = 'rst'

;= API

function mg_uniform_dist::select, n
  compile_opt strictarr

  if (n_elements(*self.seed) gt 0L) then seed = *self.seed
  r = *self.range
  values = (r[1] - r[0]) * randomu(seed, n) + r[0]
  *self.seed = seed

  if (mg_isinteger(self.type, /type)) then begin
    values = fix(round(values), type=self.type)
  endif

  return, values
end


;= property cycle

;= lifecycle

pro mg_uniform_dist::cleanup
  compile_opt strictarr

  ptr_free, self.range
  self->mg_distribution::cleanup
end


function mg_uniform_dist::init, range, type=type, _extra=e
  compile_opt strictarr

  if (self->mg_distribution::init(_extra=e) eq 0L) then return, 0L

  self.range = ptr_new(mg_default(range, [0.0, 1.0]))

  self.type = mg_default(type, 4L)

  return, 1
end


pro mg_uniform_dist__define
  compile_opt strictarr

  !null = {mg_uniform_dist, inherits mg_distribution, $
           range: ptr_new(), $
           type: 0L}
end


; main-level example

d = mg_uniform_dist([5.0, 10.0])
x = d->select(20)
print, mg_range(x)

end
