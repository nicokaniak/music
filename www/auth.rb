
before do
  return if request.path_info == "/login"
  return if request.path_info.match == "^/system"

  @user = User.get(session[:uid])
  if not @user
    redirect "/login"
  end
end

post '/login' do
  user = User.first(:username => params[:username])

  if user
    puts "Logged in as #{user.username}"
    session[:uid] = user.id
    redirect '/'
  else
    erb :login
  end
end

get '/login' do
  erb :login
end

get '/logout' do
  session[:uid] = nil
  redirect '/'
end
