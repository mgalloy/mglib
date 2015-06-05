function mg_serialize_ut::test_array
  compile_opt strictarr

  x = randomu(100L, 10)
  s = mg_serialize(x)
  result_x = mg_deserialize(s)

  assert, size(s, /type) eq 7, 'serialization is not a string'

  assert, array_equal(x, result_x, /no_typeconv), 'incorrect value'

  x_dims = size(x, /dimensions)
  result_x_dims = size(result_x, /dimensions)
  assert, array_equal(x_dims, result_x_dims, /no_typeconv), 'incorrect dims'

  return, 1
end


function mg_serialize_ut::test_structure
  compile_opt strictarr

  x = { field1: 'Mike', field2: randomu(100L, 10) }
  s = mg_serialize(x)
  result_x = mg_deserialize(s)

  assert, size(s, /type) eq 7, 'serialization is not a string'

  assert, x.field1 eq result_x.field1, 'incorrect field1'

  assert, array_equal(x.field2, result_x.field2, /no_typeconv), 'incorrect value'

  field1_dims = size(x.field2, /dimensions)
  result_field1_dims = size(result_x.field2, /dimensions)
  assert, array_equal(field1_dims, result_field1_dims, /no_typeconv), 'incorrect dims'

  return, 1
end


function mg_serialize_ut::test_object
  compile_opt strictarr

  el1 = 1.0
  el2 = 100L
  el3 = 'A string'

  x = list()
  x->add, el1
  x->add, el2
  x->add, el3

  s = mg_serialize(x)
  result_x = mg_deserialize(s)

  assert, size(s, /type) eq 7, 'serialization is not a string'

  assert, obj_isa(result_x, 'list'), 'result not a list'

  assert, n_elements(result_x) eq 3, 'wrong number of elements'
  assert, result_x[0] eq el1, 'incorrect value for result[0]'
  assert, result_x[1] eq el2, 'incorrect value for result[1]'
  assert, result_x[2] eq el3, 'incorrect value for result[2]'

  obj_destroy, x
  obj_destroy, result_x

  return, 1
end


pro mg_serialize_ut__define
  compile_opt strictarr

  define = { mg_serialize_ut, inherits MGutLibTestCase }
end
