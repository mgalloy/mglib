; docformat = 'rst'

;+
; Calculate a "cube helix" color table. Based on the FORTRAN 77 code provided
; in D.A. Green, 2011, BASI, 39, 289::
;
;   http://adsabs.harvard.edu/abs/2011arXiv1108.5083G
;
; From the example code in the paper: "Calculates a 'cube helix' colour table.
; The colors are a tapered helix around the diagonal of the [R, G, B] color
; cube, from black [0,0,0] to white [1, 1, 1]. Deviations away from the
; diagonal vary quadratically, increasing from zero at black, to a maximum,
; then decreasing to zero at white, all the time rotating in colour."
;
; :Keywords:
;   start : in, optional, type=float, default=0.5
;     color (1=red, 2=green, 3=blue), e.g.  0.5=purple
;   rotations : in, optional, type=float, default=-1.5
;     rotations in color, typically -1.5 to 1.5, e.g., -1.0 is one blue to green
;     to red cycle
;   gamma : in, optional, type=float, default=1.0
;     set the gamma correction for intensity
;   hue : in, optional, type=float, default=1.0
;     hue intensity scaling, in the range 0 (BW) to 1; to be strictly correct,
;     larger values may be OK with particular star/end colors
;   ncolors : in, optional, type=int, default=!d.table_size
;     number of colors to output
;   rgb_table : out, optional, type="bytarr(256, 3)"
;     set to a named variable to retrieve the color table as an array containing
;     the color table values
;
; :Examples:
;   Create the default cube helix color table and display it in a direct
;   graphics window::
;
;     IDL> mg_cubehelix
;     IDL> device, decomposed=0
;     IDL> tv, bindgen(256) # (bytarr(10) + 1B)
;
; :History:
;   Derived from James R.A. Davenport's `CUBEHELIX` routine
;-
pro mg_cubehelix, start=start, rotations=rotations, hue=hue, gamma=gamma, $
                  ncolors=ncolors, rgb_table=rgb_table
  compile_opt strictarr

  ; use defaults from the paper if not otherwise set
  _ncolors = n_elements(ncolors) eq 0L ? !d.table_size : n_colors
  _start = n_elements(start) eq 0L ? 0.5 : start   ; purple
  _rotations = n_elements(rotations) eq 0L ? -1.5 : rotations
  _gamma = n_elements(gamma) eq 0L ? 1.0 : gamma
  _hue = n_elements(hue) eq 0L ? 1.0 : hue

  fract = findgen(_ncolors) / (_ncolors - 1.0)
  angle = 2.0 * !dpi * (_start / 3.0 + 1.0 + _rotations * fract)
  fract = fract ^ _gamma
  amp   = _hue * fract * (1.0 - fract) / 2.0

  r = fract + amp * (-0.14861 * cos(angle) + 1.78277 * sin(angle))
  g = fract + amp * (-0.29227 * cos(angle) - 0.90649 * sin(angle))
  b = fract + amp * ( 1.97294 * cos(angle))
  
  nhi = total(b gt 1) + total(g gt 1) + total(r gt 1)
  nlo = total(b lt 0) + total(g lt 0) + total(r lt 0)

  if (total(nhi) gt 0) then begin
    message, 'Warning: color-clipping on high-end', /informational
  endif

  if (total(nlo) gt 0) then begin
    message, 'Warning: color-clipping on low-end', /informational
  endif

  r >= 0.
  g >= 0.
  b >= 0.

  xr = where(r gt 1, nxr)
  xg = where(g gt 1, nxg)
  xb = where(b gt 1, nxb)

  if (nxr gt 0L) then r[xr] = 1.0
  if (nxg gt 0L) then g[xg] = 1.0
  if (nxb gt 0L) then b[xb] = 1.0

  ; output the color vectors if requested
  if (arg_present(rgb_table)) then begin
    rgb_table = byte([[r], [g], [b]])
  endif else begin
    tvlct, byte(r * 254.0), byte(g * 254.0), byte(b * 254.0)
  endelse
end


; main-level example program

mg_cubehelix           
device, decomposed=0
tv, bindgen(256) # (bytarr(10) + 1B)

end
