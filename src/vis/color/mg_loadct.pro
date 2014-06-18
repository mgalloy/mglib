; docformat = 'rst'

;+
; Load a color table by index. This routine is directly analogous to `LOADCT`,
; but with more color table options.
;
; The default color tables:
;
; .. image:: default-colors.png
;
; The Brewer color tables are split into three types: sequential, diverging,
; and qualitative. Sequential color tables are simple sequences from white to
; a given color. The diverging color tables have white in the middle of the
; color table and progress in each direction towards two different colors. The
; qualitative color tables contain only a few colors for labeling purposes.
; The qualitative color tables are expanded to take up the same space of the
; other color tables in the graphic below:
;
; .. image:: brewer-colors.png
;
; The GMT color tables:
;
; .. image:: gmt-colors.png
;
; The Yorick/Gist color tables:
;
; .. image:: gist-colors.png
;
; The matplotlib color tables:
;
; .. image:: mpl-colors.png
;
; :Categories:
;    direct graphics
;
; :Copyright:
;   Color tables accessed with `MG_LOADCT` and `MG_XLOADCT` are provided
;   courtesy of Brewer, Cynthia A., 2007. http://www.ColorBrewer.org,
;   accessed 20 October 2007.
;
;   Apache-Style Software License for ColorBrewer software and ColorBrewer
;   Color Schemes
;
;   Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania
;   State University.
;
;   Licensed under the Apache License, Version 2.0 (the "License"); you may
;   not use this file except in compliance with the License. You may obtain
;   a copy of the License at::
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
;   Unless required by applicable law or agreed to in writing, software
;   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
;   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
;   License for the specific language governing permissions and limitations
;   under the License.
;-

;+
; Helper routine to determine the number of columns in the terminal window.
; Returns 80 if it can't find `MG_TERMCOLUMNS`.
;
; :Private:
;
; :Returns:
;   long
;-
function mg_loadct_termcolumns
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 80L
  endif

  return, mg_termcolumns()
end


;+
; Routine to print the color table names.
;
; :Private:
;
; :Params:
;   ctnames : in, required, type=strarr
;     names of the color tables
;-
pro mg_loadct_showtables, ctnames
  compile_opt strictarr

  if (n_elements(ctnames) eq 1L) then begin
    print, 0, ctnames, format='(%"%1d. %-0s")'
    return
  endif

  ndigits = long(alog10(n_elements(ctnames) - 1L) + 1L)
  indexFormat = string(ndigits, format='(%"(\%\"\%%dd. \")")')
  indices = string(indgen(n_elements(ctnames)), format=indexFormat)
  entries = indices + ctnames

  ntermcols = mg_loadct_termcolumns()
  width = max(strlen(entries) + 3L)
  ncols = ntermcols / width
  widthFormat = string(width, format='(%"\%-%ds")')

  format = string(strjoin(strarr(ncols) + widthFormat, ''), $
                  format='(%"(\%\"%s\")")')

  print, entries, format=format
end


