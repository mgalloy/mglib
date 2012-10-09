; docformat = 'rst'

;+
; Creates a user-defined symbol for use in plotting in direct graphics via
; routines that accept the `PSYM` graphics keyword. All user symbols are scaled
; to fill the -1 to 1 range (use `SYMSIZE` of the graphics routine to change
; the size of the symbol).
;
; :Categories:
;    direct graphics
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_usersym
;
;    The core lines of code to produce the plot are::
;
;       plot, [0, 1], [0, 1], /nodata, xrange=[0, 1], yrange=[0, 1], $
;             xstyle=9, ystyle=9
;       oplot, randomu(seed, 10), randomu(seed, 10), $
;              psym=mg_usersym(/circle, /fill, color=128B)
;       oplot, randomu(seed, 10), randomu(seed, 10), $
;              psym=mg_usersym(/triangle, rotation=90, /fill)
;       oplot, randomu(seed, 10), randomu(seed, 10), $
;              psym=mg_usersym(/triangle, rotation=-90, color=64B)
;       oplot, randomu(seed, 10), randomu(seed, 10), $
;              psym=mg_usersym(/hexagon)
;
;    It should look something like:
;
;    .. image:: usersym.png
;-

;+
; Create a user symbol.
;
; :Returns:
;    correct PSYM value for pre-defined types, 8 for the special symbols,
;    i.e. PSYM=8 means use the current user symbol
;
; :Params:
;    x : in, optional, type=fltarr
;       x-values of the user symbol's shape
;    y : in, optional, type=fltarr
;       y-values of the user symbol's shape
;
; :Keywords:
;    color : in, optional, type=color
;       color for the symbol
;    fill : in, optional, type=boolean
;       set to fill inside the symbol
;    thick : in, optional, type=float, default=1.0
;       line thickness of the symbol
;    with_line : in, optional, type=boolean
;       set to display symbols and a line connecting them; the default is to
;       show just the symbol
;    none : in, optional, type=boolean
;       set to produce no symbol
;    plus_sign : in, optional, type=boolean
;       set to produce a plus sign symbol
;    asterisk : in, optional, type=boolean
;       set to produce an asterisk symbol
;    dot : in, optional, type=boolean
;       set to produce a dot symbol
;    diamond : in, optional, type=boolean
;       set to produce a diamond symbol
;    x : in, optional, type=boolean
;       set to produce an x symbol
;    user_defined : in, optional, type=boolean
;       set to use the currently defined user symbol
;    histogram : in, optional, type=boolean
;       set to use histogram mode
;    horizontal_line : in, optional, type=boolean
;       set to produce a horizontal line user symbol
;    vertical_line : in, optional, type=boolean
;       set to produce a vertical line user symbol
;    triangle : in, optional, type=boolean
;       set to produce a triangular user symbol
;    square : in, optional, type=boolean
;       set to produce a square
;    hexagon : in, optional, type=boolean
;       set to produce a hexagonal user symbol
;    circle : in, optional, type=boolean
;       set to produce a circular user symbol
;    n_vertices : in, optional, type=long
;       number of vertices for a regular polygonal symbol
;    rotation : in, optional, type=float, default=0.0
;       angle in degrees to rotate the symbol; 0 degrees places the first
;       vertex at (1, 0) in user symbol coordinate space
;-
function mg_usersym, x, y, $
                     color=color, fill=fill, thick=thick, $
                     with_line=withLine, $
                     none=none, $
                     plus_sign=plusSign, asterisk=asterisk, dot=dot, $
                     diamond=diamond, $
                     x=xSymbol, $
                     user_defined=userDefined, $
                     histogram=histogram, $
                     horizontal_line=horizontalLine, $
                     vertical_line=verticalLine, $
                     triangle=triangle, square=square, $
                     hexagon=hexagon, circle=circle, $
                     n_vertices=nVertices, $
                     rotation=rotation
  compile_opt strictarr
  on_error, 2

  _rotation = n_elements(rotation) eq 0L ? 0.0 : rotation

  if (n_elements(x) gt 0L) then begin
    if (n_elements(y) gt 0L) then begin
      _x = x
      _y = y
    endif else begin
      if (n_elements(x) gt 1L) then message, 'missing y-value array'
      if (x[0] lt 0L || x[0] gt 10L) then message, 'invalid PYSM value'
      return, keyword_set(withLine) ? - x[0] : x[0]
    endelse
  endif else begin
    n = 0L
    case 1 of
      ; pre-defined symbols
      keyword_set(none): return, 0L
      keyword_set(plusSign): return, keyword_set(withLine) ? -1L : 1L
      keyword_set(asterisk): return, keyword_set(withLine) ? -2L : 2L
      keyword_set(dot): return, keyword_set(withLine) ? -3L : 3L
      keyword_set(diamond): return, keyword_set(withLine) ? -4L : 4L
      keyword_set(xSymbol): return, keyword_set(withLine) ? -7L : 7L
      keyword_set(userDefined): return, keyword_set(withLine) ? -8L : 8L
      keyword_set(histogram): return, keyword_set(withLine) ? -10L : 10L

      ; user-defined symbols
      keyword_set(horizontalLine): begin
          _x = [-1, 1]
          _y = [0, 0]
        end
      keyword_set(verticalLine): begin
          _x = [0, 0]
          _y = [-1, 1]
        end
      keyword_set(triangle): n = 3L
      keyword_set(square): begin
          n = 4L
          _rotation += 45.0
        end
      keyword_set(hexagon): n = 6L
      keyword_set(circle): n = 36L
      n_elements(nVertices): n = nVertices
      else: message, 'no symbol defined'
    endcase

    if (n gt 0L) then begin
      t = findgen(n + 1L) * 360. / n * !dtor + _rotation * !dtor
      _x = cos(t)
      _y = sin(t)
    endif
  endelse

  usersym, _x, _y, color=color, fill=fill, thick=thick

  return, keyword_set(withLine) ? -8L : 8L
end


; main-level example program

device, get_decomposed=dec, decomposed=0
mg_loadct, 5

mg_psbegin, filename='usersym.ps', /image, xsize=6, ysize=4, /inches
plot, [0, 1], [0, 1], /nodata, xrange=[0, 1], yrange=[0, 1], $
      xstyle=9, ystyle=9
oplot, randomu(seed, 10), randomu(seed, 10), $
       psym=mg_usersym(/circle, /fill, color=128B)
oplot, randomu(seed, 10), randomu(seed, 10), $
       psym=mg_usersym(/triangle, rotation=90, /fill)
oplot, randomu(seed, 10), randomu(seed, 10), $
       psym=mg_usersym(/triangle, rotation=-90, color=64B)
oplot, randomu(seed, 10), randomu(seed, 10), $
       psym=mg_usersym(/hexagon)
mg_psend

device, decomposed=dec

mg_convert, 'usersym', max_dimensions=[400, 400], output=im
mg_image, im, /new_window

end
