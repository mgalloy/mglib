; docformat = 'rst'

;+
; Display information about the available platforms and devices.
;
; :Keywords:
;   verbose : in, optional, type=boolean
;     set to display more information
;-
pro mg_cl_report, verbose=verbose
  compile_opt strictarr
  on_error, 2

  indent = '  '

  platforms = mg_cl_platforms(count=n_platforms, error=error)
  if (error ne 0L) then message, 'error finding platforms'
  for p = 0L, n_platforms - 1L do begin
    print, platforms[p].name, format='(%"Name:    %s")'
    print, platforms[p].vendor, format='(%"Vendor:  %s")'
    print, platforms[p].version, format='(%"Version: %s")'
    if (keyword_set(verbose)) then begin
      print, 'Extensions:'
      print, indent + transpose(strsplit(platforms[p].extensions, /extract))
    endif

    devices = mg_cl_devices(platform=p, count=n_devices, error=error)
    if (error ne 0L) then begin
      message, 'error finding devices for platform'
    endif
    for d = 0L, n_devices - 1L do begin
      print
      print, indent, devices[d].name, format='(%"%sName:           %s")'
      print, indent, devices[d].vendor, format='(%"%sVendor:         %s")'
      print, indent, devices[d].device_version, format='(%"%sVersion:        %s")'
      print, indent, mg_human_size(devices[d].global_mem_size), $
             format='(%"%sGlobal memory:  %s")'

      if (keyword_set(verbose)) then begin
        print, indent, format='(%"%sExtensions:")'
        print, indent + indent + transpose(strsplit(devices[d].extensions, /extract))
      endif
    endfor
  endfor
end
