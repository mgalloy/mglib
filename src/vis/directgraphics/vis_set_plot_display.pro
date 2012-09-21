; docformat = 'rst'

;+
; Sets the direct graphics device to the "display", i.e., 'X' on Unix-based 
; systems or 'WIN' on Windows systems.
;
; :Keywords:
;    original_device : out, optional, type=string
;       device name of original device
;-
pro vis_set_plot_display, original_device=original_device
  compile_opt strictarr
  
  original_device = !d.name
  case !version.os_family of
    'unix': set_plot, 'X'
    'Windows': set_plot, 'WIN'
  endcase
end
