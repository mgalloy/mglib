; docformat = 'rst'

;+
; Wrapper to READ_ASCII and ASCII_TEMPLATE.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run mg_read_ascii
;
;    It does::
;
;       IDL> col_names = ['lon', 'lat', 'elev', 'temp', 'dewpt', 'wind_speed', 'wind_dir']
;       IDL> wdata = mg_read_ascii(file_which('ascii.txt'), data_start=5, $
;       IDL>                       column_types=[4, 4, 3, 3, 3, 3, 3], $
;       IDL>                       column_names=col_names, $
;       IDL>                       groups=lindgen(7))
;       IDL> help, wdata
;       ** Structure <2851608>, 7 tags, length=420, data length=420, refs=1:
;          LON             FLOAT     Array[15]
;          LAT             FLOAT     Array[15]
;          ELEV            LONG      Array[15]
;          TEMP            LONG      Array[15]
;          DEWPT           LONG      Array[15]
;          WIND_SPEED      LONG      Array[15]
;          WIND_DIR        LONG      Array[15]
;
;       IDL> adata = mg_read_ascii(file_which('ascii.dat'), data_start=3, $
;       IDL>                       delimiter=string(9B), comment_symbol='%', $
;       IDL>                       groups=lonarr(4), missing_value=-999.)
;       IDL> print, adata.col0
;             55.3000      22.1000      19.3000      40.0000
;             19.1000     -999.000      15.1000      33.4000
;             100.300      79.0000      22.1000      3.30000
;
; :Returns:
;    structure with field names given by `COLUMN_NAMES` keyword, or, if
;    `COLUMN_NAMES` is not present, "col0", "col1", etc.
;
; :Params:
;    filename : in, required, type=string
;       filename of file to read
;
; :Keywords:
;    column_names : in, optional, type=strarr
;       names for the columns in the data; if there are groups specified,
;       the column names should be repeated for each column in the group, so
;       that the number of column names is always equal to the number of
;       columns
;    column_types : in, optional, type=lonarr
;       SIZE type codes for the columns in the data; if there are groups
;       specified, the column types should be repeated for each column in the
;       group, so that the number of column types is always equal to the
;       number of columns
;    comment_symbol : in, optional, type=string
;       specifies a comment character for the lines in the file
;    data_start : in, optional, type=long, default=0L
;       number of lines to skip at the beginning of the file
;    delimiter : in, optional, type=string
;       delimiter between columns of data
;    groups : in, optional, type=lonarr
;       indices of groups for each column, i.e.::
;
;          [0, 0, 0, 0, 0, 0, 0]
;
;       indicates all seven columns are in a single group, where::
;
;          [0, 1, 2, 3, 4, 5, 6]
;
;       would put each column in a new group
;    missing_value : in, optional, type=scalar
;       value to use for missing items in the data
;    count : out, optional, type=long
;       set to a named variable to get the number of records read
;    header : out, optional, type=strarr
;       set to a named variable to get the header information skipped by
;       `DATA_START`
;    num_records : in, optional, type=long
;       number of records to read; default is to read all available records
;    record_start : in, optional, type=long, default=0
;       set to index of first record to read (after `DATA_START` is taken into
;       account)
;    verbose : in, optional, type=boolean
;       set to print runtime messages
;-
function mg_read_ascii, filename, $
                        column_names=columnNames, $
                        column_types=columnTypes, $
                        comment_symbol=commentSymbol, $
                        data_start=dataStart, $
                        delimiter=delimiter, $
                        groups=groups, $
                        missing_value=missingValue, $
                        count=count, $
                        header=header, $
                        num_records=numRecords, $
                        record_start=recordStart, $
                        verbose=verbose
  compile_opt strictarr
  on_error, 2

  _commentSymbol = n_elements(commentSymbol) eq 0L ? '' : commentSymbol
  _dataStart = n_elements(dataStart) eq 0L ? 0L : dataStart
  _delimiter = n_elements(delimiter) eq 0L ? ' ' : delimiter

  ; columnNames, columnTypes, and groups must have the same number of elements
  ; or be undefined, but one of them must be defined
  nColumns = n_elements(columnTypes) eq 0L $
               ? (n_elements(columnNames) eq 0L $
                    ? (n_elements(groups) eq 0L $
                         ? 0L $
                         : n_elements(groups)) $
                    : n_elements(columnNames)) $
               : n_elements(columnTypes)

  if (nColumns eq 0L) then begin
    message, 'one of COLUMN_NAMES, COLUMN_TYPES, or GROUPS must be defined'
  endif

  ; pad column names with the correct number of zeros
  colNameFormat = '(I0' + strtrim(ceil(alog10(nColumns)), 2) + ')'

  _columnNames = n_elements(columnNames) eq 0L $
                   ? 'col' + string(sindgen(nColumns), format=colNameFormat) $
                   : columnNames
  _columnTypes = n_elements(columnTypes) eq 0L $
                   ? (lonarr(nColumns) + 4L) $
                   : columnTypes

  _groups = n_elements(groups) eq 0L ? lonarr(nColumns) : groups

  _missingValue = n_elements(missingValue) eq 0L $
                    ? fix(0, type=_columnTypes[0]) $
                    : missingValue

  t = { version: 1., $
        datastart:_dataStart, $
        delimiter:byte(_delimiter), $
        missingvalue:_missingValue, $
        commentsymbol:_commentSymbol, $
        fieldcount:nColumns, $
        fieldtypes:_columnTypes, $
        fieldnames:_columnNames, $
        fieldlocations:lindgen(nColumns), $
        fieldgroups:_groups }

  return, read_ascii(filename, $
                     count=count, $
                     header=header, $
                     template=t, $
                     num_records=numRecords, $
                     record_start=recordStart, $
                     verbose=verbose)
end


; main-level example program
col_names = ['lon', 'lat', 'elev', 'temp', 'dewpt', 'wind_speed', 'wind_dir']
wdata = mg_read_ascii(file_which('ascii.txt'), data_start=5, $
                      column_types=[4, 4, 3, 3, 3, 3, 3], $
                      column_names=col_names, $
                      groups=lindgen(7), count=nrows)
help, wdata

adata = mg_read_ascii(file_which('ascii.dat'), data_start=3, $
                      delimiter=string(9B), comment_symbol='%', $
                      groups=lonarr(4), missing_value=-999.)
print, adata.col0

end

