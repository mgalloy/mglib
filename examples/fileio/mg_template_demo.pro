;+
; An example that uses the template class to produce HTML output from a
; QUERY_IMAGE call. The structure from QUERY_IMAGE has fields channels,
; dimensions, has_palette, image_index, num_images, pixel_type, type.
;-
pro mg_template_demo
  compile_opt strictarr

  ; specify file and query it
  filename = filepath('people.jpg', subdir=['examples', 'data'])
  result = query_image(filename, info)

  ; create a template from a template file
  otemplate = obj_new('MGffTemplate', 'image-file.tt')
  
  ; send a structure with fields matching the names in the template file to the
  ; template object
  otemplate->process, info, 'image.html'

  ; done with the template
  obj_destroy, otemplate
end
