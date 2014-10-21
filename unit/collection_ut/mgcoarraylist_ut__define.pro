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


function mgcoarraylist_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgcoarraylist__define', $
                            'mgcoarraylist::cleanup', $
                            'mgcoarraylist::add', $
                            'mgcoarraylist::move', $
                            'mgcoarraylist::remove', $
                            'mgcoarraylist::setProperty', $
                            'mgcoarraylist::getProperty', $
                            'mgcoarraylist::_overloadBracketsLeftSide']
  self->addTestingRoutine, ['mgcoarraylist::init', $
                            'mgcoarraylist::iterator', $
                            'mgcoarraylist::count', $
                            'mgcoarraylist::get', $
                            'mgcoarraylist::isaGet', $
                            'mgcoarraylist::isContained', $
                            'mgcoarraylist::_overloadSize', $
                            'mgcoarraylist::_overloadHelp', $
                            'mgcoarraylist::_overloadPrint', $
                            'mgcoarraylist::_overloadForeach', $
                            'mgcoarraylist::_overloadAsterisk', $
                            'mgcoarraylist::_repeatStructure', $
                            'mgcoarraylist::_repeatNonNumeric', $
                            'mgcoarraylist::_repeatNumeric', $
                            'mgcoarraylist::_overloadPlus', $
                            'mgcoarraylist::_overloadBracketsRightSide'], $
                           /is_function

  return, 1
end


;+
; Test array list.
;-
pro mgcoarraylist_ut__define
  compile_opt strictarr

  define = { MGcoArrayList_ut, inherits MGutLibTestCase }
end
