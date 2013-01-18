; docformat = 'rst'

;+
; Used in conjunction with `MG_PSBEGIN` to end PostScript output.
;-
pro mg_psend
  compile_opt strictarr
  common _$mg_ps, origdev, _image, psconfig

  if (!d.name eq 'PS') then device, /close_file

  set_plot, origdev

  if (_image) then begin
    !p.charsize = psconfig.pcharsize
    !p.thick = psconfig.pthick
    !x.thick = psconfig.xthick
    !y.thick = psconfig.ythick
    !z.thick = psconfig.zthick
    !p.symsize = psconfig.psymsize
    !p.font = psconfig.pfont
    ;device, set_font='Helvetica', /tt_font
  endif
end
