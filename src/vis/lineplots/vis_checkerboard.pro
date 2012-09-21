; docformat = 'rst'

;+
; Returns a checkerboard pattern suitable for use with the `PATTERN` keyword to
; `POLYFILL`.
;
; :Returns:
;    `bytarr(2 * block_size, 2 * block_size)`
;
; :Keywords:
;    block_size : in, optional, type=long, default=1L
;       size of one square of the checkerboard in pixels
;    colors : in, optional, type=bytarr(2), default="[0B, 255B]"
;       alternating colors for the two types of squares in the checkerboard
;-
function vis_checkerboard, block_size=blockSize, colors=colors
  compile_opt strictarr

  _blockSize = n_elements(blockSize) eq 0L ? 1L : blockSize
  _colors = n_elements(colors) eq 0L ? [0B, 255B] : colors
  
  im = bytarr(2, 2) + _colors[1]
  im[0, 0] = _colors[0]
  im[1, 1] = _colors[0]
  
  im = congrid(im, 2 * _blockSize, 2 * _blockSize)
  
  return, im
end
