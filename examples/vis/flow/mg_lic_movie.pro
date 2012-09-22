; docformat = 'rst'

;+
; Main-level program that demonstrates the use of `MG_LIC` with the `TEXTURE`
; keyword to make a movie.
;-

restore, filename='ye.sav'

mg_loadct, 9, /brewer
tvlct, ctr, ctg, ctb, /get
lic_im = bytarr(3, 300, 300)

tex = byte(255 * randomu(seed, 300, 300))
ye = rebin(ye, 3, 30, 30, 300)

if (~file_test('lic_movie', /directory)) then file_mkdir, 'lic_movie'

for i = 0, 299 do begin
  u = rebin(reform(ye[0, *, *, i]), 300, 300)
  v = rebin(reform(ye[1, *, *, i]), 300, 300)
  
  im = mg_lic(u, v, texture=tex)
  
  lic_im[0, *, *] = im
  lic_im[1, *, *] = im
  lic_im[2, *, *] = im
      
  mag = sqrt(u * u + v *v)
  m = mag / max(mag)

  mscaled = bytscl(m)
  m_image = fltarr(3L, 300, 300)
  m_image[0, *, *] = ctr[mscaled] / 255.0
  m_image[1, *, *] = ctg[mscaled] / 255.0
  m_image[2, *, *] = ctb[mscaled] / 255.0

  im2 = lic_im * m_image

  ind = where(u eq 0 and v eq 0, count)
  if (count gt 0) then im2[[3 * ind, 3 * ind + 1, 3 * ind + 2]] = 255B
  
  tv, im2, true=1
  write_png, filepath('ye' + strtrim(i, 2) + '.png', $
                      subdir='lic_movie', $
                      root='.'), $
             im2
endfor

end