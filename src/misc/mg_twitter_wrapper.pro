; docformat = 'rst'

;+
; Command line wrapper for MG_TWITTER. Sets username (u) and password (p) 
; options.
;-
pro mg_twitter_wrapper
  compile_opt strictarr

  opts = obj_new('MG_Options', app_name='mg_twitter', version='1.0.0')
  opts->addOption, 'username', 'u', help='username for friends timeline'
  opts->addOption, 'password', 'p', help='password for username'
  
  opts->parseArgs, error_message=err
  
  username = opts->get('username', present=usernamePresent)
  password = opts->get('password', present=passwordPresent)
  
  if (usernamePresent) then _username = username
  if (passwordPresent) then _password = password
  
  if (~opts->get('help') && ~opts->get('version')) then begin
    mg_twitter, _username, _password
  endif
  
  obj_destroy, opts
end
