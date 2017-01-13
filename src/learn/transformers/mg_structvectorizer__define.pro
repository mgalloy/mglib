; docformat = 'rst'

;+
; The `mg_structvectorizer` turns an array of structures into a 2-dimensional
; numerical array, suitable for the `fit`/predict methods of one of the
; `mg_estimator` subclasses.
;
; Numerical data is promoted to a suitable class to contain the data of all the
; fields: byte > int > long > long64 > float > double.
;
; String data is assumed to be string category names. String fields are
; expanded to a set of binary columns (one for each unique string) where each
; column represents the presence of one of the strings in the original field.
;-


;= helper methods

function mg_structvectorizer::_expandCategories, column, column_name, $
                                                 feature_names=feature_names
  compile_opt strictarr

  n_samples = n_elements(column)

  h = mg_word_count(column)

  n_keys = h->count()
  keys_list = h->keys()
  keys = keys_list->toArray()
  obj_destroy, [h, keys_list]

  result = lonarr(n_keys, n_samples)
  feature_names = column_name + '=' + keys
  for k = 0L, n_keys - 1L do begin
    result[k, *] = column eq keys[k]
  endfor
  return, result
end


function mg_structvectorizer::_typeOrder, type1, type2
  compile_opt strictarr

  type_order = [1, 2, 3, 14, 4, 5]
  ind1 = where(type_order eq type1, count1)
  ind2 = where(type_order eq type2, count2)
  return, type_order[ind1[0] > ind2[0]]
end


;= API

;+
; Transforms an array of structures into a 2-dimensional array. String fields
; in the structures will get expanded into a set of columns.
;
; :Returns:
;   fltarr
;
; :Params:
;   data : in, required, type=array of structures
;     array of structures to transform
;-
function mg_structvectorizer::fit_transform, data
  compile_opt strictarr

  ; TODO: split this into fit and transform

  n_samples = n_elements(data)
  n_columns = 0L
  columns = list()
  feature_names = list()
  result_type = 0L
  field_names = tag_names(data)
  for c = 0L, n_tags(data) - 1L do begin
    type = size(data.(c), /type)

    if (type eq 7) then begin
      result_type = self->_typeOrder(3, result_type)
      expanded_column = self->_expandCategories(data.(c), field_names[c], feature_names=column_feature_names)
      feature_names->add, column_feature_names, /extract
      n_columns += (size(expanded_column, /dimensions))[0]
      columns->add, expanded_column
    endif else begin
      result_type = self->_typeOrder(type, result_type)
      feature_names->add, field_names[c]
      n_columns += 1
      columns->add, data.(c)
    endelse
  endfor

  result = make_array(dimension=[n_columns, n_samples], type=result_type)
  current_column = 0L
  foreach col, columns do begin
    if (size(col, /n_dimensions) eq 2) then begin
      result[current_column, 0] = col
      current_column += (size(col, /dimensions))[0]
    endif else begin
      result[current_column, *] = col
      current_column += 1
    endelse
  endforeach

  *self.feature_names = feature_names->toArray()

  obj_destroy, [columns, feature_names]
  return, result
end


;= property access

pro mg_structvectorizer::getProperty, feature_names=feature_names
  compile_opt strictarr

  if (arg_present(feature_names)) then feature_names = *self.feature_names
end


;= lifecyle methods

pro mg_structvectorizer::cleanup
  compile_opt strictarr

  ptr_free, self.feature_names
end


function mg_structvectorizer::init
  compile_opt strictarr

  self.feature_names = ptr_new(/allocate_heap)

  return, 1
end


pro mg_structvectorizer__define
  compile_opt strictarr

  !null = {mg_structvectorizer, inherits mg_transformer, $
           feature_names: ptr_new()}
end


; main-level example program

data = [{price: 850000, rooms: 4, neighborhood: 'Queen Anne'}, $
        {price: 700000, rooms: 3, neighborhood: 'Fremont'}, $
        {price: 650000, rooms: 3, neighborhood: 'Wallingford'}, $
        {price: 600000, rooms: 2, neighborhood: 'Fremont'}]

svec = mg_structvectorizer()

transformed_data = svec->fit_transform(data)
help, transformed_data
print, transformed_data
print, svec.feature_names

end
