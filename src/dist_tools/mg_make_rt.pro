; docformat = 'rst'

;+
; `MG_MAKE_RT` can build a cross-platform runtime distribution.
; 
; :Todo:
;    make a table of all possible combinations of platforms and test
;
; :Author:
;    Michael Galloy
;-


;+
; Converts a Windows text file containing CR+LF linebreaks to a Unix style
; text file with just LF linebreaks.
;
; :Private:
; 
; :Params:
;    filename : in, required, type=string
;       filename of text file to modify
;-
pro mg_make_rt_dos2unix, filename
  compile_opt strictarr
  
  ; read the file
  nlines = file_lines(filename)
  lines = strarr(nlines)
  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun
  
  ; add the Unix style newline to each line
  lines += string([10B])

  ; write the file
  openw, lun, filename, /get_lun
  writeu, lun, lines
  free_lun, lun
end


;+
; Wrapper for `MAKE_RT`. `MG_MAKE_RT` will automatically use all the platforms
; which are available in the $IDL_DIR/bin directory. The params/keywords are 
; the same as for `MAKE_RT`, except all the platform specifying ones are 
; omitted since they are no longer needed.
;
; :Params:
;    appname : in, required, type=string
;       name of the application
;    outdir : in, required, type=string
;       directory to place output in; this directory must exist and must use 
;       the `OVERWRITE` keyword if this directory is not empty
;
; :Keywords:
;    embedded : in, optional, type=boolean
;       set to launch savefile in embedded license mode
;    idldir : in, optional, type=string, default=!dir
;       specify IDL distribution which the files should be copied from
;    logfile : in, optional, type=string, default=outdir/appname/log.txt
;       full path to log file produced while generating the runtime 
;       distribution
;    manifest : in, optional, type=string, default=!DIR/bin/make_rt/manifest_rt.txt
;       specify a manifest file
;    app_manifest : in, optional, type=string
;       specify a manifest of application files
;    overwrite : in, optional, type=boolean
;       set to overwrite existing files instead of generating an error
;    savefile : in, optional, type=string
;       full path to save file to be launched; if nothing specified, then a 
;       file selection dialog will be displayed
;    vm : in, optional, type=boolean
;       set to automatically run in virtual machine mode instead of attempting
;       runtime
;    dataminer : in, optional, type=boolean
;       set to include support for Dataminer
;    dicomex : in, optional, type=boolean
;       set to include support for `IDLffDicomEx` objects
;    hires_maps : in, optional, type=boolean
;       set to include support for high resolution maps
;
; :Requires:
;    IDL 7.1
;-
pro mg_make_rt, appname, outdir, $
                idldir=idldir, logfile=logfile, $
                app_manifest=appManifest, manifest=manifest, $
                overwrite=overwrite, savefile=savefile, $
                vm=vm, embedded=embedded, dataminer=dataminer, $
                dicomex=dicomex, hires_maps=hires_maps
  compile_opt strictarr
  
  binFiles = filepath('bin.*', subdir=['bin'])
  binDirs = file_basename(file_search(binFiles, /test_directory))
  archAvailable = strmid(binDirs, 4)
  
  for a = 0, n_elements(archAvailable) - 1L do begin
    case archAvailable[a] of
      'x86': win32 = 1
      'x86_64': win64 = 1
      'darwin.ppc': macppc32 = 1
      'darwin.i386': macint32 = 1
      'darwin.x86_64': macint64 = 1
      'linux.x86': lin32 = 1
      'linux.x86_64': lin64 = 1
      'solaris2.sparc': sun32 = 1
      'solaris2.sparc64': sun64 = 1
      'solaris2.x86_64': sunx86_64 = 1     
      else: message, 'unknown architecture ' + archAvailable[a], /informational
    endcase    
  endfor
  
  ; make the output directory if it doesn't exist already
  if (~file_test(outdir, /directory)) then file_mkdir, outdir
  
  make_rt, appname, outdir, $
           idldir=idldir, logfile=logfile, manifest=manifest, $
           overwrite=overwrite, savefile=savefile, $
           vm=vm, embedded=embedded, dataminer=dataminer, $
           dicomex=dicomex, hires_maps=hires_maps, $
           win32=win32, win64=win64, $
           macppc32=macppc32, macint32=macint32, macint64=macint64, $
           lin32=lin32, lin64=lin64, $
           sunx86_64=sunx86_64, sun32=sun32, sun64=sun64

  if (n_elements(appManifest) gt 0L) then begin
    if (~file_test(appManifest)) then begin
      message, 'application manifest file specified does not exist', /informational
    endif else begin
      nlines = file_lines(appManifest)
      manifestFiles = strarr(nlines)
      
      openr, lun, appManifest, /get_lun
      readf, lun, manifestFiles
      free_lun, lun
      
      _outdir = file_expand_path(outdir)
      
      cd, current=origdir
      if (n_elements(savefile) gt 0L) then cd, file_dirname(appManifest)
      for i = 0L, nlines - 1L do begin
        filename = strtrim(manifestFiles[i], 2)
        file_copy, filename, $
                   filepath(filename, subdir=[appname], root=_outdir), $
                   recursive=file_test(filename, /directory)
      endfor
      cd, origdir
    endelse
  endif        
           
  ; fixes for IDL problems
  
  ; if on Windows and producing a Linux run script, there will be CR-LF 
  ; linebreaks instead of just LF
  if (!version.os_family eq 'Windows' $
        && (keyword_set(lin32) || keyword_set(lin64))) then begin
    script = filepath(appname, subdir=appname, root=outdir)
    if (file_test(script)) then mg_make_rt_dos2unix, script
  endif
  
  ; Mac launcher not created on Linux
  if (keyword_set(macppc32) || keyword_set(macint32) || keyword_set(macint64)) then begin
    if (!version.os_name ne 'Mac OS X') then begin
      message, 'Mac launcher app not created', /informational
    endif
  endif
end
