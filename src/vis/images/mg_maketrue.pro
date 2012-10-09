; docformat 'rst'

;+
; Converts an image in one TRUE format to another.
;
; :Examples:
;    Run the main-level example program with::
;
;       IDL> .run mg_maketrue
;
; :Returns:
;    image of the `TRUE` format specified
;
; :Params:
;    im : in, required, type=image
;       2- or 3-dimensional image array to convert
;
; :Keywords:
;    red : in, out, optional, type=bytarr(256)
;       red values of color table to use when converting to a TRUE=1-3 image,
;       defaults to current color table in this case; red values produced in
;       a conversion to a TRUE=0 image
;    green : in , out, optional, type=bytarr(256)
;       green values of color table to use when converting to a TRUE=1-3 image,
;       defaults to current color table in this case; green values produced in
;       a conversion to a TRUE=0 image
;    blue : in, out, optional, type=bytarr(256)
;       blue values of color table to use when converting to a TRUE=1-3 image,
;       defaults to current color table in this case; blue values produced in
;       a conversion to a TRUE=0 image
;    rgb_table : in, out, optional, type=`bytarr(256, 3)`
;       entire RGB color table instead of using `RED`, `GREEN`, and `BLUE`
;       keywords
;    true : in, optional, type=long, default=1
;       desired interleave of output image: 0, 1, 2, or 3
;    input_true : in, out, optional, type=long
;       interleave of input image: 0, 1, 2, or 3; `MG_MAKETRUE` will guess
;       depending on dimensions and location of first dimension of size 3
;       in the input image; returns the value it guessed
;-
function mg_maketrue, im, red=red, green=green, blue=blue, $
                      rgb_table=rgbTable, $
                      true=true, input_true=inputTrue
  compile_opt strictarr

  _true = n_elements(true) gt 0L ? true : 1L
  dims = mg_image_getsize(im, true=inputTrue)

  if (_true eq inputTrue) then return, im

  if (inputTrue eq 0L) then begin
    if (n_elements(red) gt 0L) then begin
      _red = red
      _green = green
      _blue = blue
    endif else if (n_elements(rgbTable) gt 0L) then begin
      _red = reform(rgbTable[*, 0])
      _green = reform(rgbTable[*, 1])
      _blue = reform(rgbTable[*, 2])
    endif else begin
      if (!d.name eq 'WIN' || !d.name eq 'X' || !d.name eq 'Z') then begin
        device, get_decomposed=dec
      endif else dec = 0

      if (dec) then begin
        _red = bindgen(256)
        _green = bindgen(256)
        _blue = bindgen(256)
      endif else begin
        tvlct, _red, _green, _blue, /get
      endelse
    endelse

    case _true of
      0: return, im
      1: return, transpose([[[_red[im]]], [[_green[im]]], [[_blue[im]]]], [2, 0, 1])
      2: return, transpose([[[_red[im]]], [[_green[im]]], [[_blue[im]]]], [0, 2, 1])
      3: return, [[[_red[im]]], [[_green[im]]], [[_blue[im]]]]
    endcase
  endif

  if (_true gt 0L) then begin
    ; just transpose to get the correct TRUE
    lookup = [[[0, 1, 2], [1, 0, 2], [1, 2, 0]], $
              [[1, 0, 2], [0, 1, 2], [0, 2, 1]], $
              [[2, 0, 1], [0, 2, 1], [0, 1, 2]]]
    return, transpose(im, reform(lookup[*, _true - 1L, inputTrue - 1L]))
  endif else begin
    ; use COLOR_QUAN to convert to an indexed color image
    result = color_quan(im, inputTrue, red, green, blue)
    if (arg_present(rgbTable)) then rgbTable = [[[red], [green], [blue]]]
    return, result
  endelse
end


; main-level example program

device, get_decomposed=odec
tvlct, rgb, /get

f = filepath('endocell.jpg', subdir=['examples', 'data'])
read_jpeg, f, im
mg_loadct, 9, /brewer

window, xsize=2*615, ysize=416, /free

device, decomposed=0
tv, im, 0

im1 = mg_maketrue(im)

device, decomposed=1
tv, im1, 1, true=1

tvlct, rgb
device, decomposed=odec

end
