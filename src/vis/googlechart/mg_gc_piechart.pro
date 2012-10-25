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
;       IDL> .run mg_gc_piechart
;
;    produces:
;
;    .. image:: profiles_piechart.png
;
; :Returns:
;    bytarr(3, xsize, ysize)
;
; :Params:
;    slices : in, required, type=fltarr
;       vector of values of slices
;
; :Keywords:
;    dimensions : in, optional, type=lonarr, default="[200, 100]"
;       size of output image
;    title : in, optional, type=string or strarr
;       title of the chart
;    threed : in, optional, type=boolean
;       set to create a 3D pie chart; default is a 2D pie chart
;    label : in, optional, type=strarr
;       labels for pie slices
;    color : in, optional, type=lonarr
;       colors of the slices
;    url : out, optional, type=string
;       URL used by Google Charts API
;-
function mg_gc_piechart, slices, dimensions=dimensions, threed=threed, $
                         title=title, label=label, color=color, $
                         url=url
  compile_opt strictarr

  return, mg_gc_base(data=slices, $
                     type=keyword_set(threed) ? 'p3' : 'p', $
                     dimensions=dimensions, $
                     title=title, label=label, $
                     color=color, $
                     url=url)
end

; main-level example of MG_GC_PIECHART

; get directories in IDL_DIR/lib
lib = filepath('', subdir=['lib'])
dirs = [file_search(lib, '*', /test_directory, count=ndirs), lib + '.']
nfiles = lonarr(++ndirs)

; find the number of .pro files in the above directories
for d = 0, ndirs - 1 do begin
  dummy = file_search(dirs[d], '*.pro', count=n)
  nfiles[d] = n
endfor

ind = where(nfiles gt 0, count)
if (count gt 0) then begin
  dirs = dirs[ind]
  nfiles = nfiles[ind]
endif

; use a Brewer qualitative color table to colors
mg_loadct, 27, /brewer
tvlct, r, g, b, /get
color = mg_rgb2index([[b[0:11]], [g[0:11]], [r[0:11]]])

dirs = strmid(dirs, strlen(lib))
im = mg_gc_piechart(nfiles, label=dirs, dimensions=[425, 175], color=color, $
                     url=url)
window, /free, xsize=425, ysize=175, title=url
tv, im, true=1

end