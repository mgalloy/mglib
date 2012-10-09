;+
; Trick to automatically add this to the ENVI menu.
;
; @param button_info {out}{required}{type=structure} information about the button
;-
pro mg_google_lookup_define_buttons, button_info
    compile_opt strictarr

    envi_define_menu_button, button_info, $
      /display, $
      value='Find location using Google Maps', $
      event_pro='mg_google_lookup', $
      ref_value='Tools',  $
      position='last', $
      uvalue='google widget', $
      separator=1
end

;+
; Event handler for ENVI menu.
;
; @file_comments For the current image in an ENVI display, show it's outline in
;                Google Maps.
; @param event {in}{required}{type=event structure} event from ENVI
;-
pro mg_google_lookup, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=dn

    ; query image for info using ENVI routines
    envi_disp_query, dn, fid=fid
    envi_file_query, fid, p_map=p_map, ns=ns, nl=nl

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

    ; bring up the web page showing the image
    url = 'http://michaelgalloy.com/maps/envi_lookup.html?' $
        + 'alon=' + strtrim(lon[0], 2) + ',alat=' + strtrim(lat[0], 2) $
        + ',blon=' + strtrim(lon[1], 2) + ',blat=' + strtrim(lat[1], 2) $
        + ',clon=' + strtrim(lon[2], 2) + ',clat=' + strtrim(lat[2], 2) $
        + ',dlon=' + strtrim(lon[3], 2) + ',dlat=' + strtrim(lat[3], 2)
    mg_open_url, url
end
