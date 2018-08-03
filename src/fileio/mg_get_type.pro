; docformat = 'rst'

function mg_get_type, name
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_format

  switch strlowcase(name) of
    '1':
    'bool':
    'boolean': begin
        type = 1
        break
      end
    '3':
    'long': begin
        type = 3
        break
      end
    '4':
    'float': begin
        type = 4
        break
      end
    '7':
    'str':
    'string': begin
        type = 7
        break
      end
    else: begin
        type = long(name)
      end
  endswitch

  return, type

  bad_format:
  message, 'bad type code'
end
