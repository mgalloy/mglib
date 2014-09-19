; docformat = 'rst'

;+
; Extract header/trailer structures from a compressed buffer.
;
; :Private:
;
; :Returns:
;   status code: 0 for failure, 1 for success
;
; :Params:
;   pdata : in, required, type=pointer
;     pointer to compressed data
;
; :Keywords:
;   header : out, optional, type=structure
;     structure giving header information found in first 10 bytes of compressed
;     data
;   trailer : out, optional, type=structure
;     structure giving trailer information
;   length : out, optional, type=lonarr(2)
;     length of the header and trailer
;-
function mg_zip_headertrailer, pdata, header=header, trailer=trailer, length=len
  compile_opt idl2, hidden

  if (~ptr_valid(pdata)) then return, 0

  flag = (*pdata)[3]

  if (arg_present(header)) then begin
    header = { id1:   (*pdata)[0], $
               id2:   (*pdata)[1], $
               cm:    (*pdata)[2], $  ; compression method
               flg:   flag, $  ; flags for possible extra header info
               mtime: (*pdata)[4:7], $
               xfl:   (*pdata)[8], $
               os:    (*pdata)[9] $
             }
  endif

  hdr_len = 10L

  ; fextra
  if (flag and 4) then hdr_len += 2L + long(fix((*pdata)[10:11], 0))

  ; fname
  if (flag and 8) then while ((*pdata)[hdr_len] ne 0B) do hdr_len++

  ; fcomment
  if (flag and 16) then while ((*pdata)[hdr_len] ne 0B) do hdr_len++

  ; fhcrc
  if (flag and 2) then hdr_len += 2L

  if (arg_present(trailer)) then begin
    n = n_elements(*pdata)
    trailer = { crc32: (*pdata)[n - 8L:n - 5L], $
                isize: (*pdata)[n - 4L:n - 1L] $ ; uncompressed size
              }
  endif

  ; length of header and trailer, trailer length is always 8
  if (arg_present(len)) then len = [hdr_len, 8L]

  return, 1B
end


;+
; Create local header.
;
; :Private:
;
; :Returns:
;   status code: 0 for failure, 1 for success
;
; :Params:
;   header : in, required, type=structure
;     header structure
;   trailer : in, required, type=structure
;     trailer structure
;   comp_size : in, required, type=long
;     compressed size
;   filename : in, required, type=string
;     filename of file to zip
;
; :Keywords:
;   local_header : out, optional, type=bytarr
;     byte array buffer of local header
;-
function mg_zip_localheader, header, trailer, comp_size, filename, $
                             local_header=local_header
  compile_opt idl2, hidden

  if (~isa(header) || ~isa(trailer) || ~isa(comp_size) || ~isa(filename)) then $
    return, 0

  big_endian = (byte(1, 0, 2))[0] eq 0B

  if (~arg_present(local_header)) then return, 1

  ; setup the header structure
  sheader = { signature:   [80B, 75B, 3B, 4B], $
              version:     bytarr(2), $
              flg:         bytarr(2), $
              cm:          bytarr(2), $
              mtime:       bytarr(2), $
              mdate:       bytarr(2), $
              crc32:       bytarr(4), $
              comp_size:   bytarr(4), $
              uncomp_size: bytarr(4), $
              fname_len:   bytarr(2), $
              extra_len:   bytarr(2) $
            }

  if (big_endian) then begin
    sheader.cm = byte(swap_endian(fix(header.cm)), 0, 2)
    sheader.comp_size = byte(swap_endian(long(comp_size)), 0, 4)
    sheader.fname_len = byte(swap_endian(strlen(file_basename(filename))), 0, 2)
  endif else begin
    sheader.cm = byte(fix(header.cm), 0, 2)
    sheader.comp_size = byte(long(comp_size), 0, 4)
    sheader.fname_len = byte(fix(strlen(file_basename(filename))), 0, 2)
  endelse

  sheader.crc32 = trailer.crc32
  sheader.uncomp_size = trailer.isize

  local_header = byte([sheader.signature, $
                       sheader.version, $
                       sheader.flg, $
                       sheader.cm, $
                       sheader.mtime, $
                       sheader.mdate, $
                       sheader.crc32, $
                       sheader.comp_size, $
                       sheader.uncomp_size, $
                       sheader.fname_len, $
                       sheader.extra_len, $
                       byte(file_basename(filename)) $
                      ])

  return, 1
end


