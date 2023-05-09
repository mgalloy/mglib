; docformat = 'rst'

;+
; Apply gamma correction to the color table.
;
; The gamma correction is implemented as x^gamma, where x is the range of color
; table indices scaled from 0 to 1.
;
; This changes the current color table, as well as the values in the `colors`
; common block.
;
; :Params:
;   gamma : in, optional, type-float, default=1.0
;     The value of gamma correction. A value of 1.0 indicates a linear ramp,
;     i.e., no gamma correction. Higher values of gamma give more contrast.
;     Values less than 1.0 yield lower contrast.
;
; :Keywords:
;   current : in, optional, type=boolean
;     If this keyword is set, apply correction from the current table.
;     Otherwise, apply from the original color table. When `CURRENT` is set,
;     the color table input to `GAMMA_CT` is taken from the `R_CURR`, `G_CURR`,
;     and `B_CURR` variables in the `colors` common block. Otherwise, input is
;     from `R_ORIG`, `G_ORIG`, and `B_ORIG` from the `colors` common block. The
;     resulting tables are always saved in the "current" table.
;   intensity : in, option, type=boolean
;     If this keyword is set, correct the individual intensities of each color
;     in the color table. Otherwise, shift the colors according to the gamma
;     function.
;   n_colors : in, optional, type=long, default=!d.table_size
;     Set this to the number of colors to correct in the color table. If not set
;     all values in the color table will be corrected.
;
; :history:
;   DMS, Oct, 1990. Added ability shift intensities of colors, rather
;     than the mapping of the colors. DMS, April, 1991.
;-
pro mg_gamma_ct, gamma, current=current, intensity=intensity, n_colors=n_colors
  compile_opt strictarr
  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  n = n_elements(n_colors) eq 0L ? !d.table_size : n_colors

  if (n_elements(r_orig) le 0) then begin
    r_orig = indgen(n)
    r_curr = r_orig
    g_orig = r_orig
    g_curr = g_orig
    b_orig = r_orig
    b_curr = b_orig
  endif

  _gamma = n_elements(gamma) eq 0L ? 1.0 : gamma

if (keyword_set(intensity)) then begin
  s = byte(256.0 * ((findgen(256) / 256.0)^_gamma))
  if (keyword_set(current)) then begin   ; scale color mapping, not intensities
    r_curr = s[r_curr]
    g_curr = s[g_curr]
    b_curr = s[b_curr]
  endif else begin
    r_curr = s[r_orig]
    g_curr = s[g_orig]
    b_curr = s[b_orig]
  endelse
endif else begin   ; scale color mapping, not intensities
  s = long(n * ((findgen(n) / n)^_gamma))
  if (keyword_set(current)) then begin
    r_curr = r_curr[s]
    g_curr = g_curr[s]
    b_curr = b_curr[s]
  endif else begin
    r_curr = r_orig[s]
    g_curr = g_orig[s]
    b_curr = b_orig[s]
  endelse
endelse

  tvlct, r_curr, g_curr, b_curr
end
