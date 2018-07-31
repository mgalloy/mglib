; docformat = 'rst'

;+
; Produce a labelled heatmap.
;
; .. image:: heatmap.png
;
; :Params:
;   arr : in, required, type=2-dimensional numeric array
;     array to display
;
; :Keywords:
;   x_labels : in, optional, type=starr
;     labels for the x-axis
;   y_labels : in, optional, type=starr
;     labels for the y-axis
;   _extra : in, optional, type=keywords
;     keywords to `MG_IMAGE`
;-
pro mg_heatmap, arr, $
                x_labels=x_labels, $
                y_labels=y_labels, $
                _extra=e
  compile_opt strictarr

  dims = size(arr, /dimensions)
  mg_image, arr, scale=30, /axes, $
            xtickname=strarr(dims[0] + 1) + ' ', $
            ytickname=strarr(dims[1] + 1) + ' ', $
            xminor=1, yminor=1, $
            xticks=dims[0], yticks=dims[1], $
            _extra=e

  text_height = 0.30

  if (n_elements(x_labels) gt 0L) then begin
    for i = 0L, n_elements(x_labels) - 1L do begin
      xyouts, i + (1.0 + text_height) / 2.0, -0.5, x_labels[i], /data, alignment=1.0, orientation=90
    endfor
  endif

  if (n_elements(y_labels) gt 0L) then begin
    for i = 0L, n_elements(y_labels) - 1L do begin
      xyouts, - 0.5, i + (1.0 - text_height) / 2.0, y_labels[i], /data, alignment=1.0
    endfor
  endif
end


; main-level example program

demo = 0

device, get_decomposed=dec, decomposed=0
mg_loadct, 5

if (keyword_set(demo)) then begin
  mg_psbegin, filename='heatmap.ps', /image, xsize=6, ysize=4, /inches
  charsize = 0.75

  mg_window, xsize=5.5, ysize=7, /inches, /free
endif


x = randomu(seed, 8, 8) + rotate(2.0 * diag_matrix((randomu(seed, 8) + 0.5)), 1)
names = ['Ariel Sharon', $
         'Colin Powell', $
         'Donald Rumsfeld', $
         'George W Bush', $
         'Gerhard Schroeder', $
         'Hugo Chavez', $
         'Junichiro Koizumi', $
         'Tony Blair']
mg_heatmap, x, x_labels=names, y_labels=names, $
            /new_window, position=[0.32, 0.32, 0.95, 0.95], $
            charsize=charsize

if (keyword_set(demo)) then begin
  mg_psend
  device, decomposed=dec

  mg_convert, 'heatmap', max_dimensions=[400, 400], output=im
  mg_image, im, /new_window
  write_png, 'heatmap.png', im
endif

end

