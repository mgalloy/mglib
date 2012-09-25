; docformat = 'rst'

;+
; Flips an image upside down (for all interleaves).
;
; :Returns:
;    an image of the same dimensions as the input
;
; :Params:
;    im : in, required, type=image
;       2D or 3D image of any interleave
;-
function mg_image_flip, im
  compile_opt strictarr
  
  dims = mg_image_getsize(im, true=true)
  
  case true of
    0: return, rotate(im, 7)
    1: begin
        result = im
        result[0, *, *] = rotate(reform(im[0, *, *]), 7)
        result[1, *, *] = rotate(reform(im[1, *, *]), 7)
        result[2, *, *] = rotate(reform(im[2, *, *]), 7)  
        return, result              
      end
    2: begin
        result = im
        result[*, 0, *] = rotate(reform(im[*, 0, *]), 7)
        result[*, 1, *] = rotate(reform(im[*, 1, *]), 7)
        result[*, 2, *] = rotate(reform(im[*, 2, *]), 7)  
        return, result       
      end
    3: begin
        result = im
        result[*, *, 0] = rotate(reform(im[*, *, 0]), 7)
        result[*, *, 1] = rotate(reform(im[*, *, 1]), 7)
        result[*, *, 2] = rotate(reform(im[*, *, 2]), 7)  
        return, result       
      end
  endcase
end
