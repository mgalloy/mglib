; docformat = 'rst'

;+
; Perform  Empirical Mode Decomposition (EMD), created by Huang, N. E. et al.
; EMD decomposes a signal into intrinsic mode functions (IMF), which can be
; used to build the power-spectra (using `HILBERTSPEC`) with wavelets.
;
; See `https://en.wikipedia.org/wiki/Hilbert–Huang_transform` for more
; information and a list of references.
;
; The signal will be decomposed into a maximum number of `max_componnents`
; (default: 20) IMF components.
;
; :Categories:
;   signal processing
;
; :Returns:
;   the return variable contains the decomposed intrinsic mode functions,
;   `fltarr(n_components, n)`
;
; :Params:
;   signal : in, required, type=fltarr(n)
;     a 1D time series
;   sda : in, required, type=float
;     standard deviation to be achieved before accepting an IMF (recommended
;     value between 0.2 and 0.3; perhaps even smaller)
;
; :Keywords:
;   n_components : out, optional, type=long
;     set to a named variable to retrieve the number of components found
;   max_componnents : in, optional, type=integer, default=20
;     set to the maximum number of components to look for
;
; :Examples:
;   For example::
;
;     IDL> n = 360
;     IDL> x = findgen(n) * !dtor
;     IDL> y = sin(2 * x) + 1.5 * sin(5 * x) + 0.25 * cos(7 * x) + 0.5 * randomu(seed, n)
;     IDL> imf = mg_emd(y, 0.3, dt=!dtor, n_components=n_components)
;
; :Authors:
;   Michael Galloy <mgalloy@gmail.com>
;
;   adapted from code written by Jaume Terradas Calafell
;   Departament de Fisica
;   Universitat de les Illes Balears
;   email: jaume.terradas@uib.es
;
; :History:
;   slight modifiaction of emdecomp.pro
;   Written by:     Jaume Terradas, 29 Dec 2001
;   Jaume Terradas, 20 Jan 2002, option to add characteristic waves at ends
;   Ramon Oliver, 2004, routines written in nice idl format
;   Jaume Terradas 22-6-2009, minor changes
;   Nabil Freij, 11/11/11, Changed the plotting routines
;   Peter Keys, 11/14, Making it nicer/easier to understand and changing the plots
;   Peter Keys, 11/14, Changed to function to output the plots as various arrays
;   Peter Keys, 11/14, Changed the cap on number of IMFs (was 12 originally now 20)
;   Michael Galloy, 15 Jan 2020, removed plotting code, added components keywords
;-
function mg_emd, signal, sda, $
                 n_components=n_components, max_components=max_components
  compile_opt strictarr
  on_error, 2

  n_dims = size(signal, /n_dimensions)
  if (n_dims ge 3) then begin
    message, string(n_dims, $
                    format='(%"invalid number of dimensions for signal: %")')
  endif

  ; make sure signal is double precision
  _signal = double(signal)

  ; to extend at the ends of extrema
  waveextensionm = 1B

  ; to control large swings at the ends
  controlext = 1B

  n_signal = n_elements(signal)
  time = dindgen(n_signal)

  ; setting up some IMF/EMD parameters

  ; maximum number of IMFs that can be created
  _max_components = n_elements(max_components) eq 0L ? 20L : max_components
  imf = dblarr(_max_components, n_signal)
  d = dblarr(n_signal - 1)
  h = dblarr(n_signal)
  x = time
  time1 = time
  n_components = 1

  for t = 0L, _max_components - 1L do begin
    h = _signal
    sd = 1.0
    control = 0
    while (sd gt sda) do begin
      for k = 0, n_signal - 2 do begin
        d[k] = h[k + 1] - h[k]
      endfor

      maxmin=[0]

      ; deal with the extrema
      for i = 0L, n_signal - 3L do begin
        if ((d[i] eq 0.0D) and (i ne 0)) then begin
          if (d[i - 1] * d[i + 1] lt 0.0) then maxmin = [maxmin, i]
        endif else begin
          if (d[i] * d[i + 1] lt 0.0) then maxmin = [maxmin, i + 1]
        endelse
      endfor

      if (n_elements(maxmin) gt 1) then maxmin = maxmin[1:*]
      smaxmin = n_elements(maxmin)
      if (smaxmin le 2L) then begin
        control = -1
        goto, jump
      endif

      maxes = [0]
      mins  = [0]
      if (h[maxmin[0]] gt h[maxmin[1]]) then begin
        for j = 0, smaxmin - 1, 2 do begin
	        maxes = [maxes, maxmin[j]]
	        if (j + 1 le smaxmin - 1) then mins = [mins, maxmin[j + 1]]
        endfor
      endif else begin
        for j = 0, smaxmin - 1, 2 do begin
	        mins = [mins, maxmin[j]]
	        if (j + 1 le smaxmin - 1) then maxes = [maxes, maxmin[j + 1]]
        endfor
      endelse

      maxes = maxes[1:*]
      mins = mins[1:*]
      nmax = n_elements(maxes)
      nmin = n_elements(mins)

      ; begin extending at the ends of the extrema
      if (keyword_set(waveextensionm)) then begin
        maxes1 = [0, $
                  maxes[0], $
                  maxes + maxes[0], $
                  - maxes[nmax - 1] + 2 * (n_signal - 1) + maxes[0], $
                  2 * (n_signal - 1 - maxes[nmax - 1]) + n_signal - 1 + maxes[0]]
        hmodmax = [h[maxes[0]], $
                   h[maxes[0]], $
                   h[maxes], $
                   h[maxes[nmax - 1]], $
                   h[maxes[nmax-1]]]
        y2 = spl_init(maxes1, hmodmax)
        maxenv = spl_interp(maxes1, hmodmax, y2, time1 + maxes[0])

        mins1 = [0, mins[0], $
                 mins + mins[0], $
                 - mins[nmin - 1] + 2 * (n_signal - 1) + mins[0], $
                 2 * (n_signal-1 - mins[nmin - 1]) + n_signal - 1 + mins[0]]
        hmodmin = [h[mins[0]], $
                   h[mins[0]], $
                   h[mins], $
                   h[mins[nmin - 1]], $
                   h[mins[nmin - 1]]]
        y2 = spl_init(mins1, hmodmin)
        minenv = spl_interp(mins1, hmodmin, y2, time1 + mins[0])
      endif

      increm = 0.0
      timeenvmax = time1
      timeenvmin = time1

      if (keyword_set(controlext)) then begin
        if (h[0] gt maxenv[0]) and (h[n_signal - 1] gt maxenv[n_signal - 1]) then begin
          maxes1 = [0, maxes, n_signal - 1]
          hmodmax = [h[0] + increm, h[maxes], h[n_signal - 1] + increm]
          timeenvmax = time1
          y2 = spl_init(maxes1, hmodmax)
          maxenv = spl_interp(maxes1, hmodmax, y2, time1)
        endif else begin
          if (h[0] gt maxenv[0]) then begin
            maxes1 = [0, $
                      maxes, $
                      - maxes[nmax - 1] + 2 * (n_signal - 1), $
                      2 * ((n_signal - 1) - maxes[nmax - 1]) + n_signal - 1]
            hmodmax = [h[0] + increm, $
                       h[maxes], $
                       h[maxes[nmax - 1]], $
                       h[maxes[nmax - 1]]]
            timeenvmax = time1
            y2 = spl_init(maxes1, hmodmax)
            maxenv = spl_interp(maxes1, hmodmax, y2, time1)
          endif

          if (h[n_signal - 1] gt maxenv[n_signal - 1]) then begin
            maxes1 = [0, maxes[0], maxes + maxes[0], maxes[0] + n_signal - 1]
            hmodmax = [h[maxes[0]], h[maxes[0]], h[maxes], h[n_signal - 1] + increm]
            timeenvmax = time1 + maxes[0]
            y2 = spl_init(maxes1, hmodmax)
            maxenv = spl_interp(maxes1, hmodmax, y2, time1 + maxes[0])
          endif
        endelse

        if (h[0] lt minenv[0]) and (h[n_signal - 1] lt minenv[n_signal - 1]) then begin
          mins1 = [0, mins, n_signal - 1]
          hmodmin = [h[0] - increm, h[mins], h[n_signal - 1] - increm]
          timeenvmin = time1
          y2 = spl_init(mins1, hmodmin)
          minenv = spl_interp(mins1, hmodmin, y2, time1)
        endif else begin
          if (h[0] lt minenv[0]) then begin
            mins1 = [0, $
                     mins, $
                     - mins[nmin - 1] + 2 * (n_signal - 1), $
                     2 * (n_signal - 1 - mins[nmin - 1]) + n_signal - 1]
            hmodmin = [h[0] - increm, $
                       h[mins], $
                       h[mins[nmin - 1]], $
                       h[mins[nmin - 1]]]
            timeenvmin = time1
            y2 = spl_init(mins1,hmodmin)
            minenv = spl_interp(mins1, hmodmin, y2, time1)
          endif

          if (h[n_signal - 1] lt minenv[n_signal - 1]) then begin
            mins1 = [0, mins[0], mins + mins[0], mins[0] + n_signal - 1]
            hmodmin = [h[mins[0]], h[mins[0]], h[mins], h[n_signal - 1] - increm]
            timeenvmin = time1 + mins[0]
            y2 = spl_init(mins1, hmodmin)
            minenv = spl_interp(mins1, hmodmin, y2, time1 + mins[0])
          endif
        endelse
      endif

      if ((abs(minenv[0]) eq !values.f_nan) $
            or (abs(maxenv[0]) eq !values.f_nan)) then begin
        message, 'NaN values found'
      endif

      m = (maxenv + minenv) / 2.0
      prevh = h
      h -= m

      sd = total((prevh - h)^2 / (prevh^2))
    endwhile

    jump:
    dims = size(maxmin, /dimensions)
    imf[t, *] = h[*]

    if (dims[0] le 2) or (control eq -1) then begin
      n_components += 1l
      goto, done
    endif
    n_components += 1l
    _signal -= h
  endfor

  done:
  n_components -= 1L

  ; remove unneeded space in the IMF array
  imf = imf[0:n_components - 1L, *]

  return, imf
end


; main-level example program

n = 360
x = findgen(n) * !dtor
y = sin(2 * x) + 1.5 * sin(5 * x) + 0.25 * cos(7 * x) + 0.5 * randomu(seed, n)
window, xsize=800, ysize=250, title='Original signal', /free
plot, x, y, xstyle=9, ystyle=8

imf = mg_emd(y, 0.3, n_components=n_components)
window, xsize=800, ysize=250 * n_components, title='IMF components', /free
!p.multi = [0, 1, n_components]
for c = 0L, n_components - 1L do plot, x, imf[c, *], xstyle=9, ystyle=8, charsize=2.0
!p.multi = 0

window, xsize=800, ysize=250, title='Reconstruction error', /free
plot, x, y - total(imf, 1), xstyle=9, ystyle=8

end
