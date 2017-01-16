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


pro mg_tfidftransformer::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, _extra=e

  n_samples = n_elements(x)
  self._all_words_hash->remove, /all

  for d = 0L, n_samples - 1L do begin
    words = strsplit(x[d], /extract)
    word_counts = mg_word_count(words)
    foreach count, word_counts, w do begin
      if (self._all_words_hash->haskey(w)) then begin
        self._all_words_hash[w] += 1
      endif else begin
        self._all_words_hash[w] = 1
      endelse
    endforeach
    obj_destroy, word_counts
  endfor

  all_words_list = self._all_words_hash->keys()
  *self._all_words = all_words_list->toArray()

  obj_destroy, all_words_list
end


;+
; :Returns:
;   fltarr
;
; :Params:
;   x : in, required, type=strarr
;     array of strings to transform
;-
function mg_tfidftransformer::transform, x
  compile_opt strictarr

  n_samples = n_elements(x)
  word_counts = objarr(n_samples)         ; word frequency by document

  for d = 0L, n_samples - 1L do begin
    words = strsplit(x[d], /extract)
    word_counts[d] = mg_word_count(words)
  endfor

  n_words = n_elements(*self._all_words)

  *self.feature_names = *self._all_words

  tfidf = fltarr(n_words, n_samples)
  for t = 0L, n_words - 1L do begin
    word = (*self._all_words)[t]
    count = self._all_words_hash->hasKey(word) ? self._all_words_hash[word] : 0L
    idf = alog(float(n_samples + 1) / (count + 1.0)) + 1
    for d = 0L, n_samples - 1L do begin
      tf = ((word_counts[d])->haskey(word) ? (word_counts[d])[word] : 0)
      tfidf[t, d] =  tf * idf
    endfor
  endfor

  ; normalize rows
  for d = 0L, n_samples - 1L do begin
    tfidf[*, d] /= sqrt(total((tfidf[*, d])^2, /preserve_type))
  endfor

  obj_destroy, word_counts

  return, tfidf
end


;= overload methods

function mg_tfidftransformer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'TFIDF'
  _specs = '<>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_tfidftransformer::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_tfidftransformer::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecyle methods

pro mg_tfidftransformer::cleanup
  compile_opt strictarr

  ptr_free, self._all_words
  obj_destroy, self._all_words_hash

  self->mg_transformer::cleanup
end


function mg_tfidftransformer::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self._all_words = ptr_new(/allocate_heap)
  self._all_words_hash = hash()

  return, 1
end


pro mg_tfidftransformer__define
  compile_opt strictarr

  !null = {mg_tfidftransformer, inherits mg_transformer, $
           _all_words: ptr_new(), $
           _all_words_hash: obj_new()}
end


; main-level example program

sample = ['problem of evil', $
          'evil queen', $
          'horizon problem']
tfidf = mg_tfidftransformer()
transformed_data = tfidf->fit_transform(sample)
t = mg_table(transformed_data, column_names=tfidf.feature_names)
print, t

obj_destroy, [t, tfidf]

end
