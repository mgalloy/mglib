; docformat = 'rst'

function mg_ad_exp, d
  compile_opt strictarr

  a = isa(d, 'mg_ad_var') ? d.a : d
  b = isa(d, 'mg_ad_var') ? d.b : 0

  return, mg_ad_var(exp(a), b * exp(a), subvars=list(d))
end
