; docformat = 'rst'

pro mgnetgvoice::login, email, passwd
  compile_opt strictarr

  data = string(passwd, email, $
                format='(%"Passwd=%s&service=grandcentral&Email=%s&accountType=HOSTED_OR_GOOGLE")')

  h = [string(strlen(data), format='(%"Content-length: %d")'), $
       'Content-type: application/x-www-form-urlencoded;charset=utf-8', $
       string(self.user_agent, format='(%"User-Agent: %s")')]
  self.url->setProperty, headers=h

  rfile = self.url->put(data, /post, /buffer, $
                        url='https://www.google.com/accounts/ClientLogin')
  rfile_info = file_info(rfile)
  r = read_binary(rfile, data_type=1, data_dims=[rfile_info.size])
  file_delete, rfile

  r = mg_strunmerge(string(r))
  self.auth = r[2]

  h = [string(self.auth, format='(%"Autherization: GoogleLogin %s")'), $
       string(self.user_agent, format='(%"User-Agent: %s")')]
  self.url->setProperty, headers=h
  d = self.url->get(/string_array, url='https://www.google.com/voice/#inbox')

print, d
end


pro mgnetgvoice::logout
  compile_opt strictarr

  h = ['Content-type: application/x-www-form-urlencoded;charset=utf-8', $
       string(self.user_agent, format='(%"User-Agent: %s")')]
  self.url->setProperty, headers=h

  r = self.url->get(/string_array, url='https://www.google.com/voice/account/signout')
end


pro mgnetgvoice::send_sms, number, msg
  compile_opt strictarr

end


pro mgnetgvoice::setProperty
  compile_opt strictarr

end


pro mgnetgvoice::cleanup
  compile_opt strictarr

  obj_destroy, self.url
end


function mgnetgvoice::init, _extra=e
  compile_opt strictarr

  ;self->setProperty, _extra=e

  self.url = obj_new('IDLnetURL')
  self.user_agent = 'MGnetGVoice'

  return, 1
end


pro mgnetgvoice__define
  compile_opt strictarr

  define = { MGnetGVoice, $
             url: obj_new(), $
             user_agent: '', $
             auth:'' $
           }
end


email = 'mgalloy%40gmail.com'
passwd = 'my password'

gvoice = mgnetgvoice()
gvoice->login, email, passwd
gvoice->send_sms, '3033246476', 'This is a MGnetGVoice test.'
gvoice->logout
obj_destroy, gvoice

end
