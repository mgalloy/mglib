; docformat = 'rst'

function mg_randomu, seed, d1, d2, d3, d4, d5, d6, d7, d8, $
                     poisson=poisson, _extra=e
  compile_opt strictarr
  on_error, 2

  if (n_elements(poisson) gt 1L) then begin
    if (n_elements(d1) gt 1L) then begin
      dims = d1
    endif else begin
      case n_params() of
        0: message, 'seed argument required'
        1: message, 'dimensions argument required'
        2: dims = [d1]
        3: dims = [d1, d2]
        4: dims = [d1, d2, d3]
        5: dims = [d1, d2, d3, d4]
        6: dims = [d1, d2, d3, d4, d5]
        7: dims = [d1, d2, d3, d4, d5, d6]
        8: dims = [d1, d2, d3, d4, d5, d6, d7]
        9: dims = [d1, d2, d3, d4, d5, d6, d7, d8]
    endelse
    p = ulonarr(dims)
    for i = 0L, n_elements(p) - 1L do begin
      p[i] = randomu(seed, 1, poisson=poisson[i], _extra=e)
    endfor
    return, p
  endif else begin
    return, randomu(seed, d1, d2, d3, d4, d5, d6, d7, d8, $
                    double=double, poisson=poisson, _extra=e)
  endelse
end


; main-level example program

x_org = randomn(seed, 1000)
p = mg_randomu(seed, 1000, poisson=10.0 * exp(x_org))
print, histogram(p)

end

