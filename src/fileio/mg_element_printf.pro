; docformat = 'rst'

;+
; Returns the default Fortran-style format for a particular type.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   type : in, required, type=integer
;     `SIZE` type code
;-
function mg_element_printf_formatcode, type
  compile_opt strictarr

  case type of
    1: return, 'I'
    2: return, 'I'
    3: return, 'I'
    4: return, 'F'
    5: return, 'F'
    6: return, 'F, F'
    7: return, 'A'
    8: return, ''
    9: return, 'F, F'
    10: return, ''
    11: return, ''
    12: return, 'I'
    13: return, 'I'
    14: return, 'I'
    15: return, 'I'
    else:
  endcase
end


;+
; Convenience routine to print arrays elementwise.
;
; :Examples:
;   For example::
;
;     IDL> mg_element_printf, -1, indgen(3), findgen(3)
;           0      0.0000000
;           1      1.0000000
;           2      2.0000000
;
; :Params:
;   lun : in, required, type=integer
;     logical unit number to output to
;   p1 : in, optional, type=any array
;     first array to print
;   p2 : in, optional, type=any array
;     second array to print
;   p3 : in, optional, type=any array
;     third array to print
;   p4 : in, optional, type=any array
;     fourth array to print
;   p5 : in, optional, type=any array
;     fifth array to print
;   p6 : in, optional, type=any array
;     sixth array to print
;   p7 : in, optional, type=any array
;     seventh array to print
;   p8 : in, optional, type=any array
;     eighth array to print
;   p9 : in, optional, type=any array
;     ninth array to print
;   p10 : in, optional, type=any array
;     tenth array to print
;
; :Keywords:
;   format : in, optional, type=string
;     format string
;-
pro mg_element_printf, lun, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, $
                       format=format
  compile_opt strictarr

  s = {}

  switch n_params() of
    11: s = create_struct('p10', p10[0], s)
    10: s = create_struct('p9', p9[0], s)
     9: s = create_struct('p8', p8[0], s)
     8: s = create_struct('p7', p7[0], s)
     7: s = create_struct('p6', p6[0], s)
     6: s = create_struct('p5', p5[0], s)
     5: s = create_struct('p4', p4[0], s)
     4: s = create_struct('p3', p3[0], s)
     3: s = create_struct('p2', p2[0], s)
     2: s = create_struct('p1', p1[0], s)
  endswitch

  if (n_elements(format) eq 0L) then begin
    _format = ''
    for i = 0L, n_tags(s) - 1L do begin
      _format = _format + ',' + mg_element_printf_formatcode(size(s.(i), /type))
    endfor
    _format = strmid(_format, 1)
    _format = '(' + _format + ')'
  endif else _format = format

  if (n_params() gt 0L) then s = replicate(s, n_elements(p1))

  switch n_params() of
    11: s.(9) = p10
    10: s.(8) = p9
     9: s.(7) = p8
     8: s.(6) = p7
     7: s.(5) = p6
     6: s.(4) = p5
     5: s.(3) = p4
     4: s.(2) = p3
     3: s.(1) = p2
     2: s.(0) = p1
  endswitch

  printf, lun, s, format=_format
end
