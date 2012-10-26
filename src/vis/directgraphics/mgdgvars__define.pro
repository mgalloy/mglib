; docformat = 'rst'

;+
; Object to save/restore direct graphics system variables. This is needed when
; using multiple graphics windows and it is necessary to use the coordinate
; system of a window which does not contain the last item plotted. For
; example, this happens when using `WSET` to change to a graphics window
; containing a plot (but not the most recently plotted) and overplotting or
; using CONVERT_COORD with the coordinate system of that window.
;
; :Examples:
;    See the main-level example program at the end of the file::
;
;       IDL> .run mgdgvars__define
;-

;+
; Save direct graphics system variables.
;-
pro mgdgvars::save
    compile_opt strictarr

    self.p = !p
    self.x = !x
    self.y = !y
    self.z = !z
    self.map = !map
end


;+
; Restore direct graphics system variables.
;-
pro mgdgvars::restore
    compile_opt strictarr

    !p = self.p
    !x = self.x
    !y = self.y
    !z = self.z
    !map = self.map
end


;+
; Free resources.
;-
pro mgdgvars::cleanup
    compile_opt strictarr

end


;+
; Create an mgdgvars object.
;
; :Returns:
;    1B for success, 0B otherwise
;-
function mgdgvars::init
    compile_opt strictarr

    return, 1B
end


;+
; Define member variables.
;
; :Fields:
;    p
;       saved !p system variable
;    x
;       saved !x system variable
;    y
;       saved !y system variable
;    z
;       saved !z system variable
;    map
;       saved !map system variable
;-
pro mgdgvars__define
    compile_opt strictarr

    define = { mgdgvars, $
               p: !p, $
               x: !x, $
               y: !y, $
               z: !z, $
               map: !map $
             }
end


; main-level example program

mg_constants

; do it incorrectly without `MGdgVars`
window, 0
plot, findgen(10)

window, 1
plot, 2 * findgen(10)

wset, 0
coords = convert_coord([5], [5], /data, /to_normal)
plots, coords[0], coords[1], /normal, psym=!mg.psym.x


; do it correctly with `MGdgVars`
vars = obj_new('MGdgVars')

window, 2
plot, findgen(10)
vars->save

window, 3
plot, 2 * findgen(10)

wset, 2
vars->restore

coords = convert_coord([5], [5], /data, /to_normal)
plots, coords[0], coords[1], /normal, psym=!mg.psym.x

obj_destroy, vars

end