;+
; Create central header.
;
; :Private:
;
; :Returns:
;   status code: 0 for failure, 1 for success
;
; :Params:
;   compHdr : in, required, type=structure
;     compression header
;   compTrailer : in, required, type=structure
;     compression trailer
;   compressed_size : in, required, type=integer
;     compressed size
;   filename : in, required, type=string
;     filename of output
;   local_hdr_offset : in, required, type=integer
;     offset
;   num_centralDir : in, optional, type=integer
;     unused
;
; :Keywords:
;   central_dir : out, required, type=bytarr
;     central header
;-
function mg_zip_centralheader, compHdr, $
                               compTrailer, $
                               compressed_size, $
                               filename, $
                               local_hdr_offset, $
                               num_centralDir, $
                               central_dir=centralDirHdr
  compile_opt idl2, hidden

  big_endian = (byte(1, 0, 2))[0] eq 0B

  if (~arg_present(centralDirHdr)) then return, 1

  ; setup central directory header
  zipCentralDirHdr = { signature:       [80B, 75B, 1B, 2B], $
                       version_made_by: bytarr(2), $
                       version_needed:  bytarr(2), $
                       flg:             bytarr(2), $
                       cm:              bytarr(2), $
                       mtime:           bytarr(2), $
                       mdate:           bytarr(2), $
                       crc32:           bytarr(4), $
                       comp_size:       bytarr(4), $
                       uncomp_size:     bytarr(4), $
                       fname_len:       bytarr(2), $
                       extra_len:       bytarr(2), $
                       comment_len:     bytarr(2), $
                       disk_num:        bytarr(2), $
                       int_attr:        bytarr(2), $
                       ext_attr:        bytarr(4), $
                       rel_offset:      bytarr(4) $
                     }

  if (big_endian) then begin
    zipCentralDirHdr.cm = byte(swap_endian(fix(compHdr.cm)), 0, 2)
    zipcentralDirHdr.comp_size = byte(swap_endian(long(compressed_size)), 0, 4)
    zipCentralDirHdr.fname_len = byte(swap_endian(strlen(file_basename(filename))), 0, 2)
    zipCentralDirHdr.rel_offset = byte(swap_endian(long(local_hdr_offset)), 0, 4)
  endif else begin
    zipCentralDirHdr.cm = byte(fix(compHdr.cm), 0, 2)
    zipcentralDirHdr.comp_size = byte(long(compressed_size), 0, 4)
    zipCentralDirHdr.fname_len = byte(strlen(file_basename(filename)), 0, 2)
    zipCentralDirHdr.rel_offset = byte(long(local_hdr_offset), 0, 4)
  endelse

  zipCentralDirHdr.crc32 = compTrailer.crc32
  zipCentralDirHdr.uncomp_size = compTrailer.isize

  centralDirHdr = byte([zipCentralDirHdr.signature, $
                        zipCentralDirHdr.version_made_by, $
                        zipCentralDirHdr.version_needed, $
                        zipCentralDirHdr.flg, $
                        zipCentralDirHdr.cm, $
                        zipCentralDirHdr.mtime, $
                        zipCentralDirHdr.mdate, $
                        zipCentralDirHdr.crc32, $
                        zipCentralDirHdr.comp_size, $
                        zipCentralDirHdr.uncomp_size, $
                        zipCentralDirHdr.fname_len, $
                        zipCentralDirHdr.extra_len, $
                        zipCentralDirHdr.comment_len, $
                        zipCentralDirHdr.disk_num, $
                        zipCentralDirHdr.int_attr, $
                        zipCentralDirHdr.ext_attr, $
                        zipCentralDirHdr.rel_offset, $
                        byte(file_basename(filename)) $
                       ])

  return, 1
end


