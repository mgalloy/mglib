; docformat = 'rst'

;+
; Processes specially formatted text output in `.ps` and `.eps` files with 
; LaTeX.
; 
; Keyword values to graphics command expecting strings to output as text can 
; be set to values like::
;
;    \tex[<posn>][<psposn>][<scale>][<rot>]{LATEX text}
;
; where `posn` and `psposn` are positions and can be one of the following::
;
;    bl = bottom left
;    c = center
;    t = top
;    r = right
;    B = baseline
;
; The `<scale>` parameter is used in place of the `CHARSIZE` keyword, which 
; will be ignored.
;
; This routine requires `sed`, `latex`, and `dvips` to be installed and 
; available in the system path. Also, `ps2eps` is needed to if the file to be 
; created is an `.eps` file.
;
; :Examples:
;    See the main-level program at the end of this file. To run it::
;
;       IDL> .run mg_psfrag
;
;    Produce a `.ps` or `.eps` file with text output inside a `\tex{}`. This 
;    text will be translated by LaTeX::
;
;       set_plot, 'ps'
;       device, filename='figure.eps', /times, /encapsulated
;       xyouts, 3., 5., '\tex[bl][bl][3.0]{Sun symbol: $M_\odot$}', font=0
;       plot, findgen(10), /nodata
;       device, /close
;
;    Note: the entire text  must be the `\tex{}` phrase, it cannot be combined 
;    with normal output like::
;
;       xyouts, 3., 5., 'Sun symbol: \tex[bl][bl][3.0]{$M_\odot$}', font=0
;
;    Then run `VIS_PSFRAG` on the output::
;
;       mg_psfrag, 'figure.eps', 'figure-subs.eps'
;
;    This should produce output like:
;
;    .. image:: figure-subs.png
; 
; :Params:
;    filename : in, optional, type=string, default=idl.ps
;       filename of PS or EPS file to substitue text in
;    output_filename : in, optional, type=string, default=`filename`
;       filename of output PS file
;
; :Keywords:
;    xsize : in, optional, type=float, default=17.78
;       width of graphic in cm
;    ysize : in, optional, type=float, default=12.7
;       height of graphic in cm
;    inches : in, optional, type=boolean
;       set to specify sizes in inches instead of centimeters
;-
pro mg_psfrag, filename, output_filename, $
                xsize=xsize, ysize=ysize, inches=inches
  compile_opt strictarr
  on_error, 2
  
  ; remove temporary directory if anything fails
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    if (n_elements(tmpdir) gt 0L) then file_delete, tmpdir, /recursive
    message, /reissue_last
  endif
  
  ; set defaults
  units = keyword_set(inches) ? 2.54 : 1.   ; we convert size to cm
  
  _filename = n_elements(filename) eq 0L ? 'idl.ps' : filename
  
  dotpos = strpos(_filename, '.', /reverse_search)
  extension = strlowcase(strmid(_filename, dotpos + 1L))
  if (n_elements(output_filename) eq 0L) then begin
    _output_filename = string(strmid(_filename, 0L, dotpos), extension, $
                              format='(%"%s-subs.%s")')
  endif else _output_filename = output_filename

  if (~file_test(_filename)) then message, 'file not found: ' + _filename

  _xsize = n_elements(xsize) eq 0L ? (7. * 2.54) : (xsize * units)
  _ysize = n_elements(ysize) eq 0L ? (5. * 2.54) : (ysize * units)
  
  ; create temporary directory to do work in
  tmpdir = filepath(string(systime(/seconds), format='(%"psfrag-%f")'), /tmp)
  file_mkdir, tmpdir
  
  ; replace sizes and filename in LaTeX template with actual values
  template_filename = filepath('figure.tex.sed', root=mg_src_root())
  sedCmdF = '(%"sed -e\"s/paper_xsize/%fcm/\" -e\"s/paper_ysize/%fcm/\" -e\"s/xsize/%fcm/\" -e\"s/ysize/%fcm/\" -e\"s@filename@%s@\" %s > %s")'
  tex_filename = filepath('figure.tex', root=tmpdir)
  sedCmd = string(_xsize, _ysize, _xsize - 0.2, _ysize - 0.2, $
                  file_expand_path(_filename), $
                  template_filename, tex_filename, $
                  format=sedCmdF) 
  spawn, sedCmd, sedOutput, sedErrorOutput, exit_status=sed_status
  if (sed_status ne 0L) then message, 'sed command failed'

  ; run LaTeX to produce .dvi file
  texCmdF = '(%"latex -output-directory %s %s")'
  texCmd = string(tmpdir, filepath('figure.tex', root=tmpdir), $
           format=texCmdF)           
  spawn, texCmd, texOutput, texErrorOutput, exit_status=tex_status
  if (tex_status ne 0L) then message, 'LaTeX command failed'
  
  ; run dvips to produce PostScript file
  dvipsCmdF = '(%"dvips -o %s %s")'
  dvipsCmd = string(filepath('figure.ps', root=tmpdir), $
                    filepath('figure.dvi', root=tmpdir), $
                    format=dvipsCmdF)
  spawn, dvipsCmd, dvipsOutput, dvipsErrorOutput, exit_status=dvips_status
  if (dvips_status ne 0L) then message, 'dvips command failed'
  
  ; convert to EPS if original was EPS
  if (strlowcase(extension) eq 'eps') then begin
    ps2epsCmdF = '(%"ps2eps %s")'
    ps2epsCmd = string(filepath('figure.ps', root=tmpdir), $
                       format=ps2epsCmdF)
    spawn, ps2epsCmd, ps2epsOutput, ps2epsErrorOutput, exit_status=ps2eps_status
    if (ps2eps_status ne 0L) then message, 'ps2eps command failed'
    
    file_copy, filepath('figure.eps', root=tmpdir), $
               file_expand_path(_output_filename), $
               /overwrite
  endif else begin
    file_copy, filepath('figure.ps', root=tmpdir), $
               file_expand_path(_output_filename), $
               /overwrite
  endelse
  
  file_delete, tmpdir, /recursive
end


; main-level example program

set_plot, 'ps'
device, filename='figure.eps', /times, /encapsulated
plot, findgen(10), /nodata
xyouts, 3., 5., '\tex[bl][bl][3.0]{Sun symbol: $M_\odot$}', font=0
device, /close

mg_psfrag, 'figure.eps', 'figure-subs.eps'

; retrieve Postscript info from the generated file
mg_psinfo, 'figure-subs.eps', bounding_box=bb, hires_bounding_box=hires_bb

; adjust bounding box
adj = [-35, -25, 15, 20]
mg_psinfo, 'figure-subs.eps', $
            bounding_box=bb + adj, $
            hires_bounding_box=hires_bb + adj

end
