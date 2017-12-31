; docformat = 'rst'

;= API

;+
; :Abstract:
;-
function mg_distribution::select, n
  compile_opt strictarr

  ; not implemented
end


;= property cycle

;= lifecycle

pro mg_distribution::cleanup
  compile_opt strictarr

  ptr_free, self.seed
end


function mg_distribution::init, seed=seed
  compile_opt strictarr

  self.seed = ptr_new(seed)

  return, 1
end


pro mg_distribution__define
  compile_opt strictarr

  !null = {mg_distribution, inherits IDL_Object, $
           seed: ptr_new()}
end
