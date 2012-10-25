; docformat = 'rst'

; The mglib library is released under a BSD-type license.
;
; Copyright (c) 2007-2012, Michael Galloy <mgalloy@idldev.com>
;
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
;     a. Redistributions of source code must retain the above copyright notice,
;        this list of conditions and the following disclaimer.
;     b. Redistributions in binary form must reproduce the above copyright
;        notice, this list of conditions and the following disclaimer in the
;        documentation and/or other materials provided with the distribution.
;     c. Neither the name of Michael Galloy nor the names of its contributors
;        may be used to endorse or promote products derived from this software
;        without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;+
; Use ImageMagick to convert a file between formats. To specify the location
; of the convert command from the ImageMagick utilities, do one of the
; following:
;
;    1. set the `CONVERT_LOCATION` keyword
;    2. set the `!convert_location` system variable
;    3. place `convert` in the OS `PATH`
;
; :Examples:
;    Try the main-level program at the end of this file::
;
;       IDL> .run mg_convert
;
; :Categories:
;    system utility
;-


;+
; Attempt to read an image file.
;
; :Returns:
;    image or -1L if format not supported
;
; :Params:
;    filename : in, required, type=string
;       filename of file to read
;-
function mg_convert_read_image, filename
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, cancel
    return, -1L
  endif

  return, read_image(filename)
end


;+
; Use ImageMagick to convert a file between formats.
;
; :Params:
;    basename : in, optional, type=string
;       basename of file to convert (used for output name as well)
;
; :Keywords:
;    density : in, optional, type=long, default=300
;       density of output image in dots per inch
;    scale : in, optional, type=long, default=100
;       scale percentage to use
;    from_extension : in, optional, type=string
;       extension to use for input file
;    from_eps : in, optional, type=boolean
;       if set, indicates the input is a Encapsulated PostScript file
;    from_png : in, optional, type=boolean
;       if set, indicates the input is a PNG file
;    from_ps : in, optional, type=boolean
;       if set, indicates the input is a PostScript file
;    max_dimensions : in, optional, type=lonarr(2)
;       maximum dimensions for the output image in pixels
;    to_extension : in, optional, type=string
;       extension to use for output file
;    to_eps : in, optional, type=boolean
;       if set, indicates the output should a Encapsulated Postscript file
;    to_png : in, optional, type=boolean
;       if set, indicates the output should a PNG image file
;    to_ps : in, optional, type=boolean
;       if set, indicates the output should a Postscript file
;    command : out, optional, type=string
;       convert command
;    output : out, optional, type=bytarr
;       output image if output format is an image type
;    convert_location : in, optional, type=string
;       location of the convert command
;-
pro mg_convert, basename, $
                density=density, $
                max_dimensions=maxDimensions, $
                scale=scale, $
                from_extension=fromExtension, $
                from_eps=fromEps, $
                from_png=fromPng, $
                from_ps=fromPs, $
                to_extension=toExtension, $
                to_eps=toEps, $
                to_png=toPng, $
                to_ps=toPs, $
                command=cmd, $
                output=output, $
                convert_location=convertLocation
  compile_opt strictarr
  on_error, 2

  case 1 of
    n_elements(fromExtension) gt 0L: inputExtension = fromExtension
    keyword_set(fromEps): inputExtension = 'eps'
    keyword_set(fromPng): inputExtension = 'png'
    keyword_set(fromPs): inputExtension = 'ps'
    else: inputExtension = 'ps'
  endcase

  case 1 of
    n_elements(toExtension) gt 0L: outputExtension = toExtension
    keyword_set(toEps): outputExtension = 'eps'
    keyword_set(toPng): outputExtension = 'png'
    keyword_set(toPs): outputExtension = 'ps'
    else: outputExtension = 'png'
  endcase

  _density = n_elements(density) eq 0L ? 300L : density
  _resize = n_elements(maxDimensions) eq 0L $
              ? (n_elements(scale) eq 0 $
                   ? '' $
                   : ' -resize ' + strtrim(scale, 2) + '%') $
              : ' -resize ' + strjoin(strtrim(maxDimensions, 2), 'x')

  defsysv, '!convert_location', exists=locationExists
  if (n_elements(convertLocation) gt 0L) then begin
    _convertLocation = convertLocation
    defsysv, '!convert_location', convertLocation
  endif else begin
    _convertLocation = locationExists $
                         ? !convert_location $
                         : 'convert'
  endelse

  ; create ImageMagick command:
  ;    -alpha is needed to produce a normal background for a PNG file that IDL
  ;           can read
  cmdFormat = '\"%s\" -alpha off -density %d %s.%s%s -quality 100 %s%s.%s'
  cmd = string(format='(%"' + cmdFormat + '")', $
               _convertLocation, _density, basename, inputExtension, $
               _resize, $
               (outputExtension eq 'png' ? 'PNG24:' : ''), basename, $
               outputExtension)

  ; run ImageMagick and check for an error
  spawn, cmd, result, errorResult, exit_status=err
  if (err ne 0L || strjoin(errorResult) ne '') then message, errorResult[0]

  ; send output back if requested
  if (arg_present(output)) then begin
    output = mg_convert_read_image(basename + '.' + outputExtension)
  endif
end


; main-level example program

filename = file_which('sine_waves.txt')
data = fltarr(2, file_lines(filename))
openr, lun, filename, /get_lun
readf, lun, data
free_lun, lun

mg_psbegin, filename='sine-waves.ps', /image, xsize=5, ysize=2, /inches
mg_decomposed, 1

plot, data[0, *], xstyle=9, ystyle=8, charsize=0.7
oplot, data[1, *], color='0000ff'x

mg_psend

mg_convert, 'sine-waves', max_dimensions=[500, 500], output=im
mg_image, im, /new_window
file_delete, 'sine-waves.' + ['png', 'ps']

end

