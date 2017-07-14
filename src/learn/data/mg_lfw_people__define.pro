; docformat = 'rst'

;+
; .. image: lfw.png
;-

;= overload methods

function mg_lfw_people::_overloadBracketsRightSide, is_range, ss1
  compile_opt strictarr

  if (is_range[0]) then begin
    filenames = (*self.image_filenames)[ss1[0]:ss1[1]:ss1[2]]
  endif else begin
    filenames = (*self.image_filenames)[ss1]
  endelse
  n_files = n_elements(filenames)

  if (self.color) then begin
    faces = bytarr(n_files, 3, self.size[0], self.size[1])
  endif else begin
    faces = bytarr(n_files, self.size[0], self.size[1])
  endelse

  for f = 0L, n_files - 1L do begin
    read_jpeg, filenames[f], im, true=1
    im = im[*, self.xslice[0]:self.xslice[1], self.yslice[0]:self.yslice[1]]

    if (self.color) then begin
      im = congrid(im, 3, self.size[0], self.size[1])
      faces[f, 0, 0, 0] = reform(im, 1, 3, self.size[0], self.size[1])
    endif else begin
      im = mean(im, dimension=1)
      im = congrid(im, self.size[0], self.size[1])
      faces[f, 0, 0] = reform(im, 1, self.size[0], self.size[1])
    endelse
  endfor

  return, reform(faces)
end


;= lifecycle methods

pro mg_lfw_people::cleanup
  compile_opt strictarr

  ptr_free, self.image_filenames
end


function mg_lfw_people::init, size=size, seed=seed, color=color
  compile_opt strictarr

  self.color = keyword_set(color)

  self.xslice = [78L, 172L]
  self.yslice = [70L, 195L]

  nx = self.xslice[1] - self.xslice[0] + 1
  ny = self.yslice[1] - self.yslice[0] + 1

  if (n_elements(size) eq 0L) then begin
    self.size = [nx, ny]
  endif else if (size gt 0.0 && size lt 1.0) then begin
    self.size = long([nx, ny] * size)
  endif else begin
    self.size = long([1, 1] * size)
  endelse

  ; download LFW data if not present
  if (~file_test(filepath('lfw', root=mg_src_root()), /directory)) then begin
    base_url = 'http://vis-www.cs.umass.edu/lfw/'

    archive_name = 'lfw.tgz'

    url = IDLnetURL()
    filename = url->get(filename=filepath(archive_name, $
                                          root=mg_src_root()), $
                        url=base_url + archive_name)
    obj_destroy, url

    file_untar, filename
    file_delete, filename
  endif

  image_filenames = file_search(filepath('lfw', root=mg_src_root()), '*.jpg', $
                                count=n_image_files)

  ind = mg_sample(n_image_files, n_image_files, seed=seed)

  self.image_filenames = ptr_new(image_filenames[ind])

  return, 1
end


pro mg_lfw_people__define
  compile_opt strictarr

  !null = { mg_lfw_people, inherits IDL_Object, $
            color:  0B, $
            size:   lonarr(2), $
            xslice: lonarr(2), $
            yslice: lonarr(2), $
            image_filenames: ptr_new() $
          }
end
