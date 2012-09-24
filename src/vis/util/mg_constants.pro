; docformat = 'rst'

;+
; Defines constants for values of LINESTYLE, PSYM, and [XYZ]STYLE keywords.
;
; This routine defines a system variable !vis which contains constants for the 
; LINESTYLE keyword to direct graphics routines or the LINESTYLE property of 
; object graphics classes::
;
;    IDL> help, !mg.linestyle, /structures
;    ** Structure <172b228>, 7 tags, length=14, data length=14, refs=2:
;       SOLID           INT              0
;       DOTTED          INT              1
;       DASHED          INT              2
;       DASHDOT         INT              3
;       DASHDOTDOT      INT              4
;       LONGDASHES      INT              5
;       NOLINE          INT              6
;
; Also defined are the constants for the PSYM keyword to the direct graphics
; routines or the value of the IDLgrSymbol object graphics class::
;
;    IDL> help, !mg.psym, /structures     
;    ** Structure <1887e08>, 11 tags, length=22, data length=22, refs=2:
;       PLUSSIGN        INT              1
;       ASTERISK        INT              2
;       PERIOD          INT              3
;       DIAMOND         INT              4
;       TRIANGLE        INT              5
;       SQUARE          INT              6
;       X               INT              7
;       USERDEFINED     INT              8
;       GREATERTHAN     INT              8
;       LESSTHAN        INT              9
;       HISTOGRAM       INT             10
;
; Also defined are values for the [XYZ]STYLE keyword of the direct graphics 
; routines::
;
;    IDL> help, !mg.style, /structures
;    ** Structure <1729be8>, 5 tags, length=10, data length=10, refs=2:
;       EXACT           INT              1
;       EXTEND          INT              2
;       SUPPRESS        INT              4
;       SUPPRESSBOX     INT              8
;       INHIBITYZERO    INT             16
;-
pro vis_constants
  compile_opt strictarr
  
  defsysv, '!mg', { linestyle: { solid: 0, $
                                 dotted: 1, $
                                 dashed: 2, $
                                 dashdot: 3, $
                                 dashdotdot: 4, $
                                 longdashes: 5, $
                                 noline: 6 }, $   ; object graphics only
                    psym: { plussign: 1, $
                            asterisk: 2, $
                            period: 3, $
                            diamond: 4, $
                            triangle: 5, $
                            square: 6, $
                            x: 7, $
                            userdefined: 8, $   ; direct graphics only
                            greaterthan: 8, $   ; object graphics only
                            lessthan: 9, $      ; object graphics only
                            histogram: 10 }, $
                    style: { exact: 1, $
                             extend: 2, $
                             suppress: 4, $
                             suppressbox: 8, $
                             inhibityzero: 16 }}
end
