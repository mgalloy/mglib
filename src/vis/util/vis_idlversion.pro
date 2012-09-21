; docformat = 'rst'

;+
; Returns the IDL version number as a string or a boolean indicating whether
; a required version is met. 
;
; :Returns:
;    string version number or boolean
;
; :Keywords:
;    require : in, optional, type=string
;       IDL version required; if set, VIS_IDLVERSION returns a boolean of 
;       whether the version requirement is met
;-
function vis_idlversion, require=require
  compile_opt strictarr
  
  version = (strsplit(!version.release, /extract))[0]
  
  if (n_elements(require) gt 0L) then begin
    versionTokens = long(strsplit(version, '.', /extract, count=nVersion))
    requireTokens = long(strsplit(require, '.', /extract, count=nRequire))
    
    versionParts = lonarr(nVersion > nRequire)
    requireParts = lonarr(nVersion > nRequire)
    versionParts[0] = versionTokens
    requireParts[0] = requireTokens
    
    for i = 0L, (nVersion > nRequire) - 1L do begin
      if (versionParts[i] lt requireParts[i]) then return, 0B
      if (versionParts[i] gt requireParts[i]) then return, 1B
    endfor
    
    return, 1B
  endif else begin
    return, version
  endelse
end
