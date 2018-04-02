; docformat = 'rst'

;+
; Dual numbers are of the form `a + b*e`, where `e^2 = 0`. Evaluating a function
; `f(x)` at `a + b*e` gives:
;
;   $$f(a + be) =  f(a) + b f'(a) e$$
;
; So evaluating $f(a + e)$ gives both $f(a)$ and $f'(a)$.
;
; Using this library, we can evaluate a function and its derivative for
; functions involving `+`, `-`, `*`, `/`, `sin`, `cos`, `exp`, `alog`, and
; `abs`. For example, if we want to evaluate at `x=2`, then we create the
; dual number::
;
;   IDL> x = mg_ad_var(2, 1)
;
; We can then evaluate, a function at `x`, like:
;
;   IDL> y = 2 * x ^ 2 - 3 * x
;   IDL> print, y
;   2 + 5e
;
; This indicates that $f(2) = 2$ and $f'(2) = 5,$ which is correct.
;-


;= helper methods

pro mg_ad_var::_decompose, left, right, $
                                lefta=lefta, leftb=leftb, $
                                righta=righta, $
                                rightb=rightb
  compile_opt strictarr

  lefta = isa(left, 'mg_ad_var') ? left.a : left
  leftb = isa(left, 'mg_ad_var') ? left.b : 0

  righta = isa(right, 'mg_ad_var') ? right.a : right
  rightb = isa(right, 'mg_ad_var') ? right.b : 0
end


;= operator overload methods

function mg_ad_var::_overloadPrint
  compile_opt strictarr

  s = string(*self.a, format=('(%"%g")')) + ' + ' + string(*self.b, format=('(%"%g")')) + 'e'
  return, n_elements(s) gt 1 ? transpose(s) : s
end


function mg_ad_var::_overloadHelp, name
  compile_opt strictarr

  type = 'ADVAR'
  info = string(n_elements(*self.a), format='(%"Array[%d]")')
  return, string(name, type, info, format='(%"%-15s %-9s = %s")')
end


function mg_ad_var::_overloadPlus, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_ad_var(lefta + righta, leftb + rightb, subvars=list(left, right))
end


function mg_ad_var::_overloadMinus, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_ad_var(lefta - righta, leftb - rightb, subvars=list(left, right))
end


function mg_ad_var::_overloadMinusUnary
  compile_opt strictarr

  return, mg_ad_var(- *self.a, - *self.b, subvars=list(left, right))
end


function mg_ad_var::_overloadAsterisk, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_ad_var(lefta * righta, leftb * righta + lefta * rightb, $
                    subvars=list(left, right))
end


function mg_ad_var::_overloadSlash, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_ad_var(lefta * righta / (righta * righta), $
                         (leftb * righta - lefta * rightb) / (righta * righta), $
                         subvars=list(left, right))
end


function mg_ad_var::_overloadCaret, left, right
  compile_opt strictarr
  on_error, 2

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb
  if (rightb ne 0.0) then message, 'unable to handle dual exponent'

  return, mg_ad_var(lefta ^ righta, $
                    righta * lefta ^ (righta - 1) * leftb, $
                    subvars=list(left, right))
end


;= property access

pro mg_ad_var::getProperty, a=a, b=b
  compile_opt strictarr

  if (arg_present(a)) then a = *self.a
  if (arg_present(b)) then b = *self.b
end


pro mg_ad_var::setProperty, a=a, b=b
  compile_opt strictarr

  if (n_elements(a) gt 0L) then *self.a = a
  if (n_elements(b) gt 0L) then *self.b = b  
end


;= lifecycle methods

pro mg_ad_var::cleanup
  compile_opt strictarr

  ptr_free, self.a, self.b
  foreach v, self.subvars do obj_destroy, v
  obj_destroy, self.subvars
end


function mg_ad_var::init, a, b, subvars=subvars
  compile_opt strictarr

  self.a = ptr_new(a)
  self.b = ptr_new(n_elements(b) eq 0L ? (dblarr(n_elements(a)) + 1.0D) : b)

  _subvars = list(subvars, /extract)
  self.subvars = list(_subvars->filter(lambda(x : isa(x, 'mg_ad_var'))), /extract)

  obj_destroy, _subvars
  if (obj_valid(subvars)) then begin
    obj_destroy, subvars
  endif

  return, 1
end


pro mg_ad_var__define
  compile_opt strictarr

  !null = {mg_ad_var, inherits IDL_Object, $
           a: ptr_new(), $
           b: ptr_new(), $
           subvars: obj_new()}
end


; main-level example

old_quiet = !quiet
!quiet = 1

x = mg_ad_var(2.0, 1.0)
print, x, format='(%"For x = %s:")'

y1 = 2.0 * x ^ 2 - 3.0 * x
print, y1, format='(%"  2x^2 - 3x = %s")'

y2 = 1.0 / x
print, y2, format='(%"  1/x = %s")'

y3 = 5 * mg_ad_exp(2 * x)
print, y3, format='(%"  5 e^(2x) = %s")'

y4 = 5 * mg_ad_alog(2 * x)
print, y4, format='(%"  5 ln(2x) = %s")'

y5 = 5 * mg_ad_abs(2 * x)
print, y5, format='(%"  5 abs(2x) = %s")'

obj_destroy, [y1, y2, y3, y4, y5]

print

t = mg_ad_var(!dpi, 1.0)
print, t, format='(%"For t = %s:")'

w1 = 2 * mg_ad_sin(2 * t)
print, w1, format='(%"  2 sin(2t) = %s")'

w2 = 2 * mg_ad_cos(2 * t)
print, w2, format='(%"  2 cos(2t) = %s")'

obj_destroy, [w1, w2]

; let's plot the logistic function and its derivative
x = mg_ad_var(10.0 * findgen(100) / 99 - 5.0)
y = 1.0 / (1 + mg_ad_exp(- x))

!p.multi = [0, 1, 2]

plot, x.a, y.a, xstyle=9, ystyle=9, $      ; logistic function values
      title='logistic function and its derivative'
oplot, x.a, y.b, linestyle=1               ; derivative

plot, x.a, y.b - deriv(x.a, y.a), $        ; error from DERIV
      xstyle=9, ystyle=9, $
      title='DERIV error'   

!p.multi = 0

!quiet = old_quiet

end
