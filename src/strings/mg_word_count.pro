; docformat = 'rst'

;+
; Count frequency of strings in the string array, `words`
;
; :Returns:
;   hash with `hash[word] = count`
;
; :Params:
;   words : in, required, type=strarr
;     strings to consider
;-
function mg_word_count, words
  compile_opt strictarr

  h = hash()
  for t = 0L, n_elements(words) - 1L do begin
    if (h->haskey(words[t])) then begin
      h[words[t]] += 1
    endif else begin
      h[words[t]] = 1
    endelse
  endfor

  return, h
end
