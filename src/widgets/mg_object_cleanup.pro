; docformat = 'rst'

;+
; Generic cleanup for writing object widget programs. XMANAGER will not
; allow methods to be called via the CLEANUP keyword. To get around this:
;
;   * Specify CLEANUP='mg_object_cleanup' as a keyword to XMANAGER
;   * Put the object widget's reference in the TLB's UVALUE.
;   * Write a cleanupWidgets method in your object widget.
;
; :Params:
;    tlb : in, required, type=structure
;       top-level base widget ID
;-
pro mg_object_cleanup, tlb
  compile_opt strictarr

  widget_control, tlb, get_uvalue=owidget
  owidget->cleanupWidgets, tlb
end
