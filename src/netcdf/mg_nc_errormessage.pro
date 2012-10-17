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
    else:
  endcase

  return, m
end
