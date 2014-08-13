; docformat = 'rst'

;+
; Convenience routine to print arrays elementwise.
;
; :Examples:
;   For example::
;
;     IDL> mg_element_print, indgen(3), findgen(3)
;           0      0.0000000
;           1      1.0000000
;           2      2.0000000
;
; :Params:
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
pro mg_element_print, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, format=format
  compile_opt strictarr

  case n_params() of
     0: mg_element_printf, -1, format=format
     1: mg_element_printf, -1, p1, format=format
     2: mg_element_printf, -1, p1, p2, format=format
     3: mg_element_printf, -1, p1, p2, p3, format=format
     4: mg_element_printf, -1, p1, p2, p3, p4, format=format
     5: mg_element_printf, -1, p1, p2, p3, p4, p5, format=format
     6: mg_element_printf, -1, p1, p2, p3, p4, p5, p6, format=format
     7: mg_element_printf, -1, p1, p2, p3, p4, p5, p6, p7, format=format
     8: mg_element_printf, -1, p1, p2, p3, p4, p5, p6, p7, p8, format=format
     9: mg_element_printf, -1, p1, p2, p3, p4, p5, p6, p7, p8, p9, format=format
    10: mg_element_printf, -1, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, format=format
    else:
  endcase
end
