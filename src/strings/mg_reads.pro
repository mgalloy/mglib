; docformat = 'rst'

function mg_reads, str, format=format
  compile_opt strictarr

  tokens = strsplit(format, '%', /extract, count=ntokens)
  if (strpos(format, '%') eq -1L) then ntokens = 0L
  
  re = '^[[:digit:]]*.?[[:digit:]]*([a-zA-Z])'
  
  varnames = strarr(ntokens)
  
  for t = 0L, ntokens - 1L do begin
    varnames[t] = string(t, format='(%"t%d")')
    format_code = stregex(tokens[t], re, /extract, /subexpr)
    case strlowcase(format_code[1]) of
      'b':
      'd': value = '0L'
      'e':
      'f': value = '0.0'
      'g':
      'i':
      'o':
      's': value = ''''''
      'x':
      'z':
      else: begin
          message, string(format_code[1], $
                          format='(%"unsupported format code %s")')
        end
    endcase
    
    status = execute(string(varnames[t], value, format='(%"%s = %s")'))
  endfor
  
  _format = string(format, format='(%"(\%\"%s\")")')

  reads_cmd = string(strjoin(varnames, ', '), _format, $
                     format='(%"reads, str, %s, format=''%s''")')
  status = execute(reads_cmd)

  values = list()
  
  for t = 0L, ntokens - 1L do begin
    status = execute(string(varnames[t], format='(%"values->add, %s")'))
  endfor
  
  return, values
end
