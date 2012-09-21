; docformat = 'rst'

;+
; Create a Venn Diagram using the Google Charts API.
;
; :Requires:
;    IDL 6.4
;
; :Examples:
;    See the main-level program at the end of this file::
;
;       IDL> .run vis_gc_venn
;
;    This should produce:
;
;    .. image:: gc_venn.png
;
; :Returns:
;    bytarr(3, xsize, ysize)
;
; :Params:
;    sizes : in, required, type=fltarr(3)
;       relative sizes of A, B, and C
;    ab : in, required, type=float
;       area of intersection of A and B
;    ac : in, required, type=float
;       area of intersection of A and C
;    bc : in, required, type=float
;       area of B and C
;    abc : in, required, type=float
;       area of intersection of A, B, and C
;
; :Keywords:
;    dimensions : in, optional, type=lonarr, default="[200, 100]"
;       size of output image
;    title : in, optional, type=string or strarr
;       string or string array representing title
;    legend_labels : in, optional, type=strarr
;       string array of labels for sets
;    legend_position : in, optional, type=string
;       position of legend: t (top), b (bottom), r (right), or l (left)
;    color : in, optional, type=lonarr
;       colors of the slices
;    background : in, optional, type=long
;       background color of chart
;    alpha_channel : in, optional, type=float
;       transparency of chart: 0.0 for completely transparent, 1.0 for 
;       completely opaque
;    url : out, optional, type=string
;       URL used by Google Charts API
;-
function vis_gc_venn, sizes, ab, ac, bc, abc, $
                      dimensions=dimensions, $
                      title=title, $
                      legend_labels=legendLabels, $
                      legend_position=legendPosition, $
                      color=color, background=background, $
                      alpha_channel=alphaChannel, $
                      url=url
  compile_opt strictarr
  
  return, vis_gc_base(data=[sizes, ab, ac, bc, abc], $
                      type='v', $
                      dimensions=dimensions, $
                      title=title, $
                      legend_labels=legendLabels, $
                      legend_position=legendPosition, $                      
                      color=color, background=background, $
                      alpha_channel=alphaChannel, $
                      url=url)
end


; main-level example program

vis_loadct, 27, /brewer
tvlct, r, g, b, /get
color = vis_rgb2index([[b[0:2]], [g[0:2]], [r[0:2]]])

im = vis_gc_venn([100, 80, 60], 10, 30, 50, 10, $
                 dimensions=[400, 250], $
                 title=['Venn diagram', 'Set intersection'], $
                 legend_labels=['Set 1', 'Set 2', 'Set 3'], $
                 legend_position='l', $
                 color=color, background='F0FFFF'x, alpha=0.5, $
                 url=url)
                     
window, /free, xsize=400, ysize=250, title=url
tv, im, true=1

end
