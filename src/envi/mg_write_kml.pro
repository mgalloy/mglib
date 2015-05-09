; docformat = 'rst'


;+
; For the current image in an ENVI display, export image to KML file for Google
; Earth.
;-


;+
; Trick to automatically add this to the ENVI menu.
;
; :Params:
;   button_info : out, required, type=structure
;     information about the button
;-
pro mg_write_kml_define_buttons, button_info
  compile_opt strictarr

  envi_define_menu_button, button_info, $
                           /display, $ $
                           value='Write KML file for Google Earth', $
                           event_pro='mg_write_kml', $
                           ref_value='Tools', $
                           position='last', $
                           uvalue='google earth widget', $
                           separator=1
end


;+
; Event handler for ENVI menu.
;
; :Params:
;   event : in, required, type=event structure
;     event from ENVI
;-
pro mg_write_kml, event
  compile_opt strictarr

  ; get display number
  widget_control, event.top, get_uvalue=dn

  ; query image for info using ENVI routines
  envi_disp_query, dn, fid=fid
  envi_file_query, fid, p_map=p_map, ns=ns, nl=nl, nb=nb, dims=dims, descrip=descrip

  ; fail if no map info is present
  if (envi_has_map_info(p_map, /no_arbitrary) eq 0) then begin
    envi_error, ['Sorry, this image has no map information associated with it.']
    return
  endif

  ; get coordinates for image and convert to lat/lon
  xfile = [0, ns-1, ns-1, 0]
  yfile = [0, 0, nl-1, nl-1]
  envi_convert_file_coordinates, fid, xfile, yfile, xmap, ymap, /to_map
  i_proj = envi_get_projection(fid=fid)
  envi_convert_projection_coordinates, xmap, ymap, i_proj, lon, lat, $
                                       envi_proj_create(/geo)

  outputKMLFile = dialog_pickfile(title='Select output KML filename', $
                                  default_extension='kml', /write)
  extension = strlowcase(strmid(outputKMLFile, 3, 4, /reverse_offset))
  if (extension ne '.kml') then begin
    outputKMLFile = outputKMLFile + '.kml'
  endif
  openw, kml_lun, outputKMLFile, /get_lun

  ; header info
  printf, kml_lun, '<?xml version="1.0" encoding="UTF-8"?>'
  printf, kml_lun, '<kml xmlns="http://www.opengis.net/kml/2.2">'
  printf, kml_lun, '  <GroundOverlay>'
  printf, kml_lun, '    <name>' + file_basename(outputKMLFile, '.kml') + '</name>'
  printf, kml_lun, '    <description>' + descrip + '</description>'

  ; choose a filename to write output file
  outputOverlayFile = file_dirname(outputKMLFile, /mark_directory) $
                      + file_basename(outputKMLFile, 'kml') + 'tiff'

  ; stretch the image
  envi_doit, 'stretch_doit', fid=fid, $
             dims=dims, pos=lindgen(nb), $
             i_max=255, i_min=0, range_by=1, method=1, $
             out_dt=1, out_max=255, out_min=0, /in_memory, r_fid=sfid

  ; write an output file that Google Earth understands: (BMP, GIF, TIFF, TGA,
  ; and PNG)
  envi_output_to_external_format, fid=sfid, dims=dims, pos=lindgen(nb), $
                                  out_name=outputOverlayFile, /tiff

  ;envi_output_to_external_format, fid=fid, dims=dims, pos=pos, $
  ;                                out_name=outputOverlayFile, /tiff

  ; get the edges
  ;north_lat = (map_info.mc)[3]
  ;south_lat = (map_info.mc)[3] - (map_info.ps)[1] * geo_nl
  ;east_lon = (map_info.mc)[2] + (map_info.ps)[0] * geo_nl
  ;west_lon = (map_info.mc)[2]

  ; printf, kml_lun, '    <LookAt>'
  ; printf, kml_lun, '      <longitude>' + strtrim(total(lon) / 4.0, 2) + '</longitude>'
  ; printf, kml_lun, '      <latitude>' + strtrim(total(lat) / 4.0, 2) + '</latitude>'
  ; printf, kml_lun, '      <range>18934</range>'
  ; printf, kml_lun, '      <tilt>0.0</tilt>'
  ; printf, kml_lun, '      <heading>0.0</heading>'
  ; printf, kml_lun, '    </LookAt>'

  ; Add the icon tag (the actual image), for example:
  ;  <Icon>
  ;    <href>/Users/mgalloy/bighorn.tif</href>
  ;  </Icon>
  printf, kml_lun, '    <Icon>'
  printf, kml_lun, '      <href>' + outputOverlayFile + '</href>'
  printf, kml_lun, '    </Icon>'

  ; Add the corners to the kml file

  ;  <LatLonBox>
  ;    <north>37.41778844370899</north>
  ;    <south>37.39517166922765</south>
  ;    <east>-122.2075616019248</east>
  ;    <west>-122.2369463102683</west>
  ;    <rotation>-4.572382628066295</rotation>
  ;  </LatLonBox>

  angle = (atan((lat[1] - lat[0]) / (lon[1] - lon[0])) $
           + atan((lat[2] - lat[3]) / (lon[2] - lon[3]))) / 1.4 * !radeg

  printf, kml_lun, '    <LatLonBox>'
  printf, kml_lun, '      <north>' + strtrim((lat[0] + lat[1]) /2.0, 2) + '</north>'
  printf, kml_lun, '      <south>' + strtrim((lat[3] + lat[2]) /2.0, 2) + '</south>'
  printf, kml_lun, '      <east>'  + strtrim((lon[2] + lon[1]) / 2.0, 2)  + '</east>'
  printf, kml_lun, '      <west>'  + strtrim((lon[0] + lon[3]) /2.0, 2)  + '</west>'
  printf, kml_lun, '      <rotation>' + strtrim(angle, 2) + '</rotation>'
  printf, kml_lun, '    </LatLonBox>'

  printf, kml_lun, '  </GroundOverlay>'
  printf, kml_lun, '</kml>'

  close, kml_lun
end
