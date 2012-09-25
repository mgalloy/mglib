; docformat = 'rst'

;+
; Set IDL direct graphics system to PostScript plotting.
;
; :Examples:
;    Running the main-level program attached to this program::
;
;       IDL> .run mg_psbegin
;
;    Should produce the following image:
; 
;    .. image:: maroonbells.png
;
; :Keywords:
;    image : in, optional, type=boolean
;       set to configure PostScript with a few defaults specific to converting
;       the PostScript output to an image format later
;    charsize : in, optional, type=float, default=1.0 or 1.25
;       default CHARSIZE to use (defaults to 1.25 if IMAGE is set)
;    thick : in, optional, type=float, default=1.0 or 2.0
;       default THICK to use (defaults to 2.0 if IMAGE is set)
;    symsize : in, optional, type=float, default=1.0 or 1.25
;       default SYMSIZE to use (defaults to 1.25 if IMAGE is set)
;    _extra : in, optional, type=keywords
;       keywords to DEVICE to configure the PostScript device
;-
pro mg_psbegin, image=image, $
                charsize=charsize, thick=thick, symsize=symsize, $
                _extra=e
  compile_opt strictarr
  common _$mg_ps, origdev, _image, psconfig
  
  if (!d.name ne 'PS') then origdev = !d.name
  _image = keyword_set(image)
  set_plot, 'PS', /copy
  
  ; set some default settings if the intent is to produce postscript simply
  ; to convert to an image format later
  if (_image) then begin
    psconfig = { pcharsize: !p.charsize, $
                 pthick: !p.thick, $
                 xthick: !x.thick, $
                 ythick: !y.thick, $
                 zthick: !z.thick, $
                 psymsize: !p.symsize, $
                 pfont: !p.font }
                 
    !p.charsize = n_elements(charsize) eq 0 ? 1. : charsize
    !p.thick    = n_elements(thick) eq 0    ? 1. : thick
    !x.thick    = n_elements(thick) eq 0    ? 1. : thick
    !y.thick    = n_elements(thick) eq 0    ? 1. : thick
    !z.thick    = n_elements(thick) eq 0    ? 1. : thick
    !p.symsize  = n_elements(symsize) eq 0  ? 1. : symsize
    !p.font = 0
    
    device, /helvetica
  endif
  
  device, /color, bits_per_pixel=8, _extra=e
end


; main-level example of using `MG_PSBEGIN`, in this case to ultimately create a 
; PNG file

; read in example data
bells = intarr(350, 450)
openr, lun, filepath('surface.dat', subdir=['examples', 'data']), /get_lun
readu, lun, bells
free_lun, lun

; set some variables
nlevels = 10
basename = 'maroonbells'

mg_psbegin, /image, filename=basename + '.ps', xsize=6, ysize=4, /inches

mg_decomposed, 0, old_decomposed=olddec
loadct, 0
mg_contour, bells, /nodata, xstyle=1, ystyle=1, title='Maroon Bells'

mg_loadct, 10, /brewer
mg_contour, bells, /fill, nlevels=nlevels, /overplot

loadct, 0
mg_contour, bells, nlevels=nlevels, /overplot, color=0

mg_decomposed, olddec

mg_psend
mg_convert, basename, max_dimensions=[500, 500], output=im

mg_image, im, /new_window

end