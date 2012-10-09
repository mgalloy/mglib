; docformat = 'rst'

;+
; Prints system information.
;
; :Keywords:
;    filename : in, optional, type=string
;       if present, filename to send output to
;-
pro mg_sysreport, filename=filename
  compile_opt strictarr
  on_error, 2

  if (n_elements(filename) eq 0L) then begin
    _lun = -1
  endif else begin
    openw, _lun, filename, /get_lun, error=error
    if (error) then message, 'error opening ' + filename + ' for writing'
  endelse

  ; platform

  printf, _lun, 'PLATFORM'
  printf, _lun, '--------'
  printf, _lun, !version.arch, format='(%"Architecture: %s")'
  printf, _lun, !version.os, format='(%"OS: %s")'
  printf, _lun, !version.os_family, format='(%"OS family: %s")'
  printf, _lun, !version.os_name, format='(%"OS name: %s")'
  printf, _lun, !version.memory_bits, format='(%"Memory bits: %d")'
  printf, _lun, !version.file_offset_bits, format='(%"File offset bits: %d")'
  printf, _lun, !cpu.hw_ncpu, format='(%"Number of CPUs: %d")'

  ; version info

  printf, _lun
  printf, _lun, 'VERSION'
  printf, _lun, '-------'
  printf, _lun, !version.release, format='(%"Release: %s")'
  printf, _lun, !version.build_date, format='(%"Build date: %s")'

  ; licensing

  result = lmgr(lmhostid=lmhostid)
  result = lmgr(expire_date=expireDate)
  expireDate = n_elements(expireDate) eq 0 ? 'no expiration' : expireDate
  result = lmgr(install_num=installNum)
  installNum = n_elements(installNum) eq 0 ? 'unlicensed' : installNum

  printf, _lun
  printf, _lun, 'LICENSING'
  printf, _lun, '---------'
  printf, _lun, lmhostid, format='(%"LM host id: %s")'
  printf, _lun, installNum, format='(%"Install number: %s")'

  printf, _lun, lmgr(/runtime) ? 'yes' : 'no', format='(%"Runtime: %s")'
  printf, _lun, lmgr(/vm) ? 'yes' : 'no', format='(%"Virtual machine: %s")'

  printf, _lun, lmgr(/trial) ? 'yes' : 'no', format='(%"Trial: %s")'
  printf, _lun, expireDate, format='(%"Expiration date: %s")'

  printf, _lun, lmgr(/clientserver) ? 'yes' : 'no', format='(%"Client/server: %s")'
  printf, _lun, lmgr(/demo) ? 'yes' : 'no', format='(%"Demo mode: %s")'
  printf, _lun, lmgr(/embedded) ? 'yes' : 'no', format='(%"Embedded: %s")'

  ; monitor info

  sysMonitors = obj_new('IDLsysMonitorInfo')
  nMonitors = sysMonitors->getNumberOfMonitors()
  monitorNames = sysMonitors->getMonitorNames()
  primaryMonitorIndex = sysMonitors->getPrimaryMonitorIndex()
  monitorRectangles = sysMonitors->getRectangles()
  monitorResolutions = sysMonitors->getResolutions()
  isExtendedDesktop = sysMonitors->isExtendedDesktop()
  obj_destroy, sysMonitors

  printf, _lun
  printf, _lun, 'MONITOR INFO'
  printf, _lun, '------------'
  printf, _lun, nMonitors, format='(%"Number of monitors: %d")'
  printf, _lun, isExtendedDesktop ? 'yes' : 'no', $
          format='(%"Extended desktop: %s")'
  for m = 0L, nMonitors - 1L do begin
    printf, _lun, monitorNames[m], $
            strjoin(strtrim(round(2.54 / monitorResolutions[*, m]), 2), ' by '), $
            strjoin(strtrim(monitorRectangles[*, m], 2), ', '), $
            primaryMonitorIndex eq m ? '(primary)' : '', $
            format='(%"%s: %s dpi [%s] %s")'
  endfor

  ; direct graphics

  help, /device, output=graphicsHelp
  printf, _lun
  printf, _lun, 'DIRECT GRAPHICS'
  printf, _lun, '---------------'
  printf, _lun, transpose(graphicsHelp)

  ; object graphics

  win = obj_new('IDLgrWindow')
  win->iconify, 1
  win->getDeviceInfo, version=ogVersion, $
                      shading_language_version=shadingLanguageVersion, $
                      vendor=graphicsCardVendor, $
                      name=graphicsCardName, $
                      framebuffer_object_extension=framebufferObjectExtensions
  obj_destroy, win

  shadingLanguageVersion = shadingLanguageVersion eq '' $
                           ? 'shading language not supported' $
                           : shadingLanguageVersion

  printf, _lun
  printf, _lun, 'OBJECT GRAPHICS'
  printf, _lun, '---------------'

  printf, _lun, graphicsCardName, format='(%"Graphics card: %s")'
  printf, _lun, graphicsCardVendor, format='(%"Graphics card vendor: %s")'

  printf, _lun, ogVersion, format='(%"Rendering device driver version: %s")'

  printf, _lun, shadingLanguageVersion, format='(%"Shading language version: %s")'
  printf, _lun, framebufferObjectExtensions ? 'yes' : 'no', $
          format='(%"Framebuffer object extensions: %s")'

  ; scientific data formats

  printf, _lun
  printf, _lun, 'SCIENTIFIC DATA FORMATS'
  printf, _lun, '-----------------------'

  hdf_lib_info, version=h4Version
  printf, _lun, h4Version, format='(%"HDF 4 version: %s")'

  printf, _lun, h5_get_libversion(), format='(%"HDF 5 version: %s")'

  cdf_lib_info, version=cdfVersion, release=cdfRelease, increment=cdfIncrement
  printf, _lun, cdfVersion, cdfRelease, cdfIncrement, $
          format='(%"CDF version: %d.%d.%d")'

  ;printf, _lun, 'unknown', format='(%"netCDF version: %s")'

  eosFilename = filepath('test_eos_version.eos', /tmp)
  fid = eos_gd_open(eosFilename, /create)
  result = eos_eh_getversion(fid, eosVersion)
  result = eos_gd_close(fid)
  file_delete, eosFilename
  printf, _lun, eosVersion, format='(%"HDF-EOS version: %s")'

  ; floating point precision from MACHAR

  fp = machar()
  dp = machar(/double)

  printf, _lun
  printf, _lun, 'FLOATING POINT PRECISION'
  printf, _lun, '------------------------'
  printf, _lun, fp.ibeta, format='(%"ibeta: %d")'
  printf, _lun, fp.it, format='(%"it: %d")'
  printf, _lun, fp.irnd, format='(%"irnd: %d")'
  printf, _lun, fp.ngrd, format='(%"ngrd: %d")'
  printf, _lun, fp.machep, format='(%"machep: %d")'
  printf, _lun, fp.negep, format='(%"negep: %d")'
  printf, _lun, fp.iexp, format='(%"iexp: %d")'
  printf, _lun, fp.minexp, format='(%"minexp: %d")'
  printf, _lun, fp.maxexp, format='(%"maxexp: %d")'
  printf, _lun, fp.eps, format='(%"eps: %f")'
  printf, _lun, fp.epsneg, format='(%"epsneg: %f")'
  printf, _lun, fp.xmin, format='(%"xmin: %f")'
  printf, _lun, fp.xmax, format='(%"xmax: %f")'

  printf, _lun
  printf, _lun, 'DOUBLE PRECISION'
  printf, _lun, '----------------'
  printf, _lun, dp.ibeta, format='(%"ibeta: %d")'
  printf, _lun, dp.it, format='(%"it: %d")'
  printf, _lun, dp.irnd, format='(%"irnd: %d")'
  printf, _lun, dp.ngrd, format='(%"ngrd: %d")'
  printf, _lun, dp.machep, format='(%"machep: %d")'
  printf, _lun, dp.negep, format='(%"negep: %d")'
  printf, _lun, dp.iexp, format='(%"iexp: %d")'
  printf, _lun, dp.minexp, format='(%"minexp: %d")'
  printf, _lun, dp.maxexp, format='(%"maxexp: %d")'
  printf, _lun, dp.eps, format='(%"eps: %f")'
  printf, _lun, dp.epsneg, format='(%"epsneg: %f")'
  printf, _lun, dp.xmin, format='(%"xmin: %f")'
  printf, _lun, dp.xmax, format='(%"xmax: %f")'

  ; preferences

  help, /preferences, output=preferencesHelp
  printf, _lun
  printf, _lun, 'PREFERENCES'
  printf, _lun, '-----------'
  printf, _lun, transpose(preferencesHelp)

  if (_lun ne -1L) then free_lun, _lun
end


mg_sysreport, filename='system-report.log'

end
