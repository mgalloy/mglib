; docformat = 'rst'

;+
; Wrap a string to a given width.
;
; :Examples:
;    To run a simple example::
;
;       IDL> .run mg_grstrwrap
;
; :Returns:
;    string array
;
; :Params:
;    text : in, required, type=string
;       scalar string to wrap
;    width : in, required, type=long
;       width in pixels of the text area
;
; :Keywords:
;    charsize : in, optional, type=float
;       CHARSIZE keyword to XYOUTS
;    charthick : in, optional, type=float
;       CHARTHICK keyword to XYOUTS
;    font : in, optional, type=integer
;       FONT keyword to XYOUTS
;-
function mg_grstrwrap, text, width, $
                       charsize=charsize, charthick=charthick, font=font
  compile_opt strictarr

  wordstart = strsplit(text, count=nwords, length=wordlength)
  output = ['']
  line = 0L

  linestart = 0L
  linelength = 0L

  window, /pixmap, /free, xsize=1000
  winId = !d.window

  for w = 0L, nwords - 1L do begin
    linelength = wordstart[w] + wordlength[w] - linestart
    s = strmid(text, linestart, linelength)

    xyouts, 0, 0, s, /device, $
            charsize=charsize, charthick=charthick, font=font, $
            width=lineWidth

    lineWidth *= 1000

    if (lineWidth le width) then begin
      output[line] = s
    endif else begin
      output = [output, strmid(text, wordstart[w], wordlength[w])]
      ++line
      linestart = wordstart[w]
      linelength = 0L
    endelse
  endfor

  wdelete, winId

  return, output
end


; main-level program example

;device, set_font='Helvetica', /tt_font
font = 2
width = 400
charsize = 2.0

erase

text = 'This  is a rather long line,  but  something  that wraps is needed to ' $
         + 'demonstrate the capabilities of mg_grstrwrap.'
v1 = mg_grstrwrap(text, width, font=font, charsize=charsize)
v2 = mg_grstrwrap(text, width / 2, font=font, charsize=charsize)
print, 'ORIGINAL LINE:'
print, '"' + text + '"'
print
print, 'WRAPPED LINE (at ' + strtrim(width, 2) + ' pixels):'
print, transpose('"' + v1 + '"')

coords = convert_coord([0.05, 0.05], [0.0, 1.0], /normal, /to_device)

xyouts, 0.05, 0.95, 'ORIGINAL LINE:!C' + text, /normal, $
        font=font, charsize=charsize
xyouts, 0.05, 0.70, $
        'WRAPPED LINE (at ' + strtrim(width, 2) + ' pixels):!C' + strjoin(v1, '!C'), $
        /normal, font=font, charsize=charsize
xyouts, 0.05, 0.45, $
        'WRAPPED LINE (at ' + strtrim(width / 2, 2) + ' pixels):!C' + strjoin(v2, '!C'), $
        /normal, font=font, charsize=charsize

tvlct, 255, 255, 0, 0

plots, coords[0, 0:1], coords[1, 0:1], /device, color='00ffff'x
plots, coords[0, 0:1] + width, coords[1, 0:1], /device, color='00ffff'x
plots, coords[0, 0:1] + width / 2, coords[1, 0:1], /device, color='00ffff'x

end
