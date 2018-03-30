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
;   IDL> x = mg_dual_number(2, 1)
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

pro mg_dual_number::_decompose, left, right, $
                                lefta=lefta, leftb=leftb, $
                                righta=righta, $
                                rightb=rightb
  compile_opt strictarr

  lefta = isa(left, 'mg_dual_number') ? left.a : left
  leftb = isa(left, 'mg_dual_number') ? left.b : 0

  righta = isa(right, 'mg_dual_number') ? right.a : right
  rightb = isa(right, 'mg_dual_number') ? right.b : 0
end


;= operator overload methods

function mg_dual_number::_overloadPrint
  compile_opt strictarr

  return, string(self.a, self.b, format='(%"%g + %ge")')
end


function mg_dual_number::_overloadHelp, name
  compile_opt strictarr

  type = 'DUAL'
  info = string(self.a, self.b, format='(%"<%g + %ge>")')
  return, string(name, type, info, format='(%"%-15s %-9s = %s")')
end


function mg_dual_number::_overloadPlus, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_dual_number(lefta + righta, leftb + rightb)
end


function mg_dual_number::_overloadMinus, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_dual_number(lefta - righta, leftb - rightb)
end


function mg_dual_number::_overloadAsterisk, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_dual_number(lefta * righta, leftb * righta + lefta * rightb)
end


function mg_dual_number::_overloadSlash, left, right
  compile_opt strictarr

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb

  return, mg_dual_number(lefta * righta / (righta * righta), $
                         (leftb * righta - lefta * rightb) / (righta * righta))
end


function mg_dual_number::_overloadCaret, left, right
  compile_opt strictarr
  on_error, 2

  self->_decompose, left, right, $
                    lefta=lefta, leftb=leftb, $
                    righta=righta, rightb=rightb
  if (rightb ne 0.0) then message, 'unable to handle dual exponent'

  return, mg_dual_number(lefta ^ righta, $
                         righta * lefta ^ (righta - 1) * leftb)
end


;= property access

pro mg_dual_number::getProperty, a=a, b=b
  compile_opt strictarr

  if (arg_present(a)) then a = self.a
  if (arg_present(b)) then b = self.b
end


pro mg_dual_number::setProperty, a=a, b=b
  compile_opt strictarr

  if (n_elements(a) gt 0L) then self.a = a
  if (n_elements(b) gt 0L) then self.b = b  
end


;= lifecycle methods

pro mg_dual_number::cleanup
  compile_opt strictarr

end

function mg_dual_number::init, a, b
  compile_opt strictarr

  self.a = a
  self.b = b

  return, 1
end


pro mg_dual_number__define
  compile_opt strictarr

  !null = {mg_dual_number, inherits IDL_Object, $
           a: 0.0D, $
           b: 0.0D}
end


; main-level example

old_quiet = !quiet
!quiet = 1

x = mg_dual_number(2.0, 1.0)
print, x, format='(%"For x = %s:")'
print, 2.0 * x ^ 2 - 3.0 * x, format='(%"  2x^2 - 3x = %s")'
print, 1.0 / x, format='(%"  1/x = %s")'

print, 5 * mg_ad_exp(2 * x), format='(%"  5 e^(2x) = %s")'
print, 5 * mg_ad_alog(2 * x), format='(%"  5 ln(2x) = %s")'
print, 5 * mg_ad_abs(2 * x), format='(%"  5 abs(2x) = %s")'

print

t = mg_dual_number(!dpi, 1.0)
print, t, format='(%"For t = %s:")'
print, 2 * mg_ad_sin(2 * t), format='(%"  2 sin(2t) = %s")'
print, 2 * mg_ad_cos(2 * t), format='(%"  2 cos(2t) = %s")'

!quiet = old_quiet

end
