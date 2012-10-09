;+
; Add elements using POSITION keyword.
;-
function mgcoarraylist_ut::test_add_position
  compile_opt strictarr

  list = obj_new('MGcoArrayList', type=1)
  list->add, 5
  list->add, 7, position=0
  list->add, 9, position=1

  assert, list->count() eq 3, 'incorrect size'
  assert, array_equal(list->get(/all, count=count), [7B, 9B, 5B], /no_typeconv), $
          'incorrect data'
  assert, count eq 3, 'incorrect size from ::get'

  obj_destroy, list

  return, 1
end


;+
; Add elements in order.
;-
function mgcoarraylist_ut::test_add_consecutive
  compile_opt strictarr

  list = obj_new('MGcoArrayList', type=1)
  list->add, 5
  list->add, 7

  assert, list->count() eq 2, 'incorrect size'
  assert, array_equal(list->get(/all, count=count), [5B, 7B], /no_typeconv), $
          'incorrect data'
  assert, count eq 2, 'incorrect size %d from ::get', count

  obj_destroy, list

  return, 1
end


;+
; Test array list.
;-
pro mgcoarraylist_ut__define
  compile_opt strictarr

  define = { MGcoArrayList_ut, inherits MGutLibTestCase }
end
