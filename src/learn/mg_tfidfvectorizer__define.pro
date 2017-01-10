; docformat = 'rst'

;+
; The formula that is used to compute the tf-idf of term t is
; tf-idf(d, t) = tf(t) * idf(d, t), and the idf is computed as
; idf(d, t) = log [ n / df(d, t) ] + 1 (if smooth_idf=False), where n is the
; total number of documents and df(d, t) is the document frequency; the
; document frequency is the number of documents d that contain term t. The
; effect of adding “1” to the idf in the equation above is that terms with zero
; idf, i.e., terms that occur in all documents in a training set, will not be
; entirely ignored. (Note that the idf formula above differs from the standard
; textbook notation that defines the idf as
; idf(d, t) = log [ n / (df(d, t) + 1) ]).
;-


;= API

;+
; :Returns:
;   fltarr
;
; :Params:
;   data : in, required, type=strarr
;     array of strings to transform
;-
function mg_tfidfvectorizer::fit_transform, data
  compile_opt strictarr

  n_samples = n_elements(data)
  word_counts = objarr(n_samples)   ; word frequency by document
  all_words = hash()                ; # of documents with a word
  for d = 0L, n_samples - 1L do begin
    words = strsplit(data[d], /extract)
    word_counts[d] = mg_word_count(words)
    foreach count, word_counts[d], w do begin
      if (all_words->haskey(w)) then begin
        all_words[w] += 1
      endif else begin
        all_words[w] = 1
      endelse
    endforeach
  endfor

  n_words = all_words->count()

  all_words_list = all_words->keys()
  feature_names = all_words_list->toArray()
  *self.feature_names = feature_names

  tfidf = fltarr(n_words, n_samples)
  for t = 0L, n_elements(feature_names) - 1L do begin
    word = feature_names[t]
    idf = alog(float(n_samples + 1) / (all_words[word] + 1.0)) + 1
    for d = 0L, n_samples - 1L do begin
      tf = ((word_counts[d])->haskey(word) ? (word_counts[d])[word] : 0)
      tfidf[t, d] =  tf * idf
    endfor
  endfor

  obj_destroy, [all_words, all_words_list]
  obj_destroy, word_counts

  ; normalize rows
  for d = 0L, n_samples - 1L do begin
    tfidf[*, d] /= sqrt(total((tfidf[*, d])^2, /preserve_type))
  endfor

  return, tfidf
end


;= property access

pro mg_tfidfvectorizer::getProperty, feature_names=feature_names
  compile_opt strictarr

  if (arg_present(feature_names)) then feature_names = *self.feature_names
end


;= lifecyle methods

pro mg_tfidfvectorizer::cleanup
  compile_opt strictarr

  ptr_free, self.feature_names
end


function mg_tfidfvectorizer::init
  compile_opt strictarr

  self.feature_names = ptr_new(/allocate_heap)

  return, 1
end


pro mg_tfidfvectorizer__define
  compile_opt strictarr

  !null = {mg_tfidfvectorizer, inherits IDL_Object, $
           feature_names: ptr_new()}
end


; main-level example program

sample = ['problem of evil', $
          'evil queen', $
          'horizon problem']
tfidf = mg_tfidfvectorizer()
transformed_data = tfidf->fit_transform(sample)
column_width = 18
print, tfidf.feature_names, format='(5A' + strtrim(column_width) + ')'
print, strarr(5) + strjoin(strarr(column_width - 1) + '='), format='(5A' + strtrim(column_width) + ')'
print, transformed_data, format='(5F' + strtrim(column_width) + ')'

end
