compile_opt strictarr

; Mac OS X Lion workaround
device, retain=2

appdir = app_user_dir('mgalloy', 'mgalloy', 'mglib', 'mglib', 'mglib', 1)
last_modified = 0LL
last_modified_filename = filepath('last_modified_paths', root=appdir)
if (file_test(last_modified_filename)) then begin & openr, lun, last_modified_filename, /get_lun & readf, lun, last_modified & free_lun, lun & endif

changed_paths = 0B
  
; set IDL_PATH
idl_path_filename = filepath('.idl_path', root=getenv('HOME'))
if ((file_info(idl_path_filename)).mtime gt last_modified) then begin & changed_paths = 1B & nPathDirs = file_lines(idl_path_filename) & pathDirs = strarr(nPathDirs) & openr, lun, idl_path_filename, /get_lun & readf, lun, pathDirs & free_lun, lun & commentPos = strpos(pathDirs, ';') & pathDirInds = where(commentPos ne 0, nPathDirs) & if (nPathDirs gt 0) then mg_set_path, pathDirs[pathDirInds] & endif

; set IDL_DLM_PATH
idl_path_filename = filepath('.idl_dlm_path', root=getenv('HOME'))
if ((file_info(idl_path_filename)).mtime gt last_modified) then begin & changed_paths = 1B & nPathDirs = file_lines(idl_path_filename) & pathDirs = strarr(nPathDirs) & openr, lun, idl_path_filename, /get_lun & readf, lun, pathDirs & free_lun, lun & commentPos = strpos(pathDirs, ';') & pathDirInds = where(commentPos ne 0, nPathDirs) & if (nPathDirs gt 0) then mg_set_path, pathDirs[pathDirInds], /dlm & endif

if (changed_paths) then begin & message, 'mg_startup.pro: Changing paths...', /noname, /informational & openw, lun, last_modified_filename & printf, lun, long64(systime(/seconds)) & free_lun, lun & endif

; quietly load mglib constants
oldQuiet = !quiet
!quiet = 1
mg_constants
!quiet = oldQuiet

; remove temporary variables
delvar, appdir, last_modified, last_modified_filename, changed_paths, $
        idl_path_filename, nPathDirs, pathDirs, lun, $
        commentPos, pathDirInds, oldQuiet
