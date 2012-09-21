; docformat = 'rst'

;+
; Produce a spectrogram of the given time series.
;
; :Categories:
;    graphics computation
;-

;+
; Produce a spectrogram.
;
; :Returns:
;    2-dimensional fltarr
; 
; :Params:
;    s : in, required, type=fltarr
;       input time series
;    windowSize : in, required, type=long
;       size of the window
;-
function vis_spectrogram, s, windowSize
  compile_opt strictarr

  result = fltarr(n_elements(s) - windowSize + 1L, windowSize)
  
  for w = 0L, n_elements(s) - windowSize do begin
    result[w, *] = abs(fft(s[w:w + windowSize - 1L])) ^ 2
  endfor
  
  return, result   
end


; main-level example program

openr, lun, file_which('damp_sn2.dat'), /get_lun
damp1 = bytarr(512)
readu, lun, damp1
free_lun, lun

device, get_decomposed=dec
device, decomposed=0
vis_loadct, 39

ws = 5
vis_image, alog10(congrid(vis_spectrogram(damp1, ws), 512 - ws + 1, 100)), /new_window

device, decomposed=dec

end
