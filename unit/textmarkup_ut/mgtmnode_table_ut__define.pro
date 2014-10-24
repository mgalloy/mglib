; docformat = 'rst'

function mgtmnode_table_ut::test_rst
  compile_opt strictarr

  @error_is_fail

  rst = obj_new('MGtmRst')
  rstResult = rst->process(self.msg)

  ;print, 'Restructured text'
  ;print, transpose(rstResult)

  obj_destroy, rst

  return, 1
end


function mgtmnode_table_ut::test_html
  compile_opt strictarr

  @error_is_fail

  html = obj_new('MGtmHTML')
  htmlResult = html->process(self.msg)

  ;print, 'HTML'
  ;print, transpose(htmlResult)

  obj_destroy, html

  return, 1
end


function mgtmnode_table_ut::test_latex
  compile_opt strictarr

  @error_is_fail

  latex = obj_new('MGtmLatex')
  latexResult = latex->process(self.msg)

  ;print, 'LaTeX'
  ;print, transpose(latexResult)

  obj_destroy, latex

  return, 1
end


pro mgtmnode_table_ut::setup
  compile_opt strictarr

  self->mgutlibtestcase::setup
  self.msg = obj_new('MGtmTag', type='paragraph')

  table = obj_new('MGtmTag', type='table')
  self.msg->addChild, table

  row1 = obj_new('MGtmTag', type='row')
  table->addChild, row1

  col11 = obj_new('MGtmTag', type='column_header')
  row1->addChild, col11
  col11->addChild, obj_new('MGtmText', text='Output name')

  col12 = obj_new('MGtmTag', type='column_header')
  row1->addChild, col12
  col12->addChild, obj_new('MGtmText', text='Description')

  row2 = obj_new('MGtmTag', type='row')
  table->addChild, row2

  col21 = obj_new('MGtmTag', type='column')
  row2->addChild, col21
  col21->addChild, obj_new('MGtmText', text='HTML')

  col22 = obj_new('MGtmTag', type='column')
  row2->addChild, col22
  col22->addChild, obj_new('MGtmText', text='Send output to HTML')

end


pro mgtmnode_table_ut::teardown
  compile_opt strictarr

  obj_destroy, self.msg
  self->mgutlibtestcase::teardown
end


function mgtmnode_table_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutLibTestCase::init(_extra=e)) then return, 0

  return, 1
end


pro mgtmnode_table_ut__define
  compile_opt strictarr

  define = { MGtmNode_table_ut, inherits MGutLibTestCase, $
             msg: obj_new() $
           }
end
