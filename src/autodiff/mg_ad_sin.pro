; docformat = 'rst'

function mg_ad_sin, d
  compile_opt strictarr

  a = isa(d, 'mg_ad_var') ? d.a : d
  b = isa(d, 'mg_ad_var') ? d.b : 0

  return, mg_ad_var(sin(a), b * cos(a), subvars=list(d))
end
