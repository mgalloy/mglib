; docformat = 'rst'

;+
; Set ANSI escape codes for the given text.
;
; :Todo:
;   Support more codes, available at::
;
;     http://en.wikipedia.org/wiki/ANSI_escape_code
;-


;+
; Set ANSI color codes for the given text.
;
; :Returns:
;   string/`strarr`
;
; :Params:
;   text : in, required, type=string/strarr
;     text to colorize
;
; :Keywords:
;   bold : in, optional, type=boolean
;   bright : in, optional, type=boolean
;     set to color foreground text to a brighter shade
;   black : in, optional, type=boolean
;     set to color foreground text black
;   red : in, optional, type=boolean
;     set to color foreground text red
;   green : in, optional, type=boolean
;     set to color foreground text green
;   yellow : in, optional, type=boolean
;     set to color foreground text yellow
;   blue : in, optional, type=boolean
;     set to color foreground text blue
;   magenta : in, optional, type=boolean
;     set to color foreground text magenta
;   cyan : in, optional, type=boolean
;     set to color foreground text cyan
;   white : in, optional, type=boolean
;     set to color foreground text white
;   background_bright : in, optional, type=boolean
;     set to color background text to a brighter shade
;   background_black : in, optional, type=boolean
;     set to color background text black
;   background_red : in, optional, type=boolean
;     set to color background text red
;   background_green : in, optional, type=boolean
;     set to color background text green
;   background_yellow : in, optional, type=boolean
;     set to color background text yellow
;   background_blue : in, optional, type=boolean
;     set to color background text blue
;   background_magenta : in, optional, type=boolean
;     set to color background text magenta
;   background_cyan : in, optional, type=boolean
;     set to color background text cyan
;   background_white : in, optional, type=boolean
;     set to color background text white
;-
function mg_ansicode, text, $
                      bold=bold, $
                      bright=bright, $
                      black=black, red=red, green=green, yellow=yellow, $
                      blue=blue, magenta=magenta, cyan=cyan, white=white, $
                      background_bright=backgroundBright, $
                      background_black=backgroundBlack, $
                      background_red=backgroundRed, $
                      background_green=backgroundGreen, $
                      background_yellow=backgroundYellow, $
                      background_blue=backgroundBlue, $
                      background_magenta=backgroundMagenta, $
                      background_cyan=backgroundCyan, $
                      background_white=backgroundWhite
  compile_opt strictarr

  esc = string(27B)

  case 1 of
    keyword_set(black): foreground = 30L
    keyword_set(red): foreground = 31L
    keyword_set(green): foreground = 32L
    keyword_set(yellow): foreground = 33L
    keyword_set(blue): foreground = 34L
    keyword_set(magenta): foreground = 35L
    keyword_set(cyan): foreground = 36L
    keyword_set(white): foreground = 37L
    else:
  endcase

  if (keyword_set(bright)) then foreground += 60

  case 1 of
    keyword_set(backgroundBlack): background = 40L
    keyword_set(backgroundRed): background = 41L
    keyword_set(backgroundGreen): background = 42L
    keyword_set(backgroundYellow): background = 43L
    keyword_set(backgroundBlue): background = 44L
    keyword_set(backgroundMagenta): background = 45L
    keyword_set(backgroundCyan): background = 46L
    keyword_set(backgroundWhite): background = 47L
    else:
  endcase

  if (keyword_set(backgroundBright)) then background += 60

  if (n_elements(foreground) gt 0L || n_elements(background) gt 0L $
        || keyword_set(bold)) then begin
    codes = ''
    codes += keyword_set(bold) ? string(esc, 1, format='(%"%s[%dm")') : ''
    codes += (n_elements(foreground) gt 0L) $
               ? string(esc, foreground, format='(%"%s[%dm")') $
               : ''
    codes += (n_elements(background) gt 0L) $
               ? string(esc, background, format='(%"%s[%dm")') $
               : ''
    _text = string(format='(%"%s%s%s[0m")', codes, text, esc)
  endif else _text = text

  return, _text
end


; main-level example

print, mg_ansicode('passed', /green), mg_ansicode('failed', /red), $
       format='(%"Test %s, test %s")'

end
