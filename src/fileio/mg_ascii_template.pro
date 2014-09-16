; docformat = 'rst'


;IDL> help, template, /structures
;** Structure <8109608>, 10 tags, length=288, data length=285, refs=1:
;   VERSION         FLOAT           1.00000
;   DATASTART       LONG                 1
;   DELIMITER       BYTE        44
;   MISSINGVALUE    FLOAT               NaN
;   COMMENTSYMBOL   STRING    ''
;   FIELDCOUNT      LONG                 9
;   FIELDTYPES      LONG      Array[9]
;   FIELDNAMES      STRING    Array[9]
;   FIELDLOCATIONS  LONG      Array[9]
;   FIELDGROUPS     LONG      Array[9]
;IDL> print, template.fieldtypes
;           7           4           4           4           4           4           4           4
;           4
;IDL> print, template.fieldgroups
;           0           1           1           1           1           1           1           1
;           1
;IDL> print, template.fieldnames
;FIELD1 FIELD2 FIELD3 FIELD4 FIELD5 FIELD6 FIELD7 FIELD8 FIELD9
;IDL> print, template.fieldlocations
;           0           6           9          21          33          45          53          54
;          55
;IDL> d = read_ascii(f, template=template)
;% Compiled module: READ_ASCII.
;IDL> help, d, /structure
;** Structure <7ae02c8>, 2 tags, length=384, data length=384, refs=1:
;   FIELD1          STRING    Array[8]
;   FIELD2          FLOAT     Array[8, 8]
;IDL> print, d.field2
;      12.0000      15.7689      14.1446      5.81902      5.63385          NaN          NaN
;          NaN
;          NaN      18.3888      15.1016      9.60315      5.77482      7.03187          NaN
;          NaN
;          NaN          NaN      23.5579      23.6343      12.4605      8.68182      9.10576
;          NaN
;          NaN          NaN          NaN      29.5969      27.6552      20.6319      14.3522
;      13.6318
;          NaN          NaN          NaN          NaN      36.3850      30.4547      21.8565
;      16.5361
;          NaN          NaN          NaN          NaN          NaN      37.1546      36.1780
;      28.8108
;          NaN          NaN          NaN          NaN          NaN          NaN      39.4682
;      34.6980
;          NaN          NaN          NaN          NaN          NaN          NaN          NaN
;      31.2281


;+
; Programmatically creates a structure of the type returned by
; `ASCII_TEMPLATE`.
;
; :Examples:
;   For example, read an ASCII file from the IDL distribution::
;
;     filename = file_which('ascii.txt')
;
;   The first few rows of the file looks like::
;
;     This file contains ASCII format weather data in a comma delimited table
;     with comments prefaced by the "%" character. The columns represent:
;     Longitude, latitude, elevation (in feet), temperature (in degrees F),
;     dew point (in degrees  F), wind speed (knots), wind direction (degrees)
;
;     -156.9500, 20.7833, 399, 68, 64, 10, 60
;     -116.9667, 33.9333, 692, 77, 50, 8, 270
;     -104.2545, 32.3340, 1003, 87, 50, 10, 340
;
;   Define the row using a structure to specify the names, types, and sizes of
;   the fields::
;
;     row = { fdata: fltarr(2), ldata: lonarr(5) }
;
;   Use the row definition and where the data starts to define the template::
;
;     t = mg_ascii_template(data_start=5, example_row=row)
;
;   Finally, read the data with the template::
;
;     d = read_ascii(filename, template=t)
;
; :Returns:
;   structure
;
; :Keywords:
;   data_start : in, optional, type=integer, default=0
;     offset of where dat begins
;   delimiter : in, optional, type=byte, default=44B
;     delimiter between values
;   missing_value : in, optional, type=float, default=!values.f_nan
;     value to replace missing data with
;   comment_symbol : in, optional, type=string
;     prefix to comment lines
;   example_row : in, optional, type=structure
;     structure defining the data values in a row
;-
function mg_ascii_template, data_start=data_start, $
                            delimiter=delimiter, $
                            missing_value=missing_value, $
                            comment_symbol=comment_symbol, $
                            example_row=example_row
  compile_opt strictarr

  _data_start = n_elements(data_start) eq 0L ? 0L : long(data_start)
  _delimiter = n_elements(delimiter) eq 0L ? 44B : byte(delimiter)
  _missing_value = n_elements(missing_value) eq 0L ? !values.f_nan : missing_value
  _comment_symbol = n_elements(comment_symbol) eq 0L ? '' : comment_symbol

  _example_row = example_row

  fieldcount = n_tags(_example_row)
  n_cols = 0L
  for t = 0L, fieldcount - 1L do begin
    n_cols += n_elements(_example_row.(t))
  endfor

  field_types = lonarr(n_cols)
  field_names = strarr(n_cols)
  _field_names = tag_names(_example_row)
  field_locations = lonarr(n_cols)
  field_groups = lonarr(n_cols)

  i = 0L
  for t = 0L, n_tags(_example_row) - 1L do begin
    fieldwidth = n_elements(_example_row.(t))
    field_types[i:i + fieldwidth - 1] = size(_example_row.(t), /type)
    field_names[i:i + fieldwidth - 1] = _field_names[t]
    field_groups[i:i + fieldwidth - 1] = i

    i += fieldwidth
  endfor

  return, { version: 1.0, $
            datastart: _data_start, $
            delimiter: _delimiter, $
            missingvalue: _missing_value, $
            commentsymbol: _comment_symbol, $
            fieldcount: [n_cols], $
            fieldtypes: field_types, $
            fieldnames: field_names, $
            fieldlocations: field_locations, $
            fieldgroups: field_groups $
          }
end


; main-level example program

filename = file_which('ascii.txt')
row = { fdata: fltarr(2), ldata: lonarr(5) }
t = mg_ascii_template(data_start=5, example_row=row)
d = read_ascii(filename, template=t)

end
