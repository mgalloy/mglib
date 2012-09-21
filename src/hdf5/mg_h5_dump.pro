; docformat = 'rst'

;+
; Dumps the structure of an HDF5 file to the output log. This routine does
; not read any data, it simply finds the names and datatypes of datasets,
; groups, types, and links.
;
; :Categories: 
;    file i/o, hdf5, sdf
;
; :Examples:
;    See the attached main-level program for a simple example::
; 
;       IDL> .run mg_h5_dump
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
; Return a string representing an IDL declaration of the given item 
; (attribute or dataset).
;
; :Private:
;
; :Returns: 
;    string
;
; :Params:
;    typeId : in, required, type=long
;       type identifier
;    spaceId : in, required, type=long
;       dataspace identifier
;-
function mg_h5_dump_typedecl, typeId, spaceId
  compile_opt strictarr

  idlType = h5t_idltype(typeId)
  scalarDecl = ['undefined', 'byte', 'int', 'long', 'float', 'double', $
                'complex', 'string', 'structure', 'dcomplex', 'ptr', 'object', $
                'uint', 'ulong', 'long64', 'ulong64']
  arrayDecl = ['', 'bytarr', 'intarr', 'lonarr', 'fltarr', 'dblarr', $ 
               'complexarr', 'strarr', 'structarr', 'dcomplexarr', 'ptrarr', $
               'objarr', 'uintarr', 'ulonarr', 'lon64arr', 'ulon64arr']
                
  dims = h5s_get_simple_extent_dims(spaceId)
  if (dims[0] eq 0) then begin
    decl = scalarDecl[idlType]
  endif else begin
    decl =  arrayDecl[idlType] + '(' + strjoin(strtrim(dims, 2), ', ') + ')'
  endelse

  return, decl
end


;+
; Return information about a named item as `H5G_GET_OBJINFO`, but handles the
; case where the item type is not known (as in a new type not supported by the
; current HDF5 library used by IDL).
;
; :Private:
;
; :Returns:
;    `{ H5G_STAT }` structure
;
; :Params:
;    groupId : in, required, type=long
;       HDF5 identifier for parent group of item queried for
;    objName : in, required, type=string
;       name of the item queried for
;-
function mg_h5_dump_get_objinfo, groupId, objName
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel

    info = { h5g_stat }
    info.type = 'UNKNOWN'

    return, info
  endif

  objInfo = h5g_get_objinfo(groupId, objName)

  return, objInfo
end


;+
; Parse a dataset or group.
; 
; :Private:
;
; :Params:
;    groupId : in, required, type=long
;       identifier of parent item to parse (group or dataset)
;
; :Keywords:
;    level : in, required, type=long
;       level from root (where root is level 0)
;    cache : in, out, required, type=strarr
;       cache of fileno and objno used to identify a hard link
;    objects : in, optional, type=boolean
;       set to parse objects (i.e. for groups)
;    attributes : in, optional, type=boolean
;       set to parse attributes (i.e. for datasets and non-top-level groups)
;-
pro mg_h5_dump_level, groupId, level=level, cache=cache, $
                      objects=objects, attributes=attributes
  compile_opt strictarr

  spaces = level eq 0 ? '' : string(replicate(32B, 2L * level))
  format = '(%"%s%s (%s)")'
  
  if (keyword_set(attributes)) then begin
    nattrs = h5a_get_num_attrs(groupId)
    for a = 0L, nattrs - 1L do begin
      attrId = h5a_open_idx(groupId, a)
      attrName = h5a_get_name(attrId)
      
      attrTypeId = h5a_get_type(attrId)
      attrSpaceId = h5a_get_space(attrId)
      typeDecl = mg_h5_dump_typedecl(attrTypeId, attrSpaceId)
      h5s_close, attrSpaceId
      h5t_close, attrTypeId
      
      h5a_close, attrId
      
      print, spaces, typeDecl, attrName, format='(%"%sATTRIBUTE %s %s")'
    endfor
  endif
  
  if (keyword_set(objects)) then begin
    nmembers = h5g_get_num_objs(groupId)
    for g = 0L, nmembers - 1L do begin
      objName = h5g_get_obj_name_by_idx(groupId, g)    
      objInfo = mg_h5_dump_get_objinfo(groupId, objName)

      strcache = STRJOIN([objInfo.fileno, objInfo.objno], ' ')      
      if (n_elements(cache) gt 0) then begin
        if (total(cache eq strcache) gt 0) then begin
          objInfo.type = 'LINK'
        endif else begin
          cache = [cache, strcache]
        endelse
      endif else begin
        cache = strcache
      endelse
      
      case objInfo.type of
        'GROUP': begin
          print, spaces, objName, format='(%"%sGROUP %s")'
          objId = h5g_open(groupId, objName)
          mg_h5_dump_level, objId, level=level + 1L, /attributes, /objects, cache=cache
          h5g_close, objId        
        end
        'DATASET': begin
          datasetId = h5d_open(groupId, objName)
          
          datasetTypeId = h5d_get_type(datasetId)
          datasetSpaceId = h5d_get_space(datasetId)
          typeDecl = mg_h5_dump_typedecl(datasetTypeId, datasetSpaceId)
          h5s_close, datasetSpaceId
          h5t_close, datasetTypeId
          
          print, spaces, typeDecl, objName, format='(%"%sDATASET %s %s")'
          
          mg_h5_dump_level, datasetId, level=level + 1L, /attributes, cache=cache
          
          h5d_close, datasetId            
          break
        end
        'LINK': print, spaces, objName, format='(%"%sLINK %s")'
        'TYPE': print, spaces, objName, format='(%"%sTYPE %s")'
        'UNKNOWN': print, spaces, objName, format='(%"%sUNKNOWN %s")'
        else: print, spaces, objInfo.type, objName, format='(%"%s%s %s")'
      endcase
    endfor  
  endif
end


;+
; Parse and display a simple hierarchy of contents of a HDF5 file.
;
; :Params:
;    filename : in, required, type=string
;       HDF5 file to parse
;-
pro mg_h5_dump, filename
  compile_opt strictarr

  fileId = h5f_open(filename) 
   
  rootGroupId = h5g_open(fileId, '/')
  mg_h5_dump_level, rootGroupId, level=0, /attributes, /objects  
  h5g_close, rootGroupId
  
  h5f_close, fileId
end


; example of using mg_h5_dump 

f = filepath('hdf5_test.h5', subdir=['examples', 'data'])
mg_h5_dump, f

end