; docformat = 'rst'

;+
; Subclass of `IDLgrPalette` with more color table choices.
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
;    object graphics
;
; :Copyright:
;    Color tables accessed with `MG_LOADCT` and `MG_XLOADCT` are provided
;    courtesy of Brewer, Cynthia A., 2007. http://www.ColorBrewer.org,
;    accessed 20 October 2007.
;
;    Apache-Style Software License for ColorBrewer software and ColorBrewer
;    Color Schemes
;
;    Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania
;    State University.
;
;    Licensed under the Apache License, Version 2.0 (the "License"); you may
;    not use this file except in compliance with the License. You may obtain
;    a copy of the License at::
;
;       http://www.apache.org/licenses/LICENSE-2.0
;
;    Unless required by applicable law or agreed to in writing, software
;    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
;    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
;    License for the specific language governing permissions and limitations
;    under the License.
;-

;+
; Load a Brewer color table by index.
;
; :Params:
;    tableNum : in, optional, type=long
;       table number, 0-40 if using default color table file, 0-34 for Brewer
;       color tables, 0-6 for the Yorick/Gist color tables, or 0-15 for the
;       matplotlib color tables
;
; :Keywords:
;    file : in, optional, type=string, default=colors.tbl
;       filename of color table file; this is present to make `MGgrPalette`
;       completely implement `IDLgrPalette`'s interface, it would normally not
;       be used
;    brewer : in, optional, type=boolean
;       set to use the Brewer color tables
;    gmt : in, optional, type=boolean
;       set to use the GMT color tables
;    mpl : in, optional, type=boolean
;       set to use the matplotlib color tables
;    gist : in, optional, type=boolean
;       set to use the Gist/Yorick color tables
;    chaco : in, optional, type=boolean
;       set to use the Chaco color tables
;    mg : in, optional, type=boolean
;       set to use the MG library color tables
;    reverse : in, optional, type=boolean
;       set to reverse color table
;    cpt_filename : in, optional, type=string
;       filename of `.cpt` file to load a color table from; the `.cpt` filename
;       extension is optional; the filename given can be absolute, relative
;       from the current working directory, or relative from the `cpt-city`
;       directory in the MG library
;-
pro mggrpalette::loadCT, tableNum, file=file, cpt_filename=cptFilename, $
                         brewer=brewer, gmt=gmt, mpl=mpl, gist=gist, chaco=chaco, $
                         mg=mg, reverse=reverse
  compile_opt strictarr

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

    if (keyword_set(reverse)) then rgb = reverse(rgb, 1)

    self->setProperty, red_values=reform(rgb[*, 0])
    self->setProperty, green_values=reform(rgb[*, 1])
    self->setProperty, blue_values=reform(rgb[*, 2])

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

  self->idlgrpalette::loadCt, tableNum, file=ctfilename

  if (keyword_set(reverse)) then begin
    self->getProperty, red_values=r, green_values=g, blue_values=b
    self->setProperty, red_values=reverse(r), $
                       green_values=reverse(g), $
                       blue_values=reverse(b)
  endif
end


;+
; Define instance variables.
;-
pro mggrpalette__define
  compile_opt strictarr

  define = { MGgrPalette, inherits IDLgrPalette }
end
