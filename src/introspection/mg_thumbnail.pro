; docformat = 'rst'

;+
; Create a thumbnail image of a simple visualization of the data. The
; visualization type is guessed based on the dimensions of the data.
;-

;+
; Create a line plot.
;
; :Returns:
;    bytarr(3, m, n) or -1L
;
; :Params:
;    data : in, required, type=numeric array
;       data to visualize
;
; :Keywords:
;    valid : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid
;       visualization type could be found, -1L is returned
;-
function mg_thumbnail_lineplot, data, valid=valid
  compile_opt strictarr

  ; min and max size of the output image
  maxDimSize = 100L
  minDimSize = 10L

  ; goal is to make curve in output have a mean absolute value of the derivative
  ; of 1 (because that makes differences in the slope easiest to see)
  mDeriv = mean(abs(deriv(data)))
  xrange = n_elements(data) - 1L
  yrange = max(data, min=minData) - minData

  ; calculate output dimensions, making sure the dimensions fall in the range
  ; of minDimSize...maxDimSize
  dims = [xrange, yrange * mDeriv]
  dims = long(dims / float(max(dims)) * maxDimSize)
  dims = dims > minDimSize < maxDimSize

  view = obj_new('IDLgrView')

  model = obj_new('IDLgrModel')
  view->add, model

  plot = obj_new('IDLgrPlot', data, color=[0, 0, 255])
  model->add, plot

  ; use most of the view: -0.9...0.9 for both x and y
  plot->getProperty, xrange=xr, yrange=yr
  xc = mg_linear_function(xr, [-0.9, 0.9])
  yc = mg_linear_function(yr, [-0.9, 0.9])
  if (total(finite(yc)) ne 2L) then begin
    yc = mg_linear_function([yr[0] - 1, yr[0] + 1], [-0.9, 0.9])
  endif
  plot->setProperty, xcoord_conv=xc, ycoord_conv=yc

  buffer = obj_new('IDLgrBuffer', dimensions=dims)
  buffer->draw, view
  buffer->getProperty, image_data=im

  obj_destroy, [buffer, view]

  return, im
end


;+
; Create a contour plot.
;
; :Returns:
;    bytarr(3, m, n) or -1L
;
; :Params:
;    data : in, required, type=numeric array
;       data to visualize
;
; :Keywords:
;    valid : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid
;       visualization type could be found, -1L is returned
;-
function mg_thumbnail_contourplot, data, valid=valid
  compile_opt strictarr

  maxDimSize = 100L
  minDimSize = 10L

  ; preserve aspect ration but make sure the dimensions fall in the range
  ; minDimSize...maxDimSize
  sz = size(data, /structure)
  dims = sz.dimensions[0:1]
  dims = long(dims / float(max(dims)) * maxDimSize)
  dims = dims > minDimSize < maxDimSize

  view = obj_new('IDLgrView')

  model = obj_new('IDLgrModel')
  view->add, model

  nLevels = 20
  contour = obj_new('IDLgrContour', data, $
                    planar=1, $
                    geomz=0.0, $
                    n_levels=nLevels, $
                    c_color=bytscl(bindgen(nLevels)), $
                    /fill)
  model->add, contour

  ; use most of the view: -0.9...0.9 for both x and y
  contour->getProperty, xrange=xr, yrange=yr
  xc = mg_linear_function(xr, [-1.0, 1.0])
  yc = mg_linear_function(yr, [-1.0, 1.0])
  contour->setProperty, xcoord_conv=xc, ycoord_conv=yc

  buffer = obj_new('IDLgrBuffer', dimensions=dims)
  buffer->draw, view
  buffer->getProperty, image_data=im

  obj_destroy, [buffer, view]

  return, im
end


