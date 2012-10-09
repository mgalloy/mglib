; docformat = 'rst'

;+
; Write a variable or attribute to an HDF 5 file with a simple notation.
;
; :Categories:
;    file i/o, hdf5, sdf
;
; :Examples:
;    For example, the following creates an HDF5 file::
;
;       IDL> filename = 'test.h5'
;       IDL> mg_h5_putdata, filename, 'scalar', 1.0
;       IDL> mg_h5_putdata, fid, 'array', findgen(10)
;       IDL> mg_h5_putdata, filename, 'group/another_scalar', 1.0
;       IDL> mg_h5_putdata, filename, 'group/another_array', findgen(10)
;       IDL> mg_h5_putdata, filename, 'array.attribute', 'Attribute of an array'
;
;    To browse the results::
;
;       IDL> ok = h5_browser(filename)
;
; :Author:
;    Michael Galloy
;
; :Copyright:
;    This library is released under a BSD-type license.
;
;    Copyright (c) 2007-2010, Michael Galloy <mgalloy@idldev.com>
;
;    All rights reserved.
;
;    Redistribution and use in source and binary forms, with or without
;    modification, are permitted provided that the following conditions are
;    met:
;
;        a. Redistributions of source code must retain the above copyright
;           notice, this list of conditions and the following disclaimer.
;        b. Redistributions in binary form must reproduce the above copyright
;           notice, this list of conditions and the following disclaimer in
;           the documentation and/or other materials provided with the
;           distribution.
;        c. Neither the name of Michael Galloy nor the names of its
;           contributors may be used to endorse or promote products derived
;           from this software without specific prior written permission.
;
;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;    THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;-


;+
; Determines if an object with a given name exists at a given location.
;
; :Private:
;
; :Returns:
;    1 if exists, 0 if it doesn't
;
; :Params:
;    loc : in, required, type=long
;       file or group identifier
;    name : in, required, type=string
;       name of object to check
;-
function mg_h5_putdata_varexists, loc, name
  compile_opt strictarr

  nobjs = h5g_get_num_objs(loc)
  for o = 0L, nobjs - 1L do begin
    if (name eq h5g_get_obj_name_by_idx(loc, o)) then return, 1
  endfor

  return, 0
end


; +
; Write a variable to a file.
;
; :Private:
;
; :Params:
;    fildename : in, required, type=long
;       HDF5 filename to write variable into
;    name : in, required, type=string
;       name of variable in HDF5 file
;    data : in, optional, type=any
;       IDL variable to write
;-
pro mg_h5_putdata_putvariable, filename, name, data
  compile_opt strictarr

	if (file_test(filename)) then begin
	  fileId = h5f_open(filename, /write)
  endif else begin
    fileId = h5f_create(filename)
  endelse

  tokens = strsplit(name, '/', /extract, /preserve_null, count=ntokens)
  loc = fileId

  ; loop over tokens except last one
  groups = lonarr(ntokens)   ; one too big, but makes sure not zero-length
  for t = 0L, ntokens - 2L do begin
    if (mg_h5_putdata_varexists(loc, tokens[t])) then begin
      loc = h5g_open(loc, tokens[t])
    endif else begin
      loc = h5g_create(loc, tokens[t])
    endelse

    groups[t] = loc
  endfor

  if (tokens[ntokens - 1L] ne '') then begin
    ; get the HDF5 type from the IDL variable
    datatypeId = h5t_idl_create(data)

    ; scalars and arrays are created differently
    if (size(data, /n_dimensions) eq 0L) then begin
      dataspaceId = h5s_create_scalar()
    endif else begin
      dataspaceId = h5s_create_simple(size(data, /dimensions))
    endelse

    if (~mg_h5_putdata_varexists(loc, tokens[ntokens - 1L])) then begin
      datasetId = h5d_create(loc, tokens[ntokens - 1L], datatypeId, dataspaceId)
    endif else begin
      datasetId = h5d_open(loc, tokens[ntokens - 1L])
    endelse

    h5d_write, datasetId, data

    h5d_close, datasetId
    h5s_close, dataspaceId
    h5t_close, datatypeId
  endif

  for t = ntokens - 2L, 0L, -1L do h5g_close, groups[t]

  h5f_close, fileId
end


;+
; Write an attribute to a specific group, dataset, or type in a file.
;
; :Private:
;
; :Params:
;    id : in, required, type=long
;       identifier of group, dataset, or type to attach the attribute to
;    attname : in, required, type=string
;       name of attribute to write
;    attvalue : in, required, type=any
;       value of attribute to write
;-
pro mg_h5_putdata_putattributedata, id, attname, attvalue
  compile_opt strictarr

  datatypeId = h5t_idl_create(attvalue)

  ; scalars and arrays are created differently
  if (size(data, /n_dimensions) eq 0L) then begin
    dataspaceId = h5s_create_scalar()
  endif else begin
    dataspaceId = h5s_create_simple(size(attvalue, /dimensions))
  endelse

  attributeId = h5a_create(id, attname, datatypeId, dataspaceId)

  h5a_write, attributeId, attvalue
  h5a_close, attributeId
end


;+
; Write an attribute to a file.
;
; :Private:
;
; :Params:
;    filename : in, required, type=long
;       HDF5 filename to write variable into
;    loc : in, required, type=string
;       name of variable in HDF5 file
;    attname : in, required, type=string
;       name of attribute to write
;    attvalue : in, optional, type=any
;       IDL variable to write
;-
pro mg_h5_putdata_putattribute, filename, loc, attname, attvalue
  compile_opt strictarr
  on_error, 2

	if (file_test(filename)) then begin
	  fileId = h5f_open(filename, /write)
  endif else begin
    fileId = h5f_create(filename)
  endelse

  objInfo = h5g_get_objinfo(fileId, loc)
  case objInfo.type of
    'LINK': message, 'Cannot handle an attribute of a reference'
    'GROUP': begin
        group = h5g_open(fileId, loc)
        mg_h5_putdata_putattributedata, group, attname, attvalue
        h5g_close, group
      end
    'DATASET': begin
        dataset = h5d_open(fileId, loc)
        mg_h5_putdata_putattributedata, dataset, attname, attvalue
        h5d_close, dataset
      end
    'TYPE': begin
        type = h5t_open(fileId, loc)
        mg_h5_putdata_putattributedata, type, attname, attvalue
        h5t_close, type
      end
    'UNKNOWN': message, 'Unknown item'
  endcase

  h5f_close, fileId
end


;+
; Write data to a file.
;
; :Params:
;    filename : in, required, type=long
;       HDF5 filename to write variable into
;    name : in, required, type=string
;       name of variable in HDF5 file
;    data : in, optional, type=any
;       IDL variable to write
;-
pro mg_h5_putdata, filename, name, data
	compile_opt strictarr
	on_error, 2

  dotPos = strpos(name, '.', /reverse_search)
  if (dotPos eq -1L) then begin
    ; write variable
    mg_h5_putdata_putvariable, filename, name, data
  endif else begin
    ; write attribute
    path = strmid(name, 0, dotPos)
    attname = strmid(name, dotPos + 1L)
    mg_h5_putdata_putattribute, filename, path, attname, data
  endelse
end


; main-level example program

filename = 'test.h5'

mg_h5_putdata, filename, 'scalar', 1.0
mg_h5_putdata, filename, 'array', findgen(10)
mg_h5_putdata, filename, 'group/another_scalar', 1.0
mg_h5_putdata, filename, 'group/another_array', findgen(10)
mg_h5_putdata, filename, 'array.attribute', 'Attribute of an array'

mg_h5_dump, 'test.h5'

end