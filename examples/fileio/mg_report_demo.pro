;+
; Produces an HTML report of the the images in a given directory.
; 
; @param dir {in}{optional}{type=string}{default=$IDLDIR/examples/data}
;        directory to check for image files
;-
pro mg_report_demo, dir
  compile_opt strictarr

  ; default directory is the examples/data directory in the IDL installation
  myDir = n_elements(dir) eq 0 $
          ? filepath('', subdir=['examples', 'data']) $
          : dir

  ; find any files in the given directory
  files = file_search(myDir, '*', count=nFiles)

  ; define the information to report for each image
  imageInfo = { filename: '', $
                channels: 0L, $
                dimensions: lonarr(2), $
                has_palette: 0L, $
                num_images: 0L, $
                image_index: 0L, $
                pixel_type: 0L, $
                type: '' $
              }
  infoArray = replicate(imageInfo, nFiles)

  ; store whether each file is a supported image file type
  isImage = bytarr(nFiles)

  ; query each file for image information
  for f = 0L, nFiles - 1L do begin
    info = imageInfo
    isImage[f] = query_image(files[f], info)
    struct_assign, info, imageInfo
    imageInfo.filename = files[f]
    infoArray[f] = imageInfo
  endfor

  ; check to see which files are image files
  ind = where(isImage, nImages)
  if (nImages eq 0) then begin
    print, 'No images to report'
    return
  endif

  ; only pass along the info of image files
  infoArray = infoArray[ind]

  ; create the template, variables structure, and process
  template = obj_new('MGffTemplate', 'report.tt')
  variables = { dir: myDir, $
                files: infoArray, $
                header: 'header.tt', $
                footer: 'footer.tt' $
              }
  template->process, variables, 'report.html'
  obj_destroy, template
end

