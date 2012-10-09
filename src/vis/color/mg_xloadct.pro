; docformat = 'rst'

;+
; Load a color table by index using a GUI interface. This routine is
; directly analogous to `XLOADCT`, but with more color tables options.
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
;
; :Keywords:
;    file : in, optional, type=string, default=colors.tbl
;       filename of color table file; this is present to make `MG_XLOADCT`
;       completely implement `XLOADCT`'s interface, it would normally not be
;       used
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
;    _extra : in, out, optional, type=keyword
;       keywords to LOADCT
;-
pro mg_xloadct, file=file, $
                brewer=brewer, gmt=gmt, mpl=mpl, gist=gist, chaco=chaco, mg=mg, $
                _extra=e
  compile_opt strictarr

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

  xloadct, file=ctfilename, _strict_extra=e
end
