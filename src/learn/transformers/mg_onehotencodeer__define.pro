; docformat = 'rst'

;= helper methods

function mg_onehotvectorizer::_expand_column, column, values, n_values
  compile_opt strictarr

  n_rows = n_elements(column)
  type = size(column, /type)
  new_data = make_array(dimension=[n_values, n_rows], type=type)
  for v = 0L, n_values - 1L do begin
    ind = where(column eq values[v], count)
    col = make_array(dimension=n_rows, type=type)
    col[ind] = fix(1, type=type)
    new_data[v, *] = col
  endfor
  return, new_data
end


;= API

;+
; Expands an array with some columns that are categorical.
;
; :Returns:
;   fltarr
;
; :Params:
;   data : in, required, type=array of structures
;     array of structures to transform
;-
function mg_onehotvectorizer::fit_transform, data, $
                                                  feature_names=feature_names, $
                                                  new_feature_names=new_feature_names
  compile_opt strictarr

  n_cat_columns = n_elements(*self.categorical_columns)
  n_categories = lonarr(n_cat_columns)
  categories = list()
  for c = 0L, n_cat_columns - 1L do begin
    col = data[(*self.categorical_columns)[c], *]
    col_categories = col[uniq(col, sort(col))]
    n_categories[c] = n_elements(col_categories)
    categories->add, col_categories
  endfor

  dims = size(data, /dimensions)
  type = size(data, /type)
  new_n_columns = dims[0] - n_cat_columns + total(n_categories, /preserve_type)
  new_data = make_array(dimension=[new_n_columns, dims[1]], $
                        type=type)

  if (n_elements(feature_names) gt 0L) then new_feature_names = strarr(new_n_columns)

  c = 0L
  new_c = 0L
  next_cat_column = 0L
  while (c lt dims[0]) do begin
    if (next_cat_column ge n_cat_columns $
          || c lt (*self.categorical_columns)[next_cat_column]) then begin
      ; copy all columns up to next categorical column
      last_col = next_cat_column ge n_cat_columns $
                   ? (dims[0] - 1L) $
                   : (*self.categorical_columns)[next_cat_column] - 1
      new_data[new_c:last_col - c + new_c, *] = data[c:last_col, *]
      new_feature_names[new_c:last_col - c + new_c] = feature_names[c:last_col]
      new_c += last_col - c + 1
      c = last_col + 1
    endif else begin
      ; expand next categorical column
      new_data[new_c, 0] = self->_expand_column(data[c, *], $
                                                categories[next_cat_column], $
                                                n_categories[next_cat_column])
      new_names = type eq 1 ? fix(categories[next_cat_column]) : categories[next_cat_column]
      new_feature_names[new_c] = feature_names[c] + '=' + strtrim(new_names, 2)
      c += 1
      new_c += n_categories[next_cat_column]
      next_cat_column += 1
    endelse
  endwhile

  obj_destroy, categories

  return, new_data
end


;= property access

pro mg_onehotvectorizer::getProperty, feature_names=feature_names
  compile_opt strictarr

  if (arg_present(feature_names)) then feature_names = *self.feature_names
end


pro mg_onehotvectorizer::setProperty, categorical_columns=categorical_columns, $ 
                                           feature_names=feature_names
  compile_opt strictarr

  if (n_elements(categorical_columns) gt 0L) then begin
    *self.categorical_columns = categorical_columns[sort(categorical_columns)]
  endif
  if (n_elements(feature_names) gt 0L) then *self.feature_names = feature_names
end


;= lifecyle methods

pro mg_onehotvectorizer::cleanup
  compile_opt strictarr

  ptr_free, self.feature_names
end


function mg_onehotvectorizer::init, _extra=e
  compile_opt strictarr

  self.categorical_columns = ptr_new(/allocate_heap)
  self.feature_names = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_onehotvectorizer__define
  compile_opt strictarr

  !null = {mg_onehotvectorizer, inherits IDL_Object, $
           categorical_columns: ptr_new(), $
           feature_names: ptr_new()}
end


; main-level example program

data = bindgen(3, 5)
cv = mg_onehotvectorizer(categorical_columns=[0, 2])
feature_names = ['A', 'B', 'C']
new_data = cv->fit_transform(data, $
                             feature_names=feature_names, $
                             new_feature_names=new_feature_names)
data_df = mg_table(data, column_names=feature_names)
print, data_df

print

new_data_df = mg_table(new_data, column_names=new_feature_names)
print, new_data_df

obj_destroy, [data_df, new_data_df]

end
