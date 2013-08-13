; docformat = 'rst'

;+
; Output a polygon to an `.obj` file, as described in the
; `Wikipedia article <https://en.wikipedia.org/wiki/Wavefront_.obj_file>`.
;
; :Params:
;   filename : in, required, type=string
;     filename of output `.obj` file
;   poly : in, required, type=`IDLgrPolygon` object
;     `IDLgrPolygon` to write
;-
pro mg_write_obj, filename, poly
  compile_opt strictarr

  openw, lun, filename, /get_lun

  printf, lun, systime(), format='(%"# produced by MG_WRITE_OBJ on %s")'

  poly->getProperty, data=data
  printf, lun
  printf, lun, '# vertices'
  printf, lun, data, format='(%"v %f %f %f")'

  poly->getProperty, texture_coord=tcoord
  if (tcoord[0] ge 0.) then begin
    printf, lun
    printf, lun, '# texture coordinates'
    printf, lun, tcoord, format='(%"vt %f %f %f")'
  endif

  poly->getProperty, normals=normals
  if (n_elements(normals) gt 1L) then begin
    printf, lun
    printf, lun, '# normals'
    printf, lun, normals, format='(%"vn %f %f %f")'
  endif

  poly->getProperty, polygons=polygons
  printf, lun
  printf, lun, '# face definitions'
  p = 0L
  while (p lt n_elements(polygons) && polygons[p] gt 0L) do begin
    n = polygons[p]
    printf, lun, strjoin(strtrim(polygons[p+1:p+n] + 1L, 2), ' '), format='(%"f %s")'
    p += n + 1L
  endwhile

  free_lun, lun
end


; main-level example program

restore, filename=filepath('cow10.sav', subdir=['examples', 'data'])
cow = obj_new('IDLgrPolygon', x, y, z, polygons=polylist)
mg_write_obj, 'cow10.obj', cow
obj_destroy, cow

end
