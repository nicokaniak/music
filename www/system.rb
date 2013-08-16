
post '/system/update/' + settings.update_token do
  exec 'git pull origin master'
  Process::exit 0
end
