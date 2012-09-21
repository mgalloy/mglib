; docformat = 'rst'

;+
; Pure IDL implementation of the RADON routine.
;
; :Todo:
;    implement forward projection
;
; :Returns:
;    fltarr
;
; :Params:
;    arr : in, required, type=fltarr
;       array to transform or backproject
;
; :Keywords:
;    backproject : in, optional, type=boolean
;       set to perform backprojection instead of forward Radon transform
;    rho : in, optional, type=fltarr
;    theta : in, optional, type=fltarr
;    dx : in, optional, type=float, default=1.0
;    dy : in, optional, type=float, default=1.0
;    nx : in, optional, type=float, default=
;       when doing a backprojection, this specifies x-size of the output; the
;       default is::
;
;          floor(2 * ((drho * nrho / 2.) / sqrt(_dx * _dx + _dy * _dy)) + 1.)
;
;    ny : in, optional, type=float
;       when doing a backprojection, this specifies y-size of the output; the
;       default is::
;
;          floor(2 * ((drho * nrho / 2.) / sqrt(_dx * _dx + _dy * _dy)) + 1.)
;
;    xmin : in, optional, type=float, default=- _dx * (_nx - 1.) / 2.
;    ymin : in, optional, type=float, default=- _dy * (_ny - 1.) / 2.
;-
function mg_radon, arr, backproject=backproject, $
                   nrho=nrho, ntheta=ntheta, rho=rho, theta=theta, $
                   dx=dx, dy=dy, nx=nx, ny=ny, xmin=xmin, ymin=ymin
  compile_opt strictarr
  on_error, 2

  _dx = n_elements(dx) eq 0L ? 1.0 : dx
  _dy = n_elements(dy) eq 0L ? 1.0 : dy
    
  dims = size(arr, /dimensions)
  
  if (keyword_set(backproject)) then begin        
    ntheta = dims[0]
    nrho = dims[1]
    dtheta = !pi / ntheta
    drho = sqrt(_dx * _dx + _dy * _dy) / 2.

    rhomin = - (nrho - 1.) * drho / 2.

    _theta = n_elements(theta) eq 0L ? findgen(ntheta) * dtheta : theta
    
    _dim = floor(2 * ((drho * nrho / 2.) / sqrt(_dx * _dx + _dy * _dy)) + 1.)
    _nx = n_elements(nx) eq 0L ? _dim : nx
    _ny = n_elements(ny) eq 0L ? _dim : ny

    _xmin = n_elements(xmin) eq 0L ? (- _dx * (_nx - 1.) / 2.) : xmin
    _ymin = n_elements(ymin) eq 0L ? (- _dy * (_ny - 1.) / 2.) : ymin
    
    backproject = fltarr(_nx, _ny)
    
    for m = 0L, _nx - 1L do begin
      for n = 0L, _ny - 1L do begin
        for t = 0L, ntheta - 1L do begin
          p = round(((m * _dx + _xmin) * cos(_theta[t]) $
                      + (n * _dy + _ymin) * sin(_theta[t]) $
                      - rhomin) / drho)

          backproject[m, n] += arr[t, 0L > p < (dims[1] - 1L)]
        endfor
      endfor
    endfor
    
    backproject *= dtheta
    
    return, backproject
  endif else begin
    nx = dims[0]
    ny = dims[1]

    _nrho = n_elements(nrho) eq 0L ? 100L : nrho
    drho = sqrt(_dx * _dx + _dy * _dy) / 2.
    _rmin = n_elements(rmin) eq 0L ? (- _nrho - 1.) / 2. * drho : rmin
    rho = n_elements(rho) eq 0L ? (findgen(_nrho) * drho + _rmin) : rho
    
    _ntheta = n_elements(ntheta) eq 0L ? 180L : ntheta
    dtheta = !pi / _ntheta
    theta = n_elements(theta) eq 0L ? findgen(_ntheta) * dtheta : theta

    _xmin = n_elements(xmin) eq 0L ? (- _dx * (nx - 1.) / 2.) : xmin
    _ymin = n_elements(ymin) eq 0L ? (- _dx * (ny - 1.) / 2.) : ymin
    
    transform = fltarr(_ntheta, _nrho)
    
    for t = 0L, _ntheta - 1L do begin
      if (abs(sin(theta[t])) gt sqrt(2.) / 2.) then begin
        for r = 0L, _nrho - 1L do begin
          a = - _dx / _dy * cos(theta[t]) / sin(theta[t])
          b = (rho[r] - _xmin * cos(theta[t]) - _ymin * sin(theta[t])) / (_dy * sin(theta[t]))
          
          for m = 0L, nx - 1L do begin
            transform[t, r] += arr[m, 0L > round(a * m + b) < (ny - 1L)]
          endfor
          
          transform[t, r] *= _dx / abs(sin(theta[t]))
        endfor
      endif else begin
        for r = 0L, _nrho - 1L do begin
          a = - _dy / _dx * sin(theta[t]) / cos(theta[t])
          b = (rho[r] - _xmin * cos(theta[t]) - _ymin * sin(theta[t])) / (_dx * cos(theta[t]))
          
          for n = 0L, ny - 1L do begin
            transform[t, r] += arr[0L > round(a * n + b) < (nx - 1L), n]
          endfor
          
          transform[t, r] *= _dy / abs(cos(theta[t]))
        endfor
      endelse
    endfor
    
    return, transform
  endelse
end


; main-level example program

m = 100
n = 100
x = (lindgen(m, n) mod m) - (n - 1.) / 2. 
y = (lindgen(m, n) / m) - (n - 1.) / 2.
radius = sqrt(x^2 + y^2)  
array = (radius gt 25) and (radius lt 35)  
array = array + randomu(seed, m, n)

dims = size(array, /dimensions)
window, /free, title='Original', xsize=dims[0], ysize=dims[1]
tvscl, array

result = radon(array, rho=rho, theta=theta, nrho=100, ntheta=100)
dims = size(result, /dimensions)
window, /free, title='RADON transform', xsize=dims[0], ysize=dims[1]
tvscl, result

backproject = radon(result, /backproject, rho=rho, theta=theta, nx=100, ny=100) 
dims = size(backproject, /dimensions)
window, /free, title='RADON backprojection', xsize=dims[0], ysize=dims[1]
tvscl, backproject

mg_backproject = mg_radon(result, /backproject, rho=rho, theta=theta, nx=100, ny=100) 
dims = size(mg_backproject, /dimensions)
window, /free, title='MG_RADON Backprojection', xsize=dims[0], ysize=dims[1]
tvscl, mg_backproject

end

   