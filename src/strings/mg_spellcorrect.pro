; docformat = 'rst'

;+
; Returns the correct spelling of the given word. Based on Peter Norvig's
; Python `spelling corrector <http://norvig.com/spell-correct.html>`.
;
; :Examples:
;    Try the main-level program at the end of the file::
;
;       IDL> .run mg_spellcorrect
;       "corect" should be spelled "correct"
;       "information" was spelled correctly
;       "informtion" should be spelled "information"
;       "known" was spelled correctly
;
; :Requires:
;    IDL 8.0
;
; :Author:
;    Michael Galloy
;-

;+
; Generates the known words hash.
;
; :Returns:
;    hash: string->long
;-
function mg_spellcorrect_generate_hash
  compile_opt strictarr, hidden

  filename = filepath('big.txt', root=mg_src_root())
  nlines = file_lines(filename)
  text = strarr(nlines)
  openr, lun, filename, /get_lun
  readf, lun, text
  free_lun, lun

  text = strlowcase(text)
  text = mg_strmerge(text)   ; make a scalar string

  ignore_ind = where(bindgen(256) lt 65 $
                       or (bindgen(256) gt 90 and bindgen(256) lt 97) $
                       or bindgen(256) gt 122)
  ignore = string(byte(ignore_ind[1:*]))
  words = strsplit(text, ignore, /extract)
  nwords = n_elements(words)

  model = hash()
  start = 0L

  for w = 0L, nwords - 1L do begin
    word = strlowcase(words[w])

    if ((w mod 10000) eq 0) then begin
      print, 100. * w / nwords, w, nwords, $
             format='(%"%0.1f\% completed: %d out of %d done")'
    endif

    if (model->hasKey(word)) then begin
      model[word] = model[word] + 1L
    endif else begin
      model[word] = 1L
    endelse
  endfor

  return, model
end


;+
; Create hash of all edits of a word that are only 1 character off from the
; original.
;
; :Returns:
;    hash: string->byte
;
; :Params:
;    word : in, optional, type=string
;       word to find edits of
;-
function mg_spellcorrect_edits1, word
  compile_opt strictarr, hidden

  splits = list()

  for i = 0L, strlen(word) do begin
    splits->add, { first: strmid(word, 0, i), second: strmid(word, i) }
  endfor

  edits1 = hash()
  alphabet = list()
  foreach char, bindgen(26) + (byte('a'))[0] do alphabet->add, string(char)

  ; deletes
  foreach s, splits do begin
    edits1[s.first + strmid(s.second, 1)] = 1B
  endforeach

  ; transposes
  foreach s, splits do begin
    if (strlen(s.second) gt 1) then begin
      edits1[s.first + strmid(s.second, 0, 1) + strmid(s.second, 1, 1) + strmid(s.second, 2)] = 1B
    endif
  endforeach

  ; replaces
  foreach s, splits do begin
    foreach char, alphabet do begin
      edits1[s.first + string(char) + strmid(s.second, 1)] = 1B
    endforeach
  endforeach

  ; inserts
  foreach s, splits do begin
    foreach char, alphabet do begin
      edits1[s.first + string(char) + s.second] = 1B
    endforeach
  endforeach

  return, edits1
end


;+
; Create hash of all correct edits of a word that are only 2 edits off from
; the original.
;
; :Returns:
;    hash: string->byte
;
; :Params:
;    word : in, optional, type=string
;       word to find edits of
;
; :Keywords:
;    known_hash : in, out, optional, type=hash: string->long
;       hash of known word frequencies
;-
function mg_spellcorrect_known_edits2, word, known_hash=hash
  compile_opt strictarr, hidden

  edits2 = hash()

  foreach v1, mg_spellcorrect_edits1(word), e1 do begin
    foreach v2, mg_spellcorrect_edits1(e1), e2 do begin
      if (hash->hasKey(e2)) then edits2[e2] = 1B
    endforeach
  endforeach

  return, edits2
end


;+
; Creates a hash of the known words in a given hash of words.
;
; :Returns:
;    hash: string->byte
;
; :Params:
;    words : in, required, type=hash: string->byte
;
; :Keywords:
;    known_hash : in, out, optional, type=hash: string->long
;       hash of known word frequencies
;-
function mg_spellcorrect_known, words, known_hash=hash
  compile_opt strictarr, hidden

  known = hash()

  foreach val, words, w do if (hash->hasKey(w)) then known[w] = 1B

  return, known
end


;+
; Corrects the spelling of a word.
;
; :Returns:
;   string
;
; :Params:
;   word : in, required, type=string
;     string to check spelling of
;
; :Keywords:
;   known_words : in, out, optional, type=hash object
;     can be passed in to avoid reading/construction the known words
;     frequency table; will be passed out if given a named variable
;   correct : out, optional, type=boolean
;     set to a named variable to indicate if the word passed in was
;     correctly spelled
;   found : out, optional, type=boolean
;     set to a named variable to return whether a match was found for the
;     incorrect word
;-
function mg_spellcorrect, word, $
                          known_words=spell_hash, $
                          correct=correct, $
                          found=found
  compile_opt strictarr

  found = 0B

  if (n_elements(spell_hash) eq 0L) then begin
    spell_hash_filename = filepath('spell_hash.sav', root=mg_src_root())
    if (file_test(spell_hash_filename)) then begin
      restore, filename=spell_hash_filename
    endif else begin
      spell_hash = mg_spellcorrect_generate_hash()
      save, spell_hash, filename=spell_hash_filename
    endelse
  endif

  candidates = mg_spellcorrect_known(hash(word, 1B), known_hash=spell_hash)

  if (n_elements(candidates) eq 0L) then begin
    correct = 0B
    candidates += mg_spellcorrect_known(mg_spellcorrect_edits1(word), known_hash=spell_hash)
  endif else begin
    correct = 1B
    found = 1B
    return, word
  endelse

  if (n_elements(candidates) eq 0L) then begin
    candidates += mg_spellcorrect_known_edits2(word, known_hash=spell_hash)
  endif

  best_candidate = ''
  highest_count = 0L

  foreach v, candidates, c do begin
    if (spell_hash[c] gt highest_count) then begin
      best_candidate = c
      highest_count = spell_hash[c]
      found = 1B
    endif
  endforeach

  return, best_candidate
end


; main-level example program

; words to check spelling of
words = ['corect', 'information', 'informtion', 'known']

foreach w, words do begin
  corrected = mg_spellcorrect(w, correct=correct)
  if (correct) then begin
    print, w, format='(%"\"%s\" was spelled correctly")'
  endif else begin
    print, w, corrected, format='(%"\"%s\" should be spelled \"%s\"")'
  endelse
endforeach

; slightly different use case: determining which choice a user made from a list
; of potential choices
choices = ['time series', 'contour', 'profile', 'image', 'heatmap']
spell_hash = hash()
foreach c, choices do spell_hash[c] = 1L

words = ['time series', 'tme series', 'contours', 'another']
foreach w, words do begin
  corrected = mg_spellcorrect(w, known_words=spell_hash, $
                              correct=correct, found=found)
  if (correct) then begin
    print, w, format='(%"you chose ''%s''")'
  endif else begin
    if (found) then begin
      print, w, corrected, format='(%"''%s'': did you mean ''%s''?")'
    endif else begin
      print, w, format='(%"no choice found matching ''%s''")'
    endelse
  endelse
endforeach

obj_destroy, spell_hash

end
