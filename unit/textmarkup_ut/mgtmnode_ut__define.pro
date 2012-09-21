function mgtmnode_ut::test_rst
  compile_opt strictarr
  
  @error_is_fail
  
  rst = obj_new('MGtmRst')
  rstResult = rst->process(self.msg)

  ;print, 'Restructured text'
  ;print, transpose(rstResult)
  
  obj_destroy, rst
  
  return, 1
end


function mgtmnode_ut::test_html
  compile_opt strictarr

  @error_is_fail
  
  html = obj_new('MGtmHTML')
  htmlResult = html->process(self.msg)

  ;print, 'HTML'
  ;print, transpose(htmlResult)
  
  obj_destroy, html
  
  return, 1
end


function mgtmnode_ut::test_latex
  compile_opt strictarr

  @error_is_fail
  
  latex = obj_new('MGtmLatex')
  latexResult = latex->process(self.msg)

  ;print, 'LaTeX'
  ;print, transpose(latexResult)
  
  obj_destroy, latex
  
  return, 1
end


pro mgtmnode_ut::setup
  compile_opt strictarr
  
  self->mgutlibtestcase::setup
  self.msg = obj_new('MGtmTag', type='paragraph')                   

  text = obj_new('MGtmText', text='this is a ')
  self.msg->addChild, text                        

  bold = obj_new('MGtmTag', type='bold')
  self.msg->addChild, bold

  real = obj_new('MGtmText', text='real')
  bold->addChild, real

  newline = obj_new('MGtmTag', type='newline')
  bold->addChild, newline 

  cool = obj_new('MGtmText', text='cool')
  bold->addChild, cool

  period = obj_new('MGtmText', text=' idea.')
  self.msg->addChild, period
end


pro mgtmnode_ut::teardown
  compile_opt strictarr
  
  obj_destroy, self.msg
  self->mgutlibtestcase::teardown
end


pro mgtmnode_ut__define
  compile_opt strictarr
  
  define = { MGtmNode_ut, inherits MGutLibTestCase, $
             msg: obj_new() $
           }
end