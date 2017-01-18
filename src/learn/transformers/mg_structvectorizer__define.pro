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

function mg_structvectorizer::_fitCategories, column, column_index, column_name
  compile_opt strictarr

  h = mg_word_count(column)

  n_categories = h->count()
  categories_list = h->keys()
  categories = categories_list->toArray()
  obj_destroy, [h, categories_list]

  return, {index: column_index, n_categories: n_categories, categories: categories}
end


function mg_structvectorizer::_expandCategories, column, fit
  compile_opt strictarr

  n_samples = n_elements(column)

  result = lonarr(fit.n_categories, n_samples)
  for c = 0L, fit.n_categories - 1L do result[c, *] = column eq fit.categories[c]

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

pro mg_structvectorizer::fit, x, y, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, _extra=e

  n_samples = n_elements(x)
  self._n_columns = 0L
  feature_names = list()
  self._result_type = 0L
  field_names = tag_names(x)
  self._columns->remove, /all

  for c = 0L, n_tags(x) - 1L do begin
    type = size(x.(c), /type)

    if (type eq 7) then begin
      self._result_type = self->_typeOrder(3, self._result_type)
      column_fit = self->_fitCategories(x.(c), c, field_names[c])
      feature_names->add, field_names[c] + '=' + column_fit.categories, /extract
      self._n_columns += column_fit.n_categories
      self._columns->add, column_fit
    endif else begin
      self._result_type = self->_typeOrder(type, self._result_type)
      feature_names->add, field_names[c]
      self._n_columns += 1
      self._columns->add, {index: c, n_categories: 0}
    endelse
  endfor

  *self.feature_names = feature_names->toArray()
  obj_destroy, feature_names
end


;+
; Transforms an array of structures into a 2-dimensional array. String fields
; in the structures will get expanded into a set of columns.
;
; :Returns:
;   fltarr
;
; :Params:
;   x : in, required, type=array of structures
;     array of structures to transform
;-
function mg_structvectorizer::transform, x
  compile_opt strictarr

  n_samples = n_elements(x)

  new_x = make_array(dimension=[self._n_columns, n_samples], $
                     type=self._result_type)
  current_new_x_column = 0L
  foreach fit, self._columns, c do begin
    if (fit.n_categories eq 0L) then begin
      new_x[current_new_x_column++, *] = x.(fit.index)
    endif else begin
      new_x[current_new_x_column, 0] = self->_expandCategories(x.(fit.index), fit)
      current_new_x_column += fit.n_categories
    endelse
  endforeach

  return, new_x
end


;= overload methods

function mg_structvectorizer::_overloadHelp, varname
  compile_opt strictarr

  _type = 'SVEC'
  _specs = '<>'
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


;= property access

pro mg_structvectorizer::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_structvectorizer::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecyle methods

pro mg_structvectorizer::cleanup
  compile_opt strictarr

  obj_destroy, self._columns

  self->mg_transformer::cleanup
end


function mg_structvectorizer::init, _extra=e
  compile_opt strictarr

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self._columns = list()
  self._n_columns = 0L

  return, 1
end


pro mg_structvectorizer__define
  compile_opt strictarr

  !null = {mg_structvectorizer, inherits mg_transformer, $
           _columns: obj_new(), $
           _n_columns: 0L, $
           _result_type: 0L}
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
