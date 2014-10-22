;+
; Basic adding elements to table and retrieving them.
;-
function mgcohashtable_ut::test_simple
  compile_opt strictarr

  table = obj_new('MGcoHashTable', key_type=1, value_type=2)

  table->put, 1, 2
  assert, table->get(1, found=found) eq 2, 'incorrect value for key=1'
  assert, found eq 1, 'not found for key=1'

  table->put, 2, 5
  assert, table->get(2, found=found) eq 5, 'incorrect value for key=2'
  assert, found eq 1, 'not found for key=2'

  assert, table->get(3, found=found) eq -1, 'incorrect value for key=3'
  assert, found eq 0, 'found for key=3'

  assert, array_equal(table->keys(count=count), [1B, 2B]), 'incorrect keys'
  assert, count eq 2, 'incorrect number of keys'

  assert, array_equal(table->values(count=count), [2, 5]), 'incorrect values'
  assert, count eq 2, 'incorrect number of values'

  obj_destroy, table

  return, 1
end


function mgcohashtable_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['mgcohashtable__define', $
                            'mgcohashtable::cleanup', $
                            'mgcohashtable::put', $
                            'mgcohashtable::update', $
                            'mgcohashtable::remove', $
                            'mgcohashtable::print', $
                            'mgcohashtable::getProperty', $
                            'mgcohashtable::_overloadBracketsLeftSide', $
                            'mgcohashtable::_findKeyPos']
  self->addTestingRoutine, ['mgcohashtable::init', $
                            'mgcohashtable::isEmpty', $
                            'mgcohashtable::count', $
                            'mgcohashtable::setdefault', $
                            'mgcohashtable::get', $
                            'mgcohashtable::_calchashcode', $
                            'mgcohashtable::values', $
                            'mgcohashtable::keys', $
                            'mgcohashtable::_getHistogram', $
                            'mgcohashtable::_overloadSize', $
                            'mgcohashtable::_overloadHelp', $
                            'mgcohashtable::_overloadPrint', $
                            'mgcohashtable::_overloadForeach', $
                            'mgcohashtable::_findNextKey', $
                            'mgcohashtable::_overloadPlus', $
                            'mgcohashtable::_overloadBracketsRightSide'], $
                           /is_function

  return, 1
end


;+
; Hash table tests.
;-
pro mgcohashtable_ut__define
  compile_opt strictarr

  define = { MGcoHashTable_ut, inherits MGutLibTestCase }
end
