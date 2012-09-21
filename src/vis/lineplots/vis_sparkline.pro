; docformat = 'rst'

;+
; Writes a sparkline plot to a PNG file. 
; 
; :Params:
;    filename : in, required, type=string
;       filename of PNG file to write
;    data : in, required, type=numeric vector
;       y data to plot
;
; :Keywords:
;    xsize : in, optional, type=integer, default=n_elements(data)
;       xsize in pixels of the output image
;    ysize : in, optional, type=integer, default=12
;       ysize in pixels of the output image
;    yrange : in, optional, type=fltarr(2)
;       range of data; default is the min and max of the data
;    color : in, optional, type=bytarr(3) or index, default="[0, 0, 0] or 0"
;       color of the plot
;    endpoint_color : in, optional, type=bytarr(3) or index, default=same as color
;       color of the endpoint of the plot
;    background : in, optional, type=bytarr(3) or index, default="[255, 255, 255] or 255"
;       background color for the plot
;    band_range : in, optional, type=fltarr(2)
;       [min, max] for band
;    band_color : in, optional, type=bytarr(3) 
;       color of band
;-
pro vis_sparkline, filename, data, xsize=xsize, ysize=ysize, yrange=yrange, $
                  color=color, background=background, $
                  endpoint_color=endpoint_color, $
                  band_range=band_range, band_color=band_color
    compile_opt strictarr
    on_error, 2

    my_xsize = n_elements(xsize) eq 0 $
               ? long(1.5 * n_elements(data)) $
               : long(xsize)
    my_ysize = n_elements(ysize) eq 0 ? 12L : long(ysize)
    multiplier = 10L

    max_data = max(data, min=min_data)
    my_yrange = n_elements(yrange) eq 0 ? [min_data, max_data] : yrange
    n_data = n_elements(Data)
    
    odest = obj_new('IDLgrBuffer', dimensions=[my_xsize, my_ysize] * multiplier)
    
    oview = obj_new('IDLgrView', color=background, $
                    viewplane_rect=[0, my_yrange[0], $
                                    n_data - 1L, my_yrange[1] - my_yrange[0]])

    omodel = obj_new('IDLgrModel')
    oview->add, omodel

    oplot = obj_new('IDLgrPlot', data, color=color, thick=multiplier)
    omodel->add, oplot
     
    if (n_elements(band_range) gt 0 || n_elements(band_color) gt 0) then begin
        if (n_elements(band_range) eq 0) then begin
            my_band_range = $
              [min_data + (max_data - min_data) / 4.0, $
               max_data - (max_data - min_data) / 4.0]
        endif else my_band_range = band_range
        my_band_color = n_elements(band_color) eq 0 $
                        ? bytarr(3) + 200B $
                        : band_color
        oband = obj_new('IDLgrPolygon', $
                        [0, n_data - 1L, n_data - 1L, 0L, 0L], $
                        my_band_range[[0, 0, 1, 1, 0]], $
                        color=my_band_color)
        omodel->add, oband
    end

    odest->draw, oview
    oimage = odest->read()
    oimage->getProperty, data=image

    obj_destroy, [oview, odest, oimage]

    if (n_elements(endpoint_color) gt 0) then begin
        end_x = my_xsize - 1L 
        end_y = (data[n_data - 1L] - my_yrange[0]) $
                * (my_ysize - 1L) / (my_yrange[1] - my_yrange[0])
    endif

    if (n_elements(background) eq 0) then begin
        final_image = bytarr(4, my_xsize, my_ysize) 
        for b = 0, 2 do begin
          final_Image[b, *, *] = congrid(reform(image[b, *, *]), $
                                         my_xsize, my_ysize, $ 
                                         /center, /interp, /minus_one) $
                                 > 0B < 255B
        endfor
        alpha = bytarr(my_xsize * multiplier, my_ysize * multiplier) + 255B
        ind = where(image[0, *, *] eq 255B and $
                    image[1, *, *] eq 255B and $
                    image[1, *, *] eq 255B, count)
        if (count gt 0) then alpha[ind] = 0B             
         
        final_image[3, *, *] = congrid(alpha, my_xsize, my_ysize, $
                                  /center, /interp, /minus_one) > 0B < 255B
        if (n_elements(endpoint_color) gt 0) then begin
            final_image[*, end_x, end_y] = [endpoint_color, 255B]
            final_image[*, end_x - 1L, end_y] = [endpoint_color, 255B]
        endif

    endif else begin 
        final_image = congrid(image, 3, my_xsize, my_ysize, $
                              /center, /interp, /minus_one) > 0B < 255B
        if (n_elements(endpoint_color) gt 0) then begin
            final_image[*, end_x, end_y] = endpoint_color
            final_image[*, end_x - 1L, end_y] = endpoint_color
        endif
    endelse

    write_png, filename, final_image    
end