;+
; Create a volume visualization.
;
; :Returns:
;    bytarr(3, m, n) or -1L
;
; :Params:
;    data : in, required, type=numeric array
;       date to visualize
;
; :Keywords:
;    valid : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid
;       visualization type could be found, -1L is returned
;-
function mg_thumbnail_volumeplot, data, valid=valid
  compile_opt strictarr

  maxDimSize = 100L
  minDimSize = 10L

  ; make a square display since the view dimensions don't correspond to data
  ; dimensions for a rotated volume
  dims = [maxDimSize, maxDimSize]

  view = obj_new('IDLgrView')

  model = obj_new('IDLgrModel')
  view->add, model

  vol = obj_new('IDLgrVolume', data)
  model->add, vol

  ; use less of the view for a 3D object: -0.7...0.7 for x, y, and z
  vol->getProperty, xrange=xr, yrange=yr, zrange=zr
  xc = mg_linear_function(xr, [-0.7, 0.7])
  yc = mg_linear_function(yr, [-0.7, 0.7])
  zc = mg_linear_function(zr, [-0.7, 0.7])
  vol->setProperty, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc

  ; who knows what orientation is best: try this one
  model->rotate, [1, 0, 0], -90
  model->rotate, [0, 1, 0], 30
  model->rotate, [1, 0, 0], 30

  buffer = obj_new('IDLgrBuffer', dimensions=dims)
  buffer->draw, view
  buffer->getProperty, image_data=im

  obj_destroy, [buffer, view]

  return, im
end


;+
; Resize image to correct dimensions while preserving the aspect ratio.
;
; :Returns:
;    bytarr(3, m, n) or -1L
;
; :Params:
;    data : in, required, type=numeric array
;       data to visualize
;
; :Keywords:
;    valid : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid
;       visualization type could be found, -1L is returned
;-
function mg_thumbnail_image, data, valid=valid
  compile_opt strictarr

  maxDimSize = 100L
  minDimSize = 10L

  sz = size(data, /structure)
  ind = where(sz.dimensions[0:sz.n_dimensions - 1L] le 4, count, complement=cind)

  ; this would be odd: quit if there is not just one dimension with size 1...4
  if (count ne 1) then begin
    valid = 0B
    return, -1L
  endif

  ; make the image pixel interleave
  im = transpose(data, [ind[0], cind])

  ; calculate dimensions that preserve aspect ratio, but are in the range
  ; minDimSize...maxDimSize
  origDims = [sz.dimensions[cind[0]], sz.dimensions[cind[1]]]
  dims = long(origDims / float(max(origDims)) * maxDimSize)

  ; only resize to smaller, never bigger
  doResize = total(dims gt origDims) eq 0

  dims = dims > minDimSize < maxDimSize

  if (doResize) then begin
    im = congrid(im, sz.dimensions[ind[0]], dims[0], dims[1])
  endif

  return, im
end


;+
; Dispatches data to proper helper routine to produce a simple thumbnail
; visualization of the data and returns the result as a true color image.
;
; :Returns:
;    bytarr(3, m, n) or -1L
;
; :Params:
;    data : in, required, type=numeric array
;       data to visualize
;
; :Keywords:
;    valid : out, optional, type=boolean
;       set to a named variable to get status of visualization; if no valid
;       visualization type could be found, -1L is returned
;-
function mg_thumbnail, data, valid=valid
  compile_opt strictarr

  sz = size(data, /structure)

  ; set to not valid for any of the following types or sizes
  valid = 0B

  ; invalid types/sizes
  if (sz.type eq 7) then return, -1L
  if (sz.type eq 8) then return, -1L
  if (sz.type eq 11) then return, -1L

  if (sz.n_dimensions eq 0) then return, -1L
  if (sz.n_dimensions gt 3) then return, -1L

  if (sz.n_elements lt 3) then return, -1L

  valid = 1B

  ; valid types/sizes
  case sz.n_dimensions of
    1: return, mg_thumbnail_lineplot(data, valid=valid)
    2: return, mg_thumbnail_contourplot(data, valid=valid)
    3: begin
        ind = where(sz.dimensions[0:sz.n_dimensions - 1L] le 4, count)

        ; if not exactly one small dimension then assume volume
        if (count ne 1) then return, mg_thumbnail_volumeplot(data, valid=valid)

        ; if there are small dimensions then assume an image
        return, mg_thumbnail_image(data, valid=valid)
      end
  endcase
end