;+
; Load a pre-defined color table.
;
; :Params:
;   table : in, optional, type=long
;     table number, 0-40 if using default color table file, 0-34 for Brewer
;     color tables, 0-6 for the Yorick/Gist color tables, or 0-15 for the
;     matplotlib color tables
;
; :Keywords:
;   file : in, optional, type=string, default=colors.tbl
;     filename of color table file; this is present to make `MG_LOADCT`
;     completely implement `LOADCT`'s interface, it would normally not be used
;   brewer : in, optional, type=boolean
;     set to use the Brewer color tables
;   gmt : in, optional, type=boolean
;     set to use the GMT color tables
;   mpl : in, optional, type=boolean
;     set to use the matplotlib color tables
;   gist : in, optional, type=boolean
;     set to use the Gist/Yorick color tables
;   chaco : in, optional, type=boolean
;     set to use the Chaco color tables
;   mg : in, optional, type=boolean
;     set to use the MG library color tables
;   rgb_table : out, optional, type="lonarr(ncolors, 2)"
;     set to a named variable to retrieve the color table
;   reverse : in, optional, type=boolean
;     set to reverse color table
;   get_names : out, optional, type=strarr
;     set to a named variables to return the name of the color tables
;   show_tables : in, optional, type=boolean
;     set to print a listing of the available color tables
;   cpt_filename : in, optional, type=string
;     filename of `.cpt` file to load a color table from; the `.cpt`
;     filename extension is optional; the filename given can be absolute,
;     relative from the current working directory, or relative from the
;     `cpt-city` directory in the mglib library; see `cptcity_catalog.idldoc`
;     for a listing of the `.cpt` files provided with the mglib library
;   _ref_extra : in, out, optional, type=keyword
;     keywords to `LOADCT`
;-
pro mg_loadct, table, file=file, $
               brewer=brewer, gmt=gmt, mpl=mpl, gist=gist, chaco=chaco, mg=mg, $
               rgb_table=rgbTable, $
               reverse=reverse, $
               get_names=get_names, show_tables=showtables, $
               cpt_filename=cptFilename, $
               _ref_extra=e
  compile_opt strictarr
  on_error, 2

  if (n_elements(cptFilename) gt 0L) then begin
    if (strmid(cptFilename, 3, /reverse_offset) ne '.cpt') then begin
      _cptFilename = cptFilename + '.cpt'
    endif else _cptFilename = cptFilename

    if (~file_test(_cptFilename)) then begin
      _cptFilename = filepath(_cptFilename, $
                              subdir=['cpt-city'], $
                              root=mg_src_root())
    endif

    if (~file_test(_cptFilename)) then begin
      message, '.cpt file not found, ' + cptFilename
    endif

    rgb = mg_cpt2ct(_cptFilename, name=ctnames)

    if (keyword_set(showTables)) then begin
      mg_loadct_showtables, ctnames

      return
    endif

    if (keyword_set(reverse)) then rgb = reverse(rgb, 1)

    if (arg_present(rgbTable)) then begin
      rgbTable = rgb
    endif else begin
      tvlct, rgb
    endelse

    return
  endif

  case 1 of
    keyword_set(brewer): ctfilename = filepath('brewer.tbl', root=mg_src_root())
    keyword_set(gmt): ctfilename = filepath('gmt.tbl', root=mg_src_root())
    keyword_set(mpl): ctfilename = filepath('mpl.tbl', root=mg_src_root())
    keyword_set(gist): ctfilename = filepath('gist.tbl', root=mg_src_root())
    keyword_set(chaco): ctfilename = filepath('chaco.tbl', root=mg_src_root())
    keyword_set(mg): ctfilename = filepath('mg.tbl', root=mg_src_root())
    n_elements(file) gt 0L: ctfilename = file
    else:
  endcase

  if (arg_present(get_names)) then begin
    loadct, get_names=get_names, file=ctfilename

    return
  endif

  if (keyword_set(showTables)) then begin
    loadct, get_names=ctnames, file=ctfilename
    mg_loadct_showtables, ctnames
    return
  endif

  ; search for color table name if it is specified as a string
  if (size(table, /type) eq 7L) then begin
    loadct, get_names=ctnames, file=ctfilename
    ind = where(stregex(ctnames, table, /boolean, /fold_case), count)
    if (count gt 0L) then begin
      _table = ind[0]
    endif else begin
      message, string(table, format='(%"color table ''%s'' not found")'), $
               /informational
      return
    endelse
  endif else begin
    if (n_elements(table) gt 0L) then _table = table
  endelse

  loadct, _table, rgb_table=rgbTable, file=ctfilename, _strict_extra=e

  if (keyword_set(reverse)) then begin
    rgbTable = reverse(rgbTable, 1)
  endif

  if (~arg_present(rgbTable)) then tvlct, rgbTable
end


; main-level program to produce image of color tables

nColorTables = 35
colorTableHeight = 13
colorTableWidth = 256
gap = 5

window, xsize=256, ysize=nColorTables * colorTableHeight

im = bindgen(256) # (bytarr(colorTableHeight) + 1B)
device, decomposed=0
mg_loadct, get_names=names, /brewer

for ct = 0L, nColorTables - 1L do begin
  mg_loadct, ct, /brewer
  if (ct gt 26) then begin
    ncolors = ([12, 9, 9, 8, 8, 8, 12, 8])[ct - 27]
    tvlct, r, g, b, /get
    r = congrid(r[0:ncolors - 1], 256, /center)
    g = congrid(g[0:ncolors - 1], 256, /center)
    b = congrid(b[0:ncolors - 1], 256, /center)
    tvlct, r, g, b
  endif
  tv, im, 0, (nColorTables - ct - 1) * colorTableHeight
endfor

end
