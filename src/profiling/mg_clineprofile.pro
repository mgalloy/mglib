; docformat = 'rst'

;+
; Creates color coded HTML output of line profiling output.
;
; :Examples:
;   For example, to profile the results output by `grof` in the file 
;   `profile_results/profile.aasquare_PlateRad000.txt`, where the source code
;   files are in the current directory, use::
;
;      mg_clineprofile, 'profile_results/profile.aasquare_PlateRad000.txt', $
;                       output_dir='profile_output', $
;                       /all_files
;
; :Params:
;    profile_file : in, required, type=string
;       filename for profile output from `gprof`
;
; :Keywords:
;    output_directory : in, optional, type=string, default=current directory
;       directory to place output into, defaults to the current directory
;    files : in, optional, type=strarr
;       array of filenames listed in the profile output to create output for
;    all_files : in, optional, type=boolean
;       set to create output for all files listed in the profile output
;-
pro mg_clineprofile, profile_file, output_directory=output_dir, $
                     files=output_files, all_files=all_files
  compile_opt strictarr
  
  if (n_elements(output_dir) gt 0L && ~file_test(output_dir, /directory)) then begin
    file_mkdir, output_dir
  endif
  
  ; read/parse profile file
  nlines = file_lines(profile_file)
  profile_output = strarr(nlines)
  openr, lun, profile_file, /get_lun
  readf, lun, profile_output
  free_lun, lun
  
  ndigits = floor(alog10(nlines) + 1L)
  line_format = '(%"        <p class=\"self color-%d\">%0' + strtrim(ndigits, 2) + 'd<span>%s</span></p>")'
  
  for blank_line_number = 5L, nlines - 1L do begin
    if (profile_output[blank_line_number] eq '') then break
  endfor

  line_profile = profile_output[5L:blank_line_number - 1L]
  self_times = float(strmid(line_profile, 16, 9))
  
  line_info = strmid(line_profile, 54)
  tokens = strsplit(line_info, /extract)

  nlines = blank_line_number - 5L
  routines = strarr(nlines)
  files = strarr(nlines)
  line_numbers = lonarr(nlines)
  
  foreach line, tokens, i do begin
    routines[i] = line[0]
    
    if (n_elements(line) lt 4L) then continue    

    parts = strsplit(strmid(line[1], 1), ':', /extract)
    files[i] = parts[0]
    line_numbers[i] = parts[1]
  endforeach
  
  ; normalize by the largest time
  self_percentages = self_times / self_times[0]
  
  ; foreach file: create HTML output
  
  if (keyword_set(all_files)) then begin
    output_files = files[mg_setintersection(uniq(files, sort(files)), where(files ne ''))]
  endif
    
  for f = 0L, n_elements(output_files) - 1L do begin
    file_code = strarr(file_lines(output_files[f]))
    
    matching_files_ind = where(files eq output_files[f], n_matching_files)
    
    openr, lun, output_files[f], /get_lun
    readf, lun, file_code
    free_lun, lun

    if (n_elements(output_dir) gt 0L) then begin
      _output_file = filepath(file_basename(output_files[f]), root=output_dir)
    endif else _output_file = output_files[f]
        
    openw, lun, _output_file + '.html', /get_lun
    printf, lun, '<html>'
    printf, lun, '  <head>'
    printf, lun, output_files[f], format='(%"    <title>%s</title>")'
    printf, lun, '    <style>'
    printf, lun, '      body { padding: 0; margin: 0; }'
    printf, lun, '      div.main { padding: 0; margin: 0; width: 500px; }'
    printf, lun, '      div.left { display: inline; float: left; width: 90px; }'
    printf, lun, '      div.right { display: inline; float: right; width: 400px; }'
    printf, lun, '      p.self { padding: 0; margin: 0; font: 0.4em Helvetica; height: 22px; color: #666; }'
    printf, lun, '      p.self span { display: inline; float: right; color: #000; }'
    printf, lun, '      pre { font: 10pt Monaco; padding: 0; margin: 0; height: 22px; }'
    
    for c = 0L, 255L do begin
      printf, lun, c, $
              string(reform(rebin(reform(byte(string(255L - c, format='(z02)')), 2, 1), 2, 2), 4)), $
              format='(%"      .color-%d { background-color: #ff%s; }")'
    endfor
    
    printf, lun, '    </style>'    
    printf, lun, '  </head>'    
    printf, lun, '  <body>'

    printf, lun, '    <div class="main">'
    printf, lun, '      <div class="left">'
    foreach line, file_code, line_no do begin
      if (n_matching_files gt 0L) then begin
        ind = where(line_numbers[matching_files_ind] eq (line_no + 1L), n)
        if (n gt 0L) then begin
          color = self_percentages[matching_files_ind[ind[0]]] * 255L
        endif else begin
          color = 0L
        endelse
      endif else begin
        color = 0L
      endelse

      printf, lun, color, line_no + 1L, n eq 0L ? '' : (' ' + strtrim(self_times[matching_files_ind[ind[0]]], 2) + ' sec'), $
              format=line_format
    endforeach
    printf, lun, '      </div>'
    
    printf, lun, '      <div class="right">'    
    foreach line, file_code, line_no do begin
      if (n_matching_files gt 0L) then begin
        ind = where(line_numbers[matching_files_ind] eq (line_no + 1L), n)
        if (n gt 0L) then begin
          color = self_percentages[matching_files_ind[ind[0]]] * 255L
        endif else begin
          color = 0L
        endelse
      endif else begin
        color = 0L
      endelse
      
      printf, lun, mg_streplace(line, '<', '&lt;'), $
              format='(%"        <pre>%s </pre>")'
    endforeach
    printf, lun, '      </div>'
    printf, lun, '    </div>'
    
    printf, lun, '  </body>'    
    printf, lun, '</html>'
    free_lun, lun
  endfor
  
  ; create index
  if (n_elements(output_dir) gt 0L) then begin
    index_filename = filepath('index.html', root=output_dir)
  endif else begin
    index_filename = 'index.html'
  endelse

  openw, lun, index_filename, /get_lun
  printf, lun, '<html>'
  printf, lun, '  <head>'
  printf, lun, '    <title>Index of profile results</title>'
  printf, lun, '  </head>'
  printf, lun, '  <body>'
  
  printf, lun, '    <ol>'
  for f = 0L, n_elements(output_files) - 1L do begin
    matching_files_ind = where(files eq output_files[f], n_matching_files)

    if (n_matching_files eq 0L) then begin
      printf, lun, $
              file_basename(output_files[f]) + '.html', $
              file_basename(output_files[f]), $
              format='(%"<li><a href=\"%s\">%s</a></li>")'
    endif else begin
      printf, lun, $
              file_basename(output_files[f]) + '.html', $
              file_basename(output_files[f]), $
              n_matching_files, $
              n_matching_files gt 1 ? 's' : '', $
              format='(%"<li><a href=\"%s\">%s</a> (%d high activity line%s)</li>")'
    endelse
  endfor
  printf, lun, '    </ol>'
  
  printf, lun, '    <pre>'
  printf, lun, transpose(mg_file(profile_file, /readf))
  printf, lun, '    </pre>'

  printf, lun, '  </body>'
  printf, lun, '</html>'
  free_lun, lun
end


; main-level example program

mg_clineprofile, 'profile_results/profile.aasquare_PlateRad000.txt', $
                 output_dir='profile_output', $
                 /all_files

end
