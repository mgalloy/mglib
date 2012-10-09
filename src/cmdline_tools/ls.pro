; docformat = 'rst'

;+
; Equivalent to UNIX `ls` command.
;
; :Examples:
;    Try::
;
;       IDL> ls, /long
;       -rw-r--r--     1K  Mar 23 14:25 COPYING
;       -rw-r--r--   298B  May 14 14:07 Makefile
;       drwxr-xr-x     1K  May 14 14:13 api-docs/
;       -rw-r--r--   259B  Apr 27 15:16 mg_build_dist_tools_docs.pro
;       drwxr-xr-x   748B  May 14 14:09 src/
;       drwxr-xr-x   476B  Apr 22 16:42 unittests/
;-


;+
; Get number of columns in display.
;
; :Private:
;
; :Returns:
;    long
;-
function ls_get_columns
  compile_opt strictarr, hidden

  ; CATCH block for if MG_TERMCOLUMNS is not available
  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    !quiet = oldQuiet
    return, 80L
  endif

  oldQuiet = !quiet
  !quiet = 1
  columns = mg_termcolumns()
  !quiet = oldQuiet

  return, columns
end


;+
; Returns the mode line for each file in the given list.
;
; :Private:
;
; :Returns:
;    `strarr`
;
; :Params:
;    files : in, required, type=strarr
;       array of files
;
; :Keywords:
;    info : in, required, type=array of structures
;       array of structures of the type returned by `FILE_INFO`
;-
function ls_permissions, files, info=info
  compile_opt strictarr, hidden

  type = [['-', 'd'], ['l', 'l']]
  r = ['-', 'r']
  w = ['-', 'w']
  x = ['-', 'x']
  bits = ['400'o, '200'o, '100'o, '040o', '020'o, '010'o, '004'o, '002'o, '001'o]

  nFiles = n_elements(files)
  permissions = strarr(nFiles)
  for f = 0L, nFiles - 1L do begin
    dummy = file_test(files[f], get_mode=mode)
    ind = (bits and mode) gt 0
    permissions[f] = $
      type[info[f].directory, info[f].symlink] $
      + r[ind[0]] + w[ind[1]] + x[ind[2]] $
      + r[ind[3]] + w[ind[4]] + x[ind[5]] $
      + r[ind[6]] + w[ind[7]] + x[ind[8]]
  endfor

  return, permissions
end


;+
; Return a human readable array of sizes using bytes, kilobytes, megabytes,
; gigabytes, terabytes, and petabytes (in powers of two).
;
; :Private:
;
; :Returns:
;    `strarr`
;
; :Params:
;    sizes : in, required, type=intarr
;       array of sizes in bytes
;-
function ls_human_size, sizes
  compile_opt strictarr, hidden

  nSizes = n_elements(sizes)
  results = strarr(nSizes)
  units = ['B', 'K', 'M', 'G', 'T', 'P']
  for i = 0L, nSizes - 1L do begin
    level = 0L
    s = sizes[i]
    while (s ge 1024L) do begin
      s /= 1024L
      level++
    endwhile
    results[i] = strtrim(s, 2) + units[level]
  endfor

  return, results
end


;+
; Convert modification times from long to normal date/time format.
;
; :Private:
;
; :Returns:
;    `strarr`
;
; :Params:
;    mtimes : in, required, type=lonarr
;       array of modification times
;-
function ls_modification_times, mtimes
  compile_opt strictarr, hidden

  currentYear = long(strmid(systime(), 3, 4, /reverse_offset))

  nMTimes = n_elements(mtimes)
  results = strarr(nMTimes)
  for f = 0L, nMTimes - 1L do begin
    date = systime(0, mtimes[f])
    day = strmid(date, 4, 6)
    time = strmid(date, 11, 5)
    year = long(strmid(date, 3, 4, /reverse_offset))

    results[f] = day $
      + (year eq currentYear $
        ? string(time, format='(A6)') $
        : string(year, format='(I6)'))
  endfor

  return, results
end


;+
; Substitute for UNIX `ls` command. Automatically uses `-hF` options.
;
; :Params:
;    pattern : in, optional, type=string, default='*'
;       pattern to match filenames against
;
; :Keywords:
;    all : in, optional, type=boolean
;       report all files (even hidden files like .*)
;    long : in, optional, type=boolean
;       more information about each file is listed
;
; :Bugs:
;    doesn't handle directories matching pattern the same as `ls` does; IDL
;    does not have a mechanism to get the owner for a file, so it is not
;    displayed in the `/LONG` format
;-
pro ls, pattern, all=all, long=long
  compile_opt strictarr, hidden

  oldQuiet = !quiet
  !quiet = 1
  sep = path_sep()
  !quiet = oldQuiet

  _pattern = n_elements(pattern) eq 0 ? '*' : pattern

  files = file_search(_pattern, count=nFiles, $
                      match_all_initial_dot=keyword_set(all))

  if (nFiles eq 0) then return

  ; get info about each file
  info = file_info(files)

  ; mark each filename with
  names = files
  for f = 0L, nFiles - 1L do begin
    case 1 of
      info[f].socket: names[f] = names[f] + '='
      info[f].symlink: names[f] = names[f] + '@'
      info[f].directory: names[f] = names[f] + path_sep()
      info[f].execute: names[f] = names[f] + '*'
      else:
    endcase

    ; FIFO and whiteout can't be determined
  endfor

  if (keyword_set(long)) then begin
    table = strarr(4, nFiles)

    ; permissions
    table[0, *] = ls_permissions(files, info=info)

    ; human readable sizes
    table[1, *] = ls_human_size(strtrim(info.size, 2))

    ; modification times
    table[2, *] = ls_modification_times(info.mtime)

    ind = where(info.symlink, nLinks)
    if (nLinks gt 0) then begin
      for f = 0L, nLinks - 1L do begin
        names[ind[f]] = names[ind[f]] + ' -> '+ file_readlink(files[ind[f]])
      endfor
    endif

    ; filenames
    table[3, *] = names

    print, table, format='(A-10, "  ", A5, "  ", A-12, " ", A)'
  endif else begin
    maxWidth = max(strlen(names)) + 1L

    lineWidth = ls_get_columns()

    ; find a tentative number of columns, then find the correct number of
    ; rows, then back to the minimum number of columns for that number of
    ; rows
    nColumns = lineWidth / maxWidth
    nRows = nFiles / nColumns + (nFiles mod nColumns ne 0)
    nColumns = nFiles / nRows + (nFiles mod nRows ne 0)

    ; pad so can reform vector into 2D array
    padding = nColumns * nRows - nFiles
    if (padding gt 0) then names = [names, strarr(padding)]

    ; print output
    format = '(' + strtrim(nColumns, 2) + 'A-' + strtrim(maxWidth, 2) + ')'
    print, transpose(reform(names, nRows, nColumns)), $
      format=format
  endelse
end
