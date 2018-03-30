; docformat = 'rst'

function mg_ad_exp, d
  compile_opt strictarr

  a = isa(d, 'mg_dual_number') ? d.a : d
  b = isa(d, 'mg_dual_number') ? d.b : 0

  return, mg_dual_number(exp(a), b * exp(a))
end