;+
; End central header.
;
; :Private:
;
; :Returns:
;   status code: 0 for failure, 1 for success
;
; :Params:
;   centralDirSize : in, required, type=integer
;     size of central dir
;   centralDir_offset : in, required, type=integer
;     offset
;   num_centralDir : in, required, type=integer
;     size of central dir header
;
; :Keywords:
;   end_central_dir : out, required, type=bytarr
;     end of central header
;-
function mg_zip_endcentralheader, centralDirSize, $
                                  centralDir_offset, $
                                  num_centralDir, $
                                  end_central_dir=supp_endCentralDir
  compile_opt idl2, hidden

  big_endian = (byte(1, 0, 2))[0] eq 0B

  if (~arg_present(supp_endCentralDir)) then return, 1

  ; setup end central directory header
  zipsupp_endCentralDir = { signature:               [80B, 75B, 5B, 6B], $
                            disk_num:                bytarr(2), $
                            central_dir_disk:        bytarr(2), $
                            num_central_dir_in_disk: bytarr(2), $
                            central_dir_total:       bytarr(2), $
                            central_dir_size:        bytarr(4), $
                            central_dir_start:       bytarr(4), $
                            comment_len:             bytarr(2) $
                          }

  if (big_endian) then begin
    zipsupp_endCentralDir.num_central_dir_in_disk = byte(swap_endian(fix(num_centralDir)), 0, 2)
    zipsupp_endCentralDir.central_dir_total = byte(swap_endian(fix(num_centralDir)), 0, 2)
    zipsupp_endCentralDir.central_dir_size =  byte(swap_endian(long(centralDirSize)), 0, 4)
    zipsupp_endCentralDir.central_dir_start = byte(swap_endian(long(centralDir_offset)), 0, 4)
  endif else begin
    zipsupp_endCentralDir.num_central_dir_in_disk = byte(fix(num_centralDir), 0, 2)
    zipsupp_endCentralDir.central_dir_total = byte(fix(num_centralDir), 0, 2)
    zipsupp_endCentralDir.central_dir_size =  byte(long(centralDirSize), 0, 4)
    zipsupp_endCentralDir.central_dir_start = byte(long(centralDir_offset), 0, 4)
  endelse

  supp_endCentralDir = byte([zipsupp_endCentralDir.signature, $
                             zipsupp_endCentralDir.disk_num, $
                             zipsupp_endCentralDir.central_dir_disk, $
                             zipsupp_endCentralDir.num_central_dir_in_disk, $
                             zipsupp_endCentralDir.central_dir_total, $
                             zipsupp_endCentralDir.central_dir_size, $
                             zipsupp_endCentralDir.central_dir_start, $
                             zipsupp_endCentralDir.comment_len $
                            ])

  return, 1
end


;+
; Make a zip file from an array of input files.
;
; :History:
;   derived from `idlkml_savekmz` in `idlitwritekml__define.pro`
;
; :Params:
;   zipfile : in, required, type=string
;     filename for created zipfile
;   files : in, required, type=strarr
;     filenames to place in zip file; original files are deleted
;
; :Keywords:
;   delete : in, optional, type=boolean
;     set to delete input files when finished adding to `.zip` file
;   error : out, optional, type=integer
;     error code from creating zip file, 0 for success and 1 for failure
;-
pro mg_zip, zipfile, files, delete=delete, error=error
  compile_opt idl2, hidden
  on_ioerror, ioFailed

  nfiles = n_elements(files)

  zip_data = !null
  headers = list()
  trailers = list()
  compressed_size = lonarr(nfiles)

  if (nfiles ne 0L) then begin
    localheader_offsets = lonarr(nfiles)
    for i = 0L, nfiles - 1L do begin
      openr, lun, files[i], /get_lun, delete=delete
      file_buffer = bytarr((file_info(files[i])).size)
      readu, lun, file_buffer
      free_lun, lun

      ; save into compressed file
      compressed_file_buffer = mg_compress(file_buffer, n_bytes=comp_size)
      pcompressed_file_buffer = ptr_new(compressed_file_buffer)

      status = mg_zip_headertrailer(pcompressed_file_buffer, $
                                    header=compHdr, $
                                    trailer=compTrailer, $
                                    length=hdrTrlLen)
      if (status eq 0) then begin
        error = 1L
        return
      endif

      headers->add, compHdr
      trailers->add, compTrailer

      compressed_size[i] = comp_size - hdrTrlLen[0] - hdrTrlLen[1]

      localheader_offsets[i] = n_elements(zip_data)

      status = mg_zip_localheader(compHdr, $
                                  compTrailer, $
                                  compressed_size[i], $
                                  files[i],$
                                  local_header=localHdr)
      if (status eq 0) then begin
        error = 1L
        return
      endif

      zip_data = [zip_data, localHdr, $
                  compressed_file_buffer[hdrTrlLen[0]:comp_size - 1L - hdrTrlLen[1]]]
    endfor
  endif

  combined_centralDir = !null
  centralDir_offset = n_elements(supp_zipdata) + n_elements(centralDir)
  for i = 0L, nfiles - 1L do begin
    status = mg_zip_centralheader(headers[i], $
                                  trailers[i], $
                                  compressed_size[i], $
                                  files[i], $
                                  localheader_offsets[i], $
                                  nfiles, $
                                  central_dir=centralDir)
    if (status eq 0) then begin
      error = 1L
      return
    endif

    centralDir_offset = centralDir_offset + n_elements(centralDir)
    combined_centralDir = [combined_centralDir, centralDir]
  endfor

  ; create end cenral directory header
  status = mg_zip_endcentralheader(n_elements(combined_centralDir), $
                                   n_elements(zip_data), $
                                   nfiles, $
                                   end_central_dir=endCentralDir)
  if (status eq 0) then begin
    error = 1L
    return
  endif

  ; output zipfile
  openw, lun, zipfile, /get_lun
  writeu, lun, zip_data, combined_centralDir, endCentralDir
  free_lun, lun

  error = 0L
  return

  ioFailed:
  error = 1L
  return
end

