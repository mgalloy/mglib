; docformat = 'rst'

;+
; Produce a report for the `PROFILER`. The default output is a fixed width
; table of the results.
;
; :Keywords:
;    filename : in, optional, type=string
;       set to a filename to send output to; if not set, output goes to
;       standard output
;    csv : in, optional, type=boolean
;       set to create CSV output
;    html : in, optional, type=boolean
;       set to output HTML output
;-
pro mg_profiler_report, filename=filename, csv=csv, html=html
  compile_opt strictarr

  profiler, /report, data=data, output=output
  ind = sort(-data.time)
  data = data[ind]
  output = output[ind]

  if (n_elements(filename) gt 0L) then begin
    openw, lun, filename, /get_lun
  endif else begin
    lun = -1L
  endelse

  case 1 of
    keyword_set(csv): printf, lun, data, format='(%"%s, %d, %f, %f, %d")'
    keyword_set(html): begin
        template_filename = filepath('profiler.tt', root=mg_src_root())
        template = obj_new('MGffTemplate', template_filename)
        template->process, data, lun=lun
        obj_destroy, template
      end
    else: printf, lun, output
  endcase

  if (n_elements(filename) gt 0L) then free_lun, lun
end
