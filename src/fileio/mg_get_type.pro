; docformat = 'rst'

function mg_get_type, name, boolean=boolean
  compile_opt strictarr
  on_error, 2
  on_ioerror, bad_format

  boolean = 0B
  switch strlowcase(name) of
    'bool':
    'boolean': boolean = 1B
    '1': begin
        type = 1
        break
      end

    '2':
    'int': begin
        type = 2
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
    '5':
    'double': begin
        type = 5
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
