; docformat = 'rst'

;= helper methods

function mg_onehotencoder::_expand_column, column, values, n_values
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

pro mg_onehotencoder::fit, x, _extra=e
  compile_opt strictarr

  self->mg_transformer::fit, _extra=e

  n_cat_columns = n_elements(*self.categorical_columns)

  *self.n_categories = lonarr(n_cat_columns)
  self.categories->remove, /all

  for c = 0L, n_cat_columns - 1L do begin
    col = x[(*self.categorical_columns)[c], *]
    col_categories = col[uniq(col, sort(col))]

    (*self.n_categories)[c] = n_elements(col_categories)
    self.categories->add, col_categories
  endfor

  dims = size(x, /dimensions)
  type = size(x, /type)
  new_n_columns = dims[0] - n_cat_columns + total(*self.n_categories, /preserve_type)

  new_feature_names = strarr(new_n_columns)

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
      new_feature_names[new_c:last_col - c + new_c] = (*self.feature_names)[c:last_col]
      new_c += last_col - c + 1
      c = last_col + 1
    endif else begin
      ; expand next categorical column
      new_names = type eq 1 ? fix((self.categories)[next_cat_column]) : (self.categories)[next_cat_column]
      new_feature_names[new_c] = (*self.feature_names)[c] + '=' + strtrim(new_names, 2)
      c += 1
      new_c += (*self.n_categories)[next_cat_column]
      next_cat_column += 1
    endelse
  endwhile

  *self.feature_names = new_feature_names
end


;+
; Expands an array with some columns that are categorical.
;
; :Returns:
;   fltarr
;
; :Params:
;   x : in, required, type=array of structures
;     array of structures to transform
;-
function mg_onehotencoder::transform, x
  compile_opt strictarr

  n_cat_columns = n_elements(*self.categorical_columns)

  dims = size(x, /dimensions)
  type = size(x, /type)
  new_n_columns = dims[0] - n_cat_columns + total(*self.n_categories, /preserve_type)
  new_x = make_array(dimension=[new_n_columns, dims[1]], type=type)

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
      new_x[new_c:last_col - c + new_c, *] = x[c:last_col, *]
      new_c += last_col - c + 1
      c = last_col + 1
    endif else begin
      ; expand next categorical column
      new_x[new_c, 0] = self->_expand_column(x[c, *], $
                                             (self.categories)[next_cat_column], $
                                             (*self.n_categories)[next_cat_column])
      c += 1
      new_c += (*self.n_categories)[next_cat_column]
      next_cat_column += 1
    endelse
  endwhile

  return, new_x
end


;= property access

pro mg_onehotencoder::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mg_transformer::getProperty, _extra=e
end


pro mg_onehotencoder::setProperty, categorical_columns=categorical_columns, $
                                   _extra=e
  compile_opt strictarr

  if (n_elements(categorical_columns) gt 0L) then begin
    *self.categorical_columns = categorical_columns[sort(categorical_columns)]
  endif
  if (n_elements(e) gt 0L) then self->mg_transformer::setProperty, _extra=e
end


;= lifecyle methods

pro mg_onehotencoder::cleanup
  compile_opt strictarr

  ptr_free, self.n_categories
  obj_destroy, self.categories

  self->mg_transformer::cleanup
end


function mg_onehotencoder::init, _extra=e
  compile_opt strictarr

  self.categorical_columns = ptr_new(/allocate_heap)

  if (~self->mg_transformer::init(_extra=e)) then return, 0

  self.categories = list()
  self.n_categories = ptr_new(/allocate_heap)

  self->setProperty, _extra=e

  return, 1
end


pro mg_onehotencoder__define
  compile_opt strictarr

  !null = {mg_onehotencoder, inherits mg_transformer, $
           categorical_columns: ptr_new(), $
           categories: obj_new(), $
           n_categories: ptr_new()}
end


; main-level example program

data = bindgen(3, 5)
cv = mg_onehotencoder(categorical_columns=[0, 2])

feature_names = ['A', 'B', 'C']
new_data = cv->fit_transform(data, feature_names=feature_names)
data_df = mg_table(data, column_names=feature_names)
print, data_df

print

new_data_df = mg_table(new_data, column_names=cv.feature_names)
print, new_data_df

obj_destroy, [data_df, new_data_df]

end
