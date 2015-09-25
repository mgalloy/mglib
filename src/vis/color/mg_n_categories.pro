; docformat = 'rst'

;+
; Return `n` decomposed colors for use as categories, i.e., legends,
; etc.
;
; :Returns:
;   `lonarr`
;
; :Params:
;   n : in, requird, type=integer
;     number of colors required
;
; :Keywords:
;   brewer_ct : in, optional, type=integer, default=27
;     Brewer qualitative color table to use
;-
function mg_n_categories, n, brewer_ct=brewer_ct
  compile_opt strictarr
  on_error, 2

  _brewer_ct = n_elements(brewer_ct) eq 0L ? 27L : brewer_ct

  ct_colors = [12, 9, 9, 8, 8, 8, 12, 8]

  if (_brewer_ct lt 27 || _brewer_ct gt 34) then begin
    message, 'invalid Brewer color table: ' + strtrim(_brewer_ct, 2)
  endif

  ; might not be able to give all n colors
  _n = n < ct_colors[_brewer_ct - 27L]

  tvlct, orig_rgb, /get
  mg_loadct, _brewer_ct, /brewer
  tvlct, rgb, /get

  colors = mg_rgb2index(rgb[0:_n - 1L, *])

  tvlct, orig_rgb

  return, colors
end
