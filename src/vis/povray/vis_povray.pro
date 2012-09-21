; docformat = 'rst'

;+
; Run POV-Ray on an .ini file and return an image of the result.
;
; :Categories:
;    system utility
;-


;+
; Run POV-Ray on an .ini file and return an image of the result.
;
; :Returns:
;    bytarr(3, m, n)
;
; :Params:
;    basename : in, required, type=string
;       path and basename to .ini file
;    output : in, optional, type=string
;       output basename (must be in same directory as basename)
; 
; :Keywords:
;    subset : in, optional, type=lonarr(4)
;       set POV-Ray to only calculate the subset of the image specified by::
;
;          [x0, y0, xsize, ysize]
;
;       The returned image will be xsize by ysize and start at [x0, y0]. 
;       Rows and columns start at 0, but the origin is at the upper left 
;       corner of the image.
;    format : in, optional, type=string
;       output format: 'targus' or 'png'
;    cmd : out, optional, type=string
;       povray invocation command
;    output : out, optional, type=strarr
;       contents of the output log of the povray run
;    convert_location : in, optional, type=string
;       full path of the convert command; needed if convert is not in the 
;       shell path
;    povray_location : in, optional, type=string
;       full path of the povray command; needed if povray is not in the shell
;       path
;    distributed : in, optional, type=boolean
;       set to use mpiDL
;    tile_size : in, optional, type=lonarr(2), default="[100, 100]"
;       set of each tile to be sent to worker nodes when DISTRIBUTED is set
;    full_size : in, optional, type=lonarr(2)
;       full size of the output image; used when DISTRIBUTED is set
;    n_procs : in, optional, type=long, default=1L
;       number of processors to use when DISTRIBUTED is set
;-
function vis_povray, basename, output, subset=subset, format=format, $
                     cmd=cmd, output=povrayErrors, $
                     convert_location=convertLocation, $
                     povray_location=povrayLocation, $
                     distributed=distributed, $
                     tile_size=tileSize, full_size=fullSize, n_procs=nprocs
  compile_opt strictarr
  on_error, 2
  
  if (keyword_set(distributed)) then begin
    _tileSize = n_elements(tileSize) eq 0L ? [100L, 100L] : tileSize
    _nprocs = n_elements(nprocs) eq 0L ? 1L : nprocs 
    if (n_elements(fullSize) eq 0L) then begin
      ; figure out the size of the output image from the .ini file
      iniFilename = basename + '.ini'
      iniOutput = strarr(file_lines(iniFilename))
      openr, lun, iniFilename, /get_lun
      readf, lun, iniOutput
      free_lun, lun
      
      tokens = strsplit(iniOutput[1], /extract)
      _fullSize = long(strmid(tokens, 2))
    endif else begin
      _fullSize = fullSize
    endelse
    
    templateFilename = filepath('vis_povray_mpidl.tt', root=vis_src_root())
    template = obj_new('MGffTemplate', templateFilename)
    vars = { basename:basename, tile_size:_tileSize, full_size:_fullSize }
    templateOutput = string(file_dirname(basename), $
                            path_sep(), $
                            format='(%"%s%svis_povray_mpidl.pro")')
    template->process, vars, templateOutput
    obj_destroy, template
    
    cd, current=origDir
    cd, file_dirname(basename)
    
    resolve_routine, 'vis_povray_mpidl'
    
    cd, origDir
    
    save, /routines, filename='vis_povray_mpidl.sav'
    
    runmpidlCmd = string(_nprocs, $
                         file_expand_path(file_dirname(basename)), $
                         path_sep(), $
                         'vis_povray_mpidl.sav', $
                         format='(%"runmpidl -n %d %s%s%")')
    spawn, runmpidlCmd, runmpidlOutput, runmpidlErrors
  endif

  dir = file_dirname(basename)
  cd, current=origDir
  cd, dir
  
  _format = n_elements(format) eq 0L ? '' : format
  if (n_elements(subset) gt 0L) then _format = 'targa'
  
  case strlowcase(_format) of
    'targa': formatString = '+FT '
    'png': formatString = '+FN8 '
    else: formatString = ''
  endcase

  _output = n_elements(output) eq 0L $
              ? file_basename(basename) $
              : file_basename(output)
  
  ; create a string of povray subsetting options; remember: POV-Ray rows and
  ; columns start with 1
  if (n_elements(subset) gt 0L) then begin
    _subset = string(subset[0] + 1L, $
                     subset[0] + subset[2], $
                     subset[1] + 1L, $
                     subset[1] + subset[3], $
                     format='(%"+SC%d +EC%d +SR%d +ER%d ")')
  endif else _subset = ''
  
  ; assemble the povray command and execute it    
  defsysv, '!povray_location', exists=locationExists
  if (n_elements(povrayLocation) gt 0L) then begin
    _povrayLocation = povrayLocation
    defsysv, '!povray_location', povrayLocation
  endif else begin
    _povrayLocation = locationExists $
                        ? !povray_location $
                        : (!version.os_family eq 'unix' $
                             ? 'povray' $
                             : 'pvengine.exe')          
  endelse
  
  windowsOptions = !version.os_family eq 'unix' $
                     ? '' $
                     : '/render /exit exit'
                             
  cmd = string(_povrayLocation, _subset, formatString, $
               file_basename(basename), $
               (strlen(_output) eq 0L ? '' : ('+O' + _output)), $
               windowsOptions, $
               format='(%"\"%s\" +A -D %s%s%s.ini %s %s")')
  spawn, cmd, povrayOutput, povrayErrors

  defsysv, '!convert_location', exists=locationExists
  if (n_elements(convertLocation) gt 0L) then begin
    _convertLocation = convertLocation
    defsysv, '!convert_location', convertLocation
  endif else begin
    _convertLocation = locationExists $
                         ? !convert_location $
                         : 'convert'          
  endelse
    
  case strlowcase(_format) of
    'targa': begin
        convertSubset = n_elements(subset) eq 0L $
                          ? '' $
                          : string(subset[2], $
                                   subset[3], $
                                   subset[0], $
                                   format='(%"-crop %dx%d+%d+0 ")')

        convertCmd = string(_convertLocation, $
                            convertSubset, $
                            _output, $
                            _output, $
                            format='(%"\"%s\" %s%s.tga %s.png")')
                            
        spawn, convertCmd, convertOutput, convertErrors
      end
    else: 
  endcase
  
  ; read output file
  im = read_png(_output + '.png')
  
  ; return to original directory
  cd, origDir
  
  return, im
end
