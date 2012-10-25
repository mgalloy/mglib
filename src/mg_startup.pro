compile_opt strictarr

; Mac OS X Lion workaround
device, retain=2

; set IDL_PATH
idl_path_filename = getenv('HOME') + path_sep() + '.idl_path'
nPathDirs = file_lines(idl_path_filename)
pathDirs = strarr(nPathDirs)

openr, lun, idl_path_filename, /get_lun
readf, lun, pathDirs
free_lun, lun

commentPos = strpos(pathDirs, ';')
pathDirInds = where(commentPos ne 0, nPathDirs)
if (nPathDirs gt 0) then mg_set_path, pathDirs[pathDirInds]

; set IDL_DLM_PATH
idl_path_filename = getenv('HOME') + path_sep() + '.idl_dlm_path'
nPathDirs = file_lines(idl_path_filename)
pathDirs = strarr(nPathDirs)

openr, lun, idl_path_filename, /get_lun
readf, lun, pathDirs
free_lun, lun

commentPos = strpos(pathDirs, ';')
pathDirInds = where(commentPos ne 0, nPathDirs)
if (nPathDirs gt 0) then mg_set_path, pathDirs[pathDirInds], /dlm

; quietly load mglib constnants
oldQuiet = !quiet
!quiet = 1
mg_constants
!quiet = oldQuiet

; remove temporary variables
delvar, idl_path_filename, nPathDirs, pathDirs, lun, $
        commentPos, pathDirInds, oldQuiet
