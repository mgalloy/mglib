; docformat = 'rst'

;+
; Create an image of a pie chart using the Google Charts API.
;
; :Requires:
;    IDL 6.4
;
; :Examples:
;    Running the main-level example at the end of this file::
;
;       IDL> .run mg_gc_barchart
;
;    produces:
;
;    .. image:: profiles_barchart.png
;
; :Returns:
;    bytarr(3, xsize, ysize)
;
; :Params:
;    data : in, required, type=fltarr
;       vector of values of slices
;
; :Keywords:
;    dimensions : in, optional, type=lonarr, default="[200, 100]"
;       size of output image
;    title : in, optional, type=string or strarr
;       title of the chart
;    horizontal : in, optional, type=boolean, default=0
;       set to create horizontal vars
;    vertical : in, optional, type=boolean, default=1
;       set to create vertical bars; the default
;    label : in, optional, type=strarr
;       labels for pie slices
;    color : in, optional, type=lonarr
;       colors of the slices
;    url : out, optional, type=string
;       URL used by Google Charts API
;-
function mg_gc_barchart, data, dimensions=dimensions, title=title, $
                         horizontal=horizontal, vertical=vertical, $
                         label=label, color=color, $
                         bar_width=barWidth, bar_spacing=barSpacing, $
                         group_spacing=groupSpacing, $
                         url=url
  compile_opt strictarr

  ; TODO: should calculate default values based on number of bars and
  ; dimensions of the graphics (which defaults to 200 x 100)
  sizes = [n_elements(barWidth) eq 0L ? 10L : barWidth, $
           n_elements(barSpacing) eq 0L ? 5L : barSpacing, $
           n_elements(groupSpacing) eq 0L ? 10L : groupSpacing]

  return, mg_gc_base(data=data, $
                     type=keyword_set(horizontal) ? 'bhs' : 'bvs', $
                     dimensions=dimensions, $
                     title=title, label=label, $
                     color=color, $
                     bar_sizes=sizes, $
                     url=url)
end

; main-level example of MG_GC_PIECHART

data = fix(randomu(seed, 20) * 100)
im = mg_gc_barchart(data, $
                    bar_width=15, bar_spacing=4, $
                    dimensions=[395, 175], label=strtrim(data, 2), $
                    color=mg_color('slateblue', /index), $
                    url=url, /vertical, title='A nice bar chart')
window, /free, xsize=395, ysize=175, title=url
tv, im, true=1

end
