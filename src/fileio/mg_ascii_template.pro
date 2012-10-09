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
;IDL> print, d.field1
;2-9 y 10-19 y 20-29 y 30-39 y 40-49 y 50-59 y 60-69 y 70-79 y
;IDL> print, transpose(d.field1)
;2-9 y
;10-19 y
;20-29 y
;30-39 y
;40-49 y
;50-59 y
;60-69 y
;70-79 y

function mg_ascii_template, data_start=dataStart, $
                            delimiter=delimiter, $
                            missing_value=missingValue
  compile_opt strictarr

  _dataStart = n_elements(dataStart) eq 0L ? 0L : long(dataStart)
  _delimiter = n_elements(delimiter) eq 0L ? 44B : byte(delimiter)
  _missingValue = n_elements(missingValue) eq 0L ? !values.f_nan : missingValue

  ; TODO: finish adding the other fields

  return, { version: 1.0, $
            datastart: _dataStart, $
            delimiter: _delimiter $
          }
end
