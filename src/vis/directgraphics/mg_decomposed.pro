; docformat = 'rst'

;+
; Set the decomposed mode, if available in the current graphics device i.e.
; equivalent to::
; 
;    device, get_decomposed=oldDec
;    device, decomposed=dec
;
; The main advantage of this routine is that it can be used with any graphics
; device; it will be ignored in devices which don't support it.
;
; This routine uses IDL 7.1 functionality for the PS device, but fails 
; gracefully if the IDL version is less than 7.1.
; 
; :Requires:
;    IDL 7.1
;
; :Params:
;    dec : in, required, type=long
;       decomposed mode: 0 for indexed color, 1 for decomposed color
;
; :Keywords:
;    old_decomposed : out, optional, type=long
;       decomposed mode before mode is changed (only available in X and WIN
;       graphics devices)
;-
pro vis_decomposed, dec, old_decomposed=oldDec
  compile_opt strictarr
  on_error, 2
  
  switch !d.name of
    'X':
    'WIN': begin
        device, get_decomposed=oldDec
        if (n_elements(dec) gt 0L) then device, decomposed=dec
        break
      end
      
    'METAFILE':
    'PRINTER': begin
        if (n_elements(dec) gt 0L) then device, true_color=keyword_set(dec)
        break
      end
      
    'Z': begin
        if (vis_idlversion(require='6.4')) then begin
          device, get_pixel_depth=oldDec
          if (n_elements(dec) gt 0L) then device, set_pixel_depth=keyword_set(dec) ? 24 : 8
        endif else begin
          oldDec = 0B
          if (n_elements(dec) gt 0L) then begin
            if (dec ne 0L) then begin
              message, '24-bit color not available for Z-buffer in IDL versions before 6.4'
            endif
          endif
        endelse
        
        break
      end
    
    'PS': begin
        if (vis_idlversion(require='7.1')) then begin
          help, /device, output=deviceOutput
          pos = stregex(deviceOutput, $
                        '[[:space:]]*Input Color Mode:[[:space:]]*', $
                        length=len)
          ind = where(pos ne -1L, count)
          if (count gt 0L) then begin
            mode = strmid(deviceOutput[ind[0]], pos[ind[0]] + len[ind[0]])
            oldDec = mode eq 'Decomposed'
          endif          
          
          if (n_elements(dec) gt 0L) then device, decomposed=keyword_set(dec)
        endif else begin
          oldDec = 0B
          if (n_elements(dec) gt 0L) then begin
            if (dec ne 0L) then begin
              message, '24-bit color not available in PostScript in IDL versions before 7.1'
            endif
          endif
        endelse
        
        break
      end
    else:
  endswitch
end
