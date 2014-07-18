; docformat = 'rst'

;+
; Convert a netCDF error code to a human readable error message.
;
; :Returns:
;   string
;
; :Params:
;   code : in, required, type=integer
;-
function mg_nc_errormessage, code
  compile_opt strictarr
  on_error, 2

  case code of
      0: m = 'No error'
    -33: m = 'Not a netcdf id'
    -34: m = 'Too many netcdfs open'
    -35: m = 'netcdf file exists && NC_NOCLOBBER'
    -36: m = 'Invalid Argument'
    -37: m = 'Write to read only'
    -38: m = 'Operation not allowed in data mode'
    -39: m = 'Operation not allowed in define mode'
    -40: m = 'Index exceeds dimension bound'
    -41: m = 'NC_MAX_DIMS exceeded'
    -42: m = 'String match to name in use'
    -43: m = 'Attribute not found'
    -44: m = 'NC_MAX_ATTRS exceeded'
    -45: m = 'Not a netcdf data type'
    -46: m = 'Invalid dimension id or name'
    -47: m = 'NC_UNLIMITED in the wrong index'
    -48: m = 'NC_MAX_VARS exceeded'
    -49: m = 'Variable not found'
    -50: m = 'Action prohibited on NC_GLOBAL varid'
    -51: m = 'Not a netcdf file'
    -52: m = 'In Fortran, string too short'
    -53: m = 'NC_MAX_NAME exceeded'
    -54: m = 'NC_UNLIMITED size already in use'
    -55: m = 'nc_rec op when there are no record vars'
    -56: m = 'Attempt to convert between text & numbers'
    -57: m = 'Edge+start exceeds dimension bound'
    -58: m = 'Illegal stride'
    -59: m = 'Attribute or variable name contains illegal characters'
    -60: m = 'Math result not representable'
    -61: m = 'Memory allocation (malloc) failure'
    -62: m = 'One or more variable sizes violate format constraints'
    -63: m = 'Invalid dimension size'
    -64: m = 'File likely truncated or possibly corrupted'
    -65: m = 'Unknown axis type'
    -66: m = 'Generic DAP error'
    -67: m = 'Generic libcurl error'
    -68: m = 'Generic IO error'
    -69: m = 'Attempt to access variable with no data'
    -70: m = 'DAP server error'
    -71: m = 'Malformed or inaccessible DAS'
    -72: m = 'Malformed or inaccessible DDS'
    -73: m = 'Malformed or inaccessible DATADDS'
    -74: m = 'Malformed DAP URL'
    -75: m = 'Malformed DAP Constraint'
    -76: m = 'Untranslatable construct'
    ; netCDF 4 error codes
    -101: m = ''
    -102: m = 'Can''t read'
    -103: m = 'Can''t write'
    -104: m = 'Can''t create'
    -105: m = 'Problem with file metadata'
    -106: m = 'Problem with dimension metadata'
    -107: m = 'Problem with attribute metadata'
    -108: m = 'Problem with variable metadata'
    -109: m = 'Not a compound type'
    -110: m = 'Attribute already exists'
    -111: m = 'Attempting netcdf-4 operation on netcdf-3 file'
    -112: m = ''
    -113: m = 'Attempting netcdf-3 operation on netcdf-4 file'
    -114: m = 'Parallel operation on file opened for non-parallel access'
    -115: m = 'Error initializing for parallel access'
    -116: m = 'Bad group ID'
    -117: m = 'Bad type ID'
    -118: m = 'Type has already been defined and may not be edited'
    -119: m = 'Bad field ID'
    -120: m = 'Bad class'
    -121: m = 'Mapped access for atomic types only'
    -122: m = 'Attempt to define fill value when data already exists'
    -123: m = 'Attempt to define var properties, like deflate, after enddef'
    -124: m = 'Probem with HDF5 dimscales'
    -125: m = 'No group found'
    -126: m = 'Can''t specify both contiguous and chunking'
    -127: m = 'Bad chunksize'
    -128: m = 'Attempt to use feature that was not turned on when netCDF was built'
    -129: m = 'Error in using diskless access'
    else: m = 'Unknown error code'
  endcase

  return, m
end
